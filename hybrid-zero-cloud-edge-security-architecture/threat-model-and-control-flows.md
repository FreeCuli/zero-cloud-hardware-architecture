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

The architecture maps physical and logical threats to standardized attack classifications defined in [`zero-cloud-core-attack-taxonomy.md`](../zero-cloud-core-attack-taxonomy.md) and candidate extensions:

| Attack Class ID | Adversarial Threat Description | Architectural Mitigation Mechanism | Implementation Status |
| :--- | :--- | :--- | :---: |
| **AT-001** | Direct Memory Read into isolated sensor domain | Hardware bus separation; OBI address decoding isolating sensor memory. | **PARTIAL (RTL) / Gate D (UNVERIFIED SoC)** |
| **AT-002** | Direct Memory Access (DMA) Read of raw sensor buffers | Physical domain separation; Network processor has no DMA master path to sensor SRAM. | **Architectural Invariant / Gate D (UNVERIFIED SoC)** |
| **AT-003** | Cache Residual Read (Cold-Boot / Warm-Boot) | Hardware memory zeroization (M8) upon reset or inference completion; Boot ROM verification. | **Architectural Goal / Gate D (UNVERIFIED)** |
| **AT-004** | Shared Memory / IPC Leakage | Physical SRAM domain separation; mailbox register isolation without shared sensor memory buffers. | **Architectural Invariant / Gate D (UNVERIFIED SoC)** |
| **AT-005** | Debug / Trace Extraction via JTAG/SWD | Permanent debug port disabling via OTP eFuse lock bits; hardware debug isolation. | **Gate D (UNVERIFIED Physical Security)** |
| **AT-006** | Peripheral Bridge Bypass into Trusted Domain | Dedicated point-to-point interconnect; peripheral firewall isolation. | **Architectural Invariant / Gate D (UNVERIFIED)** |
| **AT-007** | Management Controller / Control-Plane Leakage | Warm reset (`rst_sys_ni`) request gating in OBI bridge (`F-OBI-07`); AON permanent fatal lock. | **IMPLEMENTED (RTL `F-OBI-07`)** |
| **AT-008** | Reverse Channel Impossibility Bypass | Hardware-enforced unidirectional gating on sensor data path; absence of reverse read path. | **Architectural Invariant / Gate D (UNVERIFIED)** |
| **AT-009** | Undocumented Interface (Hidden Sensor Path) | Complete sensor inventory inspection under CTS (FC-ZC-013/014); zero secondary unmediated sensor interfaces. | **CTS Audit Baseline** |
| **AT-010** | AI Output / Metadata Leakage | Semantic payload quantization, bounding, and strict allowlisting of outbound telemetry (RFC-0004). | **Architectural Goal (RFC Proposal)** |
| **AT-011 (RFC)**| Bus Exhaustion & Subordinate Starvation | 1024-cycle orphan watchdog; `ST_TRAP` synthetic error delivery (`F-OBI-05`, `F-OBI-06`). | **IMPLEMENTED (RTL `F-OBI-05`, `F-OBI-06`)** |
| **AT-012 (RFC)**| Flash Write Exhaustion & Execution Hijack | Dual /CS hardware routing; Bank-B boundary containment; commit strobe gated until Boot ROM validation (`F-SPI-02`). | **IMPLEMENTED (RTL `F-SPI-01`..`F-SPI-04`)** |
| **AT-013 (RFC)**| Physical Trace Crosstalk & Electromagnetic Coupling | Physical PCB trace isolation and RF shielding; candidate radiated leakage benchmark (<-80 dBm threshold under CTS Annex B). | **Gate D (UNVERIFIED) / RFC Candidate Target** |

---

## 3. End-to-End Control & Data Flows

