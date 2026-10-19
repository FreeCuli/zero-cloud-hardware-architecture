# FREECULI ZC-CORE — Gate C HDL Modeling & Formal Verification Limits

**Document ID:** ZC-CORE-GATE-C-MODELING-LIMITS  
**Revision:** 1.0.0 (Rev. 28D P-7 Sign-Off)  
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

This disclosure satisfies **Finding P-7** of the Gate C Independent Formal Scope Audit.

---

## 2. Asynchronous Reset Abstraction (`async2sync`)

### 2.1 Mechanism and Purpose
In SystemVerilog RTL, the ZC-CORE hardware blocks declare asynchronous active-low reset inputs:
- `rst_aon_por_ni` (Always-On Cold Power-On Reset)
- `rst_sys_ni` (Warm System Reset)

In the Yosys formal pipeline:
```bash
yosys -p "read_verilog -sv -formal ...; prep -top <top> -flatten; async2sync; opt; dffunmap; write_smt2 <file>.smt2"
```
The `async2sync` pass transforms all asynchronous set/reset flip-flops (`$adff`) into synchronous flip-flops (`$dff`) whose reset condition is evaluated synchronously on the active clock edge.

### 2.2 Formal Limits & Silicon Boundary
1. **Clock-Synchronous Domain Restriction:** Formal proofs under `async2sync` prove correctness **if and only if** reset assertion and deassertion occur synchronously with respect to `clk_sys_i` / `clk_aon_i`, or are sampled at discrete clock edges.
2. **Glitch & Pulse Immunity:** Sub-cycle asynchronous reset glitches, voltage brown-out runt pulses shorter than $T_{clk}$, and asynchronous removal/recovery timing violations ($t_{rec}$, $t_{rem}$) cannot be modeled or proven by SMT2-based discrete-time BMC.
3. **Gate D / Silicon Deferral:** Asynchronous reset recovery/removal timing closure, glitch filtering, and metastable synchronizer validation are formally deferred to **Gate D** (Static Timing Analysis via OpenSTA / commercial STA) and physical silicon laboratory characterization.

---

## 3. Environment Assumptions & Free Input Constraints

### 3.1 Non-Deterministic Inputs
In the formal proof harnesses:
- [fv/zc_spi_formal_proof.sv](../../fv/zc_spi_formal_proof.sv)
- [fv/zc_obi_formal_proof.sv](../../fv/zc_obi_formal_proof.sv)
- [fv/zc_otp_formal_proof.sv](../../fv/zc_otp_formal_proof.sv)

All primary inputs that lack an explicit `assume property (...)` directive are treated by the SMT solver as non-deterministic free variables at every cycle $t \in [0..N]$. This provides exhaustive adversarial input fuzzing against unexpected protocol states.

### 3.2 Formal Assumptions Summary Table

| Block | Assumption Signal | Constraint | Architectural Justification |
| :--- | :--- | :--- | :--- |
| **SPI** | `sck_to_iso_o` | `assume property (!(cs_n_to_iso_o && sck_to_iso_o));` | Standard SPI Mode 0/3 physical bus invariant: SCK must remain idle during /CS deselect. |
| **SPI** | `rom_exec_active_i` | Unconstrained (`1'b0` or `1'b1`) | Proves firewall gating holds under both ROM boot and post-boot application phases. |
| **OBI** | `rst_sys_ni` (Steady-State) | `assume property (rst_sys_ni);` in $k$-induction | Decouples steady-state bus invariant induction from reset-edge transients. Reset transitions are verified separately via BMC unrolling and Cover `C-OBI-01`. |
| **OBI** | Primary Bus Inputs (`periph_phys_rvalid_i`, `host_req_i`, `periph_phys_gnt_i`, etc.) | Unconstrained free variables | Treated as non-deterministic free variables at every cycle, providing exhaustive adversarial fuzzing against unexpected bus interleaving. Note: `orphan_drain_active_o` is a DUT internal status output driven by `orphan_active_w`, NOT a free input. |
| **OTP** | `clk_glitch_alert_i` | Zero during normal flow BMC | Fault pins are asserted in discrete BMC paths to verify immediate transition to `AUTH_LOCKED_FATAL`. |
| **OTP** | `post_session_id_i` | Fully unconstrained free variable | Allowed to drift/change arbitrarily across all cycles; proves RTL latched `active_session_id_q` integrity without any `$stable` assumption. |

