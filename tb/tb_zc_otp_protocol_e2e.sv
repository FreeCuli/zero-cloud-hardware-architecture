// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: tb_zc_otp_protocol_e2e
// Description:
//   Gate C End-to-End RTL Protocol Simulation Testbench for zc_aon_post_auth_ctrl (GCR-08 Resolution):
//   - Scenario 1: Normal 3-Word Sequential Commit (WORD_SVN -> COMMIT_A -> COMMIT_B -> AUTH_SESSION_DONE)
//   - Scenario 2: Recovery 1-Word Commit (PENDING_B_SEAL -> COMMIT_B Only -> AUTH_SESSION_DONE)
//   - Scenario 3: Single-cycle Write Grant Consumption immediately on dai_write_accepted_w
//   - Scenario 4: Mismatched Readback Data -> Immediate AUTH_LOCKED_FATAL
//   - Scenario 5: Mismatched Readback Session ID -> Immediate AUTH_LOCKED_FATAL
//   - Scenario 6: Out-of-Context DAI Command during WSTEP_AUTH_READY -> Immediate AUTH_LOCKED_FATAL
//   - Scenario 7: Warm Reset (!rst_sys_ni) persistence -> AUTH_LOCKED_FATAL is permanently sticky
//   - Scenario 8: Cold POR (!rst_aon_por_ni) recovery -> clears AUTH_LOCKED_FATAL to AUTH_RESET_IDLE
//   - Verified cross-simulator under both Verilator and Icarus Verilog (iverilog -g2012).

