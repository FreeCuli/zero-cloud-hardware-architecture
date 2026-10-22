# Hybrid Zero-Cloud & Edge Security Architecture
## Threat Model & Control Flows Specification

**Document ID:** `ZC-HYBRID-THREAT-FLOWS-01`  
**Classification:** Canonical Architecture Suite Specification  
**Status:** `CANDIDATE BASELINE / UNRATIFIED`  
**Parent Document:** [`README.md`](README.md)  

---

## 1. Adversarial Threat Model & Assumptions

The **Hybrid Zero-Cloud & Edge Security Architecture** operates under an explicit zero-trust threat model regarding external communication interfaces.

### 1.1 Attacker Capabilities & Access Model
- **Network-Borne Exploits:** The attacker is assumed to possess full remote control over the Network Co-Processor (Domain 0) via compromised Wi-Fi/BLE firmware, malicious cloud packets, or local wireless injection.
- **Arbitrary Bus Injection:** The attacker can inject arbitrary, malformed, out-of-order, or flood-rate transactions on the untrusted OBI bus interface and SPI Flash lines.
- **Physical Non-Destructive Probing:** The attacker can observe external board traces (SPI bus, external power rails), execute voltage brown-out glitches, or manipulate reset lines.
- **Attacker Exclusions:** Invasive silicon die decapping, focused ion beam (FIB) trace editing, and cryogenic TEM probing are considered outside the threat model of commercial AIoT edge devices (evaluated under specialized military standards).

---

## 2. Threat Taxonomy Mapping (AT-001 through AT-012)

The architecture maps physical and logical threats to standardized attack classifications defined in [`zero-cloud-core-attack-taxonomy.md`](../../zero-cloud-core-attack-taxonomy.md) and candidate extensions:

| Attack Class ID | Adversarial Threat Description | Architectural Mitigation Mechanism | Implementation Status |
| :--- | :--- | :--- | :---: |
| **AT-001** | Optical / Acoustic Data Diode Reverse-Biasing | Hardware air-gap on sensor inputs; absence of physical reverse path. | **IMPLEMENTED (RTL & CTS)** |
| **AT-002** | DMA-Based Sensor Memory Snooping | Physical domain separation; Network processor has no DMA access to sensor SRAM. | **PARTIAL (RTL) / UNVERIFIED (SOC)** |
| **AT-003** | Microcontroller Firmware Hijack | Hardware-enforced Boot ROM execution check; OTP anti-rollback SVN locking. | **IMPLEMENTED (RTL & ROM)** |
| **AT-004** | Crosstalk / Electromagnetic Trace Leakage | Physical PCB trace isolation (>80 dB attenuation under CTS Annex B). | **CTS LAB VERIFIED** |
| **AT-005** | Actuator / Inference Command Tampering | Cryptographic message authentication on outbound actuation; rate limiting. | **ARCHITECTURAL PROPOSAL** |
| **AT-006** | Side-Channel Timing Leakage on Inference | Hardware constant-time execution; M8 immediate memory zeroization. | **PARTIAL (RTL)** |
| **AT-007** | Control-Plane Hijacking (Reset/Clock Injection) | Warm reset (`rst_sys_ni`) request gating in OBI bridge; AON permanent fatal lock. | **IMPLEMENTED (RTL `F-OBI-07`)** |
| **AT-008** | Covert Channel Modulation on Derived Data | Entropy bounding and quantization of outbound semantic telemetry. | **ARCHITECTURAL PROPOSAL** |
| **AT-009** | Sensor Direct-Connection Bypass | Mandatory complete sensor inventory (CTS FC-ZC-013/014); zero secondary sensors. | **CTS AUDIT ENFORCED** |
| **AT-010** | Power-Analysis Inference Reconstruction (DPA) | Hardware decoupling capacitors and random execution jitter (Gate D target). | **Gate D (UNVERIFIED)** |
| **AT-011 (RFC)**| Bus Exhaustion & Subordinate Starvation | 1024-cycle orphan watchdog; `ST_TRAP` synthetic error delivery. | **IMPLEMENTED (RTL `F-OBI-01`)** |
| **AT-012 (RFC)**| Flash Write Exhaustion & Execution Hijack | Dual /CS hardware routing; Bank-B commit gating mediated by Boot ROM. | **IMPLEMENTED (RTL `F-SPI-04`)** |

