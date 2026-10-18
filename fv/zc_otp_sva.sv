// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: zc_otp_sva
// Status: [GATE-C VERIFICATION OBLIGATION / UNVERIFIED]
// Description:
//   Bindable SystemVerilog Assertions (SVA) for zc_aon_post_auth_ctrl
//   covering Gate B Rev. 28 - Rev. 28D OTP authorization, single-use grant consumption,
//   normal vs. recovery completion, and fatal lock transitions.

module zc_otp_sva
  import zc_otp_pkg::*;
(
  input logic            clk_aon_i,
  input logic            rst_aon_por_ni,
  input logic            rst_sys_ni,
  input logic            rom_exec_active_i,
  input logic            tamper_alert_i,
  input logic            clk_glitch_alert_i,
  input logic            volt_supervisor_fault_i,
  input logic            dai_prog_done_pulse_i,
  input logic            dai_rb_done_pulse_i,
  input logic            otp_word_auth_valid_o,
  input logic            otp_dai_we_o,
  input logic [2:0]      otp_auth_word_mask_o,
  input aon_auth_state_e aon_auth_state_q,
  input otp_wstep_e      wstep_q,
  input logic            word_grant_avail_q,
  input logic [1:0]      expected_word_idx_q,
  input logic            val_ctx_seal_b_only_q,
  input logic            pending_b_exists_q,
  input logic            write_authorized_w,
  input logic            dai_write_accepted_w,
  input logic            readback_verified_w,
  input logic            any_session_done_ok_w
);

  // SVA-OTP-06a (R28B-02): Single-word grant is consumed immediately on dai_write_accepted_w
  // and stays 0 throughout the physical write and readback verification window.
  a_otp_grant_consumed_on_accept:
    assert property (@(posedge clk_aon_i) disable iff (!rst_aon_por_ni)
      dai_write_accepted_w
      |=> (!write_authorized_w && !word_grant_avail_q && !otp_dai_we_o)
          throughout (dai_rb_done_pulse_i[->1])
    );

  // SVA-OTP-06b: In normal mode, intermediate word (0 or 1) readback verification
  // opens the grant for the exact next sequential word.
  a_otp_normal_step_progression:
    assert property (@(posedge clk_aon_i) disable iff (!rst_aon_por_ni)
      (readback_verified_w && !val_ctx_seal_b_only_q && (expected_word_idx_q < OTP_WORD_COMMIT_B) &&
       rst_sys_ni && rom_exec_active_i &&
       !tamper_alert_i && !clk_glitch_alert_i && !volt_supervisor_fault_i)
      |=> (aon_auth_state_q == AUTH_GRANT) &&
          (wstep_q == WSTEP_AUTH_READY) &&
          word_grant_avail_q &&
          (expected_word_idx_q == ($past(expected_word_idx_q) + 2'd1))
    );

  // SVA-OTP-06c (R28B-01): Both normal mode final word (2'd2) and recovery mode (2'd2 only)
  // transition to AUTH_SESSION_DONE and clear all grants and recovery flags.
  a_otp_both_modes_complete_and_clean:
    assert property (@(posedge clk_aon_i) disable iff (!rst_aon_por_ni)
      (any_session_done_ok_w && rst_sys_ni && rom_exec_active_i &&
       !tamper_alert_i && !clk_glitch_alert_i && !volt_supervisor_fault_i)
      |=> (aon_auth_state_q == AUTH_SESSION_DONE) &&
          (wstep_q == WSTEP_IDLE) &&
          !word_grant_avail_q &&
          !val_ctx_seal_b_only_q &&
          !pending_b_exists_q &&
          !otp_word_auth_valid_o &&
          (otp_auth_word_mask_o == 3'b000)
    );

  // SVA-OTP-07 (R28-02): Out-of-context or mismatched readback immediately locks AUTH_LOCKED_FATAL.
  a_otp_mismatched_readback_locks_fatal:
    assert property (@(posedge clk_aon_i) disable iff (!rst_aon_por_ni)
      ((aon_auth_state_q == AUTH_GRANT) && (wstep_q == WSTEP_WAIT_RB_VERIFY) &&
       dai_rb_done_pulse_i && !readback_verified_w)
      |=> (aon_auth_state_q == AUTH_LOCKED_FATAL) &&
          !word_grant_avail_q &&
          (wstep_q == WSTEP_IDLE) &&
          !otp_word_auth_valid_o
    );

  // SVA-OTP-08: AUTH_LOCKED_FATAL is sticky until Cold POR (!rst_aon_por_ni).
  a_otp_fatal_lock_sticky_until_por:
    assert property (@(posedge clk_aon_i) disable iff (!rst_aon_por_ni)
      (aon_auth_state_q == AUTH_LOCKED_FATAL)
      |=> (aon_auth_state_q == AUTH_LOCKED_FATAL) && !otp_word_auth_valid_o && !otp_dai_we_o
    );

endmodule : zc_otp_sva
