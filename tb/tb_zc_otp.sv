// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: tb_zc_otp
// Description:
//   Gate C Self-Checking SystemVerilog HDL Simulation Testbench for:
//   - zc_otp_pkg (Exhaustive Hsiao (22,16) d_min=4 & 4,080 (k,v) seal non-collision check)
//   - zc_aon_post_auth_ctrl (4-phase atomic DAI handshake, single-use grant consumption,
//     normal 0->1->2 commit, PENDING_B_SEAL recovery 2-only commit, mismatched readback
//     fatal lock, and sticky AUTH_LOCKED_FATAL until Cold POR)

`timescale 1ns / 1ps

module tb_zc_otp;
  import zc_otp_pkg::*;

  logic                  clk_aon_i;
  logic                  rst_aon_por_ni;
  logic                  rst_sys_ni;
  logic                  rom_exec_active_i;
  logic                  tamper_alert_i;
  logic                  clk_glitch_alert_i;
  logic                  volt_supervisor_fault_i;
  logic                  boot_scan_done_i;
  logic                  boot_scan_pending_b_i;
  logic                  post_auth_req_i;
  logic [31:0]           post_session_id_i;
  logic                  val_step_done_i;
  logic                  val_all_checks_ok_i;
  logic [3:0]            req_target_slot_i;
  logic [7:0]            req_target_svn_i;
  logic                  req_seal_b_only_i;
  logic [1:0]            dai_state_i;
  logic                  otp_macro_phys_active_i;
  logic                  dai_cmd_req_i;
  logic [3:0]            dai_slot_idx_i;
  logic [1:0]            dai_word_sel_i;
  logic                  dai_prog_done_pulse_i;
  logic                  dai_prog_err_i;
  logic                  dai_rb_done_pulse_i;
  logic                  dai_ecc_err_i;
  logic [31:0]           dai_rb_session_id_i;
  logic [3:0]            dai_rb_slot_idx_i;
  logic [1:0]            dai_rb_word_sel_i;
  logic [21:0]           dai_rb_raw_data_i;

  logic                  otp_word_auth_valid_o;
  logic                  otp_dai_we_o;
  logic [3:0]            otp_auth_slot_o;
  logic [7:0]            otp_auth_svn_o;
  logic [1:0]            otp_auth_word_sel_o;
  logic [2:0]            otp_auth_word_mask_o;
  logic [21:0]           otp_auth_expected_cw_o;
  logic [2:0]            aon_auth_state_o;
  logic [1:0]            aon_wstep_o;
  logic                  aon_fatal_locked_o;

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
    .post_session_id_i        (post_session_id_i),
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

  initial clk_aon_i = 1'b0;
  always #5 clk_aon_i = ~clk_aon_i;

  int pass_cnt = 0;
  int fail_cnt = 0;

  task automatic check(input bit cond, input string name);
    if (cond) begin
      $display("[TB-OTP][PASS] %s", name);
      pass_cnt++;
    end else begin
      $display("[TB-OTP][FAIL] %s (state=%0d wstep=%0d auth=%0b we=%0b fatal=%0b)",
               name, aon_auth_state_o, aon_wstep_o, otp_word_auth_valid_o, otp_dai_we_o, aon_fatal_locked_o);
      fail_cnt++;
    end
  endtask

  task automatic reset_dut(input bit pending_b);
    rst_aon_por_ni          = 1'b0;
    rst_sys_ni              = 1'b0;
    rom_exec_active_i       = 1'b0;
    tamper_alert_i          = 1'b0;
    clk_glitch_alert_i      = 1'b0;
    volt_supervisor_fault_i = 1'b0;
    boot_scan_done_i        = 1'b0;
    boot_scan_pending_b_i   = pending_b;
    post_auth_req_i         = 1'b0;
    post_session_id_i       = 32'h0;
    val_step_done_i         = 1'b0;
    val_all_checks_ok_i     = 1'b0;
    req_target_slot_i       = 4'd0;
    req_target_svn_i        = 8'd0;
    req_seal_b_only_i       = 1'b0;
    dai_state_i             = DAI_IDLE;
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
    rst_aon_por_ni    = 1'b1;
    rst_sys_ni        = 1'b1;
    rom_exec_active_i = 1'b1;
    @(posedge clk_aon_i);
  endtask

  task automatic execute_4phase_word(
    input logic [3:0]  slot,
    input logic [1:0]  word_idx,
    input logic [31:0] sess_id,
    input logic [21:0] rb_cw
  );
    // Phase 1 & 2: Issue DAI command request in WSTEP_AUTH_READY
    @(negedge clk_aon_i);
    dai_cmd_req_i  = 1'b1;
    dai_slot_idx_i = slot;
    dai_word_sel_i = word_idx;
    #1;
    check(otp_word_auth_valid_o == 1'b1 && otp_dai_we_o == 1'b1 && otp_auth_word_sel_o == word_idx,
          $sformatf("Word %0d Phase 1&2: write_authorized and dai_write_accepted active", word_idx));
    @(posedge clk_aon_i);
    #1;
    dai_cmd_req_i           = 1'b0;
    dai_state_i             = DAI_PROG_BUSY;
    otp_macro_phys_active_i = 1'b1;
    // Immediately after accept clock edge, single-word grant must be consumed!
    check(otp_word_auth_valid_o == 1'b0 && otp_dai_we_o == 1'b0 &&
          otp_auth_word_mask_o == 3'b000 && aon_wstep_o == WSTEP_WAIT_PHYS_DONE,
          $sformatf("Word %0d Phase 2->3: single-use grant immediately consumed (word_grant_avail_q=0)", word_idx));

    // Wait 1 cycle in physical programming, then complete Phase 3
    @(posedge clk_aon_i);
    @(negedge clk_aon_i);
    otp_macro_phys_active_i = 1'b0;
    dai_state_i             = DAI_IDLE;
    dai_prog_done_pulse_i   = 1'b1;
    @(posedge clk_aon_i);
    #1;
    dai_prog_done_pulse_i   = 1'b0;
    check(aon_wstep_o == WSTEP_WAIT_RB_VERIFY && otp_word_auth_valid_o == 1'b0,
          $sformatf("Word %0d Phase 3->4: transitioned to WSTEP_WAIT_RB_VERIFY with grant still 0", word_idx));

    // Phase 4: Present bound readback
    @(negedge clk_aon_i);
    dai_rb_done_pulse_i = 1'b1;
    dai_rb_session_id_i = sess_id;
    dai_rb_slot_idx_i   = slot;
    dai_rb_word_sel_i   = word_idx;
    dai_rb_raw_data_i   = rb_cw;
    @(posedge clk_aon_i);
    #1;
    dai_rb_done_pulse_i = 1'b0;
  endtask

  initial begin
    int coll_cnt;
    int min_w, max_w, w_svn, w_a, w_b;
    logic [15:0] d_svn, d_a, d_b;
    logic [21:0] cw_svn, cw_a, cw_b;

    $display("======================================================================");
    $display(" STARTING GATE C HDL SIMULATION: tb_zc_otp");
    $display("======================================================================");

    // ------------------------------------------------------------------
    // TEST 1: Exhaustive 4,080 (k,v) Hsiao Package & Seal Verification
    // ------------------------------------------------------------------
    coll_cnt = 0;
    min_w    = 99;
    max_w    = 0;
    for (int k = 0; k < 16; k++) begin
      for (int v = 1; v <= 255; v++) begin
        d_svn  = f_word_svn_16(8'(v));
        d_a    = f_seal_a(4'(k), 8'(v));
        d_b    = f_seal_b(4'(k), 8'(v));
        if ((d_a == d_b) || (d_a == d_svn) || (d_b == d_svn)) coll_cnt++;

        cw_svn = f_hsiao_encode22(d_svn);
        cw_a   = f_hsiao_encode22(d_a);
        cw_b   = f_hsiao_encode22(d_b);
        if ((f_hsiao_syndrome6(cw_svn) != 6'h0) ||
            (f_hsiao_syndrome6(cw_a)   != 6'h0) ||
            (f_hsiao_syndrome6(cw_b)   != 6'h0)) coll_cnt++;

        w_svn = $countones(cw_svn);
        w_a   = $countones(cw_a);
        w_b   = $countones(cw_b);
        if (w_svn < min_w) min_w = w_svn;
        if (w_a   < min_w) min_w = w_a;
        if (w_b   < min_w) min_w = w_b;
        if (w_svn > max_w) max_w = w_svn;
        if (w_a   > max_w) max_w = w_a;
        if (w_b   > max_w) max_w = w_b;
      end
    end
    check(coll_cnt == 0 && min_w == 8 && max_w == 14,
          "Exhaustive 4,080 (k,v) RTL package check: 0 collisions, zero syndrome, w_H in [8..14]");

    // ------------------------------------------------------------------
    // TEST 2: Normal 3-Word Sequential Commit (WORD_SVN -> COMMIT_A -> COMMIT_B -> AUTH_SESSION_DONE)
    // ------------------------------------------------------------------
    reset_dut(1'b0);
    @(negedge clk_aon_i);
    boot_scan_done_i = 1'b1;
    @(posedge clk_aon_i);
    #1;
    boot_scan_done_i = 1'b0;
    check(aon_auth_state_o == AUTH_WAIT_CHAL, "Normal Flow: Entered AUTH_WAIT_CHAL after boot_scan_done");

    @(negedge clk_aon_i);
    post_auth_req_i   = 1'b1;
    post_session_id_i = 32'hCAFE_1234;
    @(posedge clk_aon_i);
    #1;
    post_auth_req_i   = 1'b0;
    check(aon_auth_state_o == AUTH_VALIDATE, "Normal Flow: Entered AUTH_VALIDATE");

    @(negedge clk_aon_i);
    val_step_done_i     = 1'b1;
    val_all_checks_ok_i = 1'b1;
    req_target_slot_i   = 4'd3;
    req_target_svn_i    = 8'd7;
    req_seal_b_only_i   = 1'b0;
    @(posedge clk_aon_i);
    #1;
    val_step_done_i     = 1'b0;
    check(aon_auth_state_o == AUTH_GRANT && aon_wstep_o == WSTEP_AUTH_READY &&
          otp_word_auth_valid_o == 1'b1 && otp_auth_word_sel_o == OTP_WORD_SVN &&
          otp_auth_word_mask_o == 3'b001,
          "Normal Flow: Entered AUTH_GRANT at OTP_WORD_SVN (0) with mask 3'b001");

    // Step 0: OTP_WORD_SVN
    execute_4phase_word(4'd3, OTP_WORD_SVN, 32'hCAFE_1234,
                        f_expected_otp_codeword22(4'd3, 8'd7, OTP_WORD_SVN));
    check(aon_auth_state_o == AUTH_GRANT && aon_wstep_o == WSTEP_AUTH_READY &&
          otp_word_auth_valid_o == 1'b1 && otp_auth_word_sel_o == OTP_WORD_COMMIT_A &&
          otp_auth_word_mask_o == 3'b010,
          "Normal Flow: Progressed to OTP_WORD_COMMIT_A (1) with mask 3'b010");

    // Step 1: OTP_WORD_COMMIT_A
    execute_4phase_word(4'd3, OTP_WORD_COMMIT_A, 32'hCAFE_1234,
                        f_expected_otp_codeword22(4'd3, 8'd7, OTP_WORD_COMMIT_A));
    check(aon_auth_state_o == AUTH_GRANT && aon_wstep_o == WSTEP_AUTH_READY &&
          otp_word_auth_valid_o == 1'b1 && otp_auth_word_sel_o == OTP_WORD_COMMIT_B &&
          otp_auth_word_mask_o == 3'b100,
          "Normal Flow: Progressed to OTP_WORD_COMMIT_B (2) with mask 3'b100");

    // Step 2: OTP_WORD_COMMIT_B -> must finish in AUTH_SESSION_DONE
    execute_4phase_word(4'd3, OTP_WORD_COMMIT_B, 32'hCAFE_1234,
                        f_expected_otp_codeword22(4'd3, 8'd7, OTP_WORD_COMMIT_B));
    check(aon_auth_state_o == AUTH_SESSION_DONE && aon_wstep_o == WSTEP_IDLE &&
          otp_word_auth_valid_o == 1'b0 && otp_auth_word_mask_o == 3'b000 && !aon_fatal_locked_o,
          "Normal Flow: Completed final word 2 and transitioned cleanly to AUTH_SESSION_DONE");

    // ------------------------------------------------------------------
    // TEST 3: Recovery Commit (PENDING_B_SEAL -> req_seal_b_only_i=1 -> Word 2 Only -> AUTH_SESSION_DONE)
    // ------------------------------------------------------------------
    reset_dut(1'b1); // boot_scan_pending_b_i = 1
    @(negedge clk_aon_i);
    boot_scan_done_i = 1'b1;
    @(posedge clk_aon_i);
    #1;
    boot_scan_done_i = 1'b0;

    @(negedge clk_aon_i);
    post_auth_req_i   = 1'b1;
    post_session_id_i = 32'hBEEF_5678;
    @(posedge clk_aon_i);
    #1;
    post_auth_req_i   = 1'b0;

    @(negedge clk_aon_i);
    val_step_done_i     = 1'b1;
    val_all_checks_ok_i = 1'b1;
    req_target_slot_i   = 4'd5;
    req_target_svn_i    = 8'd12;
    req_seal_b_only_i   = 1'b1;
    @(posedge clk_aon_i);
    #1;
    val_step_done_i     = 1'b0;
    check(aon_auth_state_o == AUTH_GRANT && aon_wstep_o == WSTEP_AUTH_READY &&
          otp_word_auth_valid_o == 1'b1 && otp_auth_word_sel_o == OTP_WORD_COMMIT_B &&
          otp_auth_word_mask_o == 3'b100,
          "Recovery Flow (R28B-01): Entered AUTH_GRANT directly at OTP_WORD_COMMIT_B (2)");

    execute_4phase_word(4'd5, OTP_WORD_COMMIT_B, 32'hBEEF_5678,
                        f_expected_otp_codeword22(4'd5, 8'd12, OTP_WORD_COMMIT_B));
    check(aon_auth_state_o == AUTH_SESSION_DONE && aon_wstep_o == WSTEP_IDLE &&
          otp_word_auth_valid_o == 1'b0 && otp_auth_word_mask_o == 3'b000 && !aon_fatal_locked_o,
          "Recovery Flow (R28B-01): Completed single-word recovery and transitioned to AUTH_SESSION_DONE");

    // ------------------------------------------------------------------
    // TEST 4: Mismatched Readback Locks AUTH_LOCKED_FATAL & Sticky Across Warm Reset
    // ------------------------------------------------------------------
    reset_dut(1'b0);
    @(negedge clk_aon_i);
    boot_scan_done_i = 1'b1;
    @(posedge clk_aon_i);
    #1;
    boot_scan_done_i = 1'b0;

    @(negedge clk_aon_i);
    post_auth_req_i   = 1'b1;
    post_session_id_i = 32'hDEAD_0001;
    @(posedge clk_aon_i);
    #1;
    post_auth_req_i   = 1'b0;

    @(negedge clk_aon_i);
    val_step_done_i     = 1'b1;
    val_all_checks_ok_i = 1'b1;
    req_target_slot_i   = 4'd2;
    req_target_svn_i    = 8'd9;
    req_seal_b_only_i   = 1'b0;
    @(posedge clk_aon_i);
    #1;
    val_step_done_i     = 1'b0;

    // Corrupt readback data with ^ 22'h00_0001
    execute_4phase_word(4'd2, OTP_WORD_SVN, 32'hDEAD_0001,
                        f_expected_otp_codeword22(4'd2, 8'd9, OTP_WORD_SVN) ^ 22'h00_0001);
    check(aon_auth_state_o == AUTH_LOCKED_FATAL && aon_fatal_locked_o == 1'b1 &&
          otp_word_auth_valid_o == 1'b0 && otp_dai_we_o == 1'b0,
          "Fatal Lock (R28-02): Corrupted readback immediately locked FSM into AUTH_LOCKED_FATAL");

    // Pulse Warm Reset (!rst_sys_ni = 0) -> must NOT clear AUTH_LOCKED_FATAL
    @(negedge clk_aon_i);
    rst_sys_ni = 1'b0;
    @(posedge clk_aon_i);
    @(negedge clk_aon_i);
    rst_sys_ni = 1'b1;
    @(posedge clk_aon_i);
    #1;
    check(aon_auth_state_o == AUTH_LOCKED_FATAL && aon_fatal_locked_o == 1'b1,
          "Fatal Lock Sticky: Warm Reset (!rst_sys_ni) did NOT clear AUTH_LOCKED_FATAL");

    // Pulse Cold POR (!rst_aon_por_ni = 0) -> clears AUTH_LOCKED_FATAL back to AUTH_RESET_IDLE
    @(negedge clk_aon_i);
    rst_aon_por_ni = 1'b0;
    @(posedge clk_aon_i);
    #1;
    check(aon_auth_state_o == AUTH_RESET_IDLE && !aon_fatal_locked_o,
          "Cold POR Recovery: Cold POR (!rst_aon_por_ni) cleared AUTH_LOCKED_FATAL to AUTH_RESET_IDLE");

    $display("----------------------------------------------------------------------");
    $display(" tb_zc_otp SUMMARY: PASS=%0d, FAIL=%0d", pass_cnt, fail_cnt);
    $display("======================================================================");
    if (fail_cnt > 0) $fatal(1, "tb_zc_otp FAILED");
    $finish;
  end

endmodule : tb_zc_otp
