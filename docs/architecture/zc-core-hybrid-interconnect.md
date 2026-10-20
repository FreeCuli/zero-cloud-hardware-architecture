# FREECULI ZC-CORE — Hybrid Hardware Interconnect Architecture Specification
## RTL Block Interfaces, Trust Boundary Topologies & Bus Isolation Contracts

**Status:** `PROPOSED / NOT RELEASED / NOT SOC-VERIFIED`  
**Document ID:** ZC-CORE-SPEC-HYBRID-INTERCONNECT-DRAFT  
**Revision:** 0.9.0-draft  
**Target Milestone:** Post-Gate C Governance / Gate D Preparation  
**Reference Technical Baseline:** Commit [`eb3ed5a`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/eb3ed5ad9fddb551506d43d2692bd040843af06f) (Run #45)  
**Classification:** Technical Hardware Interconnect Specification (Draft)  

---

> [!WARNING]
> **GOVERNANCE & REVIEW NOTICE:**  
> This specification is an architectural draft (`PROPOSED / NOT RELEASED / NOT SOC-VERIFIED`). It defines the interconnect topology, clock/reset domains, and hardware firewall contracts for the **HYBRID Profile**. The digital RTL IP blocks described herein have been verified under Gate C (`PARTIAL / QUALIFIED`). Full-SoC bus integration (PMP, crossbar arbitration, NPU miter) and physical silicon characteristics remain deferred to **Gate D (UNVERIFIED)**.

---

## 1. Architectural Overview & Problem Statement

In a conventional AIoT system, a network co-processor (Wi-Fi, Bluetooth, or Ethernet SoC) connects to the main system bus via high-speed interfaces (SPI, SDIO, PCIe, or OBI/AXI crossbars). If the network processor is compromised remotely, an attacker can:
1. Issue unauthorized direct memory access (DMA) reads to snoop raw sensor buffers.
2. Hold the bus in prolonged wait-states or inject deadlocks.
3. Flash malicious firmware binaries into shared non-volatile memory (SPI Flash).
4. Manipulate warm reset lines to circumvent memory zeroization.

The FreeCuli ZC-CORE Hybrid Interconnect resolves these vulnerabilities at the hardware RTL level through three specialized firewall blocks positioned directly on the boundary between the untrusted domain and the secure core:

```
+---------------------------------------------------------------------------------------------------------+
|                                    ZC-CORE TRUST BOUNDARY TOPOLOGY                                      |
+---------------------------------------------------------------------------------------------------------+
|                                                                                                         |
|   [ UNTRUSTED NETWORK DOMAIN ]                                                                          |
|     |  Network Co-Processor (Wi-Fi/BLE)                                                                  |
|     +---------------+-------------------------------------+                                             |
|                     |                                     |                                             |
|          (SPI Bus)  v                         (OBI Bus)   v                                             |
|   +---------------------------------+   +------------------------------------+                          |
|   |   zc_spi_flash_firewall         |   |   zc_obi_subordinate_bridge        |                          |
|   |   - Dual /CS Gating (Primary/Sec)|   |   - Synchronous Bus Decoupling     |                          |
|   |   - Rising /CS + SCK=0 Strobe   |   |   - 1024-Cycle Orphan Watchdog     |                          |
|   |   - 05h RDSR1 Status Reconciler |   |   - ST_TRAP Synthetic Error Injection                         |
|   |   - Bank-B Commit Gating        |   |   - Warm Reset (rst_sys_ni) Gating |                          |
|   +----------------+----------------+   +-----------------+------------------+                          |
|                    |                                      |                                             |
|                    v (Protected SPI)                      v (Safe Host OBI)                             |
|          [ Shared SPI Flash ]                   [ Secure Host CPU / Interconnect ]                      |
|                                                           |                                             |
|                                                (DAI Bus)  v                                             |
|                                         +------------------------------------+                          |
|                                         |   zc_aon_post_auth_ctrl            |                          |
|                                         |   - 4-Phase DAI Handshake          |                          |
|                                         |   - Immediate Grant Consumption    |                          |
|                                         |   - Permanent Fatal Lock (AON)     |                          |
|                                         |   - Hsiao (22,16) Parity Match     |                          |
|                                         +-----------------+------------------+                          |
|                                                           |                                             |
|                                                           v                                             |
|                                                 [ AON Physical OTP / eFuse ]                            |
|                                                                                                         |
|   [ TRUSTED PROCESSING DOMAIN ]                                                                         |
|     |  Edge NPU + Secure SRAM (M8 Zeroization) + Privacy Sensors (M1/M9 Air-Gap)                        |
|                                                                                                         |
+---------------------------------------------------------------------------------------------------------+
```

---

## 2. RTL Block Interface Specifications

### 2.1 SPI Flash Firewall (`zc_spi_flash_firewall.sv`)
* **Source Location:** [`rtl/zc_spi_flash_firewall.sv`](../../rtl/zc_spi_flash_firewall.sv)
* **Formal Verification Harness:** [`fv/zc_spi_formal_proof.sv`](../../fv/zc_spi_formal_proof.sv)
* **Clock Domain:** Synchronous SPI domain (`clk_i`, `rst_ni`) under `async2sync`.
* **Primary Role:** Shields the shared external SPI Flash memory containing boot code and firmware banks from unauthorized writes, flash desynchronization, and partial frame injection.

#### Key Interface Signals:
| Signal Name | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `cs_n_to_iso_o` | Input | 1 | Primary Chip Select from Network / Host SPI Master. |
| `sck_to_iso_o` | Input | 1 | Serial Clock line from SPI Master. |
| `si_to_iso_o` | Input | 1 | Serial Input (MOSI) from Master. |
| `so_from_iso_i` | Output | 1 | Serial Output (MISO) returned to Master. |
| `fault_high_sec_i` | Input | 1 | Secondary electrical fault line (asserts on physical glitch/tamper). |
| `cs_n_flash_eff_o` | Output | 1 | Effective gated Chip Select routed directly to physical Flash chip. |
| `bank_b_commit_ready_o`| Output | 1 | Hardware authorization gate for Bank B execution. |
| `rom_img_verif_valid_i`| Input | 1 | Cryptographic verification validity from isolated ROM bootloader. |
| `f_sr1_latched_byte_o` | Output (Formal)| 8 | Latched RDSR1 status byte (WIP/WEL sampled bits). |

#### Hardware Guarantees Formally Proven in Gate C:
1. **RDSR1 State Reconciliation (`F-SPI-01` / `ZC-CLAIM-01`):**  
   Transition from `UPD_UNSYNC_RESET` to `UPD_IDLE` strictly requires an 05h RDSR1 frame, completed on rising /CS with SCK=0, bit 15 sampled, `fault_high_sec_i == 0`, and status register confirming `WIP == 0` and `WEL == 0` (`SR1[1:0] == 2'b00`).
2. **WRDI Stay in Reset (`F-SPI-01b` / `ZC-CLAIM-02`):**  
   04h (WRDI) frame arriving during `UPD_UNSYNC_RESET` unconditionally maintains the firewall in reset.
3. **Cryptographic Bank B Commit Gating (`F-SPI-02` / `ZC-CLAIM-03`):**  
   `bank_b_commit_ready_o` asserts if and only if independent ROM signature verification succeeds (`rom_img_verif_valid_i == 1`).
4. **Fail-Closed Secondary Fault Gating (`F-SPI-04` / `ZC-CLAIM-05`):**  
   Any assertion of `fault_high_sec_i == 1` unconditionally forces physical `/CS` high (`cs_n_flash_eff_o == 1`), aborting SPI communication.

---

### 2.2 OBI Subordinate Bridge (`zc_obi_subordinate_bridge.sv`)
* **Source Location:** [`rtl/zc_obi_subordinate_bridge.sv`](../../rtl/zc_obi_subordinate_bridge.sv)
* **Formal Verification Harness:** [`fv/zc_obi_formal_proof.sv`](../../fv/zc_obi_formal_proof.sv)
* **Clock Domain:** Synchronous system bus domain (`clk_sys_i`, `rst_sys_ni`).
* **Primary Role:** Decouples the untrusted host/network bus from the secure core. Prevents orphan transaction leakage, enforces bus timeouts, and handles deadlocks gracefully.

#### Key Interface Signals:
| Signal Name | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `host_req_i` | Input | 1 | OBI bus request from Host / Network master. |
| `host_req_ready_o` | Output | 1 | OBI grant (ready) signal returned to master. |
| `host_rvalid_o` | Output | 1 | Response valid returned to master. |
| `host_err_o` | Output | 1 | Error flag returned to master. |
| `host_rdata_o` | Output | 32 | Response read data returned to master. |
| `periph_phys_req_o`| Output | 1 | Physical request forwarded to protected subordinate peripheral. |
| `periph_phys_rvalid_i`| Input | 1 | Physical response valid returned from protected peripheral. |
| `drain_wdog_cnt_o` | Output | 10 | 1,024-cycle orphan drain watchdog counter state. |
| `subsys_dead_locked_o`| Output | 1 | Permanent deadlock trap status flag. |

#### Hardware Guarantees Formally Proven in Gate C:
1. **Single Response Invariant (`F-OBI-01` / `ZC-CLAIM-06`):**  
   Every accepted request produces exactly one response (`host_rvalid_o`), returning the bridge to `ST_IDLE` with `rvalid=0` (no double responses or frame echoes).
2. **Orphan Silent Drain (`F-OBI-02a/b/c` / `ZC-CLAIM-07..09`):**  
   Peripheral responses arriving in `ST_IDLE` without an active host request are silently absorbed (`host_rvalid_o == 0`), clearing physical bus state on the following cycle with zero leaked data.
3. **Warm Reset Request Gating (`F-OBI-07` / `ZC-CLAIM-12`):**  
   While warm reset is active (`rst_sys_ni == 0`), `host_req_ready_o`, `periph_phys_req_o`, and `host_rvalid_o` are strictly forced to 0.
4. **Deadlock Trap Synthetic Error (`F-OBI-06a/b/c` / `ZC-CLAIM-11`):**  
   When the 1,024-cycle watchdog expires (`subsys_dead_locked_q == 1`), accepted requests never access the physical bus (`periph_phys_req_o == 0`), enter `ST_TRAP`, and deliver a 1-cycle synthetic bus error (`rvalid=1, err=1, rdata=0x0000_0000`).

---

### 2.3 AON Post-Authorization Controller (`zc_aon_post_auth_ctrl.sv`)
* **Source Location:** [`rtl/zc_aon_post_auth_ctrl.sv`](../../rtl/zc_aon_post_auth_ctrl.sv)
* **Formal Verification Harness:** [`fv/zc_otp_formal_proof.sv`](../../fv/zc_otp_formal_proof.sv)
* **Clock Domain:** Dual-Domain: Always-On (`clk_aon_i`, `rst_aon_por_ni`) & System Reset (`rst_sys_ni`).
* **Primary Role:** Manages anti-rollback version fuses and permanent authorization seals in non-volatile OTP memory via a 4-phase Direct Access Interface (DAI).

#### Key Interface Signals:
| Signal Name | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `clk_aon_i` | Input | 1 | Always-On dedicated security clock. |
| `rst_aon_por_ni` | Input | 1 | Cold Power-On Reset (clears fatal lock). |
| `rst_sys_ni` | Input | 1 | Warm System Reset (cannot clear fatal lock). |
| `post_session_id_i`| Input | 32 | Session identifier presented for OTP commit. |
| `f_dut_active_session_id_o`| Output (Formal)| 32 | Latched active session identifier. |
| `otp_word_auth_valid_o`| Output | 1 | Authorization strobe to physical OTP macro. |
| `otp_dai_we_o` | Output | 1 | Write-enable strobe to physical OTP DAI. |
| `auth_state_o` | Output | 4 | Current FSM authorization state. |

#### Hardware Guarantees Formally Proven in Gate C:
1. **Immediate Grant Consumption (`F-OTP-01a` / `ZC-CLAIM-13`):**  
   An active write grant in `WSTEP_AUTH_READY` consumes in exactly one cycle upon `otp_dai_we_o` assertion.
2. **Session Completion Invariants (`F-OTP-02`, `F-OTP-03a/b/c` / `ZC-CLAIM-15..16`):**  
   Verified readback advances expected words ($0 \to 1 \to 2$ for normal mode, $2$ only for recovery mode), cleanly transitioning to `AUTH_SESSION_DONE` and deasserting all grants.
3. **Mismatched Readback Fatal Lock (`F-OTP-04`, `F-OTP-04b` / `ZC-CLAIM-17`):**  
   Any corrupted data, unexpected slot, or session-ID mismatch during readback immediately forces the FSM into `AUTH_LOCKED_FATAL`.
4. **Permanent Sticky Invariant (`F-OTP-05` / `ZC-CLAIM-18`):**  
   `AUTH_LOCKED_FATAL` permanently persists across warm reset `!rst_sys_ni`; it can be cleared ONLY by a full Cold Power-On Reset (`!rst_aon_por_ni`).

---

## 3. Clock, Reset & Power Domain Topologies

```
+---------------------------------------------------------------------------------------------------------+
|                                    CLOCK & RESET DOMAIN TOPOLOGY                                        |
+---------------------------------------------------------------------------------------------------------+
|                                                                                                         |
|   +---------------------------------------+      +-------------------------------------------+          |
|   |   ALWAYS-ON (AON) DOMAIN              |      |   SYSTEM DOMAIN (SYS)                     |          |
|   +---------------------------------------+      +-------------------------------------------+          |
|   | Clock: clk_aon_i (Low-power, tamper-  |      | Clock: clk_sys_i (High-speed system bus)  |          |
|   |        resistant oscillator)          |      | Reset: rst_sys_ni (Warm System Reset)     |          |
|   | Reset: rst_aon_por_ni (Cold Power-On) |      | Target Blocks: zc_obi_subordinate_bridge  |          |
|   | Target Blocks: zc_aon_post_auth_ctrl  |      |                zc_spi_flash_firewall      |          |
|   +---------------------------------------+      +-------------------------------------------+          |
|                      |                                                 |                                |
|                      v                                                 v                                |
|             Sticky Fatal Lock                              Host Request Blocking                        |
|             (Crosses to SYS domain)                        (Gated when rst_sys_ni=0)                    |
|                                                                                                         |
+---------------------------------------------------------------------------------------------------------+
```

### 3.1 Reset Domain Hierarchy
1. **Cold Power-On Reset (`rst_aon_por_ni`):** The master reset generated by the physical power-management IC (PMIC). Deasserts only after supply voltages and bias currents stabilize. Clears `AUTH_LOCKED_FATAL`.
2. **Warm System Reset (`rst_sys_ni`):** Initiated by software, watchdog expiration, or external debug request. **Does NOT clear `AUTH_LOCKED_FATAL`**. Property `F-OBI-07` guarantees that when `rst_sys_ni == 0`, all OBI bus grants and physical peripheral requests are immediately forced to zero, preventing warm-reset transient leakage.

---

## 4. Hardware Verification Boundaries: Gate C vs. Gate D

| Hardware Domain | Verification Scope | Status | Sign-Off Deliverable |
| :--- | :--- | :---: | :--- |
| **Digital RTL Logic & State Machines** | Yosys formal BMC, $k$-induction ($t=20$), and cycle-accurate Verilator/Icarus testbenches. | **CLOSED** | Gate C Sign-Off (`PARTIAL / QUALIFIED`) |
| **Top-Level Full-SoC Crossbar** | Multi-master OBI/AXI crossbar connecting Ibex CPU, NPU enclave, and Network Co-Processor. | `BLOCKED` | Gate D / `SVA-M7-01`, `SVA-M8-01` Miter Proofs |
| **Physical Antifuse Macro Cells** | Analog high-voltage ($V_{\text{PP}}$) charge pump ramp, pulse width ($10\,\mu\text{s}$), and thermal soak. | `UNVERIFIED` | Gate D / Foundry Physical PDK Silicon Characterization |
| **Static Timing Closure (STA/PVT)** | Removal/recovery timings ($t_{\text{rem}}, t_{\text{rec}}$) on asynchronous reset deassertion edges. | `UNVERIFIED` | Gate D / OpenSTA & Commercial PrimeTime Closure |
| **Physical Board & Bus Signal Integrity**| High-speed oscilloscope and logic analyzer traces under active fault injection. | `UNVERIFIED` | Gate D / Physical Laboratory Conformance Testing (CTS) |