---

## 3. End-to-End Control & Data Flows

To maintain technical fidelity, every operational flow is categorized into one of three explicit maturity states:
1. **RTL'de Mevcut ve Kanıtla Desteklenen** (Implemented in synthesizable RTL and proven via SVA/testbench)
2. **Mimari Öneri veya RFC Tasarımı** (Architectural target or unratified RFC proposal)
3. **Henüz Tanımlanmamış veya Teknik Kanıt Bekleyen** (TBD — Requires technical evidence or founder decision)

```
+---------------------------------------------------------------------------------------------------------+
|                                  LIFECYCLE FLOW MATURITY TAXONOMY                                       |
+---------------------------------------------------------------------------------------------------------+
|                                                                                                         |
|  [ STATE 1: PROVEN IN RTL ]                                                                             |
|    - SPI Flash command filtering & WIP polling (`zc_spi_flash_firewall.sv`)                                 |
|    - OBI bus orphan watchdog & ST_TRAP error generation (`zc_obi_subordinate_bridge.sv`)                |
|    - OTP 4-phase DAI handshake & fatal lockout (`zc_aon_post_auth_ctrl.sv`)                             |
|    - Hsiao (22,16) codeword generation & parity validation (`zc_otp_pkg.sv`)                            |
|                                                                                                         |
|  [ STATE 2: ARCHITECTURAL RFC PROPOSAL ]                                                                |
|    - Telemetry hardware rate-limiter and allowlist packetizer (`docs/rfc/`)                             |
|    - Multi-master SoC crossbar DMA firewalling topology                                                 |
|    - Inbound Class 0 control packet classification schema                                               |
|                                                                                                         |
|  [ STATE 3: PENDING TECHNICAL EVIDENCE / TBD ]                                                          |
|    - AON / CDC clock synchronizers for `rst_sys_ni` and `rom_exec_active_i`                             |
|    - Static Timing Analysis (STA) across foundry PVT corners                                            |
|    - Physical silicon flash setup/hold timing under high capacitive load                                |
|                                                                                                         |
+---------------------------------------------------------------------------------------------------------+
```

### 3.1 Flow A: Secure Inbound Over-The-Air (OTA) Firmware Staging
* **Maturity Status:** **RTL'de Mevcut ve Kanıtla Desteklenen** (Gating logic) / **Mimari Öneri** (External transport).
* **Control Sequence:**
  1. The untrusted Network Co-Processor downloads an encrypted firmware container from an external server over Wi-Fi/Ethernet.
  2. The network processor issues SPI Write commands targeting Flash Bank B through `zc_spi_flash_firewall.sv`.
  3. The firewall permits write transactions **if and only if** the target address falls strictly within Bank B boundaries. Any attempt to write to Bank A triggers `ST_SPI_ALARM`, permanently isolating the flash until reset.
  4. The network processor queries write completion via opcode `05h RDSR1`. The firewall's internal status reconciler intercepts the query and asserts `flash_ready_strobe_o` only when bit 0 (WIP) clears.
  5. The network processor notifies Domain 1 that staging is complete via an OBI mailbox interrupt.

