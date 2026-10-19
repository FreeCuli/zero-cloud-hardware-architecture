// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: tb_zc_otp_fn_equiv
// Description:
//   Gate C Dual-Implementation Mathematical & RTL Equivalence Testbench:
//   - Exhaustive verification across all 16 slots (k in [0..15]) and 255 SVNs (v in [1..255])
//   - Tests all 3 words: WORD_SVN (0), WORD_COMMIT_A (1), WORD_COMMIT_B (2) = 12,240 words
//   - Compares zc_otp_pkg normative multiplier functions (* 17, * 29) against:
//     1) Direct YOSYS shift-add implementation ({k,k}+0x5A, {k,0}+{0,k,0}+... + 0x3C)
//     2) zc_aon_post_auth_ctrl DUT internal codeword registers (expected_cw0_q, cw1_q, cw2_q)
//   - Designed to run independently under both standard and -DYOSYS compilation flags.

`timescale 1ns / 1ps

module tb_zc_otp_fn_equiv;
  import zc_otp_pkg::*;

  // -------------------------------------------------------------------------
  // Reference YOSYS Shift-Add Parity & Codeword Generator (identical to RTL `ifdef YOSYS)
  // -------------------------------------------------------------------------
  function automatic logic [5:0] f_yosys_hsiao_parity6(input logic [15:0] d);
    logic [5:0] p;
    begin
      p[0] = d[0] ^ d[1] ^ d[2] ^ d[4] ^ d[5] ^ d[7] ^ d[10] ^ d[11] ^ d[13];
      p[1] = d[0] ^ d[1] ^ d[3] ^ d[4] ^ d[6] ^ d[8] ^ d[10] ^ d[12] ^ d[14];
      p[2] = d[0] ^ d[2] ^ d[3] ^ d[5] ^ d[6] ^ d[9] ^ d[11] ^ d[12] ^ d[15];
      p[3] = d[1] ^ d[2] ^ d[3] ^ d[7] ^ d[8] ^ d[9] ^ d[13] ^ d[14] ^ d[15];
      p[4] = d[4] ^ d[5] ^ d[6] ^ d[7] ^ d[8] ^ d[9];
      p[5] = d[10] ^ d[11] ^ d[12] ^ d[13] ^ d[14] ^ d[15];
      f_yosys_hsiao_parity6 = p;
    end
  endfunction

  function automatic logic [21:0] f_yosys_expected_otp_codeword22(
    input logic [3:0] k,
    input logic [7:0] v,
    input logic [1:0] word_idx
  );
    logic [7:0] ma, mb, ba, bb;
    logic [15:0] d;
    begin
      ma = {k, k} + 8'h5A;
      mb = {k, 4'b0000} + {1'b0, k, 3'b000} + {2'b00, k, 2'b00} + {4'b0000, k} + 8'h3C;
      ba = v ^ ma;
      bb = v ^ mb;
      case (word_idx)
        zc_otp_pkg::OTP_WORD_SVN:      d = {~v, v};
        zc_otp_pkg::OTP_WORD_COMMIT_A: d = {~ba, ba};
        zc_otp_pkg::OTP_WORD_COMMIT_B: d = {bb, ~bb};
        default:                       d = 16'hFFFF;
      endcase
      f_yosys_expected_otp_codeword22 = {f_yosys_hsiao_parity6(d), d};
    end
  endfunction

  // -------------------------------------------------------------------------
  // DUT Signals & Instantiation
  // -------------------------------------------------------------------------
  logic        clk_aon_i;
  logic        rst_aon_por_ni;
  logic        rst_sys_ni;
  logic        rom_exec_active_i;
  logic        tamper_alert_i;
  logic        clk_glitch_alert_i;
  logic        volt_supervisor_fault_i;
  logic        boot_scan_done_i;
  logic        boot_scan_pending_b_i;
  logic        post_auth_req_i;
  logic [31:0] post_session_id_i;
  logic        val_step_done_i;
  logic        val_all_checks_ok_i;
  logic [3:0]  req_target_slot_i;
  logic [7:0]  req_target_svn_i;
  logic        req_seal_b_only_i;
  logic [1:0]  dai_state_i;
  logic        otp_macro_phys_active_i;
  logic        dai_cmd_req_i;
  logic [3:0]  dai_slot_idx_i;
  logic [1:0]  dai_word_sel_i;
  logic        dai_prog_done_pulse_i;
  logic        dai_prog_err_i;
  logic        dai_rb_done_pulse_i;
  logic        dai_ecc_err_i;
  logic [31:0] dai_rb_session_id_i;
  logic [3:0]  dai_rb_slot_idx_i;
  logic [1:0]  dai_rb_word_sel_i;
  logic [21:0] dai_rb_raw_data_i;

  logic        otp_word_auth_valid_o;
  logic        otp_dai_we_o;
  logic [3:0]  otp_auth_slot_o;
  logic [7:0]  otp_auth_svn_o;
  logic [1:0]  otp_auth_word_sel_o;
  logic [2:0]  otp_auth_word_mask_o;
  logic [21:0] otp_auth_expected_cw_o;
  logic [2:0]  aon_auth_state_o;
  logic [1:0]  aon_wstep_o;
  logic        aon_fatal_locked_o;

  zc_aon_post_auth_ctrl dut (
    .clk_aon_i               (clk_aon_i),
    .rst_aon_por_ni          (rst_aon_por_ni),
    .rst_sys_ni              (rst_sys_ni),
    .rom_exec_active_i       (rom_exec_active_i),
    .tamper_alert_i          (tamper_alert_i),
    .clk_glitch_alert_i      (clk_glitch_alert_i),
    .volt_supervisor_fault_i (volt_supervisor_fault_i),
    .boot_scan_done_i        (boot_scan_done_i),
    .boot_scan_pending_b_i   (boot_scan_pending_b_i),
    .post_auth_req_i         (post_auth_req_i),
    .post_session_id_i       (post_session_id_i),
    .val_step_done_i         (val_step_done_i),
    .val_all_checks_ok_i     (val_all_checks_ok_i),
    .req_target_slot_i       (req_target_slot_i),
    .req_target_svn_i        (req_target_svn_i),
    .req_seal_b_only_i       (req_seal_b_only_i),
    .dai_state_i             (dai_state_i),
    .otp_macro_phys_active_i (otp_macro_phys_active_i),
    .dai_cmd_req_i           (dai_cmd_req_i),
    .dai_slot_idx_i          (dai_slot_idx_i),
    .dai_word_sel_i          (dai_word_sel_i),
    .dai_prog_done_pulse_i   (dai_prog_done_pulse_i),
    .dai_prog_err_i          (dai_prog_err_i),
    .dai_rb_done_pulse_i     (dai_rb_done_pulse_i),
    .dai_ecc_err_i           (dai_ecc_err_i),
    .dai_rb_session_id_i     (dai_rb_session_id_i),
    .dai_rb_slot_idx_i       (dai_rb_slot_idx_i),
    .dai_rb_word_sel_i       (dai_rb_word_sel_i),
    .dai_rb_raw_data_i       (dai_rb_raw_data_i),
    .otp_word_auth_valid_o   (otp_word_auth_valid_o),
    .otp_dai_we_o            (otp_dai_we_o),
    .otp_auth_slot_o         (otp_auth_slot_o),
    .otp_auth_svn_o          (otp_auth_svn_o),
    .otp_auth_word_sel_o     (otp_auth_word_sel_o),
    .otp_auth_word_mask_o    (otp_auth_word_mask_o),
    .otp_auth_expected_cw_o  (otp_auth_expected_cw_o),
    .aon_auth_state_o        (aon_auth_state_o),
    .aon_wstep_o             (aon_wstep_o),
    .aon_fatal_locked_o      (aon_fatal_locked_o)
  );

  logic [31:0] f_accepted_session_id_q;
  always_ff @(posedge clk_aon_i or negedge rst_aon_por_ni) begin
    if (!rst_aon_por_ni) begin
      f_accepted_session_id_q <= 32'h0;
    end else if (!tamper_alert_i && !clk_glitch_alert_i && !volt_supervisor_fault_i) begin
      if ((aon_auth_state_o == 3'b001) &&
          !(dai_prog_done_pulse_i || dai_rb_done_pulse_i || dai_cmd_req_i) &&
          post_auth_req_i && rst_sys_ni && rom_exec_active_i) begin
        f_accepted_session_id_q <= post_session_id_i;
      end
    end
  end

  initial clk_aon_i = 1'b0;
  always #5 clk_aon_i = ~clk_aon_i;

  int fn_mismatches  = 0;
  int dut_mismatches = 0;
  int total_words_checked = 0;

  initial begin
    logic [21:0] pkg_cw, yosys_cw;

    $display("======================================================================");
    $display(" STARTING GATE C OTP FUNCTION & RTL EQUIVALENCE AUDIT");
    $display(" Testing 16 slots x 255 SVNs x 3 words = 12,240 total words");
`ifdef YOSYS
    $display(" Mode: COMPILED WITH -DYOSYS (Shift-Add Implementation in DUT)");
`else
    $display(" Mode: COMPILED WITH STANDARD SYSTEMVERILOG (Package Import in DUT)");
`endif
    $display("======================================================================");

    // -----------------------------------------------------------------------
    // PART 1: Direct Mathematical Function Equivalence (12,240 Words)
    // -----------------------------------------------------------------------
    for (int k = 0; k < 16; k++) begin
      for (int v = 1; v <= 255; v++) begin
        for (int w = 0; w < 3; w++) begin
          pkg_cw   = zc_otp_pkg::f_expected_otp_codeword22(4'(k), 8'(v), 2'(w));
          yosys_cw = f_yosys_expected_otp_codeword22(4'(k), 8'(v), 2'(w));
          if (pkg_cw !== yosys_cw) begin
            $display("[FAIL][MATH-EQUIV] Mismatch at slot=%0d svn=%0d word=%0d : pkg=0x%06x yosys=0x%06x",
                     k, v, w, pkg_cw, yosys_cw);
            fn_mismatches++;
          end
          total_words_checked++;
        end
      end
    end

    if (fn_mismatches == 0) begin
      $display("[PASS][MATH-EQUIV] All 12,240 words match identically between zc_otp_pkg and shift-add functions.");
    end else begin
      $display("[FAIL][MATH-EQUIV] Found %0d mathematical mismatches!", fn_mismatches);
    end

    // -----------------------------------------------------------------------
    // PART 2: RTL DUT Register Equivalence (All 4,080 (k,v) Pairs x 3 Words)
    // -----------------------------------------------------------------------
    // Initialize DUT
    rst_aon_por_ni          = 1'b0;
    rst_sys_ni              = 1'b1;
    rom_exec_active_i       = 1'b1;
    tamper_alert_i          = 1'b0;
    clk_glitch_alert_i      = 1'b0;
    volt_supervisor_fault_i = 1'b0;
    boot_scan_done_i        = 1'b0;
    boot_scan_pending_b_i   = 1'b0;
    post_auth_req_i         = 1'b0;
    post_session_id_i       = 32'h1234_5678;
    val_step_done_i         = 1'b0;
    val_all_checks_ok_i     = 1'b0;
    req_target_slot_i       = 4'd0;
    req_target_svn_i        = 8'd0;
    req_seal_b_only_i       = 1'b0;
    dai_state_i             = 2'b00;
    otp_macro_phys_active_i = 1'b0;
    dai_cmd_req_i           = 1'b0;
    dai_slot_idx_i          = 4'd0;
    dai_word_sel_i          = 2'd0;
    dai_prog_done_pulse_i   = 1'b0;
    dai_prog_err_i          = 1'b0;
    dai_rb_done_pulse_i     = 1'b0;
    dai_ecc_err_i           = 1'b0;
    dai_rb_session_id_i     = 32'h0;
    dai_rb_slot_idx_i       = 4'd0;
    dai_rb_word_sel_i       = 2'd0;
    dai_rb_raw_data_i       = 22'h0;

    @(posedge clk_aon_i);
    @(posedge clk_aon_i);
    rst_aon_por_ni = 1'b1;
    @(posedge clk_aon_i);

    for (int k = 0; k < 16; k++) begin
      for (int v = 1; v <= 255; v++) begin
        // Reset to AUTH_RESET_IDLE
        @(negedge clk_aon_i);
        rst_aon_por_ni = 1'b0;
        @(posedge clk_aon_i);
        @(negedge clk_aon_i);
        rst_aon_por_ni = 1'b1;

        // Boot scan complete -> AUTH_WAIT_CHAL
        boot_scan_done_i = 1'b1;
        @(posedge clk_aon_i);
        @(negedge clk_aon_i);
        boot_scan_done_i = 1'b0;

        // Post auth req -> AUTH_VALIDATE
        post_auth_req_i   = 1'b1;
        post_session_id_i = 32'hA5A5_0000 | {16'h0, 4'(k), 8'(v)};
        @(posedge clk_aon_i);
        @(negedge clk_aon_i);
        post_auth_req_i   = 1'b0;

        // Verify shadow session register matches DUT internal active_session_id_q
        if (dut.active_session_id_q !== f_accepted_session_id_q) begin
          $display("[FAIL][SESSION-EQUIV] Session ID mismatch at slot=%0d svn=%0d : dut=0x%08x shadow=0x%08x",
                   k, v, dut.active_session_id_q, f_accepted_session_id_q);
          dut_mismatches++;
        end

        // Validation step complete -> latches expected_cw0_q, cw1_q, cw2_q
        val_step_done_i     = 1'b1;
        val_all_checks_ok_i = 1'b1;
        req_target_slot_i   = 4'(k);
        req_target_svn_i    = 8'(v);
        req_seal_b_only_i   = 1'b0;
        @(posedge clk_aon_i);
        @(negedge clk_aon_i);
        val_step_done_i     = 1'b0;

        // Verify DUT latched registers against normative zc_otp_pkg
        if (dut.expected_cw0_q !== zc_otp_pkg::f_expected_otp_codeword22(4'(k), 8'(v), 2'd0)) begin
          $display("[FAIL][DUT-EQUIV] Word 0 mismatch at slot=%0d svn=%0d : dut=0x%06x pkg=0x%06x",
                   k, v, dut.expected_cw0_q, zc_otp_pkg::f_expected_otp_codeword22(4'(k), 8'(v), 2'd0));
          dut_mismatches++;
        end

        if (dut.expected_cw1_q !== zc_otp_pkg::f_expected_otp_codeword22(4'(k), 8'(v), 2'd1)) begin
          $display("[FAIL][DUT-EQUIV] Word 1 mismatch at slot=%0d svn=%0d : dut=0x%06x pkg=0x%06x",
                   k, v, dut.expected_cw1_q, zc_otp_pkg::f_expected_otp_codeword22(4'(k), 8'(v), 2'd1));
          dut_mismatches++;
        end

        if (dut.expected_cw2_q !== zc_otp_pkg::f_expected_otp_codeword22(4'(k), 8'(v), 2'd2)) begin
          $display("[FAIL][DUT-EQUIV] Word 2 mismatch at slot=%0d svn=%0d : dut=0x%06x pkg=0x%06x",
                   k, v, dut.expected_cw2_q, zc_otp_pkg::f_expected_otp_codeword22(4'(k), 8'(v), 2'd2));
          dut_mismatches++;
        end
      end
    end

    if (dut_mismatches == 0) begin
      $display("[PASS][DUT-EQUIV] All 4,080 (k,v) pairs (12,240 words) latched by DUT match zc_otp_pkg identically.");
    end else begin
      $display("[FAIL][DUT-EQUIV] Found %0d DUT register mismatches!", dut_mismatches);
    end

    $display("======================================================================");
    $display(" EQUIVALENCE AUDIT COMPLETE: Checked %0d words. Failures: Math=%0d, DUT=%0d",
             total_words_checked, fn_mismatches, dut_mismatches);
    $display("======================================================================");

    if (fn_mismatches > 0 || dut_mismatches > 0) begin
      $fatal(1, "Equivalence verification failed!");
    end else begin
      $finish;
    end
  end

endmodule
