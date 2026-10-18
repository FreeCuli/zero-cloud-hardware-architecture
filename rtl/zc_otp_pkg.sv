// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module/Package: zc_otp_pkg
// Description:
//   Gate B Rev. 28-28D Normative OTP Package:
//   - Canonical (22,16) Hsiao SECDED encoder/syndrome functions (d_min = 4)
//   - Bijective affine-complement seal functions f_seal_a and f_seal_b
//     with zero intra-(slot, SVN) collisions across all 4,080 (k, v) pairs
//   - Minimum 22-bit codeword Hamming weight w_H,min = 8 ([8..14])
//   - Shared FSM state enumerations for AON POST authorization and DAI handshake

package zc_otp_pkg;

  // Canonical (22,16) Hsiao parity submatrix H_data columns (16 x 6-bit weight-3 vectors in GF(2)^6)
  /* verilator lint_off UNUSEDPARAM */
  localparam logic [95:0] H_DATA = {
    6'h2C, 6'h2A, 6'h29, 6'h26,
    6'h25, 6'h23, 6'h1C, 6'h1A,
    6'h19, 6'h16, 6'h15, 6'h13,
    6'h0E, 6'h0D, 6'h0B, 6'h07
  };
  /* verilator lint_on UNUSEDPARAM */

  // OTP Slot Word Indices
  localparam logic [1:0] OTP_WORD_SVN      = 2'd0;
  localparam logic [1:0] OTP_WORD_COMMIT_A = 2'd1;
  localparam logic [1:0] OTP_WORD_COMMIT_B = 2'd2;

  // AON POST Authorization FSM States (Rev. 28C / 28D)
  typedef enum logic [2:0] {
    AUTH_RESET_IDLE   = 3'b000,
    AUTH_WAIT_CHAL    = 3'b001,
    AUTH_VALIDATE     = 3'b010,
    AUTH_GRANT        = 3'b011,
    AUTH_SESSION_DONE = 3'b100,
    AUTH_LOCKED_FATAL = 3'b111
  } aon_auth_state_e;

  // 4-Phase Atomic Word Write/Verify Sub-FSM States (Rev. 28C)
  typedef enum logic [1:0] {
    WSTEP_IDLE           = 2'b00,
    WSTEP_AUTH_READY     = 2'b01, // Phase 1: write_authorized active, awaiting DAI accept
    WSTEP_WAIT_PHYS_DONE = 2'b10, // Phase 2->3: dai_write_accepted consumed grant, awaiting macro
    WSTEP_WAIT_RB_VERIFY = 2'b11  // Phase 3->4: dai_write_completed, awaiting bound readback
  } otp_wstep_e;

  // OTP Direct Access Interface (DAI) Controller States
  typedef enum logic [1:0] {
    DAI_IDLE      = 2'b00,
    DAI_PROG_BUSY = 2'b01,
    DAI_RB_BUSY   = 2'b10,
    DAI_ERROR     = 2'b11
  } dai_ctrl_state_e;

  // Explicit (22,16) Hsiao parity generator p[5:0] from d[15:0] (Rev. 28 Section 1.1)
  function automatic logic [5:0] f_hsiao_parity6(input logic [15:0] d);
    logic [5:0] p;
    begin
      p[0] = d[0] ^ d[1] ^ d[2] ^ d[4] ^ d[5] ^ d[7] ^ d[10] ^ d[11] ^ d[13]; // weight 9
      p[1] = d[0] ^ d[1] ^ d[3] ^ d[4] ^ d[6] ^ d[8] ^ d[10] ^ d[12] ^ d[14]; // weight 9
      p[2] = d[0] ^ d[2] ^ d[3] ^ d[5] ^ d[6] ^ d[9] ^ d[11] ^ d[12] ^ d[15]; // weight 9
      p[3] = d[1] ^ d[2] ^ d[3] ^ d[7] ^ d[8] ^ d[9] ^ d[13] ^ d[14] ^ d[15]; // weight 9
      p[4] = d[4] ^ d[5] ^ d[6] ^ d[7] ^ d[8] ^ d[9];                         // weight 6
      p[5] = d[10] ^ d[11] ^ d[12] ^ d[13] ^ d[14] ^ d[15];                   // weight 6
      f_hsiao_parity6 = p;
    end
  endfunction

  // Systematic 22-bit Hsiao codeword: codeword_22b[21:0] = {p[5:0], d[15:0]}
  function automatic logic [21:0] f_hsiao_encode22(input logic [15:0] d);
    begin
      f_hsiao_encode22 = {f_hsiao_parity6(d), d};
    end
  endfunction

  // 6-bit syndrome calculator for SECDED verification
  function automatic logic [5:0] f_hsiao_syndrome6(input logic [21:0] cw);
    begin
      f_hsiao_syndrome6 = cw[21:16] ^ f_hsiao_parity6(cw[15:0]);
    end
  endfunction

  // Balanced 16-bit SVN data word: WORD_SVN(v) = {~v, v}
  function automatic logic [15:0] f_word_svn_16(input logic [7:0] v);
    begin
      f_word_svn_16 = {~v, v};
    end
  endfunction

  // Rev. 28B affine slot mask A: M_A(k) = (17*k + 8'h5A) mod 256
  function automatic logic [7:0] f_mask_a(input logic [3:0] k);
    logic [7:0] prod;
    begin
      prod = ({4'b0000, k} * 8'd17);
      f_mask_a = prod + 8'h5A;
    end
  endfunction

  // Rev. 28B affine slot mask B: M_B(k) = (29*k + 8'h3C) mod 256
  // Note: M_A(k) + M_B(k) = 46*k + 150 == 0 (mod 2) != 255, guaranteeing
  // zero collisions between WORD_COMMIT_A and WORD_COMMIT_B for all (k, v).
  function automatic logic [7:0] f_mask_b(input logic [3:0] k);
    logic [7:0] prod;
    begin
      prod = ({4'b0000, k} * 8'd29);
      f_mask_b = prod + 8'h3C;
    end
  endfunction

  // Primary Commit Seal A: f_seal_a(k, v) = {~B_A, B_A}
  function automatic logic [15:0] f_seal_a(input logic [3:0] k, input logic [7:0] v);
    logic [7:0] b_a;
    begin
      b_a = v ^ f_mask_a(k);
      f_seal_a = {~b_a, b_a};
    end
  endfunction

  // Redundant Commit Seal B: f_seal_b(k, v) = {B_B, ~B_B}
  function automatic logic [15:0] f_seal_b(input logic [3:0] k, input logic [7:0] v);
    logic [7:0] b_b;
    begin
      b_b = v ^ f_mask_b(k);
      f_seal_b = {b_b, ~b_b};
    end
  endfunction

  // Expected 22-bit raw Hsiao codeword selector for (slot k, SVN v, word_idx)
  function automatic logic [21:0] f_expected_otp_codeword22(
    input logic [3:0] k,
    input logic [7:0] v,
    input logic [1:0] word_idx
  );
    begin
      case (word_idx)
        OTP_WORD_SVN:      f_expected_otp_codeword22 = f_hsiao_encode22(f_word_svn_16(v));
        OTP_WORD_COMMIT_A: f_expected_otp_codeword22 = f_hsiao_encode22(f_seal_a(k, v));
        OTP_WORD_COMMIT_B: f_expected_otp_codeword22 = f_hsiao_encode22(f_seal_b(k, v));
        default:           f_expected_otp_codeword22 = 22'h3F_FFFF;
      endcase
    end
  endfunction

endpackage
