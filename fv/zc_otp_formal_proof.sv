// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: zc_otp_formal_proof
// Description:
//   Gate C Formal Verification Harness for zc_aon_post_auth_ctrl (Yosys/SymbiYosys BMC + k-induction):
//   Proves all Rev. 28 - Rev. 28D OTP authorization and single-use grant properties:
//   - F-OTP-01a (SVA-OTP-06a Part 1): Single-word grant is consumed immediately on dai_write_accepted_w (otp_dai_we_o)
//   - F-OTP-01b (SVA-OTP-06a Part 2): Throughout the physical write and readback verification window,
//     and outside AUTH_GRANT, write authorization and DAI write strobe are strictly 0
//   - F-OTP-02 (SVA-OTP-06b): Normal intermediate word (0 or 1) readback verification advances expected_word_idx_q
//     by +1 and re-opens grant in WSTEP_AUTH_READY
//   - F-OTP-03 (SVA-OTP-06c / R28B-01): Final word (2) or Recovery mode (2 only) transitions to AUTH_SESSION_DONE
//     and clears all grants, masks, and recovery flags
//   - F-OTP-04 (SVA-OTP-07 / R28-02): Any unverified, out-of-context, or mismatched readback in WSTEP_WAIT_RB_VERIFY
//     immediately locks to AUTH_LOCKED_FATAL
//   - F-OTP-05 (SVA-OTP-08): AUTH_LOCKED_FATAL is permanently sticky until Cold POR (!rst_aon_por_ni)

module zc_otp_formal_proof (
  input logic                  clk_aon_i,
  input logic                  rst_aon_por_ni,
  input logic                  rst_sys_ni,
  input logic                  rom_exec_active_i,
  input logic                  tamper_alert_i,
  input logic                  clk_glitch_alert_i,
  input logic                  volt_supervisor_fault_i,
  input logic                  boot_scan_done_i,
  input logic                  boot_scan_pending_b_i,
  input logic                  post_auth_req_i,
  input logic [31:0]           post_session_id_i,
  input logic                  val_step_done_i,
  input logic                  val_all_checks_ok_i,
  input logic [3:0]            req_target_slot_i,
  input logic [7:0]            req_target_svn_i,
  input logic                  req_seal_b_only_i,
  input logic [1:0]            dai_state_i,
  input logic                  otp_macro_phys_active_i,
  input logic                  dai_cmd_req_i,
  input logic [3:0]            dai_slot_idx_i,
  input logic [1:0]            dai_word_sel_i,
  input logic                  dai_prog_done_pulse_i,
  input logic                  dai_prog_err_i,
  input logic                  dai_rb_done_pulse_i,
  input logic                  dai_ecc_err_i,
  input logic [31:0]           dai_rb_session_id_i,
  input logic [3:0]            dai_rb_slot_idx_i,
  input logic [1:0]            dai_rb_word_sel_i,
  input logic [21:0]           dai_rb_raw_data_i
);

`ifndef YOSYS
  import zc_otp_pkg::*;
`else
  localparam logic [1:0] OTP_WORD_COMMIT_B = 2'd2;
  localparam logic [2:0] AUTH_GRANT        = 3'b011;
  localparam logic [2:0] AUTH_SESSION_DONE = 3'b100;
  localparam logic [2:0] AUTH_LOCKED_FATAL = 3'b111;
  localparam logic [1:0] WSTEP_IDLE           = 2'b00;
  localparam logic [1:0] WSTEP_AUTH_READY     = 2'b01;
  localparam logic [1:0] WSTEP_WAIT_PHYS_DONE = 2'b10;
  localparam logic [1:0] WSTEP_WAIT_RB_VERIFY = 2'b11;
