# FREECULI ZC-CORE — Gate C HDL Modeling & Formal Verification Limits

**Document ID:** ZC-CORE-GATE-C-MODELING-LIMITS  
**Revision:** 1.1.0 (Rev. 28D P-7 & Independent Audit Alignment)  
**Target Architecture:** FreeCuli Zero-Cloud Hardware Core (ZC-CORE)  
**Classification:** Normative Formal Audit Technical Disclosure  

---

## 1. Executive Summary

This document establishes the normative disclosure of formal modeling boundaries, toolchain abstractions, input assumption constraints, and verification limits applicable to the **Gate C (Rev. 28D)** HDL verification suite of the FreeCuli ZC-CORE hardware architecture.

The open-source formal verification flow is built on:
- **Yosys 0.33** (RTL elaboration, AST flattening, `async2sync`, `opt`, `dffunmap`, and SMT2 emission)
- **yosys-smtbmc** (SMT-LIB2 translation and bounded model checking / $k$-induction driver)
- **Z3 4.12+** (SMT solver engine over `QF_BV` bit-vector logic)
- **Verilator 5.0+** & **Icarus Verilog 12.0+** (Cycle-accurate dynamic simulation)

This disclosure satisfies **Finding P-7** of the Gate C Independent Formal Scope Audit and the subsequent Independent Technical Audit remediation directives (Sections 2–6).

---

## 2. Asynchronous Reset Abstraction (`async2sync`) & AON CDC / Reset Boundaries

### 2.1 Mechanism and Purpose
In SystemVerilog RTL, the ZC-CORE hardware blocks declare asynchronous active-low reset inputs:
- `rst_aon_por_ni` (Always-On Cold Power-On Reset in `rtl/zc_aon_post_auth_ctrl.sv` line 21, `always_ff @(posedge clk_aon_i or negedge rst_aon_por_ni)` at line 215)
- `rst_por_ni` (Cold Power-On Reset in `rtl/zc_obi_subordinate_bridge.sv` line 23, `always_ff @(posedge clk_i or negedge rst_por_ni)` at lines 64, 83, 106, 122)
- `rst_sys_ni` (System Warm Reset in `rtl/zc_spi_flash_firewall.sv` line 18, `always_ff @(posedge clk_i or negedge rst_sys_ni)` at lines 77, 96, 121; evaluated synchronously as an active-low reset/control input in `rtl/zc_obi_subordinate_bridge.sv` lines 24, 78, 109, 127, 183–203 and `rtl/zc_aon_post_auth_ctrl.sv` lines 22, 161, 248, 255, 282)

In the Yosys formal pipeline:
```bash
yosys -p "read_verilog -sv -formal ...; prep -top <top> -flatten; async2sync; opt; dffunmap; write_smt2 <file>.smt2"
```
The `async2sync` pass transforms all asynchronous set/reset flip-flops (`$adff`) into synchronous flip-flops (`$dff`) whose reset condition is evaluated synchronously on the active clock edge.

### 2.2 Formal Limits & Silicon Boundary
1. **Clock-Synchronous Domain Restriction:** Formal proofs under `async2sync` prove correctness **if and only if** reset assertion and deassertion occur synchronously with respect to `clk_i` / `clk_aon_i`, or are sampled at discrete clock edges.
2. **Glitch & Pulse Immunity:** Sub-cycle asynchronous reset glitches, voltage brown-out runt pulses shorter than $T_{clk}$, and asynchronous removal/recovery timing violations ($t_{rec}$, $t_{rem}$) cannot be modeled or proven by SMT2-based discrete-time BMC.
3. **Gate D / Silicon Deferral:** Asynchronous reset recovery/removal timing closure, glitch filtering, and metastable synchronizer validation are formally deferred to **Gate D** (Static Timing Analysis via OpenSTA / commercial STA and CDC/RDC sign-off, `ZC-CLAIM-33`) and physical silicon laboratory characterization.

### 2.3 AON Controller (`rtl/zc_aon_post_auth_ctrl.sv`) CDC, Wait-State Liveness & Validation Input Contract
1. **CDC Path & Upstream Synchronization Boundary (`rst_sys_ni` and `rom_exec_active_i`):**
   - Inside `rtl/zc_aon_post_auth_ctrl.sv`, `clk_aon_i` (line 20) is the sole clock domain. `rst_aon_por_ni` (line 21) is the asynchronous Cold POR input (`negedge rst_aon_por_ni` at line 215).
   - `rst_sys_ni` (line 22) and `rom_exec_active_i` (line 23) directly gate combinational write authorization (`write_authorized_w` at lines 161–162) and synchronous FSM transitions in `clk_aon_i` (`AUTH_WAIT_CHAL -> AUTH_VALIDATE` at line 248; `AUTH_VALIDATE -> AUTH_LOCKED_FATAL` at line 255; `AUTH_GRANT -> AUTH_LOCKED_FATAL` at line 282).
   - Because Gate C evaluates the standalone IP block `zc_aon_post_auth_ctrl` in isolation (no top-level SoC wrapper RTL exists in the repository), `rtl/zc_aon_post_auth_ctrl.sv` does **not** instantiate internal multi-stage CDC flip-flop synchronizers on `rst_sys_ni` or `rom_exec_active_i`.
   - **Architectural Contract & Gate D Requirement:** The module interface contract requires the upstream SoC AON wrapper / Reset Controller to synchronize `rst_sys_ni` (asynchronous assertion, synchronous deassertion into `clk_aon_i`) and `rom_exec_active_i` (2-FF synchronizer into `clk_aon_i`), and to enforce reset release ordering (`rst_aon_por_ni` deasserted and `clk_aon_i` stable prior to `rst_sys_ni` deassertion and `rom_exec_active_i` assertion). Neither the occurrence nor the absence of metastability is claimed from the standalone RTL module alone; top-level CDC/RDC synthesis and STA verification remain **`UNVERIFIED` (Deferred to Gate D, `ZC-CLAIM-33`)**.
