# FREECULI ZC-CORE — Hybrid Hardware Interconnect Architecture Specification
## RTL Block Interfaces, Trust Boundary Topologies & Bus Isolation Contracts

**Status:** `PROPOSED / NOT RELEASED / NOT SOC-VERIFIED`  
**Document ID:** ZC-CORE-SPEC-HYBRID-INTERCONNECT-DRAFT  
**Revision:** 0.9.2-draft (Post-Audit Remediation HAR-02 / HAR-03 / HAR-04 / HAR-06 / HAR-07)  
**Target Milestone:** Post-Gate C Governance / Gate D Preparation  
**Reference Technical Baseline:** Commit [`eb3ed5a`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/eb3ed5ad9fddb551506d43d2692bd040843af06f) (Run #45)  
**Classification:** Technical Hardware Interconnect Specification (Draft)  

---

> [!WARNING]
> **GOVERNANCE & BOUNDARY NOTICE:**  
> This specification is an architectural draft (`PROPOSED / NOT RELEASED / NOT SOC-VERIFIED`). It defines the interconnect topology, clock/reset domains, and hardware firewall contracts for the **HYBRID Profile**.  
> The digital RTL IP blocks described herein (`zc_spi_flash_firewall`, `zc_obi_subordinate_bridge`, `zc_aon_post_auth_ctrl`) have been formally verified under Gate C (`PARTIAL / QUALIFIED`). These blocks enforce local protocol, state, and bus-level constraints. They do **NOT** constitute a full-SoC DMA firewall, PMP crossbar, or physical tamper shield. Full-SoC multi-master bus integration and physical silicon characteristics remain strictly deferred to **Gate D (UNVERIFIED)**.

---

## 1. Architectural Topology & Interconnect Overview

In a ZC-CORE HYBRID system, the device maintains operational coexistence with external networks through an untrusted Network Co-Processor. The interconnect architecture enforces hardware trust boundaries across three discrete RTL firewall modules:

```
+---------------------------------------------------------------------------------------------------------+
|                                    ZC-CORE TRUST BOUNDARY TOPOLOGY                                      |
+---------------------------------------------------------------------------------------------------------+
|                                                                                                         |
|   [ UNTRUSTED EXTERNAL / NETWORK DOMAIN ]                                                               |
|     |  Network Co-Processor (Wi-Fi / BLE / Ethernet)                                                    |
|     +---------------+-------------------------------------+                                             |
|                     |                                     |                                             |
|          (SPI Bus)  v                         (OBI Bus)   v                                             |
|   +---------------------------------+   +------------------------------------+                          |
|   |   zc_spi_flash_firewall         |   |   zc_obi_subordinate_bridge        |                          |
|   |   - Pass-through / Gated /CS    |   |   - Synchronous Bus Decoupling     |                          |
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

## 2. RTL Block Interface Specifications (Production vs. Formal)

To ensure absolute fidelity with the RTL source code (resolving Auditor finding **HAR-03 / P1**), all signal tables below reflect the exact declarations in `rtl/*.sv`.

### 2.1 SPI Flash Firewall (`zc_spi_flash_firewall.sv`)
* **Source Location:** [`rtl/zc_spi_flash_firewall.sv`](../../rtl/zc_spi_flash_firewall.sv)
* **Clock Domain:** Synchronous SPI system domain (`clk_i`, `rst_sys_ni`).
* **Design Intent:** Shields external SPI Flash memory from desynchronized frames, write-enable poisoning, and unauthorized Bank B boot execution.

#### Production Signal Interface:
| Signal Name | Direction | Width | Description & True RTL Semantics |
| :--- | :---: | :---: | :--- |
| `clk_i` | Input | 1 | System sampling clock. |
| `rst_sys_ni` | Input | 1 | Active-low warm system reset. |
| `cs_n_to_iso_i` | Input | 1 | Primary Chip Select from SPI Master controller. |
| `sck_to_iso_i` | Input | 1 | Primary Serial Clock from SPI Master controller. |
| `sck_sample_edge_i` | Input | 1 | Clock sample strobe for SPI Mode 0/3 data capture. |
| `miso_sync_i` | Input | 1 | Synchronized MISO data line from physical Flash. |
| `opcode_i` | Input | 8 | Latched SPI command opcode (e.g., `05h`, `04h`, `02h`). |
| `target_addr_i` | Input | 24 | Flash byte address targeted by current transaction. |
| `frame_bit_cnt_i` | Input | 12 | Bit counter tracking current SPI frame length. |
| `rx_shift_i` | Input | 7 | Shift register lower bits capturing MISO responses. |
| `guard_stream_data_i`| Input | 1 | Stream data guard signal. |
| `fault_high_sec_i` | Input | 1 | Secondary-side electrical supervisor fault input. |
| `upd_wdog_timeout_i` | Input | 1 | Watchdog timeout pulse from external supervisor. |
| `rom_img_verif_valid_i`| Input | 1 | **Trust Assumption Input:** Asserted by independent Boot ROM cryptographic verifier when Bank B image signature is valid. |
| `cs_n_to_iso_o` | Output | 1 | Registered primary Chip Select pass-through (`cs_n_to_iso_o = cs_n_to_iso_i`). |
| `sck_to_iso_o` | Output | 1 | Registered primary Serial Clock pass-through (`sck_to_iso_o = sck_to_iso_i`). |
| `cs_n_flash_eff_o` | Output | 1 | **Effective Gated Chip Select:** `cs_n_to_iso_o \| fault_high_sec_i` (Forces Flash deselect upon secondary fault). |
| `spi_idle_ready_o` | Output | 1 | Asserts when firewall FSM is in `UPD_IDLE` and `fault_high_sec_i == 0`. |
| `bank_b_commit_ready_o`| Output | 1 | **Authorization Gate:** `spi_idle_ready_o && rom_img_verif_valid_i`. Authorizes boot execution from Bank B. |
| `spi_update_state_o` | Output | 3 | Current firewall FSM state (`UPD_UNSYNC_RESET` .. `UPD_RECOVERY_LOCKOUT`). |

#### Formal-Only Observation Ports (` `ifdef FORMAL `):
| Signal Name | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `f_sr1_latched_byte_o` | Output | 8 | Latched RDSR1 status register byte (`sr1_latched_byte_q`). Exposes WIP/WEL bits for formal assertions. |
| `f_sr1_byte_sampled_o` | Output | 1 | Pulse indicating SR1 status byte sampling completed. |

#### Architectural Gating & Trust Assumptions (HAR-04 Resolution):
The firewall implements Layer 3 separation via the following explicit assignment:
```verilog
assign spi_idle_ready_o      = (spi_update_fsm_q == UPD_IDLE) && !fault_high_sec_i;
assign bank_b_commit_ready_o = spi_idle_ready_o && rom_img_verif_valid_i;
```
> [!IMPORTANT]
> **Cryptographic Trust Assumption Disclosure:**  
> The SPI Firewall does **NOT** execute cryptographic hashing (SHA-256) or signature verification (Ed25519) within its RTL logic. It acts strictly as a **hardware authorization gate**. The cryptographic validity of the firmware image is a declared **external trust assumption** provided via `rom_img_verif_valid_i`. The hardware guarantees that Bank B execution is blocked unless both physical SPI idle readiness and the external ROM verification signal are simultaneously true.

---

### 2.2 OBI Subordinate Bridge (`zc_obi_subordinate_bridge.sv`)
* **Source Location:** [`rtl/zc_obi_subordinate_bridge.sv`](../../rtl/zc_obi_subordinate_bridge.sv)
* **Clock Domain:** Synchronous bus domain (`clk_i`, `rst_sys_ni`, `rst_por_ni`).
* **Design Intent:** Mediates host bus transactions to protected subordinate peripherals, silently drains orphan responses, and traps bus deadlocks.

#### Production Signal Interface:
| Signal Name | Direction | Width | Description & True RTL Semantics |
| :--- | :---: | :---: | :--- |
| `clk_i` | Input | 1 | System bus clock. |
| `rst_por_ni` | Input | 1 | Cold Power-On Reset (clears `subsys_dead_locked_q` and `phys_req_active_q`). |
| `rst_sys_ni` | Input | 1 | Warm System Reset. |
| `host_req_i` | Input | 1 | OBI host transaction request. |
| `host_req_ready_o` | Output | 1 | OBI host request grant (`1` when ready to accept request in `ST_IDLE`). |
| `host_rvalid_o` | Output | 1 | OBI host response valid. |
| `host_err_o` | Output | 1 | OBI host error indicator (`1` on timeout or in `ST_TRAP`). |
| `host_rdata_o` | Output | 32 | OBI host read data (`32'h0000_0000` during synthetic error). |
| `periph_phys_req_o`| Output | 1 | Physical request forwarded to subordinate peripheral. |
| `periph_phys_gnt_i`| Input | 1 | Physical grant returned from subordinate peripheral. |
| `periph_phys_rvalid_i`| Input | 1 | Physical response valid from peripheral. |
| `periph_phys_err_i`| Input | 1 | Physical error indicator from peripheral. |
| `periph_phys_rdata_i`| Input | 32 | Physical read data from peripheral. |
| `subsys_fatal_fault_irq_o`| Output | 1 | Interrupt asserted when deadlock watchdog triggers. |
| `orphan_drain_active_o` | Output | 1 | Status flag indicating orphan response is currently being drained. |
| `drain_wdog_cnt_o` | Output | 10 | Monotonic 1,024-cycle orphan drain watchdog counter output. |
| `bridge_state_o` | Output | 2 | Current bridge FSM state (`ST_IDLE`, `ST_WAIT_RVALID`, `ST_TIMEOUT_ERR`, `ST_TRAP`). |

#### Architectural Gating & Scope Limitations (HAR-02, HAR-06 & HAR-07 Resolution):
> [!IMPORTANT]
> **Subsystem Isolation Boundary & Verification Disclosure:**  
> The OBI Subordinate Bridge provides transaction-level decoupling on a point-to-point OBI bus link. It prevents hung peripherals from locking the CPU and prevents orphan data leaks. It does **NOT** constitute:
> 1. A multi-master crossbar IOMMU or Memory Protection Unit (MPU).
> 2. A system-wide DMA firewall that blocks arbitrary memory apertures. Full DMA master authorization and SRAM enclave isolation are tracked as **Gate D SoC integration deliverables** (`SVA-M7-01`, `SVA-M8-01`).
> 3. A telemetry allowlist filter, payload inspector, or hardware rate limiter. The bridge is protocol-agnostic and does not inspect data payload schemas. Hardware telemetry enforcement remains **`PROPOSED / NOT IMPLEMENTED IN CURRENT RTL`** (Gate D deliverable).
> 4. A universal formal temporal proof over 1,024 cycles. The continuous 1,024-cycle timeout progression is verified via digital RTL simulation (`tb_zc_obi.sv` Test 2 / `SIMULATED`). Properties `F-OBI-04` and `F-OBI-05` formally prove local inductive step logic and lock assertion (`PROVEN` at RTL step level).

---

### 2.3 AON Post-Authorization Controller (`zc_aon_post_auth_ctrl.sv`)
* **Source Location:** [`rtl/zc_aon_post_auth_ctrl.sv`](../../rtl/zc_aon_post_auth_ctrl.sv)
* **Clock Domain:** Dual-Domain: Always-On (`clk_aon_i`, `rst_aon_por_ni`) & Warm Reset (`rst_sys_ni`).
* **Design Intent:** Controls the Direct Access Interface (DAI) of the physical OTP memory for anti-rollback version fuses and permanent authorization seals.

#### Production Signal Interface:
| Signal Name | Direction | Width | Description & True RTL Semantics |
| :--- | :---: | :---: | :--- |
| `clk_aon_i` | Input | 1 | Always-On security clock. |
| `rst_aon_por_ni` | Input | 1 | Cold Power-On Reset (only reset that clears `AUTH_LOCKED_FATAL`). |
| `rst_sys_ni` | Input | 1 | Warm System Reset status. |
| `rom_exec_active_i`| Input | 1 | Boot ROM execution active indicator. |
| `tamper_alert_i` | Input | 1 | Physical tamper alert input. |
| `clk_glitch_alert_i`| Input | 1 | Clock glitch detector alert input. |
| `volt_supervisor_fault_i`| Input | 1 | Voltage supervisor brown-out fault input. |
| `boot_scan_done_i` | Input | 1 | Boot OTP scan completed. |
| `boot_scan_pending_b_i`| Input | 1 | Pending seal recovery state detected during scan. |
| `post_auth_req_i` | Input | 1 | Authorization session request. |
| `post_session_id_i`| Input | 32 | Session identifier presented for commit. |
| `val_step_done_i` | Input | 1 | Validation step completion strobe. |
| `val_all_checks_ok_i`| Input | 1 | Validation all checks pass indicator. |
| `req_target_slot_i`| Input | 4 | Target OTP slot index $k \in [0..15]$. |
| `req_target_svn_i` | Input | 8 | Target Security Version Number $v \in [1..255]$. |
| `req_seal_b_only_i`| Input | 1 | Recovery mode select (`1`: Word 2 only, `0`: normal 3-word commit). |
| `dai_state_i` | Input | 2 | Physical OTP DAI status. |
| `otp_macro_phys_active_i`| Input | 1 | Physical OTP macro busy status. |
| `dai_cmd_req_i` | Input | 1 | DAI command request acknowledge. |
| `dai_slot_idx_i` | Input | 4 | DAI current slot index. |
| `dai_word_sel_i` | Input | 2 | DAI current word select. |
| `dai_prog_done_pulse_i`| Input | 1 | Programming pulse completed strobe. |
| `dai_prog_err_i` | Input | 1 | Programming error indicator. |
| `dai_rb_done_pulse_i`| Input | 1 | Readback verification pulse strobe. |
| `dai_ecc_err_i` | Input | 1 | Uncorrectable ECC error indicator. |
| `dai_rb_session_id_i`| Input | 32 | Session ID returned from readback. |
| `dai_rb_slot_idx_i`| Input | 4 | Slot index returned from readback. |
| `dai_rb_word_sel_i`| Input | 2 | Word select returned from readback. |
| `dai_rb_raw_data_i`| Input | 22 | Raw 22-bit codeword returned from readback. |
| `otp_word_auth_valid_o`| Output | 1 | Phase 1 write authorization strobe to DAI gate. |
| `otp_dai_we_o` | Output | 1 | Phase 2 single-cycle write-enable pulse (`dai_write_accepted_w`). |
| `otp_auth_slot_o` | Output | 4 | Authorized target slot index. |
| `otp_auth_svn_o` | Output | 8 | Authorized target SVN. |
| `otp_auth_word_sel_o`| Output | 2 | Authorized word selector (`0`, `1`, `2`). |
| `otp_auth_word_mask_o`| Output | 3 | Word authorization bitmask (`[2:0]`). |
| `otp_auth_expected_cw_o`| Output | 22 | Expected Hsiao (22,16) codeword for readback verification. |
| `aon_auth_state_o` | Output | 3 | AON authorization FSM state. |
| `aon_wstep_o` | Output | 2 | Sub-step state (`WSTEP_AUTH_READY` .. `WSTEP_WAIT_RB_VERIFY`). |
| `aon_fatal_locked_o`| Output | 1 | Permanent fatal lock indicator (`AUTH_LOCKED_FATAL`). |

#### Formal-Only Observation Ports (` `ifdef FORMAL `):
| Signal Name | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `f_active_session_id_o` | Output | 32 | Gate C formal observation port exposing `active_session_id_q`. |
| `f_val_ctx_seal_b_only_o`| Output | 1 | Gate C formal observation port exposing `val_ctx_seal_b_only_q`. |

---

## 3. Clock & Reset Topologies

```
+---------------------------------------------------------------------------------------------------------+
|                                    CLOCK & RESET DOMAIN TOPOLOGY                                        |
+---------------------------------------------------------------------------------------------------------+
|                                                                                                         |
|   +---------------------------------------+      +-------------------------------------------+          |
|   |   ALWAYS-ON (AON) DOMAIN              |      |   SYSTEM DOMAIN (SYS)                     |          |
|   +---------------------------------------+      +-------------------------------------------+          |
|   | Clock: clk_aon_i                      |      | Clock: clk_i / clk_sys_i                  |          |
|   | Reset: rst_aon_por_ni (Cold POR)      |      | Reset: rst_sys_ni (Warm System Reset)     |          |
|   | Target: zc_aon_post_auth_ctrl         |      | Target: zc_obi_subordinate_bridge         |          |
|   |                                       |      |         zc_spi_flash_firewall             |          |
|   +---------------------------------------+      +-------------------------------------------+          |
|                      |                                                 |                                |
|                      v                                                 v                                |
|             Sticky Fatal Lock                              Host Request Blocking                        |
|             (Permanent until Cold POR)                     (Gated to 0 when rst_sys_ni=0)               |
|                                                                                                         |
+---------------------------------------------------------------------------------------------------------+
```

---

## 4. Verification Boundaries: Gate C vs. Gate D Deliverables

| Verification Item | Target Block | Gate C Status | Gate D Deliverable |
| :--- | :--- | :---: | :--- |
| **SPI Flash Command Firewalling** | `zc_spi_flash_firewall` | **`PROVEN` (Run #45)** | Physical Flash glitching & PCB signal integrity test. |
| **OBI Bus Decoupling & Watchdog** | `zc_obi_subordinate_bridge` | **`PROVEN` (F-OBI-01..07) / `SIMULATED` (1024-cyc wdog)** | Full SoC bus arbitration & DMA crossbar integration. |
| **AON Anti-Rollback DAI Handshake**| `zc_aon_post_auth_ctrl` | **`PROVEN` (Run #45)** | Foundry physical antifuse PDK analog macro characterization. |
| **Full-SoC 2-Trace Noninterference**| Top-Level SoC Crossbar | **`BLOCKED`** | Top-level 2-trace miter formal equivalence (`SVA-M7-01`, `SVA-M8-01`). |
| **Asynchronous Reset Removal/Recovery**| All Blocks | **`UNVERIFIED`** | Static Timing Analysis (STA) across PVT corners (PrimeTime / OpenSTA). |