To maintain technical fidelity, every operational flow is categorized into one of three explicit maturity states:
1. **Implemented in RTL & Backed by Verification Evidence** (Implemented in synthesizable RTL and verified via SVA/testbench)
2. **Architectural Proposal or RFC Design** (Architectural target or unratified RFC proposal)
3. **Undefined or Pending Technical Evidence** (TBD — Requires technical evidence or founder decision)

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
* **Maturity Status:** **Implemented in RTL & Backed by Evidence** (Gating logic) / **Architectural Proposal** (External transport).
* **Control Sequence:**
  1. The untrusted Network Co-Processor downloads an encrypted firmware container from an external server over Wi-Fi/Ethernet.
  2. The network processor issues SPI Write commands targeting Flash Bank B through `zc_spi_flash_firewall.sv`.
  3. The firewall permits write transactions **if and only if** the target address falls strictly within Bank B boundaries. Any attempt to write to Bank A triggers `UPD_RECOVERY_LOCKOUT`, permanently isolating the flash until reset.
  4. The network processor queries write completion via opcode `05h RDSR1`. The firewall's internal status reconciler intercepts the query and asserts `flash_ready_strobe_o` only when bit 0 (WIP) clears.
  5. The network processor notifies Domain 1 that staging is complete via an OBI mailbox interrupt.

### 3.2 Flow B: Cryptographic Verification & Anti-Rollback Commit
* **Maturity Status:** **Implemented in RTL & Backed by Evidence** (OTP authorization FSM) / **Gate D (UNVERIFIED)** (Foundry antifuse macro).
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
* **Maturity Status:** **Defined as RTL Gating & Trap Logic** (RTL gating and trap logic; multi-master crossbar arbitration deferred to Gate D).
* **Signal Topology & Registers:**
  - `drain_wdog_cnt_q [9:0]`: 10-bit internal digital register (UP-counter).
  - `drain_wdog_cnt_o [9:0]`: Module output port directly driven by `drain_wdog_cnt_q`.
  - `orphan_drain_active_q`: Internal latch asserted on orphan condition; reset by Cold POR (`!rst_por_ni`) or valid physical response (`periph_phys_rvalid_i`).
  - `orphan_active_w`: Combinational trigger wire (`orphan_drain_active_q || orphan_trigger_w`).
  - `subsys_dead_locked_q`: Permanent deadlock register; cleared ONLY by Cold Power-On Reset (`rst_por_ni`).
* **Control Sequence & Cycle-Accurate 4-Stage Semantics:**
  1. **Subordinate Request Initiation:** Domain 0 initiates an OBI bus read/write cycle (`host_req_i <= 1'b1`). The bridge enters `ST_WAIT_RVALID` and initiates internal subordinate request `periph_phys_req_o <= 1'b1`.
  2. **Orphan Condition Trigger:** If the internal subordinate hangs, times out (64-cycle timeout in `ST_WAIT_RVALID`), or warm reset (`!rst_sys_ni`) drops while a physical request is active, `orphan_active_w` asserts and latches `orphan_drain_active_q <= 1'b1`.
  3. **Monotonic Counter Progression (Counting):** While `orphan_active_w` holds and `!subsys_dead_locked_q`, internal register `drain_wdog_cnt_q [9:0]` operates as an **UP-COUNTER**, starting at `10'd0` and incrementing monotonically by +1 on each clock posedge (`0 → 1023`). During this progression, deadlock is NOT yet asserted.
  4. **Threshold Evaluation & Latching (Locking):** In any clock cycle where the prior registered counter value is `drain_wdog_cnt_q == 10'd1023`, on the subsequent clock posedge under active orphan drain, permanent deadlock register `subsys_dead_locked_q <= 1'b1` is clocked in.
  5. **Combinational IRQ Generation (IRQ Behavior):** By virtue of the RTL continuous assignment `assign subsys_fatal_fault_irq_o = subsys_dead_locked_q;`, output port `subsys_fatal_fault_irq_o` transitions to high combinationally in the very same clock cycle that `subsys_dead_locked_q` becomes 1.
  6. **Deadlock Bus Isolation & Error Trap:** Under `subsys_dead_locked_q == 1'b1`, physical subordinate requests are unconditionally suppressed (`periph_phys_req_o = 1'b0`). Subsequent host requests in `ST_IDLE` are accepted (`host_req_ready_o = 1'b1`), transition to `ST_TRAP`, return a deterministic 1-cycle synthetic error (`host_rvalid_o <= 1'b1`, `host_err_o <= 1'b1`, `host_rdata_o <= 32'h0000_0000`), and return to `ST_IDLE` while remaining deadlocked until Cold POR (`rst_por_ni`).

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