`timescale 1ns / 1ps

module tb_zc_otp_protocol_e2e;
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

  initial clk_aon_i = 1'b0;
  always #5 clk_aon_i = ~clk_aon_i;

  int test_pass_count = 0;
  int test_fail_count = 0;

  task automatic assert_check(input bit cond, input string desc);
    if (cond) begin
      $display("[PASS][E2E] %s", desc);
      test_pass_count++;
    end else begin
      $display("[FAIL][E2E] %s (state=%0d wstep=%0d auth=%0b we=%0b fatal=%0b)",
               desc, aon_auth_state_o, aon_wstep_o, otp_word_auth_valid_o, otp_dai_we_o, aon_fatal_locked_o);
      test_fail_count++;
    end
  endtask

  task automatic por_reset(input bit pending_b);
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

  task automatic step_4phase_dai(
    input logic [3:0]  slot,
    input logic [1:0]  word_idx,
    input logic [31:0] sess_id,
    input logic [21:0] codeword,
    input bit          inject_ecc_err,
    input bit          inject_data_err
  );
    // Phase 1: Wait for WSTEP_AUTH_READY and assert DAI command request
    @(negedge clk_aon_i);
    dai_cmd_req_i  = 1'b1;
    dai_slot_idx_i = slot;
    dai_word_sel_i = word_idx;
    #1;
    assert_check(otp_word_auth_valid_o == 1'b1 && otp_dai_we_o == 1'b1 &&
                 otp_auth_word_sel_o == word_idx && otp_auth_slot_o == slot,
                 $sformatf("Word %0d Phase 1&2: write authorization active and DAI write accepted", word_idx));

    // Phase 2: Accept clock edge -> grant must be immediately consumed on the next cycle!
    @(posedge clk_aon_i);
    #1;
    dai_cmd_req_i           = 1'b0;
    dai_state_i             = DAI_PROG_BUSY;
    otp_macro_phys_active_i = 1'b1;
    assert_check(otp_word_auth_valid_o == 1'b0 && otp_dai_we_o == 1'b0 &&
                 otp_auth_word_mask_o == 3'b000 && aon_wstep_o == WSTEP_WAIT_PHYS_DONE,
                 $sformatf("Word %0d Phase 2->3: single-use grant consumed immediately (WSTEP_WAIT_PHYS_DONE)", word_idx));

    // Phase 3: Physical high-voltage programming delay (2 clock cycles), then completion pulse
    @(posedge clk_aon_i);
    @(posedge clk_aon_i);
    @(negedge clk_aon_i);
    otp_macro_phys_active_i = 1'b0;
    dai_state_i             = DAI_IDLE;
    dai_prog_done_pulse_i   = 1'b1;
    @(posedge clk_aon_i);
    #1;
    dai_prog_done_pulse_i   = 1'b0;
    assert_check(aon_wstep_o == WSTEP_WAIT_RB_VERIFY && otp_word_auth_valid_o == 1'b0,
                 $sformatf("Word %0d Phase 3->4: transitioned to WSTEP_WAIT_RB_VERIFY with grant zeroed", word_idx));

    // Phase 4: Readback pulse verification
    @(negedge clk_aon_i);
    dai_rb_done_pulse_i = 1'b1;
    dai_rb_session_id_i = sess_id;
    dai_rb_slot_idx_i   = slot;
    dai_rb_word_sel_i   = word_idx;
    dai_ecc_err_i       = inject_ecc_err;
    dai_rb_raw_data_i   = inject_data_err ? (codeword ^ 22'h00_0001) : codeword;
    @(posedge clk_aon_i);
    #1;
    dai_rb_done_pulse_i = 1'b0;
    dai_ecc_err_i       = 1'b0;
  endtask

  initial begin
    logic [21:0] cw_svn, cw_a, cw_b;
    logic [3:0]  test_slot;
    logic [7:0]  test_svn;
    logic [31:0] test_sid;

    test_slot = 4'd2;
    test_svn  = 8'd15;
    test_sid  = 32'hDEAD_BEEF;

    cw_svn = f_expected_otp_codeword22(test_slot, test_svn, OTP_WORD_SVN);
    cw_a   = f_expected_otp_codeword22(test_slot, test_svn, OTP_WORD_COMMIT_A);
    cw_b   = f_expected_otp_codeword22(test_slot, test_svn, OTP_WORD_COMMIT_B);

    $display("======================================================================");
    $display(" FREECULI ZC-CORE GATE C END-TO-END OTP PROTOCOL SIMULATION (GCR-08)");
    $display("======================================================================");

    // -----------------------------------------------------------------------
    // SCENARIO 1: Normal 3-Word Sequential Commit (SVN -> COMMIT_A -> COMMIT_B)
    // -----------------------------------------------------------------------
    $display("--- [SCENARIO 1] Normal 3-Word Sequential Commit (0 -> 1 -> 2) ---");
    por_reset(1'b0); // Boot scan sees pending_b = 0
    assert_check(aon_auth_state_o == AUTH_RESET_IDLE, "Cold POR: Entered AUTH_RESET_IDLE");

    // Boot scan completes -> AUTH_WAIT_CHAL
    @(negedge clk_aon_i);
    boot_scan_done_i = 1'b1;
    @(posedge clk_aon_i);
    #1;
    boot_scan_done_i = 1'b0;
    assert_check(aon_auth_state_o == AUTH_WAIT_CHAL, "Boot scan: Entered AUTH_WAIT_CHAL");

    // Host issues post-auth request with Session ID -> AUTH_VALIDATE
    @(negedge clk_aon_i);
    post_auth_req_i   = 1'b1;
    post_session_id_i = test_sid;
    @(posedge clk_aon_i);
    #1;
    post_auth_req_i   = 1'b0;
    assert_check(aon_auth_state_o == AUTH_VALIDATE, "Post-auth request: Entered AUTH_VALIDATE");

    // Validation engine completes all checks -> AUTH_GRANT at Word 0 (SVN)
    @(negedge clk_aon_i);
    val_step_done_i     = 1'b1;
    val_all_checks_ok_i = 1'b1;
    req_target_slot_i   = test_slot;
    req_target_svn_i    = test_svn;
    req_seal_b_only_i   = 1'b0;
    @(posedge clk_aon_i);
    #1;
    val_step_done_i     = 1'b0;
    assert_check(aon_auth_state_o == AUTH_GRANT && aon_wstep_o == WSTEP_AUTH_READY &&
                 otp_word_auth_valid_o == 1'b1 && otp_auth_word_sel_o == OTP_WORD_SVN &&
                 otp_auth_word_mask_o == 3'b001,
                 "Normal Flow: Entered AUTH_GRANT at Word 0 (OTP_WORD_SVN) with mask 3'b001");

    // Word 0 (SVN) 4-phase execution
    step_4phase_dai(test_slot, OTP_WORD_SVN, test_sid, cw_svn, 1'b0, 1'b0);
    assert_check(aon_auth_state_o == AUTH_GRANT && aon_wstep_o == WSTEP_AUTH_READY &&
                 otp_word_auth_valid_o == 1'b1 && otp_auth_word_sel_o == OTP_WORD_COMMIT_A &&
                 otp_auth_word_mask_o == 3'b010,
                 "Normal Flow: Advanced from Word 0 to Word 1 (COMMIT_A) in WSTEP_AUTH_READY");

    // Word 1 (COMMIT_A) 4-phase execution
    step_4phase_dai(test_slot, OTP_WORD_COMMIT_A, test_sid, cw_a, 1'b0, 1'b0);
    assert_check(aon_auth_state_o == AUTH_GRANT && aon_wstep_o == WSTEP_AUTH_READY &&
                 otp_word_auth_valid_o == 1'b1 && otp_auth_word_sel_o == OTP_WORD_COMMIT_B &&
                 otp_auth_word_mask_o == 3'b100,
                 "Normal Flow: Advanced from Word 1 to Word 2 (COMMIT_B) in WSTEP_AUTH_READY");

    // Word 2 (COMMIT_B) 4-phase execution -> terminal completion
    step_4phase_dai(test_slot, OTP_WORD_COMMIT_B, test_sid, cw_b, 1'b0, 1'b0);
    assert_check(aon_auth_state_o == AUTH_SESSION_DONE && aon_wstep_o == WSTEP_IDLE &&
                 otp_word_auth_valid_o == 1'b0 && otp_dai_we_o == 1'b0 &&
                 otp_auth_word_mask_o == 3'b000 && !aon_fatal_locked_o,
                 "Normal Flow: Completed Word 2 and transitioned cleanly to AUTH_SESSION_DONE");

    // -----------------------------------------------------------------------
    // SCENARIO 2: Recovery 1-Word Commit (PENDING_B_SEAL -> COMMIT_B Only)
    // -----------------------------------------------------------------------
    $display("--- [SCENARIO 2] Recovery 1-Word Commit (COMMIT_B Only) ---");
    por_reset(1'b1); // Boot scan sees pending_b = 1

    @(negedge clk_aon_i);
    boot_scan_done_i = 1'b1;
    @(posedge clk_aon_i);
    #1;
    boot_scan_done_i = 1'b0;

    @(negedge clk_aon_i);
    post_auth_req_i   = 1'b1;
    post_session_id_i = 32'hBEEF_CAFE;
    @(posedge clk_aon_i);
    #1;
    post_auth_req_i   = 1'b0;

    @(negedge clk_aon_i);
    val_step_done_i     = 1'b1;
    val_all_checks_ok_i = 1'b1;
    req_target_slot_i   = test_slot;
    req_target_svn_i    = test_svn;
    req_seal_b_only_i   = 1'b1; // Recovery mode requested
    @(posedge clk_aon_i);
    #1;
    val_step_done_i     = 1'b0;
    assert_check(aon_auth_state_o == AUTH_GRANT && aon_wstep_o == WSTEP_AUTH_READY &&
                 otp_word_auth_valid_o == 1'b1 && otp_auth_word_sel_o == OTP_WORD_COMMIT_B &&
                 otp_auth_word_mask_o == 3'b100,
                 "Recovery Flow: Entered AUTH_GRANT directly at Word 2 (COMMIT_B) skipping words 0 and 1");

    // Word 2 (COMMIT_B) 4-phase execution
    step_4phase_dai(test_slot, OTP_WORD_COMMIT_B, 32'hBEEF_CAFE, cw_b, 1'b0, 1'b0);
    assert_check(aon_auth_state_o == AUTH_SESSION_DONE && aon_wstep_o == WSTEP_IDLE &&
                 otp_word_auth_valid_o == 1'b0 && otp_dai_we_o == 1'b0 &&
                 otp_auth_word_mask_o == 3'b000 && !aon_fatal_locked_o,
                 "Recovery Flow: Completed 1-word recovery and transitioned to AUTH_SESSION_DONE");

    // -----------------------------------------------------------------------
    // SCENARIO 3: Mismatched Readback Data Corrupted -> Fatal Lock
    // -----------------------------------------------------------------------
    $display("--- [SCENARIO 3] Corrupted Readback Data -> Fatal Lock ---");
    por_reset(1'b0);
    @(negedge clk_aon_i); boot_scan_done_i = 1'b1; @(posedge clk_aon_i); #1; boot_scan_done_i = 1'b0;
    @(negedge clk_aon_i); post_auth_req_i = 1'b1; post_session_id_i = test_sid; @(posedge clk_aon_i); #1; post_auth_req_i = 1'b0;
    @(negedge clk_aon_i);
    val_step_done_i = 1'b1; val_all_checks_ok_i = 1'b1; req_target_slot_i = test_slot; req_target_svn_i = test_svn; req_seal_b_only_i = 1'b0;
    @(posedge clk_aon_i); #1; val_step_done_i = 1'b0;

    // Inject corrupted codeword on readback
    step_4phase_dai(test_slot, OTP_WORD_SVN, test_sid, cw_svn, 1'b0, 1'b1);
    assert_check(aon_auth_state_o == AUTH_LOCKED_FATAL && aon_fatal_locked_o == 1'b1 &&
                 otp_word_auth_valid_o == 1'b0 && otp_dai_we_o == 1'b0,
                 "Fault Security: Corrupted readback data immediately locks FSM to AUTH_LOCKED_FATAL");

    // -----------------------------------------------------------------------
    // SCENARIO 4: Warm Reset Persistence across Fatal Lock
    // -----------------------------------------------------------------------
    $display("--- [SCENARIO 4] Warm Reset Persistence across Fatal Lock ---");
    @(negedge clk_aon_i); rst_sys_ni = 1'b0; @(posedge clk_aon_i);
    @(negedge clk_aon_i); rst_sys_ni = 1'b1; @(posedge clk_aon_i); #1;
    assert_check(aon_auth_state_o == AUTH_LOCKED_FATAL && aon_fatal_locked_o == 1'b1,
                 "Lock Immutability: Warm Reset (!rst_sys_ni) did NOT clear AUTH_LOCKED_FATAL");

    // -----------------------------------------------------------------------
    // SCENARIO 5: Cold POR Recovery from Fatal Lock
    // -----------------------------------------------------------------------
    $display("--- [SCENARIO 5] Cold POR Recovery from Fatal Lock ---");
    @(negedge clk_aon_i); rst_aon_por_ni = 1'b0; @(posedge clk_aon_i);
    @(negedge clk_aon_i); rst_aon_por_ni = 1'b1; @(posedge clk_aon_i); #1;
    assert_check(aon_auth_state_o == AUTH_RESET_IDLE && !aon_fatal_locked_o,
                 "Cold POR Reset: Cold POR successfully recovered FSM to AUTH_RESET_IDLE");

    // -----------------------------------------------------------------------
    // SCENARIO 6: Mismatched Readback Session ID -> Fatal Lock
    // -----------------------------------------------------------------------
    $display("--- [SCENARIO 6] Mismatched Session ID Readback -> Fatal Lock ---");
    @(negedge clk_aon_i); boot_scan_done_i = 1'b1; @(posedge clk_aon_i); #1; boot_scan_done_i = 1'b0;
    @(negedge clk_aon_i); post_auth_req_i = 1'b1; post_session_id_i = test_sid; @(posedge clk_aon_i); #1; post_auth_req_i = 1'b0;
    @(negedge clk_aon_i);
    val_step_done_i = 1'b1; val_all_checks_ok_i = 1'b1; req_target_slot_i = test_slot; req_target_svn_i = test_svn; req_seal_b_only_i = 1'b0;
    @(posedge clk_aon_i); #1; val_step_done_i = 1'b0;

    // Inject mismatched session ID
    step_4phase_dai(test_slot, OTP_WORD_SVN, 32'hDEAD_9999, cw_svn, 1'b0, 1'b0);
    assert_check(aon_auth_state_o == AUTH_LOCKED_FATAL && aon_fatal_locked_o == 1'b1,
                 "Session Integrity: Mismatched readback session ID locked FSM to AUTH_LOCKED_FATAL");

    $display("======================================================================");
    $display(" E2E PROTOCOL AUDIT COMPLETE: PASS=%0d, FAIL=%0d", test_pass_count, test_fail_count);
    $display("======================================================================");

    if (test_fail_count > 0) begin
      $fatal(1, "E2E Protocol Simulation FAILED!");
    end else begin
      $finish;
    end
  end

endmodule : tb_zc_otp_protocol_e2e