### 3.3 OTP Shadow Session Tracking & Yosys AST Boundary
- **Yosys AST Hierarchical Path Limitation:** The Yosys AST parser (`read_verilog -sv`) does not support cross-module dot references (`dut.active_session_id_q`) directly inside assertions in formal property expressions.
- **Formal Observation Port & Inductive Invariant:** A formal observation port `f_dut_active_session_id_o` (instantiated under `` `ifdef FORMAL ``) directly exposes internal register `active_session_id_q`. Property `F-OTP-SESSION-EQ` proves by $k$-induction ($t=20$) that shadow register `f_accepted_session_id_q` identically tracks `dut.active_session_id_q` across all reachable states (**GCR-05**).
- **RTL Protocol Simulation:** Dynamic session-ID matching and adversarial mismatch rejection (Scenario 7 immediate transition to `AUTH_LOCKED_FATAL`) are verified in the dedicated end-to-end RTL protocol testbench [tb/tb_zc_otp_protocol_e2e.sv](../../tb/tb_zc_otp_protocol_e2e.sv) and [tb/tb_zc_otp.sv](../../tb/tb_zc_otp.sv). (Note: [tb/tb_zc_otp_fn_equiv.sv](../../tb/tb_zc_otp_fn_equiv.sv) is strictly dedicated to the 12,240-word mathematical codeword and expected-register parity comparison, not protocol session ID tracking).

### 3.4 OBI Post-Drain Disambiguation
- **Simultaneous Request Retention:** Property `F-OBI-02c` does not assume `!host_req_i` in the past cycle, fully verifying simultaneous host request arrival during orphan peripheral response drain in `ST_IDLE`.
- **Response Source Disambiguation:** Distinguishes physical orphan data leak (proven impossible) from legitimate synthetic error delivery (`ST_TRAP` with `host_err_o == 1` and `host_rdata_o == 0x0000_0000`).

---

## 4. Formal Solver Capabilities & SVA Sequence Operators

### 4.1 IEEE 1800 Concurrent SVA Operator Support
Commercial formal verification tools (Cadence JasperGold, Synopsys VC Formal, Siemens Questa Formal) implement the complete IEEE 1800 SystemVerilog Assertion standard, including:
- Sequence overlap and non-overlap: `##[min:max]`
- Throughout operator: `seq throughout expr`
- Non-consecutive repetition: `expr[->1]`
- Local formal variables inside sequences

Open-source Yosys (v0.33) and `yosys-smtbmc` do not synthesize concurrent SVA sequence operators into SMT2 formulas directly. 

### 4.2 Equivalent Hardware Modeling in Gate C
To ensure mathematically rigorous verification under open-source tools without weakening the normative contract:
1. **Hardware Window Observers:** Complex multi-cycle sequences (such as `throughout (dai_rb_done_pulse_i[->1])` in `SVA-OTP-06a`) are implemented via cycle-exact hardware state monitors (`f_win_q` in [fv/zc_otp_formal_proof.sv](../../fv/zc_otp_formal_proof.sv)).
2. **Inductive Lemmas:** $k$-induction divergence is resolved by adding mathematically sound, state-invariant lemmas:
   - `L-OBI-1`: `!orphan_drain_active_o -> (drain_wdog_cnt_o == 0)`
   - `L-OBI-2`: `orphan_drain_active_o -> dut.phys_req_active_q`
   - `L-SPI-1`: `dut.cs_n_prev_q == $past(cs_n_to_iso_o)`
   - `L-OTP-1`: `f_win_q -> (!dut.word_grant_avail_q && (WAIT_PHYS || WAIT_RB || FATAL))`
3. **Canonical Bind Declarations:** The normative commercial SVA files:
   - [fv/zc_otp_sva.sv](../../fv/zc_otp_sva.sv)
   - [fv/zc_spi_sva.sv](../../fv/zc_spi_sva.sv)
   - [fv/zc_obi_sva.sv](../../fv/zc_obi_sva.sv)
   - [fv/zc_m7_m8_ni_sva.sv](../../fv/zc_m7_m8_ni_sva.sv)  
   remain unmodified, preserving the full IEEE 1800 concurrent sequence syntax for commercial formal sign-off during Gate D tape-out.

---

## 5. Watchdog 1,024-Cycle Formal Horizon vs. Simulation

### 5.1 Horizon Analysis
The OBI subordinate orphan watchdog counter counts from `0` to `1023` cycles ($2^{10} = 1024$ cycles):
- A bounded model check of depth $t = 20$ cannot reach cycle 1024 through unrolling.
- Unrolling 1,024 cycles in SMT2 would generate $1,024 \times |\text{AST}|$ bit-vector constraints, exceeding practical SAT solver memory limits.

### 5.2 Complementary Verification Strategy
1. **Digital Simulation Sign-Off (Bounded to RTL Simulation Environment):** Cycle-accurate simulation ([tb/tb_zc_obi.sv](../../tb/tb_zc_obi.sv) Test 2 and PowerShell test `T4.3`) fully executes all 1,024 continuous cycles under `!rst_sys_ni`, confirming that `drain_wdog_cnt_o` increments monotonically from 0 to 1023, transitions `subsys_dead_locked_q` to `1'b1`, and locks the subordinate in `ST_TRAP`. This proof is strictly bounded to the digital RTL simulation domain; physical silicon clock jitter, RC oscillator drift, and analog PVT corners remain deferred to **Gate D**.
2. **Inductive Formal Proof:** In [fv/zc_obi_formal_proof.sv](../../fv/zc_obi_formal_proof.sv):
   - Property `F-OBI-01` proves by $k$-induction ($t=20$) that while in `ST_TRAP`, the subordinate unconditionally asserts `synth_err_rvalid_w` and returns synthetic bus error response without issuing physical requests.
   - Property `F-OBI-03` proves that if an orphan completes prior to timeout, the counter immediately resets to 0 and no fatal interrupt occurs.
   - Properties `F-OBI-04` and `F-OBI-05` prove step-induction for watchdog increment and deadlock transition.

---

## 6. M7/M8 Dual-Trace Non-Interference Verification Requirements

### 6.1 Normative Scope
Properties `SVA-M7-01` (NPU Enclave Non-Interference) and `SVA-M8-01` (SRAM Enclave Spatial Isolation) require 2-trace miter equivalence:
$$\forall \tau_1, \tau_2 \in \mathcal{T}: \tau_1 \equiv_{\text{low}} \tau_2 \implies \text{Obs}(\tau_1) \equiv \text{Obs}(\tau_2)$$

### 6.2 Pre-Requisites for Formal Sign-Off
- **Top-Level SoC RTL:** Requires the complete FreeCuli ZC-CORE SoC top module including dual Ibex CPU cores, NPU matrix coprocessor, multi-bank secure SRAM controller, and physical memory protection (PMP) crossbar.
- **Current Gate C Status:** Gate C evaluates individual standalone IP blocks (`zc_aon_post_auth_ctrl`, `zc_spi_flash_firewall`, `zc_obi_subordinate_bridge`).
- **Gate D Prerequisite:** Full-SoC 2-trace formal verification of M7/M8 is tracked as a mandatory sign-off deliverable for **Gate D (Top-Level SoC Verification)** prior to silicon fabrication.

---

## 7. OTP Multi-Word Physical Transaction Horizon vs. Step Induction Boundaries

### 7.1 Scope of Formal Inductive Proofs
Under the Gate C formal harness ([fv/zc_otp_formal_proof.sv](../../fv/zc_otp_formal_proof.sv)), BMC and $k$-induction prove the following normative invariants and safety/liveness properties:
1. **Immediate Grant Consumption (`F-OTP-01a`):** A single-word grant in `WSTEP_AUTH_READY` is consumed immediately upon `otp_dai_we_o` assertion, transitioning the subordinate to `WSTEP_WAIT_PHYS_DONE` and deasserting all write strobes.
2. **Structural Write Isolation (`F-OTP-01b`):** Outside `WSTEP_AUTH_READY` during `AUTH_GRANT`, `otp_word_auth_valid_o`, `otp_dai_we_o`, and `otp_auth_word_mask_o` are strictly and unconditionally deasserted (`0`).
3. **Step-Wise Inductive Forward Liveness (`F-OTP-02`):** For any intermediate word $w \in \{\text{WORD\_SVN}, \text{WORD\_COMMIT\_A}\}$, verified readback pulse arrival under normal mode (`!f_val_ctx_seal_b_only_o`) unconditionally advances `expected_word_idx_q` to $w+1$ and re-asserts word authorization in `WSTEP_AUTH_READY`.
4. **Final Word Session Completion (`F-OTP-03a/b`):** Verified readback pulse arrival for `OTP_WORD_COMMIT_B` (in either normal or recovery mode) unconditionally transitions the FSM to `AUTH_SESSION_DONE`, clearing all active grants, recovery context, and pending seal flags.
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
     - *Scenario 3 (Immediate Grant Consumption):* Write grant (`otp_word_auth_valid_o`, `otp_dai_we_o`) consumes in exactly one cycle upon `dai_cmd_req_i` acceptance.
     - *Scenario 4 (Data Mismatch Fatal Lock):* Corrupted readback data triggers immediate `AUTH_LOCKED_FATAL`.
     - *Scenario 5 (Warm Reset Persistence):* `!rst_sys_ni = 0` does not clear `AUTH_LOCKED_FATAL` (FSM remains permanently locked).
     - *Scenario 6 (Cold POR Recovery):* Cold Power-On Reset (`!rst_aon_por_ni = 0`) cleanly resets `AUTH_LOCKED_FATAL` to `AUTH_RESET_IDLE`.
     - *Scenario 7 (Session-ID Mismatch Fatal Lock):* Mismatched readback session-ID triggers immediate `AUTH_LOCKED_FATAL`.
   - **Simulator Targets:** Verified clean across both Verilator (`sim_otp_e2e`) and Icarus Verilog (`sim_otp_e2e_iv`).

3. **Auxiliary Behavioral Reference Model ([scripts/verify_gate_b_rev28d.ps1](../../scripts/verify_gate_b_rev28d.ps1) Test `T4.1`):**
   - **Scope:** An auxiliary PowerShell structural reference model verifying the state transition logic for normal ($0 \to 1 \to 2 \to \text{AUTH\_SESSION\_DONE}$) and recovery ($2 \to \text{AUTH\_SESSION\_DONE}$) progression.
   - **Auditor Boundary Disclosed:** This is a software behavioral reference model, not a physical macro or RTL simulation.

4. **Gate D Foundry Physical Macro Analog Validation (UNVERIFIED):**
   - **Scope:** Physical antifuse cell programming, high-voltage ($V_{\text{PP}}$) charge pump ramp-up, analog pulse duration ($t_{\text{PROG}} \approx 10\,\mu\text{s}$), thermal soak, and read-sense margin timings.
   - **Sign-Off Boundary:** Formally disclosed as **Gate D UNVERIFIED**. Silicon sign-off is blocked until foundry physical PDK macro integration.

---

## 8. Sign-Off & Status Matrix

| Audit Item | Verification Method | Status | Sign-Off Authority |
| :--- | :--- | :--- | :--- |
| **GCR-01 (Warm Reset Gating)** | BMC + $k$-Induction + RTL Sim (Verilator/Icarus) | **CLOSED** | Gate C Formal Proof (`F-OBI-04`, `F-OBI-05`) |
| **GCR-05 (Session-ID Observability & Identity)** | Formal Observation Port + Inductive Invariant | **CLOSED** | Gate C Formal Proof (`F-OTP-SESSION-EQ`) |
| **GCR-06 (Source Equivalence & Port Isolation)**| Regression SHA-256 + Yosys Non-Formal Synth Stat | **CLOSED** | PowerShell `T4.5` + CI Step 1 (Class A & B) |
| **GCR-07 (Normative SVA-OTP-06b Mapping)** | Exact Component Mapping + Inductive Invariant | **CLOSED** | Gate C Formal Proof (`F-OTP-02`) |
| **GCR-07 (Modal Recovery Cover Witness)** | Discrete Target SMTBMC Cover (`-c`, $t=20$) | **CLOSED** | Gate C Cover Proofs (`C-OTP-03n`, `C-OTP-03r`) |
| **GCR-08 (Simulation Evidence Classification)** | Precise Separation of Math Equiv, RTL E2E Sim, & PS Model | **CLOSED** | [tb/tb_zc_otp_protocol_e2e.sv](../../tb/tb_zc_otp_protocol_e2e.sv) + `MODELING_LIMITS.md` |
| **GCR-09 (SPI RDSR1 Normative Proof Completeness)** | Strengthened F-SPI-01 + C-SPI-01 (WIP/WEL==00) | **CLOSED** | Gate C Formal Proof (`F-SPI-01`, `C-SPI-01`) |
| **GCR-10 (OBI Watchdog & Cover Inventory)** | 1024-Cycle Sim vs Step Induction + 6 Discrete Covers | **CLOSED** | [tb/tb_zc_obi.sv](../../tb/tb_zc_obi.sv) + Gate C Formal Cover (`C-OBI-01..07`) + `MODELING_LIMITS.md` |
| **GCR-11 (Claim Inventory & Modeling Limits)** | 1-to-1 33-Claim Inventory + Disclosed Modeling Limits | **CLOSED** | `evidence/gate-c/CONSOLIDATED_NORMATIVE_EVIDENCE_MATRIX.md` |
| **P-1 (F-OBI-03 Restoration)** | $k$-Induction ($t=20$) with `L-OBI-1` | **PROVEN** | Gate C Formal Proof (`F-OBI-03`) |
| **P-2 (10 Upgraded SVA Properties)** | Exact Normative Form BMC + $k$-Induction | **PROVEN** | Gate C Formal Proof (`fv/*.sv`) |
| **P-3 (F-OBI-02 3-Part Obligation)** | BMC + $k$-Induction ($t=20$) | **PROVEN** | Gate C Formal Proof (`F-OBI-02a/b/c`) |
| **P-4 (Non-Vacuity Cover Analysis)** | SMTBMC Cover Mode (`-c`, $t=20$) | **REACHABLE** | Gate C Cover Proofs (`C-OBI-*`, `C-SPI-*`, `C-OTP-*`) |
| **P-5 (OTP Dual Implementation Equiv)** | Dual-Compile Verilator & Icarus (12,240 Words) | **SIMULATED** | [tb/tb_zc_otp_fn_equiv.sv](../../tb/tb_zc_otp_fn_equiv.sv) |
| **P-6 (CI Integrity & Artifact Upload)** | GitHub Actions Read-Only Workflow + Artifacts | **ACTIVE** | [.github/workflows/gate-c-hdl-verify.yml](../../.github/workflows/gate-c-hdl-verify.yml) |
| **P-7 (Modeling Limits Documentation)** | Normative Audit Disclosure | **PUBLISHED** | This Document |
| **Full Continuous Physical Transaction Sequence**| Dedicated RTL Sim ([tb/tb_zc_otp_protocol_e2e.sv](../../tb/tb_zc_otp_protocol_e2e.sv)) + Step Induction | **CLOSED AT RTL** | Proven at RTL level; Analog Macro Physics Deferred to Gate D |
| **Gate-Level Logic Equivalence Checking (LEC)** | Post-Synthesis Equivalence vs PDK | **DEFERRED TO GATE D** | Class C (Requires Foundry PDK Cell Library) |
| **Gate C Milestone Verdict** | Open-Source HDL & Formal Sign-Off | **PARTIAL / QUALIFIED** | All Gate C audit items (GCR-01 through GCR-11, P-1 through P-7) resolved; Gate C HDL/formal scope signed off; full-SoC M7/M8 and physical silicon deferred to Gate D |
| **Gate D (SoC / STA / Silicon Sign-Off)** | Top-Level Integration & Timing Sign-Off | **UNVERIFIED** | Gate D Milestone (v3.4.0 / v4.0.0 Blocked) |