2. **`WSTEP_WAIT_PHYS_DONE` and `WSTEP_WAIT_RB_VERIFY` Wait-State Liveness / Timeout Contract:**
   - In `WSTEP_WAIT_PHYS_DONE` (`rtl/zc_aon_post_auth_ctrl.sv` lines 308–317) and `WSTEP_WAIT_RB_VERIFY` (lines 319–345), the single-word grant `word_grant_avail_q` has already been cleared to `1'b0` upon `dai_write_accepted_w` (line 303). Consequently, `otp_word_auth_valid_o == 1'b0`, `otp_dai_we_o == 1'b0`, and `otp_auth_word_mask_o == 3'b000` throughout both wait states (formally proven by `F-OTP-01a` and `F-OTP-01b` in `fv/zc_otp_formal_proof.sv` lines 180–200).
   - **Safety vs. Liveness Classification:** Remaining in `WSTEP_WAIT_PHYS_DONE` (if `dai_prog_done_pulse_i` and `dai_prog_err_i` never arrive) or `WSTEP_WAIT_RB_VERIFY` (if `dai_rb_done_pulse_i` never arrives) is **safe (`PROVEN` fail-closed)** because no additional write grant or premature `AUTH_SESSION_DONE` transition can occur. For **liveness/availability**, `zc_aon_post_auth_ctrl` does not implement an internal cycle-count timeout timer in these two wait states; it relies on the external DAI macro controller to assert `dai_prog_err_i` / `dai_rb_done_pulse_i` or the system POST watchdog to assert `!rst_sys_ni` (which immediately transitions `AUTH_GRANT` to `AUTH_LOCKED_FATAL` at lines 282–286). Physical macro timeout bounds remain **`UNVERIFIED` (Gate D, `ZC-CLAIM-30/31`)**.
3. **`val_all_checks_ok_i` and `AUTH_VALIDATE` Entry/Exit Contract:**
   - `AUTH_VALIDATE` (`rtl/zc_aon_post_auth_ctrl.sv` lines 254–279) can be entered **only** from `AUTH_WAIT_CHAL` (which is entered only from `AUTH_RESET_IDLE` after `boot_scan_done_i`, lines 239–242) when `!(dai_prog_done_pulse_i || dai_rb_done_pulse_i || dai_cmd_req_i) && post_auth_req_i && rst_sys_ni && rom_exec_active_i` (lines 246–251).
   - In `AUTH_VALIDATE`, any unexpected DAI pulse/request or loss of `rst_sys_ni` / `rom_exec_active_i` immediately locks the FSM to `AUTH_LOCKED_FATAL` (lines 255–258). Upon `val_step_done_i` (line 259), the RTL directly enforces `(req_target_svn_i != 8'd0)` and `(!req_seal_b_only_i || pending_b_exists_q)` (lines 261–262), while relying on the 1-bit primary input `val_all_checks_ok_i` (line 38) for upstream POST cryptographic challenge-response and monotonic SVN comparison (`SVN_new > SVN_current`). The upstream logic driving `val_all_checks_ok_i` lies outside this standalone module and is classified as an **external SoC integration obligation (`UNVERIFIED` in Gate C; deferred to Gate D)**.

---

## 3. Environment Assumptions & Free Input Constraints

### 3.1 Non-Deterministic Inputs
In the formal proof harnesses:
- [fv/zc_spi_formal_proof.sv](../../fv/zc_spi_formal_proof.sv)
- [fv/zc_obi_formal_proof.sv](../../fv/zc_obi_formal_proof.sv)
- [fv/zc_otp_formal_proof.sv](../../fv/zc_otp_formal_proof.sv)

All primary inputs after cycle 0 (`!f_past_valid`) carry **zero** `assume` constraints and are treated by the SMT solver as non-deterministic free variables at every cycle $t \in [1..20]$. This guarantees that the formal proofs do not over-constrain the DUT or assume the security property beforehand.

### 3.2 Exact Formal Assumptions Inventory (Source-Verified Against `fv/*_formal_proof.sv`)