### 3.2 Flow B: Cryptographic Verification & Anti-Rollback Commit
* **Maturity Status:** **RTL'de Mevcut ve Kanıtla Desteklenen** (OTP authorization FSM) / **Gate D (UNVERIFIED)** (Foundry antifuse macro).
* **Control Sequence:**
  1. Domain 1 Boot ROM executes an asymmetric signature check (Ed25519 / ECDSA) over the staged Bank B image.
  2. If signature verification passes, Boot ROM extracts the container's Security Version Number (SVN).
  3. Domain 1 asserts `rom_exec_active_i <= 1'b1` and initiates an authorization session with `zc_aon_post_auth_ctrl.sv`.
  4. The AON controller executes the 4-phase atomic handshake:
     - `WSTEP_AUTH_READY`: Asserts `otp_word_auth_valid_o` for Word 0 (SVN).
     - `WSTEP_WAIT_PHYS_DONE`: Consumes the grant in 1 cycle (`dai_write_accepted_w`) upon DAI acceptance.
     - `WSTEP_WAIT_RB_VERIFY`: Verifies that readback data matches the expected 22-bit Hsiao codeword.
     - Repeats sequentially for Word 1 (Commit A) and Word 2 (Commit B).
  5. Upon verifying Word 2, the FSM transitions to `AUTH_SESSION_DONE`, clearing all write authorizations.
  6. If readback data or session ID fails at any point, the FSM transitions permanently to `AUTH_LOCKED_FATAL`.

### 3.3 Flow C: Subordinate Bus Isolation & Error Recovery
* **Maturity Status:** **RTL'de Mevcut ve Kanıtla Desteklenen** (Watchdog and trap logic).
* **Control Sequence:**
  1. Domain 0 initiates an OBI bus read/write cycle (`host_req_i <= 1'b1`).
  2. The bridge initiates internal subordinate request `periph_phys_req_o <= 1'b1`.
  3. If the internal peripheral hangs or fails to return `periph_phys_rvalid_i`, internal counter `drain_wdog_cnt_o` decrements each cycle.
  4. At cycle 1024, the counter underflows, asserting `subsys_dead_locked_q <= 1'b1`.
  5. The bridge enters `ST_TRAP`, immediately isolating internal buses and asserting `host_err_o <= 1'b1` with zero data (`host_rdata_o <= 32'h0`).
  6. Subsequent external requests are immediately rejected with error responses until the subsystem completes recovery.

---

## 4. Reset & Clock Domain Topology

The architecture establishes three discrete clock domains and two reset hierarchies:

| Domain Name | Clock Source | Associated Reset Signal | Managed Modules | Isolation & Synchronization Mechanism |
| :--- | :--- | :--- | :--- | :--- |
| **Always-On (AON) Domain** | `clk_aon_i` (Low-power real-time clock, e.g., 32.768 kHz) | `rst_aon_por_ni` (Cold Power-On Reset) | `zc_aon_post_auth_ctrl.sv`, OTP Physical Macro, Tamper Supervisor | Cold reset is the **only** signal capable of clearing `AUTH_LOCKED_FATAL`. Unaffected by system warm reboots. |
| **System Core Domain** | `clk_sys_i` (High-speed system PLL, e.g., 50–200 MHz) | `rst_sys_ni` (Warm System Reset) | Host CPU, Boot ROM, `zc_obi_subordinate_bridge.sv`, System Crossbar | While `rst_sys_ni` is asserted (active-low), OBI subordinate requests are gated (`F-OBI-07`). |
| **External SPI Domain** | `sck_from_untrusted_i` (Variable serial clock from Domain 0) | Asynchronous chip-select `/CS` edge | `zc_spi_flash_firewall.sv` | SPI interface operates on serial clock strobes; transitions synchronized to `/CS` rising edge. |

### 4.1 Clock Domain Crossing (CDC) Risk Disclosure
- **Observed Design Limitation:** In `rtl/zc_aon_post_auth_ctrl.sv`, signals `rst_sys_ni` and `rom_exec_active_i` originate in the `clk_sys_i` domain and are directly sampled by combinational logic driving `write_authorized_w` in the `clk_aon_i` domain.
- **Formal Status:** Verified under Yosys using the `async2sync` pass, which models all resets synchronously.
- **Physical Silicon Status:** **`Gate D (UNVERIFIED)`**. Physical metastability, multi-cycle pulse survival, and phase jitter are not verified at the digital RTL level and require dual-rank synchronizers prior to silicon tape-out.
