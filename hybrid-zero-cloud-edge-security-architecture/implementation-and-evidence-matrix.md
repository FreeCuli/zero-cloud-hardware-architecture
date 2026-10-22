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
| **SPI Flash Command Gating & Deselect Isolation** | [`rtl/zc_spi_flash_firewall.sv`](../rtl/zc_spi_flash_firewall.sv) | `FSM: UPD_UNSYNC_RESET, UPD_IDLE, UPD_WEL_PENDING, UPD_PROGRAM_BUSY, UPD_VERIFY_CLEAR, UPD_RECOVERY_LOCKOUT`<br>`cs_n_to_iso_o`, `sck_to_iso_o` | [`fv/zc_spi_formal_proof.sv`](../fv/zc_spi_formal_proof.sv)<br>[`tb/tb_zc_spi.sv`](../tb/tb_zc_spi.sv) | **`F-SPI-01` ($t=20$ $k$-induction):** Rising `/CS` edge occurs strictly while `SCK=0` idle. Eliminates runt pulses. | PCB trace capacitive reflections and flash setup/hold violations are **Gate D (UNVERIFIED)**. |
| **Flash Write-In-Progress Status Reconciliation** | [`rtl/zc_spi_flash_firewall.sv`](../rtl/zc_spi_flash_firewall.sv) | `05h RDSR1` command decoder, `wip_tracking_q`, `flash_ready_strobe_o` | [`fv/zc_spi_formal_proof.sv`](../fv/zc_spi_formal_proof.sv)<br>Testbench Test 1 | **`F-SPI-02` ($t=20$ $k$-induction):** Bus access remains blocked until RDSR1 bit 0 (WIP) clears to `0`. | Corrupted flash MISO line reporting false WIP=0 is **Gate D (UNVERIFIED)**. |
| **Bank-B Inbound Firmware Commit Authorization** | [`rtl/zc_spi_flash_firewall.sv`](../rtl/zc_spi_flash_firewall.sv) | `bank_b_commit_ready_o`, `rom_img_verif_valid_i`, `spi_idle_ready_o` | [`fv/zc_spi_formal_proof.sv`](../fv/zc_spi_formal_proof.sv)<br>Testbench Test 3 | **`F-SPI-04` ($t=20$ $k$-induction):** Commit strobe is physically gated until Boot ROM cryptographic validation asserts. | Flash sector wear-out and endurance limits are **Gate D (UNVERIFIED)**. |
| **OBI Subordinate Bus Decoupling & Isolation** | [`rtl/zc_obi_subordinate_bridge.sv`](../rtl/zc_obi_subordinate_bridge.sv) | `FSM: ST_IDLE, ST_WAIT_GNT, ST_WAIT_RESP, ST_TRAP`<br>`host_req_i`, `host_gnt_o`, `host_rvalid_o` | [`fv/zc_obi_formal_proof.sv`](../fv/zc_obi_formal_proof.sv)<br>[`tb/tb_zc_obi.sv`](../tb/tb_zc_obi.sv) | **`F-OBI-01` ($t=20$ $k$-induction):** Subordinate never hangs; invalid states trap to synthetic error delivery. | Multi-master crossbar contention and arbitration fairness are **Gate D (UNVERIFIED)**. |
| **1024-Cycle Orphan Peripheral Drain & Error Trap** | [`rtl/zc_obi_subordinate_bridge.sv`](../rtl/zc_obi_subordinate_bridge.sv) | `drain_wdog_cnt_o [9:0]`, `subsys_dead_locked_q`, `host_err_o <= 1'b1` | Cycle-accurate simulation [`tb/tb_zc_obi.sv`](../tb/tb_zc_obi.sv) Test 2 + BMC unroll | **`C-OBI-01` (1024 cycles SIMULATED):** Peripheral hang increments counter to 1023, cleanly locks in `ST_TRAP`, returns `32'h0`. | Analog PVT variation on clock frequency affecting absolute timeout duration is **Gate D (UNVERIFIED)**. |
| **Warm Reset (rst_sys_ni) Subordinate Request Gating** | [`rtl/zc_obi_subordinate_bridge.sv`](../rtl/zc_obi_subordinate_bridge.sv) | `rst_sys_ni`, `host_req_i`, `gated_host_req_w` | [`fv/zc_obi_formal_proof.sv`](../fv/zc_obi_formal_proof.sv)<br>Audit finding GCR-01 | **`F-OBI-07` ($t=20$ $k$-induction):** While system warm reset is low (`!rst_sys_ni`), all subordinate requests are blocked. | Reset recovery/removal timing violations across PVT corners are **Gate D (UNVERIFIED)**. |
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
- **Key Architectural Features:**
  - **1024-Cycle Orphan Watchdog:** Digital down-counter counting from `10'd1023` to `0`. If an internal subordinate transaction is abandoned or fails to return `rvalid_i`, the watchdog fires.
  - **Synthetic Bus Error Injection (`ST_TRAP`):** Upon timeout or protocol violation, the bridge cleanly terminates the bus transaction by asserting `host_err_o <= 1'b1` with zero data (`host_rdata_o <= 32'h0000_0000`), precluding host bus hang.
  - **Warm Reset Gating (`rst_sys_ni`):** While the host system is under warm reset (`!rst_sys_ni`), all incoming requests (`host_req_i`) are masked to prevent reset-time transaction injection.

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
