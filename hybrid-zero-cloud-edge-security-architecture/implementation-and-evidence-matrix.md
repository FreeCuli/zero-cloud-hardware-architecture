# Hybrid Zero-Cloud & Edge Security Architecture
## Implementation & Technical Evidence Matrix

**Document ID:** `ZC-HYBRID-EVIDENCE-MATRIX-01`  
**Classification:** Canonical Architecture Suite Specification  
**Status:** `CANDIDATE BASELINE / UNRATIFIED`  
**Parent Document:** [`README.md`](README.md)  

---

## 1. Traceability Architecture

The **Hybrid Zero-Cloud & Edge Security Architecture** does not rely on abstract conceptual assertions; every security property is grounded in synthesizable Register-Transfer Level (RTL) SystemVerilog source code, formal mathematical assertions (SVA), or cycle-accurate simulation testbenches.

This matrix provides comprehensive, bidirectional traceability linking high-level architectural requirements to:
1. Synthesizable RTL source files in [`rtl/`](../rtl/)
2. Normative SystemVerilog Assertion (SVA) properties and formal proofs in [`fv/`](../fv/)
3. Cycle-accurate simulation testbenches in [`tb/`](../tb/)
4. Formal verification boundaries and open silicon limitations disclosed in [`evidence/gate-c/MODELING_LIMITS.md`](../evidence/gate-c/MODELING_LIMITS.md)

---

## 2. Comprehensive Implementation & Evidence Matrix