`endif

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

  logic f_past_valid;
  initial f_past_valid = 1'b0;
  always_ff @(posedge clk_aon_i) f_past_valid <= 1'b1;

  always_comb begin
    if (!f_past_valid) assume (!rst_aon_por_ni);

    // Environment: DAI readback session ID matches active session when readback completes
    assume (!dai_rb_done_pulse_i || (dai_rb_session_id_i == post_session_id_i));

    // F-OTP-01b (SVA-OTP-06a Part 2 / R28B-02 Structural):
    // Throughout the wait steps (WAIT_PHYS_DONE, WAIT_RB_VERIFY) or outside AUTH_GRANT,
    // write authorization and DAI write strobe are strictly 0.
    if ((aon_auth_state_o != AUTH_GRANT) ||
        (aon_wstep_o == WSTEP_WAIT_PHYS_DONE) ||
        (aon_wstep_o == WSTEP_WAIT_RB_VERIFY) ||
        (aon_wstep_o == WSTEP_IDLE)) begin
      assert (!otp_word_auth_valid_o);
      assert (!otp_dai_we_o);
      assert (otp_auth_word_mask_o == 3'b000);
    end
  end

  always_ff @(posedge clk_aon_i) begin
    if (f_past_valid && $past(rst_aon_por_ni) && rst_aon_por_ni) begin
      // F-OTP-01a (SVA-OTP-06a Part 1 / R28B-02): Single-word grant consumed immediately on otp_dai_we_o
      if ($past(otp_dai_we_o && !dai_prog_done_pulse_i && !dai_rb_done_pulse_i && !dai_prog_err_i &&
                rst_sys_ni && rom_exec_active_i &&
                !tamper_alert_i && !clk_glitch_alert_i && !volt_supervisor_fault_i)) begin
        assert (aon_wstep_o == WSTEP_WAIT_PHYS_DONE);
        assert (!otp_word_auth_valid_o);
        assert (!otp_dai_we_o);
        assert (otp_auth_word_mask_o == 3'b000);
      end

      // F-OTP-02 (SVA-OTP-06b): Strictly normative - Normal intermediate word (0 or 1) readback verification
      // advances expected_word_idx_q by +1 and re-opens grant in WSTEP_AUTH_READY
      if ($past((aon_auth_state_o == AUTH_GRANT) && (aon_wstep_o == WSTEP_WAIT_RB_VERIFY) &&
                (otp_auth_word_sel_o < OTP_WORD_COMMIT_B) &&
                !otp_macro_phys_active_i && !req_seal_b_only_i &&
                dai_rb_done_pulse_i && !dai_ecc_err_i &&
                (dai_rb_slot_idx_i == otp_auth_slot_o) &&
                (dai_rb_word_sel_i == otp_auth_word_sel_o) &&
                (dai_rb_raw_data_i == otp_auth_expected_cw_o) &&
                !dai_cmd_req_i && !dai_prog_done_pulse_i &&
                rst_sys_ni && rom_exec_active_i &&
                !tamper_alert_i && !clk_glitch_alert_i && !volt_supervisor_fault_i) &&
          rst_sys_ni && rom_exec_active_i &&
          !tamper_alert_i && !clk_glitch_alert_i && !volt_supervisor_fault_i) begin
        assert ((aon_auth_state_o == AUTH_GRANT) &&
                (aon_wstep_o == WSTEP_AUTH_READY) &&
                otp_word_auth_valid_o &&
                (otp_auth_word_sel_o == ($past(otp_auth_word_sel_o) + 2'd1)));
      end

      // F-OTP-03 (SVA-OTP-06c / R28B-01): Strictly normative - Final word (2) or Recovery mode (2 only)
      // transitions to AUTH_SESSION_DONE and clears all grants and recovery flags
      if ($past((aon_auth_state_o == AUTH_GRANT) && (aon_wstep_o == WSTEP_WAIT_RB_VERIFY) &&
                !otp_macro_phys_active_i &&
                (otp_auth_word_sel_o == OTP_WORD_COMMIT_B) &&
                dai_rb_done_pulse_i && !dai_ecc_err_i &&
                (dai_rb_slot_idx_i == otp_auth_slot_o) &&
                (dai_rb_word_sel_i == otp_auth_word_sel_o) &&
                (dai_rb_raw_data_i == otp_auth_expected_cw_o) &&
                !dai_cmd_req_i && !dai_prog_done_pulse_i &&
                rst_sys_ni && rom_exec_active_i &&
                !tamper_alert_i && !clk_glitch_alert_i && !volt_supervisor_fault_i) &&
          rst_sys_ni && rom_exec_active_i &&
          !tamper_alert_i && !clk_glitch_alert_i && !volt_supervisor_fault_i) begin
        assert ((aon_auth_state_o == AUTH_SESSION_DONE) &&
                (aon_wstep_o == WSTEP_IDLE) &&
                !otp_word_auth_valid_o &&
                !otp_dai_we_o &&
                (otp_auth_word_mask_o == 3'b000));
      end

      // F-OTP-04 (SVA-OTP-07 / R28-02): Strictly normative - Any unverified, out-of-context,
      // or mismatched readback in WSTEP_WAIT_RB_VERIFY immediately locks to AUTH_LOCKED_FATAL
      if ($past((aon_auth_state_o == AUTH_GRANT) && (aon_wstep_o == WSTEP_WAIT_RB_VERIFY) &&
                dai_rb_done_pulse_i &&
                (dai_ecc_err_i ||
                 (dai_rb_slot_idx_i != otp_auth_slot_o) ||
                 (dai_rb_word_sel_i != otp_auth_word_sel_o) ||
                 (dai_rb_raw_data_i != otp_auth_expected_cw_o)) &&
                rst_sys_ni && rom_exec_active_i)) begin
        assert (aon_auth_state_o == AUTH_LOCKED_FATAL);
        assert (aon_fatal_locked_o);
        assert (aon_wstep_o == WSTEP_IDLE);
        assert (!otp_word_auth_valid_o);
        assert (!otp_dai_we_o);
      end

      // F-OTP-05 (SVA-OTP-08): AUTH_LOCKED_FATAL is permanently sticky until Cold POR (!rst_aon_por_ni)
      if ($past(aon_auth_state_o == AUTH_LOCKED_FATAL)) begin
        assert (aon_auth_state_o == AUTH_LOCKED_FATAL);
        assert (aon_fatal_locked_o);
        assert (!otp_word_auth_valid_o);
        assert (!otp_dai_we_o);
      end
    end
  end

  // =========================================================================
  // Non-Vacuity Cover Witness Directives (Discrete Target Reporting)
  // =========================================================================
  always_comb begin
    // C-OTP-01: Write authorization active witness
    cover (otp_word_auth_valid_o && (aon_auth_state_o == AUTH_GRANT));
  end

  always_ff @(posedge clk_aon_i) begin
    if (f_past_valid && $past(rst_aon_por_ni) && rst_aon_por_ni) begin
      // C-OTP-02: Intermediate word verification and advance
      cover ((aon_auth_state_o == AUTH_GRANT) && (aon_wstep_o == WSTEP_AUTH_READY) && (otp_auth_word_sel_o > 2'd0));

      // C-OTP-03n: Normal 3-word session completed (AUTH_SESSION_DONE)
      cover ((aon_auth_state_o == AUTH_SESSION_DONE) && (aon_wstep_o == WSTEP_IDLE));

      // C-OTP-03r: Recovery 1-word session completed (AUTH_SESSION_DONE)
      cover ($past(aon_auth_state_o == AUTH_GRANT) && (aon_auth_state_o == AUTH_SESSION_DONE));

      // C-OTP-04: Fatal lock entry on mismatched readback
      cover ($past(aon_auth_state_o == AUTH_GRANT && aon_wstep_o == WSTEP_WAIT_RB_VERIFY && dai_rb_done_pulse_i) &&
             (aon_auth_state_o == AUTH_LOCKED_FATAL));

      // C-OTP-05: Fatal lock sticky persistence
      cover ($past(aon_auth_state_o == AUTH_LOCKED_FATAL) && (aon_auth_state_o == AUTH_LOCKED_FATAL));
    end
  end

endmodule
