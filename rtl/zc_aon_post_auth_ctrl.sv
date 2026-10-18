// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: zc_aon_post_auth_ctrl
// Description:
//   Gate B Rev. 28C / 28D Normative AON POST Authorization & Single-Use OTP DAI Controller:
//   - Implements the 4-phase atomic word write/verify contract:
//       1. write_authorized   (otp_word_auth_valid_o)
//       2. dai_write_accepted (dai_write_accepted_w / otp_dai_we_o)
//       3. dai_write_completed(dai_write_completed_w)
//       4. readback_verified  (readback_verified_w)
//   - Consumes single-word grant (word_grant_avail_q <= 1'b0) immediately upon dai_write_accepted_w
//   - Enforces normal sequential commit (WORD_SVN -> WORD_COMMIT_A -> WORD_COMMIT_B)
//     and recovery commit (WORD_COMMIT_B only when req_seal_b_only_i == 1'b1)
//   - Transitions both flows to AUTH_SESSION_DONE and clears all write permissions
//   - Locks permanently to AUTH_LOCKED_FATAL on any out-of-context/mismatched readback
//     or unauthorized DAI activity (recoverable only via Cold POR rst_aon_por_ni)

module zc_aon_post_auth_ctrl
  import zc_otp_pkg::*;
(
  input  logic                  clk_aon_i,
  input  logic                  rst_aon_por_ni,          // Cold POR (only reset that clears AUTH_LOCKED_FATAL)
  input  logic                  rst_sys_ni,              // System Warm Reset status
  input  logic                  rom_exec_active_i,       // Boot ROM execution active

  // Environmental & physical security fault inputs
  input  logic                  tamper_alert_i,
  input  logic                  clk_glitch_alert_i,
  input  logic                  volt_supervisor_fault_i,

  // Boot OTP scanner interface
  input  logic                  boot_scan_done_i,
  input  logic                  boot_scan_pending_b_i,

  // POST Challenge/Validation session interface
  input  logic                  post_auth_req_i,
  input  logic [31:0]           post_session_id_i,
  input  logic                  val_step_done_i,
  input  logic                  val_all_checks_ok_i,
  input  logic [3:0]            req_target_slot_i,       // Slot index k in 0..15
  input  logic [7:0]            req_target_svn_i,        // Strictly increasing SVN v in 1..255
  input  logic                  req_seal_b_only_i,       // 1: PENDING_B_SEAL recovery, 0: normal 3-word commit

  // OTP DAI interface
  input  dai_ctrl_state_e       dai_state_i,
  input  logic                  otp_macro_phys_active_i,
  input  logic                  dai_cmd_req_i,
  input  logic [3:0]            dai_slot_idx_i,
  input  logic [1:0]            dai_word_sel_i,
  input  logic                  dai_prog_done_pulse_i,
  input  logic                  dai_prog_err_i,
  input  logic                  dai_rb_done_pulse_i,
  input  logic                  dai_ecc_err_i,
  input  logic [31:0]           dai_rb_session_id_i,
  input  logic [3:0]            dai_rb_slot_idx_i,
  input  logic [1:0]            dai_rb_word_sel_i,
  input  logic [21:0]           dai_rb_raw_data_i,

  // Authorization outputs to OTP DAI gate
  output logic                  otp_word_auth_valid_o,   // Phase 1: write_authorized
  output logic                  otp_dai_we_o,            // Phase 2: dai_write_accepted single-cycle pulse
  output logic [3:0]            otp_auth_slot_o,
  output logic [7:0]            otp_auth_svn_o,
  output logic [1:0]            otp_auth_word_sel_o,
  output logic [2:0]            otp_auth_word_mask_o,
  output logic [21:0]           otp_auth_expected_cw_o,
  output aon_auth_state_e       aon_auth_state_o,
  output otp_wstep_e            aon_wstep_o,
  output logic                  aon_fatal_locked_o
);

  aon_auth_state_e aon_auth_state_q;
  otp_wstep_e      wstep_q;
  logic            word_grant_avail_q;
  logic [1:0]      expected_word_idx_q;
  logic [3:0]      expected_slot_q;
  logic [7:0]      expected_svn_q;
  logic [21:0]     expected_cw0_q;
  logic [21:0]     expected_cw1_q;
  logic [21:0]     expected_cw2_q;
  logic [31:0]     active_session_id_q;
  logic            val_ctx_seal_b_only_q;
  logic            pending_b_exists_q;

  logic [21:0]     expected_cw_cur_w;
  always_comb begin
    case (expected_word_idx_q)
      OTP_WORD_SVN:      expected_cw_cur_w = expected_cw0_q;
      OTP_WORD_COMMIT_A: expected_cw_cur_w = expected_cw1_q;
      OTP_WORD_COMMIT_B: expected_cw_cur_w = expected_cw2_q;
      default:           expected_cw_cur_w = 22'h3F_FFFF;
    endcase
  end

  // -------------------------------------------------------------------------
  // 4-Phase Atomic Handshake Signals (Rev. 28C Section 1.1 & 1.2)
  // -------------------------------------------------------------------------
  // Phase 1 (write_authorized): Active only in AUTH_GRANT + WSTEP_AUTH_READY when grant is available
  wire write_authorized_w = (aon_auth_state_q == AUTH_GRANT) &&
                            (wstep_q == WSTEP_AUTH_READY) &&
                            word_grant_avail_q &&
                            rst_sys_ni &&
                            rom_exec_active_i;

  assign otp_word_auth_valid_o  = write_authorized_w;
  assign otp_auth_slot_o        = expected_slot_q;
  assign otp_auth_svn_o         = expected_svn_q;
  assign otp_auth_word_sel_o    = expected_word_idx_q;
  assign otp_auth_word_mask_o   = write_authorized_w ? (3'b001 << expected_word_idx_q) : 3'b000;
  assign otp_auth_expected_cw_o = expected_cw_cur_w;

  // Phase 2 (dai_write_accepted): Single-cycle handshake consuming the word grant
  wire dai_write_accepted_w = write_authorized_w &&
                              dai_cmd_req_i &&
                              (dai_state_i == DAI_IDLE) &&
                              !otp_macro_phys_active_i &&
                              (dai_slot_idx_i == expected_slot_q) &&
                              (dai_word_sel_i == expected_word_idx_q);

  assign otp_dai_we_o = dai_write_accepted_w;

  // Phase 3 (dai_write_completed): Physical high-voltage programming pulse completed without error
  wire dai_write_completed_w = (aon_auth_state_q == AUTH_GRANT) &&
                               (wstep_q == WSTEP_WAIT_PHYS_DONE) &&
                               dai_prog_done_pulse_i &&
                               !dai_prog_err_i &&
                               !otp_macro_phys_active_i;

  // Phase 4 (readback_verified): Context-bound 22-bit raw Hsiao codeword readback verification
  wire readback_verified_w = (aon_auth_state_q == AUTH_GRANT) &&
                             (wstep_q == WSTEP_WAIT_RB_VERIFY) &&
                             !otp_macro_phys_active_i &&
                             dai_rb_done_pulse_i &&
                             !dai_ecc_err_i &&
                             (dai_rb_session_id_i == active_session_id_q) &&
                             (dai_rb_slot_idx_i   == expected_slot_q) &&
                             (dai_rb_word_sel_i   == expected_word_idx_q) &&
                             (dai_rb_raw_data_i   == expected_cw_cur_w);

  // Explicit completion conditions for Normal (0->1->2) and Recovery (only 2) commit modes
  wire normal_commit_done_ok_w   = readback_verified_w && !val_ctx_seal_b_only_q && (expected_word_idx_q == OTP_WORD_COMMIT_B);
  wire recovery_commit_done_ok_w = readback_verified_w &&  val_ctx_seal_b_only_q && (expected_word_idx_q == OTP_WORD_COMMIT_B);
  wire any_session_done_ok_w     = normal_commit_done_ok_w || recovery_commit_done_ok_w;

  assign aon_auth_state_o   = aon_auth_state_q;
  assign aon_wstep_o        = wstep_q;
  assign aon_fatal_locked_o = (aon_auth_state_q == AUTH_LOCKED_FATAL);

  // -------------------------------------------------------------------------
  // AON Authorization & Word-Step State Machine
  // -------------------------------------------------------------------------
  always_ff @(posedge clk_aon_i or negedge rst_aon_por_ni) begin
    if (!rst_aon_por_ni) begin
      aon_auth_state_q       <= AUTH_RESET_IDLE;
      wstep_q                <= WSTEP_IDLE;
      word_grant_avail_q     <= 1'b0;
      expected_word_idx_q    <= OTP_WORD_SVN;
      expected_slot_q        <= 4'd0;
      expected_svn_q         <= 8'd0;
      expected_cw0_q         <= 22'h0;
      expected_cw1_q         <= 22'h0;
      expected_cw2_q         <= 22'h0;
      active_session_id_q    <= 32'h0;
      val_ctx_seal_b_only_q  <= 1'b0;
      pending_b_exists_q     <= 1'b0;
    end else if (tamper_alert_i || clk_glitch_alert_i || volt_supervisor_fault_i) begin
      aon_auth_state_q       <= AUTH_LOCKED_FATAL;
      wstep_q                <= WSTEP_IDLE;
      word_grant_avail_q     <= 1'b0;
      val_ctx_seal_b_only_q  <= 1'b0;
    end else begin
      case (aon_auth_state_q)
        AUTH_RESET_IDLE: begin
          wstep_q            <= WSTEP_IDLE;
          word_grant_avail_q <= 1'b0;
          if (boot_scan_done_i) begin
            pending_b_exists_q <= boot_scan_pending_b_i;
            aon_auth_state_q   <= AUTH_WAIT_CHAL;
          end
        end

        AUTH_WAIT_CHAL: begin
          if (dai_prog_done_pulse_i || dai_rb_done_pulse_i || dai_cmd_req_i) begin
            aon_auth_state_q <= AUTH_LOCKED_FATAL;
          end else if (post_auth_req_i && rst_sys_ni && rom_exec_active_i) begin
            active_session_id_q <= post_session_id_i;
            aon_auth_state_q    <= AUTH_VALIDATE;
          end
        end

        AUTH_VALIDATE: begin
          if (dai_prog_done_pulse_i || dai_rb_done_pulse_i || dai_cmd_req_i || !rst_sys_ni || !rom_exec_active_i) begin
            wstep_q            <= WSTEP_IDLE;
            word_grant_avail_q <= 1'b0;
            aon_auth_state_q   <= AUTH_LOCKED_FATAL;
          end else if (val_step_done_i) begin
            // Recovery mode is valid only if boot scanner detected PENDING_B_SEAL
            if (val_all_checks_ok_i && (req_target_svn_i != 8'd0) &&
                (!req_seal_b_only_i || pending_b_exists_q)) begin
              expected_slot_q        <= req_target_slot_i;
              expected_svn_q         <= req_target_svn_i;
              expected_cw0_q         <= f_expected_otp_codeword22(req_target_slot_i, req_target_svn_i, OTP_WORD_SVN);
              expected_cw1_q         <= f_expected_otp_codeword22(req_target_slot_i, req_target_svn_i, OTP_WORD_COMMIT_A);
              expected_cw2_q         <= f_expected_otp_codeword22(req_target_slot_i, req_target_svn_i, OTP_WORD_COMMIT_B);
              val_ctx_seal_b_only_q  <= req_seal_b_only_i;
              expected_word_idx_q    <= req_seal_b_only_i ? OTP_WORD_COMMIT_B : OTP_WORD_SVN;
              word_grant_avail_q     <= 1'b1;
              wstep_q                <= WSTEP_AUTH_READY;
              aon_auth_state_q       <= AUTH_GRANT;
            end else begin
              wstep_q                <= WSTEP_IDLE;
              word_grant_avail_q     <= 1'b0;
              aon_auth_state_q       <= AUTH_LOCKED_FATAL;
            end
          end
        end

        AUTH_GRANT: begin
          if (!rst_sys_ni || !rom_exec_active_i) begin
            word_grant_avail_q    <= 1'b0;
            wstep_q               <= WSTEP_IDLE;
            val_ctx_seal_b_only_q <= 1'b0;
            aon_auth_state_q      <= AUTH_LOCKED_FATAL;
          end else begin
            case (wstep_q)
              WSTEP_AUTH_READY: begin
                if (dai_prog_done_pulse_i || dai_rb_done_pulse_i || dai_prog_err_i) begin
                  word_grant_avail_q <= 1'b0;
                  wstep_q            <= WSTEP_IDLE;
                  aon_auth_state_q   <= AUTH_LOCKED_FATAL;
                end else if (dai_cmd_req_i && ((dai_slot_idx_i != expected_slot_q) ||
                                               (dai_word_sel_i != expected_word_idx_q) ||
                                               (dai_state_i != DAI_IDLE) ||
                                               otp_macro_phys_active_i)) begin
                  word_grant_avail_q <= 1'b0;
                  wstep_q            <= WSTEP_IDLE;
                  aon_auth_state_q   <= AUTH_LOCKED_FATAL;
                end else if (dai_write_accepted_w) begin
                  // Phase 2: Immediately consume single-word grant upon DAI write acceptance
                  word_grant_avail_q <= 1'b0;
                  wstep_q            <= WSTEP_WAIT_PHYS_DONE;
                end
              end

              WSTEP_WAIT_PHYS_DONE: begin
                if (dai_cmd_req_i || dai_rb_done_pulse_i || dai_prog_err_i) begin
                  word_grant_avail_q <= 1'b0;
                  wstep_q            <= WSTEP_IDLE;
                  aon_auth_state_q   <= AUTH_LOCKED_FATAL;
                end else if (dai_write_completed_w) begin
                  // Phase 3: Physical write completed, transition to readback verification
                  wstep_q            <= WSTEP_WAIT_RB_VERIFY;
                end
              end

              WSTEP_WAIT_RB_VERIFY: begin
                if (dai_cmd_req_i || dai_prog_done_pulse_i) begin
                  word_grant_avail_q <= 1'b0;
                  wstep_q            <= WSTEP_IDLE;
                  aon_auth_state_q   <= AUTH_LOCKED_FATAL;
                end else if (dai_rb_done_pulse_i) begin
                  if (any_session_done_ok_w) begin
                    // Phase 4 complete for final word (WORD_COMMIT_B) in either normal or recovery mode
                    word_grant_avail_q    <= 1'b0;
                    wstep_q               <= WSTEP_IDLE;
                    val_ctx_seal_b_only_q <= 1'b0;
                    pending_b_exists_q    <= 1'b0;
                    aon_auth_state_q      <= AUTH_SESSION_DONE;
                  end else if (readback_verified_w && !val_ctx_seal_b_only_q && (expected_word_idx_q < OTP_WORD_COMMIT_B)) begin
                    // Phase 4 complete for intermediate word (SVN -> COMMIT_A or COMMIT_A -> COMMIT_B)
                    expected_word_idx_q   <= expected_word_idx_q + 2'd1;
                    word_grant_avail_q    <= 1'b1;
                    wstep_q               <= WSTEP_AUTH_READY;
                  end else begin
                    // Any mismatched or out-of-context readback locks fatally on the same clock edge
                    word_grant_avail_q    <= 1'b0;
                    wstep_q               <= WSTEP_IDLE;
                    val_ctx_seal_b_only_q <= 1'b0;
                    aon_auth_state_q      <= AUTH_LOCKED_FATAL;
                  end
                end
              end

              default: begin
                word_grant_avail_q <= 1'b0;
                wstep_q            <= WSTEP_IDLE;
                aon_auth_state_q   <= AUTH_LOCKED_FATAL;
              end
            endcase
          end
        end

        AUTH_SESSION_DONE: begin
          word_grant_avail_q    <= 1'b0;
          wstep_q               <= WSTEP_IDLE;
          val_ctx_seal_b_only_q <= 1'b0;
          if (dai_cmd_req_i || dai_prog_done_pulse_i || dai_rb_done_pulse_i) begin
            aon_auth_state_q    <= AUTH_LOCKED_FATAL;
          end
        end

        AUTH_LOCKED_FATAL: begin
          // Permanent lock until Cold POR (!rst_aon_por_ni)
          word_grant_avail_q    <= 1'b0;
          wstep_q               <= WSTEP_IDLE;
          val_ctx_seal_b_only_q <= 1'b0;
          aon_auth_state_q      <= AUTH_LOCKED_FATAL;
        end

        default: begin
          word_grant_avail_q    <= 1'b0;
          wstep_q               <= WSTEP_IDLE;
          val_ctx_seal_b_only_q <= 1'b0;
          aon_auth_state_q      <= AUTH_LOCKED_FATAL;
        end
      endcase
    end
  end

endmodule : zc_aon_post_auth_ctrl