| Architectural Security Claim | RTL Implementation Module | Internal State / Signal Interface | Verification Method & Testbench | Proven Invariant / Bound | Kalan Risk & Açık Sınır (Gate D Deferral) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **SPI Flash Frame Completion & Deselect Isolation** | [`rtl/zc_spi_flash_firewall.sv`](../rtl/zc_spi_flash_firewall.sv) | `FSM: UPD_UNSYNC_RESET, UPD_IDLE, UPD_WEL_PENDING, UPD_PROGRAM_BUSY, UPD_VERIFY_CLEAR, UPD_RECOVERY_LOCKOUT`<br>`cs_n_to_iso_o`, `sck_to_iso_o` | [`fv/zc_spi_formal_proof.sv`](../fv/zc_spi_formal_proof.sv)<br>[`tb/tb_zc_spi.sv`](../tb/tb_zc_spi.sv) | **`F-SPI-03` ($t=20$ $k$-induction):** Primary frame completion strobes checked in state transitions (`UPD_UNSYNC_RESET -> UPD_IDLE` and `UPD_IDLE -> UPD_WEL_PENDING`) bounded strictly to `/CS` rising edge while `SCK=0` idle. Does not prove all possible physical frame completion paths. | PCB trace capacitive reflections and flash setup/hold violations are **Gate D (UNVERIFIED)**. |
| **Flash Write-In-Progress Status Reconciliation** | [`rtl/zc_spi_flash_firewall.sv`](../rtl/zc_spi_flash_firewall.sv) | `UPD_UNSYNC_RESET -> UPD_IDLE`, `05h RDSR1` decoder, `f_sr1_latched_byte_o` | [`fv/zc_spi_formal_proof.sv`](../fv/zc_spi_formal_proof.sv)<br>Testbench Test 1 | **`F-SPI-01` ($t=20$ $k$-induction):** Transition to `UPD_IDLE` occurs strictly after fresh `05h RDSR1` read with `SR1[1:0] == 2'b00` and `!fault_high_sec_i`. | Corrupted flash MISO line reporting false WIP=0 is **Gate D (UNVERIFIED)**. |
| **Bank-B Inbound Firmware Commit Authorization** | [`rtl/zc_spi_flash_firewall.sv`](../rtl/zc_spi_flash_firewall.sv) | `bank_b_commit_ready_o`, `rom_img_verif_valid_i`, `spi_idle_ready_o` | [`fv/zc_spi_formal_proof.sv`](../fv/zc_spi_formal_proof.sv)<br>Testbench Test 3 | **`F-SPI-02` ($t=20$ $k$-induction):** RTL combinational gating logic only: asserts `bank_b_commit_ready_o` iff `spi_idle_ready_o && rom_img_verif_valid_i`. Does NOT prove independent cryptographic validity of Boot ROM signature verifier. | Flash sector wear-out and endurance limits are **Gate D (UNVERIFIED)**. |
| **Secondary Fault Fail-Closed Isolation** | [`rtl/zc_spi_flash_firewall.sv`](../rtl/zc_spi_flash_firewall.sv) | `fault_high_sec_i`, `cs_n_flash_eff_o` | [`fv/zc_spi_formal_proof.sv`](../fv/zc_spi_formal_proof.sv) | **`F-SPI-04` ($t=20$ $k$-induction):** Secondary fault (`fault_high_sec_i`) forces effective Flash `/CS` high (`cs_n_flash_eff_o = 1'b1`) via RTL combinational OR. Does NOT prove physical line bridge/short on PCB or glitch immunity (Gate D). | Physical line bridge/short on board traces is **Gate D (UNVERIFIED)**. |
| **OBI Subordinate Bus Decoupling & Error Trap** | [`rtl/zc_obi_subordinate_bridge.sv`](../rtl/zc_obi_subordinate_bridge.sv) | `FSM: ST_IDLE, ST_WAIT_RVALID, ST_TIMEOUT_ERR, ST_TRAP`<br>`host_req_i`, `host_req_ready_o`, `host_rvalid_o`, `host_err_o` | [`fv/zc_obi_formal_proof.sv`](../fv/zc_obi_formal_proof.sv)<br>[`tb/tb_zc_obi.sv`](../tb/tb_zc_obi.sv) | **`F-OBI-01` & `F-OBI-06` ($t=20$ $k$-induction):** `F-OBI-01` proves single-response delivery lock (`cpu_resp_delivered_q`); `F-OBI-06` proves deadlocked subordinate requests in `ST_IDLE` transition to `ST_TRAP` returning deterministic synthetic error (`rvalid=1, err=1, rdata=0`) with zero physical requests. | Multi-master crossbar contention and arbitration fairness are **Gate D (UNVERIFIED)**. |
| **1024-Cycle Orphan Peripheral Drain & Error Trap** | [`rtl/zc_obi_subordinate_bridge.sv`](../rtl/zc_obi_subordinate_bridge.sv) | `drain_wdog_cnt_q [9:0]`, `orphan_active_w`, `subsys_dead_locked_q`, `subsys_fatal_fault_irq_o` | [`fv/zc_obi_formal_proof.sv`](../fv/zc_obi_formal_proof.sv)<br>Cycle-accurate simulation [`tb/tb_zc_obi.sv`](../tb/tb_zc_obi.sv) Test 2 | **`F-OBI-05` ($t=20$ historical Run #45) & `C-OBI-01`:** Internal register `drain_wdog_cnt_q` operates as UP-counter (starts at 0, increments to 1023). When prior cycle shows `drain_wdog_cnt_q == 10'd1023`, in the subsequent evaluated clock cycle under active orphan drain, `subsys_dead_locked_q <= 1` is permanently latched; output `subsys_fatal_fault_irq_o` is continuously driven high combinationally in the same cycle. | Analog PVT variation on clock frequency affecting absolute timeout duration is **Gate D (UNVERIFIED)**. |
| **Warm Reset (rst_sys_ni) Subordinate Request Gating** | [`rtl/zc_obi_subordinate_bridge.sv`](../rtl/zc_obi_subordinate_bridge.sv) | `rst_sys_ni`, `host_req_ready_o`, `periph_phys_req_o`, `host_rvalid_o` | [`fv/zc_obi_formal_proof.sv`](../fv/zc_obi_formal_proof.sv)<br>Audit finding GCR-01 | **`F-OBI-07` ($t=20$ $k$-induction):** While system warm reset is low (`!rst_sys_ni`), `host_req_ready_o`, `periph_phys_req_o`, and `host_rvalid_o` are strictly forced to `0`. | Reset recovery/removal timing violations across PVT corners are **Gate D (UNVERIFIED)**. |
| **4-Phase Atomic OTP DAI Handshake Sequence** | [`rtl/zc_aon_post_auth_ctrl.sv`](../rtl/zc_aon_post_auth_ctrl.sv) | `wstep_q: WSTEP_AUTH_READY -> WSTEP_WAIT_PHYS_DONE -> WSTEP_WAIT_RB_VERIFY -> AUTH_SESSION_DONE` | [`fv/zc_otp_formal_proof.sv`](../fv/zc_otp_formal_proof.sv)<br>[`tb/tb_zc_otp_protocol_e2e.sv`](../tb/tb_zc_otp_protocol_e2e.sv) | **`F-OTP-01a/b` ($t=20$ $k$-induction):** Write grant consumed in exactly 1 cycle; write strobe impossible outside ready state. | Foundry antifuse high-voltage ($V_{\text{PP}}$) charge pump physics is **Gate D (UNVERIFIED)**. |
| **Strict 3-Word Sequential Commit (SVN -> A -> B)** | [`rtl/zc_aon_post_auth_ctrl.sv`](../rtl/zc_aon_post_auth_ctrl.sv) | `expected_word_idx_q [1:0]`, `OTP_WORD_SVN`, `OTP_WORD_COMMIT_A`, `OTP_WORD_COMMIT_B` | [`tb/tb_zc_otp_protocol_e2e.sv`](../tb/tb_zc_otp_protocol_e2e.sv) Scenario 1 & 2 | Verified in simulation: Normal flow strictly enforces $0 \to 1 \to 2$; recovery flow enforces word 2 only. | Physical OTP programming pulse duration ($t_{\text{PROG}} \approx 10\,\mu\text{s}$) is **Gate D (UNVERIFIED)**. |
| **Context-Bound Readback & Session Mismatch Lock** | [`rtl/zc_aon_post_auth_ctrl.sv`](../rtl/zc_aon_post_auth_ctrl.sv) | `active_session_id_q [31:0]`, `dai_rb_session_id_i`, `AUTH_LOCKED_FATAL` | [`tb/tb_zc_otp_protocol_e2e.sv`](../tb/tb_zc_otp_protocol_e2e.sv) Scenario 4 & 7 | Any readback mismatch immediately triggers `AUTH_LOCKED_FATAL`, permanent until cold POR (`rst_aon_por_ni`). | Voltage glitching bypassing register retention is **Gate D (UNVERIFIED)**. |
| **Hsiao (22,16) SECDED Codeword Parity Equivalence** | [`rtl/zc_otp_pkg.sv`](../rtl/zc_otp_pkg.sv) | `f_hsiao_parity6`, `f_expected_otp_codeword22`, $d_{\min}=4$ | [`tb/tb_zc_otp_fn_equiv.sv`](../tb/tb_zc_otp_fn_equiv.sv) (12,240 words exhaustive) | Exhaustively proven: 16 slots $\times$ 255 SVNs $\times$ 3 words = 12,240 combinations match bit-exact. | Multi-bit fault injection altering $>2$ bits simultaneously is **Gate D (UNVERIFIED)**. |

---

## 3. Detailed RTL Module Architectural Analysis

### 3.1 SPI Flash Firewall (`zc_spi_flash_firewall.sv`)
- **Module Purpose:** Implements an active hardware barrier between the untrusted Network Co-Processor and the shared SPI NOR Flash storing bootloader code and staged updates.
- **FSM Operation (`spi_update_state_e`):**
  - `UPD_UNSYNC_RESET`: Power-on/reset uncalibrated state. Requires clean RDSR1 status read (`WIP=0`, `WEL=0`) before entering idle.
  - `UPD_IDLE`: Physical SPI bus idle state. Awaiting authorized transaction sequence.
  - `UPD_WEL_PENDING`: Write-Enable-Latch cycle acknowledged; awaiting authorized Bank-B programming or erase opcode.
  - `UPD_PROGRAM_BUSY`: Hardware flash programming or erase in progress; secondary side effectively gated.
  - `UPD_VERIFY_CLEAR`: Verifying WIP=0 status register clearance after programming operation before re-enabling bus.
  - `UPD_RECOVERY_LOCKOUT`: Watchdog timeout trap state or unrecoverable fault. Permanent deselect until system reset.
- **Signal Boundary:**
  - Inbound untrusted inputs: `cs_n_from_untrusted_i`, `sck_from_untrusted_i`, `mosi_from_untrusted_i`.
  - Filtered protected outputs: `cs_n_to_iso_o`, `sck_to_iso_o`, `mosi_to_iso_o`.
  - Cryptographic validation interface: `rom_img_verif_valid_i`, `bank_b_commit_ready_o`.

### 3.2 OBI Subordinate Bridge (`zc_obi_subordinate_bridge.sv`)
- **Module Purpose:** Decouples the untrusted Network Co-Processor from the internal system crossbar, preventing external masters from inducing bus hangs or probing unmapped addresses.
- **FSM Operation (`obi_bridge_state_e`):**
  - `ST_IDLE (2'b00)`: Bridge idle; accepts CPU host requests if subordinate is not deadlocked.
  - `ST_WAIT_RVALID (2'b01)`: Awaiting peripheral response with 64-cycle timeout counter (`wait_cnt_q`).
  - `ST_TIMEOUT_ERR (2'b10)`: Timeout fault state; latches orphan condition and triggers watchdog.
  - `ST_TRAP (2'b11)`: Synthetic bus error delivery state (`host_rvalid_o <= 1'b1`, `host_err_o <= 1'b1`, `host_rdata_o <= 32'h0`).
- **Key Architectural Features:**
  - **1024-Cycle Orphan Watchdog:** Digital UP-counter (`drain_wdog_cnt_q [9:0]`) initialized to `10'd0`. Under persistent orphan drain (`orphan_active_w`), increments by +1 each cycle (`0 → 1023`) without asserting deadlock. On the clock edge following `drain_wdog_cnt_q == 10'd1023`, permanent deadlock register `subsys_dead_locked_q <= 1'b1` is latched, and output port `subsys_fatal_fault_irq_o` asserts high combinationally via continuous assignment.
  - **Synthetic Bus Error Injection (`ST_TRAP`):** Under `subsys_dead_locked_q == 1` or upon timeout, the bridge cleanly terminates bus transactions by transitioning to `ST_TRAP`, asserting `host_err_o <= 1'b1` with zero data (`host_rdata_o <= 32'h0000_0000`) without asserting `periph_phys_req_o`, precluding host bus hang.
  - **Warm Reset Gating (`rst_sys_ni`):** While the host system is under warm reset (`!rst_sys_ni`), all incoming requests (`host_req_i`) are masked (`host_req_ready_o <= 0`, `periph_phys_req_o <= 0`, `host_rvalid_o <= 0`) to prevent reset-time transaction injection.

### 3.3 AON POST Authorization Controller (`zc_aon_post_auth_ctrl.sv`)
- **Module Purpose:** Located in the Always-On (AON) power domain, this controller guards the Direct Access Interface (DAI) of the physical OTP eFuse memory.
- **Key Architectural Features:**
  - **Single-Cycle Grant Egress:** An authorization grant (`otp_word_auth_valid_o`, `otp_dai_we_o`) is valid for exactly one clock cycle and is consumed immediately upon `dai_cmd_req_i` acceptance.
  - **Session-Bound Identity:** Every commit sequence is bound to a dynamic 32-bit `active_session_id_q`. Readback responses carrying a mismatched session ID trigger an immediate permanent transition to `AUTH_LOCKED_FATAL`.
  - **Cold Reset Recovery Only:** Once locked into `AUTH_LOCKED_FATAL`, warm resets (`rst_sys_ni`) are ignored; only a cold Power-On Reset (`rst_aon_por_ni`) can clear the fault state.

---

## 4. Formal Verification Toolchain & Modeling Boundaries

Formal verification was conducted under the open-source hardware verification toolchain:
- **Yosys 0.33:** AST synthesis, logic flattening, `async2sync`, `opt`, `dffunmap`.
- **yosys-smtbmc:** SMT-LIB2 bounded model checking and $k$-induction driver.
- **Z3 4.12+:** SMT solver over bit-vector logic (`QF_BV`).
- **Verilator 5.0+ / Icarus Verilog 12.0+:** Dynamic cycle-accurate simulation.

### 4.1 Crucial Boundary Disclosure: The `async2sync` Formal Abstraction
In the Yosys formal pipeline, the pass `async2sync` converts all asynchronous resets (`rst_aon_por_ni`, `rst_sys_ni`) into synchronous resets evaluated on discrete clock edges:
1. **Clock-Synchronous Domain Restriction:** The formal proofs prove correctness **if and only if** reset assertion/deassertion occurs synchronously with `clk_aon_i` or `clk_sys_i`.
2. **Pulse & Glitch Immunity Unproven by BMC:** Sub-cycle asynchronous runt pulses, power brown-outs shorter than $T_{clk}$, and metastability during asynchronous removal/recovery ($t_{rec}, t_{rem}$) cannot be modeled or proven by discrete-time BMC.
3. **Formal Deferral:** Physical synchronizers, glitch filters, and Static Timing Analysis (STA) are formally disclosed as **`Gate D (UNVERIFIED)`**.
