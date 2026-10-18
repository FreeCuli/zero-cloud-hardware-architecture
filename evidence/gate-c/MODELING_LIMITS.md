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
- [fv/zc_spi_formal_proof.sv](file:///C:/Users/ajiba/rentalais/zero-cloud-hardware-architecture/fv/zc_spi_formal_proof.sv)
- [fv/zc_obi_formal_proof.sv](file:///C:/Users/ajiba/rentalais/zero-cloud-hardware-architecture/fv/zc_obi_formal_proof.sv)
- [fv/zc_otp_formal_proof.sv](file:///C:/Users/ajiba/rentalais/zero-cloud-hardware-architecture/fv/zc_otp_formal_proof.sv)

All primary inputs that lack an explicit `assume property (...)` directive are treated by the SMT solver as non-deterministic free variables at every cycle $t \in [0..N]$. This provides exhaustive adversarial input fuzzing against unexpected protocol states.

### 3.2 Formal Assumptions Summary Table

| Block | Assumption Signal | Constraint | Architectural Justification |
| :--- | :--- | :--- | :--- |
| **SPI** | `sck_to_iso_o` | `assume property (!(cs_n_to_iso_o && sck_to_iso_o));` | Standard SPI Mode 0/3 physical bus invariant: SCK must remain idle during /CS deselect. |
| **SPI** | `rom_exec_active_i` | Unconstrained (`1'b0` or `1'b1`) | Proves firewall gating holds under both ROM boot and post-boot application phases. |
| **OBI** | `rst_sys_ni` (Steady-State) | `assume property (rst_sys_ni);` in $k$-induction | Decouples steady-state bus invariant induction from reset-edge transients. Reset transitions are verified separately via BMC unrolling and Cover `C-OBI-01`. |
| **OBI** | `orphan_drain_active_o` | Unconstrained free variable | Solves inductive step across all possible pipeline depths without over-constraining the subordinate. |
| **OTP** | `clk_glitch_alert_i` | Zero during normal flow BMC | Fault pins are asserted in discrete BMC paths to verify immediate transition to `AUTH_LOCKED_FATAL`. |

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
1. **Hardware Window Observers:** Complex multi-cycle sequences (such as `throughout (dai_rb_done_pulse_i[->1])` in `SVA-OTP-06a`) are implemented via cycle-exact hardware state monitors (`f_win_q` in [fv/zc_otp_formal_proof.sv](file:///C:/Users/ajiba/rentalais/zero-cloud-hardware-architecture/fv/zc_otp_formal_proof.sv)).
2. **Inductive Lemmas:** $k$-induction divergence is resolved by adding mathematically sound, state-invariant lemmas:
   - `L-OBI-1`: `!orphan_drain_active_o -> (drain_wdog_cnt_o == 0)`
   - `L-OBI-2`: `orphan_drain_active_o -> dut.phys_req_active_q`
   - `L-SPI-1`: `dut.cs_n_prev_q == $past(cs_n_to_iso_o)`
   - `L-OTP-1`: `f_win_q -> (!dut.word_grant_avail_q && (WAIT_PHYS || WAIT_RB || FATAL))`
3. **Canonical Bind Declarations:** The normative commercial SVA files:
   - [fv/zc_otp_sva.sv](file:///C:/Users/ajiba/rentalais/zero-cloud-hardware-architecture/fv/zc_otp_sva.sv)
   - [fv/zc_spi_sva.sv](file:///C:/Users/ajiba/rentalais/zero-cloud-hardware-architecture/fv/zc_spi_sva.sv)
   - [fv/zc_obi_sva.sv](file:///C:/Users/ajiba/rentalais/zero-cloud-hardware-architecture/fv/zc_obi_sva.sv)
   - [fv/zc_m7_m8_ni_sva.sv](file:///C:/Users/ajiba/rentalais/zero-cloud-hardware-architecture/fv/zc_m7_m8_ni_sva.sv)  
   remain unmodified, preserving the full IEEE 1800 concurrent sequence syntax for commercial formal sign-off during Gate D tape-out.

---

## 5. Watchdog 1,024-Cycle Formal Horizon vs. Simulation

### 5.1 Horizon Analysis
The OBI subordinate orphan watchdog counter counts from `0` to `1023` cycles ($2^{10} = 1024$ cycles):
- A bounded model check of depth $t = 20$ cannot reach cycle 1024 through unrolling.
- Unrolling 1,024 cycles in SMT2 would generate $1,024 \times |\text{AST}|$ bit-vector constraints, exceeding practical SAT solver memory limits.

### 5.2 Complementary Verification Strategy
1. **Simulation Sign-Off:** Cycle-accurate simulation ([tb/tb_zc_obi.sv](file:///C:/Users/ajiba/rentalais/zero-cloud-hardware-architecture/tb/tb_zc_obi.sv) Test 2 and PowerShell test `T4.3`) fully executes all 1,024 continuous cycles under `!rst_sys_ni`, confirming that `drain_wdog_cnt_o` increments monotonically from 0 to 1023, transitions `subsys_dead_locked_q` to `1'b1`, and locks the subordinate in `ST_TRAP`.
2. **Inductive Formal Proof:** In [fv/zc_obi_formal_proof.sv](file:///C:/Users/ajiba/rentalais/zero-cloud-hardware-architecture/fv/zc_obi_formal_proof.sv):
   - Property `F-OBI-01` proves by $k$-induction ($t=20$) that while in `ST_TRAP`, the subordinate unconditionally asserts `synth_err_rvalid_w` and returns synthetic bus error response without issuing physical requests.
   - Property `F-OBI-03` proves that if an orphan completes prior to timeout, the counter immediately resets to 0 and no fatal interrupt occurs.

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

## 7. Sign-Off & Status Matrix

| Audit Item | Verification Method | Status | Sign-Off Authority |
| :--- | :--- | :--- | :--- |
| **GCR-01 (Warm Reset Gating)** | BMC + $k$-Induction + RTL Sim (Verilator/Icarus) | **CLOSED** | Gate C Formal Proof (`F-OBI-04`, `F-OBI-05`) |
| **P-1 (F-OBI-03 Restoration)** | $k$-Induction ($t=20$) with `L-OBI-1` | **PROVEN** | Gate C Formal Proof (`F-OBI-03`) |
| **P-2 (10 Upgraded SVA Properties)** | Exact Normative Form BMC + $k$-Induction | **PROVEN** | Gate C Formal Proof (`fv/*.sv`) |
| **P-3 (F-OBI-02 3-Part Obligation)** | BMC + $k$-Induction ($t=20$) | **PROVEN** | Gate C Formal Proof (`F-OBI-02a/b/c`) |
| **P-4 (Non-Vacuity Cover Analysis)** | SMTBMC Cover Mode (`-c`, $t=20$) | **REACHABLE** | Gate C Cover Proofs (`C-OBI-*`, `C-SPI-*`, `C-OTP-*`) |
| **P-5 (OTP Dual Implementation Equiv)** | Dual-Compile Verilator & Icarus (12,240 Words) | **PROVEN** | [tb/tb_zc_otp_fn_equiv.sv](file:///C:/Users/ajiba/rentalais/zero-cloud-hardware-architecture/tb/tb_zc_otp_fn_equiv.sv) |
| **P-6 (CI Integrity & Artifact Upload)** | GitHub Actions Read-Only Workflow + Artifacts | **ACTIVE** | [.github/workflows/gate-c-hdl-verify.yml](file:///C:/Users/ajiba/rentalais/zero-cloud-hardware-architecture/.github/workflows/gate-c-hdl-verify.yml) |
| **P-7 (Modeling Limits Documentation)** | Normative Audit Disclosure | **PUBLISHED** | This Document |
| **Gate D (SoC / STA / Silicon Sign-Off)** | Top-Level Integration & Timing Sign-Off | **UNVERIFIED** | Gate D Milestone (v3.4.0 / v4.0.0 Blocked) |

