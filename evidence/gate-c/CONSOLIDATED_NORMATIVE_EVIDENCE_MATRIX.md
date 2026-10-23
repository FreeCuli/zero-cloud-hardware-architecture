# FREECULI ZC-CORE — Gate C Consolidated Normative Evidence Matrix
## Rev. 2.0.0 — Strict 1-to-1 Traceable Security Claim Inventory & Formal Audit

**Document ID:** ZC-CORE-GATE-C-CONSOLIDATED-EVIDENCE-MATRIX
**Revision:** 2.0.0 (Post-GCR-09 / GCR-10 / GCR-11 Alignment)
**Milestone:** Gate C (Open-Source RTL & Formal Verification Scope Sign-Off)
**Repository:** `https://github.com/FreeCuli/zero-cloud-hardware-architecture`
**Working Branch:** `gate-c/formal-scope-audit`
**Verified Git Commit:** `eb3ed5ad9fddb551506d43d2692bd040843af06f`
**Verified CI Run:** [Run #45 (ID: 39321501893)](https://github.com/FreeCuli/zero-cloud-hardware-architecture/actions/runs/39321501893) — **SUCCESS** (13/13 Steps Pass)
**Gate Status (Gate C Kapanışında):** **Gate C PARTIAL / QUALIFIED** | **Gate D UNVERIFIED** | **RELEASE BLOCKED / DO NOT MERGE (Tarihsel Kapanış Kaydı)**

> [!NOTE]
> **Tarihsel Kanıt Matrisi Kaydı:** Bu matris, Gate C kapanışındaki (`eb3ed5a`, Run #45) doğrulanmış iddiaların tarihsel durumunu kaydeder.

---

### 1. Normative Taxonomy Definition

To eliminate any ambiguity between mathematical proof, simulation coverage, time-bounded induction, and deferred physical silicon sign-off, every architectural security property and claim is strictly classified into one of five mutually exclusive normative categories:

| Status Code | Definition & Normative Meaning | Total Count |
| :--- | :--- | :---: |
| **`PROVEN`** | Formally proven as a universal or $k$-inductive invariant ($t=20$) in the open-source formal toolchain (Yosys + yosys-smtbmc + Z3) without unproven assumptions. | **19** |
| **`SIMULATED`** | Cycle-accurate dynamic simulation verified across all defined sequences and fault injections under Verilator and Icarus Verilog (`tb/` testbenches). | **4** |
| **`BOUNDED`** | Formal proof or reachability witness subject to a finite horizon constraint ($t \le 20$), clock-synchronous abstraction (`async2sync`), or step-induction boundary. | **4** |
| **`BLOCKED`** | Top-level SoC architectural claim that cannot be proven on isolated IP blocks due to missing full-SoC integration RTL (e.g., Ibex CPU + NPU + SRAM crossbar). | **2** |
| **`UNVERIFIED`** | Physical analog silicon constraints (antifuse programming pulses, charge pumps, foundry PDK LEC, STA timing corners) deferred strictly to **Gate D**. | **4** |
| **TOTAL** | **Consolidated Single-Entry Claims Inventory** | **33** |

---

### 2. Complete 1-to-1 Unique Claim Inventory (Claims 01 to 33)

#### Category A: PROVEN Formal Inductive Invariants & Mathematical Proofs (19 Claims)

| Claim ID | Normative Property | Module & Source File | Assertion Name | Proof Method & Horizon | Classification | Disclosed Modeling Limits |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **ZC-CLAIM-01** | SPI RDSR1 Reconciler: Transition from `UPD_UNSYNC_RESET` to `UPD_IDLE` strictly requires 05h RDSR1 frame, rising /CS with SCK=0, bit 15 sampled, `SR1[1:0]==2'b00` (WIP=0, WEL=0), and no faults (**GCR-09**). | `zc_spi_flash_firewall.sv`<br>[fv/zc_spi_formal_proof.sv](../../fv/zc_spi_formal_proof.sv) | `F-SPI-01`<br>(`SVA-SPI-2c`) | $k$-Induction ($t=20$) | **`PROVEN`** | Clock-synchronous domain (`async2sync`). |
| **ZC-CLAIM-02** | SPI WRDI Reset Stay: 04h (WRDI) in `UPD_UNSYNC_RESET` unconditionally maintains `UPD_UNSYNC_RESET`. | `zc_spi_flash_firewall.sv`<br>[fv/zc_spi_formal_proof.sv](../../fv/zc_spi_formal_proof.sv) | `F-SPI-01b` | $k$-Induction ($t=20$) | **`PROVEN`** | Fully verified at RTL level. |
| **ZC-CLAIM-03** | SPI Bank B Commit Gate: `bank_b_commit_ready_o` strictly requires independent ROM cryptographic verification (`rom_img_verif_valid_i == 1`). | `zc_spi_flash_firewall.sv`<br>[fv/zc_spi_formal_proof.sv](../../fv/zc_spi_formal_proof.sv) | `F-SPI-02`<br>(`SVA-SPI-2d`) | Combinational Invariant ($t=20$) | **`PROVEN`** | Fully verified at RTL level. |
| **ZC-CLAIM-04** | SPI Physical /CS Gating: Primary frame completion strobes assert only on rising /CS while `SCK == 0`. | `zc_spi_flash_firewall.sv`<br>[fv/zc_spi_formal_proof.sv](../../fv/zc_spi_formal_proof.sv) | `F-SPI-03`<br>(`SVA-SPI-3`) | $k$-Induction ($t=20$) | **`PROVEN`** | Standard SPI Mode 0/3 invariant. |
| **ZC-CLAIM-05** | SPI Secondary Fault Fail-Closed: `fault_high_sec_i == 1` unconditionally forces Flash /CS high (`cs_n_flash_eff_o == 1`). | `zc_spi_flash_firewall.sv`<br>[fv/zc_spi_formal_proof.sv](../../fv/zc_spi_formal_proof.sv) | `F-SPI-04`<br>(`SVA-SPI-4`) | Combinational Invariant ($t=20$) | **`PROVEN`** | Fully verified at RTL level. |
| **ZC-CLAIM-06** | OBI Single Response Delivery: Delivered response in `ST_WAIT_RVALID`, `ST_TIMEOUT_ERR`, or `ST_TRAP` returns bridge to `ST_IDLE` with `rvalid=0` (no double response). | `zc_obi_subordinate_bridge.sv`<br>[fv/zc_obi_formal_proof.sv](../../fv/zc_obi_formal_proof.sv) | `F-OBI-01`<br>(`SVA-L0-10a`) | $k$-Induction ($t=20$) | **`PROVEN`** | Fully verified at RTL level. |
| **ZC-CLAIM-07** | OBI Orphan Silent Drain (Arrival Cycle): In `ST_IDLE`, arriving peripheral response without host request is silently drained (`host_rvalid_o == 0`). | `zc_obi_subordinate_bridge.sv`<br>[fv/zc_obi_formal_proof.sv](../../fv/zc_obi_formal_proof.sv) | `F-OBI-02a`<br>(`SVA-L0-10b` Part 1) | $k$-Induction ($t=20$) | **`PROVEN`** | Part 1 of 3-part obligation. |
| **ZC-CLAIM-08** | OBI Orphan State Clearance: Arriving orphan response in `ST_IDLE` clears `phys_req_active_q` on following cycle. | `zc_obi_subordinate_bridge.sv`<br>[fv/zc_obi_formal_proof.sv](../../fv/zc_obi_formal_proof.sv) | `F-OBI-02b`<br>(`SVA-L0-10b` Part 2) | $k$-Induction ($t=20$) | **`PROVEN`** | Part 2 of 3-part obligation. |
| **ZC-CLAIM-09** | OBI Orphan Leak Prevention: Cycle following orphan drain produces no delayed synthetic or stale `rvalid` to CPU. | `zc_obi_subordinate_bridge.sv`<br>[fv/zc_obi_formal_proof.sv](../../fv/zc_obi_formal_proof.sv) | `F-OBI-02c`<br>(`SVA-L0-10b` Part 3) | $k$-Induction ($t=20$) | **`PROVEN`** | Part 3 of 3-part obligation. |
| **ZC-CLAIM-10** | OBI Normal CPU Wait Watchdog Inactivity: Normal CPU wait in `ST_WAIT_RVALID` without orphan never increments watchdog (`drain_wdog_cnt_o == 0`). | `zc_obi_subordinate_bridge.sv`<br>[fv/zc_obi_formal_proof.sv](../../fv/zc_obi_formal_proof.sv) | `F-OBI-03`<br>(`SVA-L0-12a` / P-1) | $k$-Induction ($t=20$) with `L-OBI-1` | **`PROVEN`** | Inductively proven with lemma `L-OBI-1`. |
| **ZC-CLAIM-11** | OBI Deadlock Trap Synthetic Error: When `subsys_dead_locked_q == 1`, accepted request blocks physical bus (`periph_phys_req_o == 0`), enters `ST_TRAP`, and returns 1-cycle synthetic error (`rvalid=1, err=1, rdata=0`). | `zc_obi_subordinate_bridge.sv`<br>[fv/zc_obi_formal_proof.sv](../../fv/zc_obi_formal_proof.sv) | `F-OBI-06a/b/c`<br>(`SVA-L0-13c`) | Step-Wise Inductive Invariant ($t=20$) | **`PROVEN`** | Fully verified at RTL level. |
| **ZC-CLAIM-12** | OBI Warm Reset Gating: While `!rst_sys_ni == 0`, `host_req_ready_o`, `periph_phys_req_o`, and `host_rvalid_o` are strictly 0. | `zc_obi_subordinate_bridge.sv`<br>[fv/zc_obi_formal_proof.sv](../../fv/zc_obi_formal_proof.sv) | `F-OBI-07`<br>(`GCR-01` / `SVA-L0-14`) | Combinational Invariant ($t=20$) | **`PROVEN`** | Clock-synchronous domain (`async2sync`). |
| **ZC-CLAIM-13** | OTP Single-Cycle Grant Consumption: Active grant in `WSTEP_AUTH_READY` consumes immediately upon `otp_dai_we_o` assertion (drops to 0 within 1 cycle). | `zc_aon_post_auth_ctrl.sv`<br>[fv/zc_otp_formal_proof.sv](../../fv/zc_otp_formal_proof.sv) | `F-OTP-01a`<br>(`SVA-OTP-06a` Part 1) | $k$-Induction ($t=20$) | **`PROVEN`** | Fully verified at RTL level. |
| **ZC-CLAIM-14** | OTP Structural Write Isolation: Outside `WSTEP_AUTH_READY` during `AUTH_GRANT`, `otp_word_auth_valid_o`, `otp_dai_we_o`, and `otp_auth_word_mask_o` are strictly 0. | `zc_aon_post_auth_ctrl.sv`<br>[fv/zc_otp_formal_proof.sv](../../fv/zc_otp_formal_proof.sv) | `F-OTP-01b`<br>(`SVA-OTP-06a` Part 2) | Combinational Invariant ($t=20$) | **`PROVEN`** | Fully verified at RTL level. |
| **ZC-CLAIM-15** | OTP Step-Wise Intermediate Word Advance: In normal mode (`!f_val_ctx_seal_b_only_o`), verified readback of Word 0 or 1 advances `expected_word_idx_q` by +1 and re-opens grant in `WSTEP_AUTH_READY`. | `zc_aon_post_auth_ctrl.sv`<br>[fv/zc_otp_formal_proof.sv](../../fv/zc_otp_formal_proof.sv) | `F-OTP-02`<br>(`GCR-07` / `SVA-OTP-06b`) | $k$-Induction ($t=20$) | **`PROVEN`** | Step-wise inductive liveness; does not prove monolithic physical pulse zinciri from cycle 0. |
| **ZC-CLAIM-16** | OTP Terminal Session Completion: Verified readback of Word 2 transitions FSM to `AUTH_SESSION_DONE`, clearing all grants, masks, and recovery flags. | `zc_aon_post_auth_ctrl.sv`<br>[fv/zc_otp_formal_proof.sv](../../fv/zc_otp_formal_proof.sv) | `F-OTP-03a/b/c`<br>(`SVA-OTP-06c`) | $k$-Induction ($t=20$) | **`PROVEN`** | Verified for normal and recovery flows. |
| **ZC-CLAIM-17** | OTP Mismatched Readback Fatal Lock: Any unverified, out-of-context, ECC error, or data/slot/word mismatched readback in `WSTEP_WAIT_RB_VERIFY` immediately forces FSM to `AUTH_LOCKED_FATAL`. | `zc_aon_post_auth_ctrl.sv`<br>[fv/zc_otp_formal_proof.sv](../../fv/zc_otp_formal_proof.sv) | `F-OTP-04`, `F-OTP-04b`<br>(`SVA-OTP-07`) | $k$-Induction ($t=20$) | **`PROVEN`** | Fully verified at RTL level. |
| **ZC-CLAIM-18** | OTP Permanent Fatal Lock Sticky Invariant: `AUTH_LOCKED_FATAL` permanently persists across warm reset `!rst_sys_ni`; clears only on Cold POR (`!rst_aon_por_ni`). | `zc_aon_post_auth_ctrl.sv`<br>[fv/zc_otp_formal_proof.sv](../../fv/zc_otp_formal_proof.sv) | `F-OTP-05`<br>(`SVA-OTP-08`) | $k$-Induction ($t=20$) | **`PROVEN`** | Fully verified at RTL level. |
| **ZC-CLAIM-19** | OTP Session-ID Observability & Identity Invariant: Shadow session register `f_accepted_session_id_q` identically tracks DUT internal `active_session_id_q` via formal observation port. | `zc_aon_post_auth_ctrl.sv`<br>[fv/zc_otp_formal_proof.sv](../../fv/zc_otp_formal_proof.sv) | `F-OTP-SESSION-EQ`<br>(`GCR-05`) | $k$-Induction ($t=20$) | **`PROVEN`** | Formal port gated under `` `ifdef FORMAL ``. Verified non-leaking in synthesis (`GCR-06`). |

---

#### Category B: SIMULATED Cycle-Accurate Dynamic HDL Simulations (4 Claims)

| Claim ID | Normative Property | Module & Source File | Testbench Suite | Executed Horizon | Classification | Disclosed Modeling Limits |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **ZC-CLAIM-20** | OTP Dedicated End-to-End RTL Protocol Simulation: Unbroken cycle-accurate execution of normal 3-word commit ($0 \to 1 \to 2 \to \text{DONE}$), recovery 1-word commit ($2 \to \text{DONE}$), grant consumption, readback corruption fatal lock, session-ID mismatch fatal lock, warm reset stickiness, and cold POR recovery. | `zc_aon_post_auth_ctrl.sv`<br>[tb/tb_zc_otp_protocol_e2e.sv](../../tb/tb_zc_otp_protocol_e2e.sv) | Scenarios 1 to 7 (`sim_otp_e2e`, `sim_otp_e2e_iv`) | ~400 continuous cycles | **`SIMULATED`** | Digital RTL protocol simulation with handshakes; physical analog cell programming pulses modeled via completion signals. |
| **ZC-CLAIM-21** | OTP Exhaustive Codeword & DUT Register Equivalence: Dual-compiled Hsiao $(22,16)$ parity and codeword computation match identically between DUT registers (`expected_cw*_q`) and package functions across all 16 slots $\times$ 255 SVNs $\times$ 3 words = 12,240 words under standard and `-DYOSYS` builds. | `zc_aon_post_auth_ctrl.sv`<br>[tb/tb_zc_otp_fn_equiv.sv](../../tb/tb_zc_otp_fn_equiv.sv) | Full Suite (`sim_otp_equiv_pkg`, `sim_otp_equiv_yosys`, `sim_otp_equiv_iv`) | 12,240 words evaluated | **`SIMULATED`** | Strictly mathematical and expected-register equivalence; does not execute DAI physical write/readback handshake. |
| **ZC-CLAIM-22** | SPI 3-Layer Event Separation Dynamic Simulation: 04h WRDI stay-in-reset, 05h RDSR1 transition, and Bank B commit gating cycle-accurate dynamic simulation. | `zc_spi_flash_firewall.sv`<br>[tb/tb_zc_spi.sv](../../tb/tb_zc_spi.sv) | Verilator & Icarus Suite (`sim_spi`, `sim_spi_iv`) | 100+ cycles | **`SIMULATED`** | Verified clean under multiple simulators in CI. |
| **ZC-CLAIM-23** | OBI Warm Reset, Watchdog Timeout, and ST_TRAP Dynamic Simulation: Warm reset request blocking, watchdog counter progression, and synthetic error response under deadlock. | `zc_obi_subordinate_bridge.sv`<br>[tb/tb_zc_obi.sv](../../tb/tb_zc_obi.sv) | Verilator & Icarus Suite (`sim_obi`, `sim_obi_iv`) | 1,500+ cycles | **`SIMULATED`** | Verified clean under multiple simulators in CI. |

---

#### Category C: BOUNDED Formal Cover Witnesses & Horizon Limits (4 Claims)

| Claim ID | Normative Property | Module & Source File | Proof Directives | Verified Horizon | Classification | Disclosed Modeling Limits |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **ZC-CLAIM-24** | SPI 6/6 Non-Vacuity Cover Witness Suite: Discrete reachability of `UPD_IDLE` via valid RDSR1 (`C-SPI-01`), WRDI in reset (`C-SPI-01b`), Bank-B commit active (`C-SPI-02`), WREN transition (`C-SPI-03a`), RDSR1 strobe (`C-SPI-03b`), and secondary fault fail-closed (`C-SPI-04`). | `zc_spi_flash_firewall.sv`<br>[fv/zc_spi_formal_proof.sv](../../fv/zc_spi_formal_proof.sv) | `C-SPI-01`, `01b`, `02`, `03a`, `03b`, `04` | SMT BMC Depth $t \le 20$ (6/6 REACHABLE) | **`BOUNDED`** | Proof of reachability; does not constitute universal invariant. |
| **ZC-CLAIM-25** | OBI 6/6 Non-Vacuity Cover Witness Suite: Discrete reachability of normal response (`C-OBI-01`), orphan drain (`C-OBI-02`), simultaneous CPU request during drain (`C-OBI-02b`), normal CPU wait (`C-OBI-03`), watchdog progression step (`C-OBI-04`), and warm reset blocking (`C-OBI-07`) (**GCR-10**). | `zc_obi_subordinate_bridge.sv`<br>[fv/zc_obi_formal_proof.sv](../../fv/zc_obi_formal_proof.sv) | `C-OBI-01`, `02`, `02b`, `03`, `04`, `07` (Exactly 6 covers) | SMT BMC Depth $t \le 20$ (6/6 REACHABLE) | **`BOUNDED`** | Proof of reachability; does not constitute universal invariant. Formally records 6 discrete covers. |
| **ZC-CLAIM-26** | OTP 7/7 Non-Vacuity Cover Witness Suite: Discrete reachability of write authorization active (`C-OTP-01`), intermediate word advance (`C-OTP-02`), normal session complete (`C-OTP-03n`), recovery session complete (`C-OTP-03r`), fatal lock entry (`C-OTP-04`), fatal lock persistence (`C-OTP-05`), and hijacked session rejection (`C-OTP-06`). | `zc_aon_post_auth_ctrl.sv`<br>[fv/zc_otp_formal_proof.sv](../../fv/zc_otp_formal_proof.sv) | `C-OTP-01`, `02`, `03n`, `03r`, `04`, `05`, `06` (7 covers) | SMT BMC Depth $t \le 20$ (7/7 REACHABLE) | **`BOUNDED`** | Proof of reachability; does not constitute universal invariant. Proves both normal and recovery modes reach `DONE`. |
| **ZC-CLAIM-27** | OBI 1,024-Cycle Continuous Watchdog Timeout Horizon Boundary: Continuous temporal progression of watchdog from 0 to 1023 under continuous `!rst_sys_ni == 0`, leading to `subsys_dead_locked_q = 1` and `ST_TRAP` (**GCR-10**). | `zc_obi_subordinate_bridge.sv`<br>[fv/zc_obi_formal_proof.sv](../../fv/zc_obi_formal_proof.sv) & [tb/tb_zc_obi.sv](../../tb/tb_zc_obi.sv) | Formal: Step Induction (`F-OBI-04`, `F-OBI-05`, $k=20$); Sim: Test 2 in `tb_zc_obi.sv` & `T4.3` in `verify_gate_b_rev28d.ps1` | SMT Formal Step Induction Horizon ($t \le 20$); Continuous 1,024 Cycles via Digital RTL Simulation | **`BOUNDED`** | **Disclosed Formal Horizon Bound:** Unrolling 1,024 cycles in SMT formal exceeds practical solver depth limits; local transitions are proven via step induction ($k=20$), while monolithic 1,024-cycle continuity from 0 to 1023 is verified via dynamic simulation (`tb_zc_obi.sv` Test 2). |

---

#### Category D: BLOCKED Top-Level Full-SoC Architectural Scope (2 Claims)

| Claim ID | Normative Property | Architecture Specification | Target Formal Methodology | Current Status | Classification | Blocking Technical Prerequisite |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **ZC-CLAIM-28** | Full-SoC NPU Enclave Non-Interference: 2-trace miter equivalence proving zero timing or state interference between isolated NPU enclave and host software ($\tau_1 \equiv_{\text{low}} \tau_2 \implies \text{Obs}(\tau_1) \equiv \text{Obs}(\tau_2)$). | Architecture Spec §7.1 (`SVA-M7-01`) | 2-trace formal miter equivalence proof | **BLOCKED** | **`BLOCKED`** | Requires full SoC RTL top module integrating dual Ibex CPU cores, NPU coprocessor, crossbar, and PMP. Cannot be executed on isolated IP blocks. Tracked for **Gate D**. |
| **ZC-CLAIM-29** | Full-SoC SRAM Enclave Spatial Isolation: 2-trace miter equivalence proving hardware-enforced spatial isolation of secure SRAM enclave from peripheral DMA. | Architecture Spec §7.2 (`SVA-M8-01`) | 2-trace formal miter equivalence proof | **BLOCKED** | **`BLOCKED`** | Requires full SoC crossbar and multi-bank secure SRAM controller RTL. Tracked for **Gate D**. |

---

#### Category E: UNVERIFIED Physical Silicon & Macro Sign-Off (4 Claims)

| Claim ID | Physical Domain | Requirement Description | Target Verification Methodology | Current Status | Classification | Sign-Off Authority & Boundary Disclosure |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **ZC-CLAIM-30** | Physical Antifuse Charge Pump Ramp: Analog high-voltage ($V_{\text{PP}} > 1.8\,\text{V}$) charge pump regulation and settling time prior to bit-cell programming. | Foundry OTP Spec §3.1 (`PHY-OTP-01`) | SPICE / Mixed-Signal Analog Simulation + Silicon Characterization | **UNVERIFIED** | **`UNVERIFIED`** | Deferred to **Gate D**. Requires foundry physical PDK macro cell model. |
| **ZC-CLAIM-31** | Physical Bit-Cell Programming Pulse Duration & Soak: Antifuse breakdown pulse duration ($t_{\text{PROG}} \approx 10\,\mu\text{s}$) and post-write soak margins. | Foundry OTP Spec §3.2 (`PHY-OTP-02`) | Physical Silicon Laboratory Characterization | **UNVERIFIED** | **`UNVERIFIED`** | Deferred to **Gate D**. Requires physical test chip fabrication. |
| **ZC-CLAIM-32** | Gate-Level Logic Equivalence Checking (LEC): Post-synthesis gate-level netlist equivalence against foundry standard cell library. | ASIC Flow Spec §4 (`PHY-LEC-01`) | Commercial LEC (Synopsys Formality / Cadence Conformal) | **UNVERIFIED** | **`UNVERIFIED`** | Deferred to **Gate D**. Requires commercial EDA licenses and NDA foundry PDK. |
| **ZC-CLAIM-33** | Static Timing Analysis (STA) Reset Removal/Recovery: Timing closure on asynchronous reset deassertion edges ($t_{\text{rem}}, t_{\text{rec}}$) under PVT corners. | ASIC Flow Spec §5 (`PHY-STA-01`) | Static Timing Analysis (OpenSTA / PrimeTime) | **UNVERIFIED** | **`UNVERIFIED`** | Deferred to **Gate D**. Open-source formal BMC operates under synchronous `async2sync` abstraction. |

---

### 3. Verification Inventory Summary

```
========================================================================================
 FREECULI ZC-CORE GATE C — COMPLETE 1-TO-1 CLAIM INVENTORY VERDICT
========================================================================================
 Total Claims Tracked: 33 (ZC-CLAIM-01 through ZC-CLAIM-33)
----------------------------------------------------------------------------------------
 [PROVEN]     Formal Inductive Invariants & Symbolic Proofs : 19 (ZC-CLAIM-01 .. 19)
 [SIMULATED]  Cycle-Accurate Dynamic HDL Simulations        :  4 (ZC-CLAIM-20 .. 23)
 [BOUNDED]    Bounded Cover Witnesses & Modeling Horizons   :  4 (ZC-CLAIM-24 .. 27)
 [BLOCKED]    Full-SoC 2-Trace Miter Integration Properties :  2 (ZC-CLAIM-28 .. 29)
 [UNVERIFIED] Physical Silicon Macro / STA / LEC Parameters :  4 (ZC-CLAIM-30 .. 33)
========================================================================================
 Gate C Verdict: PARTIAL / QUALIFIED (HDL & Open-Source Formal Scope Closed)
 Gate D Verdict: UNVERIFIED (Full-SoC M7/M8 Miter, Foundry Macro & STA Pending Tape-Out)
 Release Status: RELEASE BLOCKED / DO NOT MERGE
========================================================================================
```
