# FREECULI ZC-CORE — GATE B REV. 28D CONSOLIDATED ARCHITECTURAL CONTRACT & GATE C PREPARATION

* **Baseline Commit:** `ca7065bb5ec49576c1c9250145edbc3347029d9a` (`v3.3.0-rc2`, Zenodo DOI: `10.5281/zenodo.22962700`)
* **Architectural Status:** Gate B Closed (`Rev. 28D` — `0 P0`, `0 P1`)
* **Release Decision:** `v3.4.0` / `v4.0.0` remains `[BLOCKER]`
* **Verification Status:** `[GATE-C/D VERIFICATION OBLIGATION / UNVERIFIED]` (`0` hardware/HDL/formal/SPICE/lab tests executed)

---

## 1. Requirement-to-RTL Traceability Matrix (Rev. 28 – Rev. 28D)

| Requirement Area | Rev. 28–28D Contract | Target RTL / SVA File | Verification Status |
| :--- | :--- | :--- | :--- |
| **A. OTP Hsiao `(22,16)` & Seal Functions (`R27-01`, `R28-01`, `P1-1`, `P1-2`)** | Canonical `H_DATA` (`0x07..0x2C`), $d_{\min}=4$, $w_{H,\min}=8$ (`[8..14]`), `M_A(k) = (17*k + 8'h5A) mod 256`, `M_B(k) = (29*k + 8'h3C) mod 256`, zero intra-`(k,v)` collisions across all 4,080 pairs | `rtl/zc_otp_pkg.sv`<br>`scripts/verify_gate_b_rev28d.ps1` | Math/Script: `PASS`<br>RTL Synthesis/Formal: `[UNVERIFIED]` |
| **B. OTP 4-Phase DAI Handshake & Single-Use Grant (`R28-02`, `R28B-01`, `R28B-02`)** | 4 distinct events (`write_authorized_w`, `dai_write_accepted_w`, `dai_write_completed_w`, `readback_verified_w`), `wstep_q` sub-FSM, immediate grant consumption on `dai_write_accepted_w`, separate normal (`0->1->2`) and recovery (`2` only) completion into `AUTH_SESSION_DONE`, sticky `AUTH_LOCKED_FATAL` until Cold POR | `rtl/zc_aon_post_auth_ctrl.sv`<br>`fv/zc_otp_sva.sv` | RTL/SVA Written<br>Formal Proof: `[UNVERIFIED]` |
| **C. SPI 3-Layer Flash Update Security (`R27-04`, `R28-03`)** | Separation of (1) primary frame completion (`*_pri_frame_done_w` on `$rose(cs_n_to_iso_o) && !sck_to_iso_o`), (2) secondary electrical `/CS` acceptance (`cs_n_flash_eff_o = cs_n_to_iso_o \| fault_high_sec_i`), and (3) internal Flash completion (`05h RDSR1` `2'b00`) + independent `rom_img_verif_valid_i` | `rtl/zc_spi_flash_firewall.sv`<br>`fv/zc_spi_sva.sv` | RTL/SVA Written<br>Formal/Timing Proof: `[UNVERIFIED]` |
| **D. OBI Orphan Transaction & 1,024-Cycle Watchdog (`R27-05`, `R28-04`, `R28B-03`)** | Separation of normal 64-cycle timeout (`wait_cnt_q`) and 1,024-cycle orphan drain (`drain_wdog_cnt_q`), unified `orphan_active_w = orphan_drain_active_q \|\| orphan_trigger_w` advancing monotonically even under continuous `!rst_sys_ni` or `ST_TIMEOUT_ERR`, permanent lock `subsys_dead_locked_q` until Cold POR | `rtl/zc_obi_subordinate_bridge.sv`<br>`fv/zc_obi_sva.sv` | RTL/SVA Written<br>Formal Proof: `[UNVERIFIED]` |
| **E. OBI `ST_TRAP` Synthetic Error Response (`Rev. 28D P1`)** | When `subsys_dead_locked_q == 1'b1`, `host_req_ready_o == 1'b1` in `ST_IDLE`, `periph_phys_req_o == 1'b0`, FSM enters `ST_TRAP` and returns `host_rvalid_o = 1'b1, host_err_o = 1'b1, host_rdata_o = 32'h0` on the next cycle before returning to `ST_IDLE` | `rtl/zc_obi_subordinate_bridge.sv`<br>`fv/zc_obi_sva.sv` (`SVA-L0-13c`) | RTL/SVA Written<br>Formal Proof: `[UNVERIFIED]` |
| **F. M7/M8 2-Trace Noninterference & Exact Zeroization (`R27-07`, `R28-05`)** | Unconstrained initial symbolic addresses (`sym_npu_addr_i`, `sym_main_addr_i`), exact zeroization (`== 64'h0 / 32'h0`), 49,152-cycle bounded liveness, Stage A control equality, Stage B L1 equivalence, non-vacuity `cover` properties | `fv/zc_m7_m8_ni_sva.sv` | SVA Written<br>Formal Proof: `[UNVERIFIED]` |