| Formal Harness File | Exact `assume` Directive in Source (Line) | Constrained Scope | Unconstrained Free Inputs ($t \ge 1$) & Audit Note |
| :--- | :--- | :--- | :--- |
| **`fv/zc_spi_formal_proof.sv`** | `if (!f_past_valid) assume (!rst_sys_ni);` (Line 106) | Initial cycle ($t=0$) active-low reset initialization only. | All 13 inputs (`rst_sys_ni` for $t \ge 1$, `cs_n_to_iso_i`, `sck_to_iso_i`, `sck_sample_edge_i`, `miso_sync_i`, `opcode_i`, `target_addr_i`, `frame_bit_cnt_i`, `rx_shift_i`, `guard_stream_data_i`, `fault_high_sec_i`, `upd_wdog_timeout_i`, `rom_img_verif_valid_i`) are **100% unconstrained free variables**. *(Note: Earlier draft text mentioning `assume property (!(cs_n_to_iso_o && sck_to_iso_o))` and `rom_exec_active_i` is superseded; no such assumption exists in `fv/zc_spi_formal_proof.sv`).* |
| **`fv/zc_obi_formal_proof.sv`** | `if (!f_past_valid) assume (!rst_por_ni);` (Line 87) | Initial cycle ($t=0$) Cold POR initialization only. | All 7 inputs (`rst_por_ni` for $t \ge 1$, `rst_sys_ni`, `host_req_i`, `periph_phys_gnt_i`, `periph_phys_rvalid_i`, `periph_phys_err_i`, `periph_phys_rdata_i`) are **100% unconstrained free variables**. *(Note: `rst_sys_ni` is NOT constrained by an `assume` in $k$-induction; steady-state properties guard their antecedent with `rst_sys_ni`, while `F-OBI-07` [lines 95–99] and Cover `C-OBI-07` [line 183] directly verify `!rst_sys_ni`. Cover `C-OBI-01` [line 189] verifies normal response delivery reachability in `ST_WAIT_RVALID`).* |
| **`fv/zc_otp_formal_proof.sv`** | `if (!f_past_valid) assume (!rst_aon_por_ni);` (Line 163) | Initial cycle ($t=0$) Cold POR initialization only. | All 28 inputs (`rst_aon_por_ni` for $t \ge 1$, `rst_sys_ni`, `rom_exec_active_i`, `tamper_alert_i`, `clk_glitch_alert_i`, `volt_supervisor_fault_i`, `boot_scan_done_i`, `boot_scan_pending_b_i`, `post_auth_req_i`, `post_session_id_i`, `val_step_done_i`, `val_all_checks_ok_i`, `req_target_slot_i`, `req_target_svn_i`, `req_seal_b_only_i`, and all `dai_*` / `otp_macro_phys_active_i` signals) are **100% unconstrained free variables**. |

### 3.3 OTP Shadow Session Tracking & Yosys AST Boundary
- **Yosys AST Hierarchical Path Limitation:** The Yosys AST parser (`read_verilog -sv`) does not support cross-module dot references (`dut.active_session_id_q`) directly inside assertions in formal property expressions.
- **Formal Observation Port & Inductive Invariant:** Two formal observation ports `f_active_session_id_o` and `f_val_ctx_seal_b_only_o` (instantiated under `` `ifdef FORMAL `` in `rtl/zc_aon_post_auth_ctrl.sv` lines 69–73 and 207–210) directly expose internal registers `active_session_id_q` and `val_ctx_seal_b_only_q`. Property `F-OTP-SESSION-EQ` (`fv/zc_otp_formal_proof.sv` lines 173–175) proves by $k$-induction ($t=20$) that shadow register `f_accepted_session_id_q` identically tracks `f_active_session_id_o` across all reachable states (**GCR-05**).
- **RTL Protocol Simulation:** Dynamic session-ID matching and adversarial mismatch rejection (Scenario 6 immediate transition to `AUTH_LOCKED_FATAL`) are verified in the dedicated end-to-end RTL protocol testbench [tb/tb_zc_otp_protocol_e2e.sv](../../tb/tb_zc_otp_protocol_e2e.sv) (lines 368–381) and [tb/tb_zc_otp.sv](../../tb/tb_zc_otp.sv).

### 3.4 OBI Post-Drain Disambiguation
- **Simultaneous Request Retention:** Property `F-OBI-02c` (`fv/zc_obi_formal_proof.sv` lines 128–135) does not assume `!host_req_i` in the past cycle, fully verifying simultaneous host request arrival during orphan peripheral response drain in `ST_IDLE`.
- **Response Source Disambiguation:** Distinguishes physical orphan data leak (proven impossible) from legitimate synthetic error delivery (`ST_TRAP` with `host_err_o == 1` and `host_rdata_o == 0x0000_0000`).

### 3.5 SPI Protocol Mode Support Boundary (SPI Mode 0 Supported; SPI Mode 3 Excluded)
- **Hardware Implementation (`rtl/zc_spi_flash_firewall.sv` line 86):**
  ```systemverilog
  wire phys_cs_deassert_edge_w = !cs_n_prev_q && cs_n_to_iso_o && !sck_to_iso_o;
  ```
- **Protocol Mode Boundary:** Because every primary-side frame completion strobe (`wren_pri_frame_done_w`, `wrdi_pri_frame_done_w`, `rdsr1_pri_frame_done_w`, `erase_pri_frame_done_w`, `prog_pri_frame_done_w` at lines 110–117) is gated by `phys_cs_deassert_edge_w`, the hardware requires `sck_to_iso_o == 1'b0` (`SCK == 0`) on the rising edge of `/CS` (`!cs_n_prev_q && cs_n_to_iso_o`).
- Consequently, `zc_spi_flash_firewall` normatively supports **SPI Mode 0 (`CPOL = 0, CPHA = 0`) only**, where the serial clock idles low (`SCK = 0`) at `/CS` deassertion. **SPI Mode 3 (`CPOL = 1, CPHA = 1`)**, where `SCK` idles high (`SCK = 1`) during `/CS` deassertion, is intentionally rejected by `!sck_to_iso_o` in `phys_cs_deassert_edge_w` and is **not supported** by this hardware block.

---

## 4. Formal Solver Capabilities & SVA Sequence Operators

### 4.1 IEEE 1800 Concurrent SVA Operator Support
Commercial formal verification tools (Cadence JasperGold, Synopsys VC Formal, Siemens Questa Formal) implement the complete IEEE 1800 SystemVerilog Assertion standard, including:
- Sequence overlap and non-overlap: `|->`, `|=>`, `##1`, `##[min:max]`
- Throughout operator: `seq throughout expr`
- Non-consecutive repetition: `expr[->1]`

Open-source Yosys (v0.33) and `yosys-smtbmc` do not synthesize concurrent SVA sequence operators or `bind` modules into SMT2 formulas directly.

### 4.2 Equivalent Immediate-Assertion Modeling in Gate C
To ensure mathematically rigorous verification under open-source tools without weakening the normative contract:
1. **Shadow State Trackers & Observation Ports:** The formal harnesses (`fv/zc_spi_formal_proof.sv`, `fv/zc_obi_formal_proof.sv`, `fv/zc_otp_formal_proof.sv`) instantiate cycle-accurate shadow registers (`f_phys_req_active_q` in `zc_obi_formal_proof.sv` lines 73–84; `cs_n_prev_q`, `f_sr1_latched_byte_q`, `f_sr1_byte_sampled_q` in `zc_spi_formal_proof.sv` lines 78–97; `f_seal_b_only_q` and `f_accepted_session_id_q` in `zc_otp_formal_proof.sv` lines 133–160) alongside `` `ifdef FORMAL `` observation ports.
2. **Inductive Invariants:** $k$-induction ($t=20$) is closed using explicit combinational invariants in `always_comb`:
   - In `fv/zc_obi_formal_proof.sv` (lines 90–105): `(bridge_state_o == ST_IDLE) -> !host_rvalid_o`; `(rst_por_ni && !rst_sys_ni) -> (!host_req_ready_o && !periph_phys_req_o && !host_rvalid_o)`; and `ST_IDLE` under `subsys_fatal_fault_irq_o` implies `host_req_ready_o == 1'b1 && periph_phys_req_o == 1'b0`.
   - In `fv/zc_otp_formal_proof.sv` (lines 166–187): `(aon_auth_state_o == AUTH_GRANT && otp_auth_word_sel_o < OTP_WORD_COMMIT_B) -> (!f_val_ctx_seal_b_only_o && !f_seal_b_only_q)`; `f_accepted_session_id_q == f_active_session_id_o` (`F-OTP-SESSION-EQ`); and structural write isolation (`F-OTP-01b`) forcing `!otp_word_auth_valid_o && !otp_dai_we_o && (otp_auth_word_mask_o == 3'b000)` outside `AUTH_GRANT + WSTEP_AUTH_READY`.
3. **Canonical Commercial SVA Bind Files (`UNVERIFIED` in Open-Source Flow):** The concurrent SVA bind files:
   - [fv/zc_otp_sva.sv](../../fv/zc_otp_sva.sv)
   - [fv/zc_spi_sva.sv](../../fv/zc_spi_sva.sv)
   - [fv/zc_obi_sva.sv](../../fv/zc_obi_sva.sv)
   - [fv/zc_m7_m8_ni_sva.sv](../../fv/zc_m7_m8_ni_sva.sv)  
   retain their explicit header status `[GATE-C VERIFICATION OBLIGATION / UNVERIFIED]` because they require commercial IEEE 1800 SVA solvers (JasperGold / VC Formal) scheduled for Gate D.

---

## 5. Watchdog 1,024-Cycle Formal Horizon vs. Simulation

### 5.1 Horizon Analysis
The OBI subordinate orphan watchdog counter counts from `0` to `1023` cycles ($2^{10} = 1024$ cycles):
- A bounded model check of depth $t = 20$ cannot reach cycle 1024 through unrolling.
- Unrolling 1,024 cycles in SMT2 would generate $1,024 \times |\text{AST}|$ bit-vector constraints, exceeding practical SAT solver memory limits.

### 5.2 Complementary Verification Strategy
1. **Digital Simulation Sign-Off (Bounded to RTL Simulation Environment):** Cycle-accurate HDL simulation ([tb/tb_zc_obi.sv](../../tb/tb_zc_obi.sv) under Verilator and Icarus Verilog) verifies:
   - **Test 1 (Lines 99–118):** Warm reset (`rst_sys_ni == 1'b0`) request/ready/rvalid blocking (`GCR-01`).
   - **Test 2 (Lines 121–148):** Normal OBI transaction acceptance and completion.
   - **Test 2B (Lines 150–186):** Normal 64-cycle response timeout (`wait_cnt_q == 6'd63 -> ST_TIMEOUT_ERR` returning 1-cycle synthetic error) and early orphan physical response silent drain in `ST_IDLE`.
   - **Test 2C (Lines 188–235):** Ongoing physical transaction interrupted by Warm Reset (`rst_sys_ni == 1'b0`), post-reset blocking of new CPU requests while orphan drain is active, and silent drain of the delayed pre-reset physical response.
   - **Test 3 (Lines 237–274):** Continuous 1,024-cycle orphan watchdog progression under `rst_sys_ni == 1'b0` from 0 to 1023, locking `subsys_dead_locked_q <= 1'b1` on cycle 1,024, and verifying counter saturation at `1023` (no wrap-around/overflow to `0`) on cycle 1,025.
   - **Test 4 (Lines 276–321):** `ST_TRAP` synthetic error response under `subsys_dead_locked_q == 1'b1`, late physical response arriving after deadlock (confirming `host_rvalid_o == 0` and permanent retention of `subsys_dead_locked_q == 1'b1`), and repeated CPU trap requests.
   *(Note: PowerShell test `T4.3` in `scripts/verify_gate_b_rev28d.ps1` is an auxiliary behavioral reference model only and is strictly separated from HDL RTL simulation).*
2. **Inductive Formal Proof:** In [fv/zc_obi_formal_proof.sv](../../fv/zc_obi_formal_proof.sv):
   - Properties `F-OBI-06a/b/c` (lines 101–105, 159–174) prove by $k$-induction ($t=20$) that under `subsys_fatal_fault_irq_o` (`subsys_dead_locked_q == 1'b1`), `ST_IDLE` accepts CPU requests with `periph_phys_req_o == 1'b0`, transitions to `ST_TRAP`, returns synthetic bus error (`host_rvalid_o=1, host_err_o=1, host_rdata_o=0`), and returns to `ST_IDLE`.
   - Properties `F-OBI-02a/b/c` (lines 117–135) prove silent orphan drain and state clearance.
   - Properties `F-OBI-03`, `F-OBI-04`, and `F-OBI-05` (lines 137–157) prove step-induction for watchdog inactivity during normal wait, monotonic $+1$ increment during orphan drain, and deadlock transition at `drain_wdog_cnt_o == 10'd1023`.

---

## 6. M7/M8 Dual-Trace Non-Interference Verification Requirements

### 6.1 Normative Scope
Properties `SVA-M7-01` (NPU Enclave Non-Interference) and `SVA-M8-01` (SRAM Enclave Spatial Isolation) require 2-trace miter equivalence:
$$\forall \tau_1, \tau_2 \in \mathcal{T}: \tau_1 \equiv_{\text{low}} \tau_2 \implies \text{Obs}(\tau_1) \equiv \text{Obs}(\tau_2)$$

### 6.2 Pre-Requisites for Formal Sign-Off
- **Top-Level SoC RTL:** Requires the complete FreeCuli ZC-CORE SoC top module including dual Ibex CPU cores, NPU matrix coprocessor, multi-bank secure SRAM controller, and physical memory protection (PMP) crossbar.
- **Current Gate C Status:** Gate C evaluates individual standalone IP blocks (`zc_aon_post_auth_ctrl`, `zc_spi_flash_firewall`, `zc_obi_subordinate_bridge`).
- **Gate D Prerequisite:** Full-SoC 2-trace formal verification of M7/M8 is tracked as a mandatory sign-off deliverable for **Gate D (Top-Level SoC Verification)** prior to silicon fabrication (`BLOCKED`, `ZC-CLAIM-28/29`).

---

## 7. OTP Multi-Word Physical Transaction Horizon, Mathematical Scope & Step Induction Boundaries

### 7.1 Scope of Formal Inductive Proofs
Under the Gate C formal harness ([fv/zc_otp_formal_proof.sv](../../fv/zc_otp_formal_proof.sv)), BMC and $k$-induction prove the following normative invariants and safety/liveness properties:
1. **Immediate Grant Consumption (`F-OTP-01a`):** A single-word grant in `WSTEP_AUTH_READY` is consumed immediately upon `otp_dai_we_o` assertion, transitioning the subordinate to `WSTEP_WAIT_PHYS_DONE` and deasserting all write strobes.
2. **Structural Write Isolation (`F-OTP-01b`):** Outside `WSTEP_AUTH_READY` during `AUTH_GRANT`, `otp_word_auth_valid_o`, `otp_dai_we_o`, and `otp_auth_word_mask_o` are strictly and unconditionally deasserted (`0`).
3. **Step-Wise Inductive Forward Liveness (`F-OTP-02`):** For any intermediate word $w \in \{\text{WORD\_SVN}, \text{WORD\_COMMIT\_A}\}$, verified readback pulse arrival under normal mode (`!f_val_ctx_seal_b_only_o`) unconditionally advances `expected_word_idx_q` to $w+1$ and re-asserts word authorization in `WSTEP_AUTH_READY`.
4. **Final Word Session Completion (`F-OTP-03a/b/c`):** Verified readback pulse arrival for `OTP_WORD_COMMIT_B` (in either normal or recovery mode) unconditionally transitions the FSM to `AUTH_SESSION_DONE`, clearing all active grants, recovery context, and pending seal flags.
5. **Recovery Mode Write Restriction Invariant:** In recovery mode (`val_ctx_seal_b_only_q == 1`), `expected_word_idx_q` is initialized strictly to `OTP_WORD_COMMIT_B` (2'd2). Because `expected_word_idx_q` has no decrement logic in the entire RTL, `val_ctx_seal_b_only_q == 1` architecturally precludes write authorization for Word 0 (`WORD_SVN`) and Word 1 (`WORD_COMMIT_A`).
6. **Permanent Fatal Lock Sticky Invariant (`F-OTP-05`):** `AUTH_LOCKED_FATAL` permanently persists until Cold Power-On Reset (`rst_aon_por_ni`).

### 7.2 Verification Classification and Modeling Horizon Disclosures

To ensure absolute precision and avoid evidence misclassification (resolving Auditor finding **GCR-08 / P2**), the verification of the 4-phase DAI write/readback sequence and codeword generation is partitioned into four distinct, rigorously defined domains:

1. **Mathematical & Expected Register Equivalence ([tb/tb_zc_otp_fn_equiv.sv](../../tb/tb_zc_otp_fn_equiv.sv)):**
   - **Scope:** Exhaustively tests all 16 slots $\times$ 255 SVNs $\times$ 3 words = 12,240 codeword generations across both standard package functions and `-DYOSYS` shift-add implementations.
   - **Purpose:** Compares the mathematical parity equations against the DUT expected codeword registers (`expected_cw0_q`, `expected_cw1_q`, `expected_cw2_q`).
   - **Auditor Boundary Disclosed:** This testbench is strictly an exhaustive mathematical codeword and DUT register equivalence check. It does **not** execute the multi-step DAI physical write handshake, pulse arrivals (`dai_prog_done_pulse_i`, `dai_rb_done_pulse_i`), or the `AUTH_SESSION_DONE` transition. It is not described as a multi-cycle protocol simulation.

2. **Dedicated End-to-End Cycle-Accurate RTL Protocol Simulation ([tb/tb_zc_otp_protocol_e2e.sv](../../tb/tb_zc_otp_protocol_e2e.sv) & [tb/tb_zc_otp.sv](../../tb/tb_zc_otp.sv)):**
   - **Scope:** Cycle-accurate execution of the full 4-phase DAI protocol (`WSTEP_AUTH_READY` $\to$ `WSTEP_WAIT_PHYS_DONE` $\to$ `WSTEP_WAIT_RB_VERIFY` $\to$ Next Word / `AUTH_SESSION_DONE`).
   - **Coverage Scenarios in `tb_zc_otp_protocol_e2e.sv`:**
     - *Scenario 1 (Normal 3-Word Sequential Commit):* SVN (Word 0) $\to$ COMMIT_A (Word 1) $\to$ COMMIT_B (Word 2) $\to$ clean entry into `AUTH_SESSION_DONE` with write grants deasserted.
     - *Scenario 2 (Recovery 1-Word Commit):* `req_seal_b_only_i` $\to$ Word 2 only $\to$ clean entry into `AUTH_SESSION_DONE` with Words 0 and 1 never authorized.
     - *Scenario 3 (Corrupted Readback Data Fatal Lock):* Corrupted readback data (`^ 22'h00_0001`) triggers immediate `AUTH_LOCKED_FATAL` (and single-cycle grant consumption is verified in every `step_4phase_dai` call).
     - *Scenario 4 (Warm Reset Persistence):* `rst_sys_ni = 0` does not clear `AUTH_LOCKED_FATAL` (FSM remains permanently locked).
     - *Scenario 5 (Cold POR Recovery):* Cold Power-On Reset (`rst_aon_por_ni = 0`) cleanly resets `AUTH_LOCKED_FATAL` to `AUTH_RESET_IDLE`.
     - *Scenario 6 (Session-ID Mismatch Fatal Lock):* Mismatched readback session-ID (`32'hDEAD_9999 != 32'hDEAD_BEEF`) triggers immediate `AUTH_LOCKED_FATAL`.
   - **Simulator Targets:** Verified clean across both Verilator (`sim_otp_e2e`) and Icarus Verilog (`sim_otp_e2e_iv`).

3. **Auxiliary Behavioral Reference Model ([scripts/verify_gate_b_rev28d.ps1](../../scripts/verify_gate_b_rev28d.ps1) Test `T4.1`):**
   - **Scope:** An auxiliary PowerShell structural reference model verifying the state transition logic for normal ($0 \to 1 \to 2 \to \text{AUTH\_SESSION\_DONE}$) and recovery ($2 \to \text{AUTH\_SESSION\_DONE}$) progression.
   - **Auditor Boundary Disclosed:** This is a software behavioral reference model, not a physical macro or RTL simulation.

4. **Gate D Foundry Physical Macro Analog Validation (UNVERIFIED):**
   - **Scope:** Physical antifuse cell programming, high-voltage ($V_{\text{PP}}$) charge pump ramp-up, analog pulse duration ($t_{\text{PROG}} \approx 10\,\mu\text{s}$), thermal soak, and read-sense margin timings.
   - **Sign-Off Boundary:** Formally disclosed as **Gate D UNVERIFIED**. Silicon sign-off is blocked until foundry physical PDK macro integration.

### 7.3 Mathematical Scope & Boundary of `zc_otp_pkg.sv` and `verify_gate_b_rev28d.ps1` (`T1.1`, `T1.2`, `T2.1..T2.5`)
1. **Hsiao $(22,16)$ SECDED Code Distance (`T1.1` & `T1.2`):**
   - `T1.1` exhaustively evaluates the $6 \times 22$ parity-check matrix $H_{\text{full}} = [H_{\text{data}} \mid I_6]$ across all $\binom{22}{1} = 22$ single-column syndromes, $\binom{22}{2} = 231$ two-column XOR sums, and $\binom{22}{3} = 1,540$ three-column XOR sums (1,793 combinations total), confirming zero linear dependencies ($d_{\min} \ge 4$). It then evaluates all $\binom{22}{4} = 7,315$ four-column combinations, identifying exactly **259** four-column XOR sums equal to `6'h00`, establishing strict minimum Hamming distance $d_{\min} = 4$ (Single-Error Correcting, Double-Error Detecting over $\mathbb{F}_2^{22}$).
   - `T1.2` dynamically parses `f_hsiao_parity6` in `rtl/zc_otp_pkg.sv` (lines 57–68), verifies that each of `p[0]..p[5]` is a strict XOR chain of `d[0..15]` terms, and verifies across all 16 unit basis vectors $e_0, \dots, e_{15} \in \mathbb{F}_2^{16}$ that the parsed RTL equations produce the exact columns of `H_DATA`.
2. **Scope of `T2.1` Seal Domain Separation vs. Cryptographic Collision Resistance:**
   - `T2.1` evaluates the finite operational parameter domain of **16 slots ($k \in [0..15]$) $\times$ 255 SVNs ($v \in [1..255]$) = 4,080 $(k, v)$ instances** (12,240 words total).
   - **What `T2.1` Proves:**
     - *Intra-pair mutual exclusivity (same $(k,v)$ instance):* For every fixed $(k, v) \in [0..15] \times [1..255]$, the three 16-bit data words `dSVN = {~v, v}`, `dA = {~(v ^ M_A(k)), v ^ M_A(k)}`, and `dB = {v ^ M_B(k), ~(v ^ M_B(k))}` satisfy `dA != dB`, `dA != dSVN`, and `dB != dSVN` (`coll_AB = 0, coll_ASVN = 0, coll_BSVN = 0`).
     - *Hamming weight bounds (`T2.2..T2.5`):* Every 22-bit codeword across all 12,240 instances has Hamming weight $w_H \in \{8, 10, 12, 14\}$ ($w_{H,\min} = 8$).
   - **What `T2.1` Does NOT Claim (Explicit Boundary):**
     - Across all 4,080 $(k, v)$ instances, `dSVN` takes `uniqSVN = 255` distinct values (since `dSVN` depends only on $v \in [1..255]$), and `dA` and `dB` each take `uniqA = 256` and `uniqB = 256` distinct values (since for each $k$, $v \mapsto v \oplus M_{A/B}(k)$ ranges over an 8-bit byte). Thus, different $(k', v')$ pairs intentionally share 16-bit codeword values across different slots.
     - `f_seal_a` and `f_seal_b` are **linear/affine algebraic error-detection and word-type domain-separation encodings**, **NOT** cryptographic hash functions, MACs, or universal collision-resistant primitives. Nor do these mathematical tests verify physical OTP antifuse cell reliability, charge-pump glitches, or silicon fault-injection resistance (which remain **`UNVERIFIED`, Gate D**).

---

## 8. Sign-Off & Status Matrix

| Audit Item | Verification Method | Status | Sign-Off Authority |
| :--- | :--- | :--- | :--- |
| **GCR-01 (Warm Reset Gating)** | BMC + $k$-Induction + RTL Sim (Verilator/Icarus) | **CLOSED** | Gate C Formal Proof (`F-OBI-07`, `C-OBI-07`) |
| **GCR-05 (Session-ID Observability & Identity)** | Formal Observation Port + Inductive Invariant | **CLOSED** | Gate C Formal Proof (`F-OTP-SESSION-EQ`) |
| **GCR-06 (Source Equivalence & Port Isolation)**| Regression SHA-256 + Yosys Non-Formal Synth Stat | **CLOSED** | PowerShell `T4.5` + CI Step 1 (Class A & B) |
| **GCR-07 (Normative SVA-OTP-06b Mapping)** | Exact Component Mapping + Inductive Invariant | **CLOSED** | Gate C Formal Proof (`F-OTP-02`) |
| **GCR-07 (Modal Recovery Cover Witness)** | Discrete Target SMTBMC Cover (`-c`, $t=20$) | **CLOSED** | Gate C Cover Proofs (`C-OTP-03n`, `C-OTP-03r`) |
| **GCR-08 (Simulation Evidence Classification)** | Precise Separation of Math Equiv, RTL E2E Sim, & PS Model | **CLOSED** | [tb/tb_zc_otp_protocol_e2e.sv](../../tb/tb_zc_otp_protocol_e2e.sv) + `MODELING_LIMITS.md` |
| **GCR-09 (SPI RDSR1 Normative Proof Completeness)** | Strengthened F-SPI-01 + C-SPI-01 (WIP/WEL==00) | **CLOSED** | Gate C Formal Proof (`F-SPI-01`, `C-SPI-01`) |
| **GCR-10 (OBI Watchdog & Cover Inventory)** | 1024-Cycle Sim vs Step Induction + 6 Discrete Covers | **CLOSED** | Gate C Formal Cover (`C-OBI-01`, `C-OBI-02`, `C-OBI-02b`, `C-OBI-03`, `C-OBI-04`, `C-OBI-07`) + [tb/tb_zc_obi.sv](../../tb/tb_zc_obi.sv) + `MODELING_LIMITS.md` |
| **GCR-11 (Claim Inventory & Modeling Limits)** | 1-to-1 33-Claim Inventory + Disclosed Modeling Limits | **CLOSED** | `evidence/gate-c/CONSOLIDATED_NORMATIVE_EVIDENCE_MATRIX.md` |
| **P-1 (F-OBI-03 Restoration)** | $k$-Induction ($t=20$) | **PROVEN** | Gate C Formal Proof (`F-OBI-03`) |
| **P-2 (10 Upgraded SVA Properties)** | Exact Normative Form BMC + $k$-Induction | **PROVEN** | Gate C Formal Proof (`fv/*.sv`) |
| **P-3 (F-OBI-02 3-Part Obligation)** | BMC + $k$-Induction ($t=20$) | **PROVEN** | Gate C Formal Proof (`F-OBI-02a/b/c`) |
| **P-4 (Non-Vacuity Cover Analysis)** | SMTBMC Cover Mode (`-c`, $t=20$) | **REACHABLE** | Gate C Cover Proofs (`C-OBI-*`, `C-SPI-*`, `C-OTP-*`) |
| **P-5 (OTP Dual Implementation Equiv)** | Dual-Compile Verilator & Icarus (12,240 Words) | **SIMULATED** | [tb/tb_zc_otp_fn_equiv.sv](../../tb/tb_zc_otp_fn_equiv.sv) |
| **P-6 (CI Integrity & Artifact Upload)** | GitHub Actions Read-Only Workflow + Artifacts | **ACTIVE** | [.github/workflows/gate-c-hdl-verify.yml](../../.github/workflows/gate-c-hdl-verify.yml) |
| **P-7 (Modeling Limits Documentation)** | Normative Audit Disclosure | **PUBLISHED** | This Document |
| **Full Continuous Physical Transaction Sequence**| Dedicated RTL Sim ([tb/tb_zc_otp_protocol_e2e.sv](../../tb/tb_zc_otp_protocol_e2e.sv)) + Step Induction | **SIMULATED AT RTL** | SIMULATED at digital RTL level; not universally formally proven; analog OTP macro UNVERIFIED |
| **Gate-Level Logic Equivalence Checking (LEC)** | Post-Synthesis Equivalence vs PDK | **DEFERRED TO GATE D** | Class C (Requires Foundry PDK Cell Library) |
| **Gate C Milestone Verdict** | Open-Source HDL & Formal Sign-Off | **PARTIAL / QUALIFIED** | All Gate C audit items (GCR-01 through GCR-11, P-1 through P-7) resolved; Gate C HDL/formal scope signed off; full-SoC M7/M8 and physical silicon deferred to Gate D |
| **Gate D (SoC / STA / Silicon Sign-Off)** | Top-Level Integration & Timing Sign-Off | **UNVERIFIED** | Gate D Milestone (v3.4.0 / v4.0.0 Blocked) |
