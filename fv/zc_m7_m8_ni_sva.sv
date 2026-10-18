// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: zc_m7_m8_ni_sva
// Status: [GATE-C VERIFICATION OBLIGATION / UNVERIFIED]
// Description:
//   Gate B Rev. 28 (R27-07 / R28-05) 2-Trace Formal Noninterference & Zeroization Miter
//   Specification for Invariants M7 (Raw-Data Lifetime) and M8 (Data Destruction):
//   - Free initial symbolic address witnesses (sym_npu_addr, sym_main_addr)
//   - Exact zeroization proof (== 64'h0 and == 32'h0) upon zero_all_done_w
//   - 49,152-cycle bounded liveness from ST_PIPE_ZERO entry
//   - Unconditional Stage A phase/control equality across resets
//   - Stage B L1 observable equivalence during runtime
//   - Mandatory non-vacuity cover obligations

module zc_m7_m8_ni_sva (
  input logic        clk_i,
  input logic        rst_por_ni,
  input logic        rst_sys_ni,

  // Instance 1 observables & memory tap
  input logic        inst1_zero_all_done_w,
  input logic        inst1_rom_exec_active_o,
  input logic        inst1_model_weights_verified_q,
  input logic [2:0]  inst1_pipe_state_q,
  input logic [15:0] inst1_hw_frame_timer_q,
  input logic        inst1_l1_tx_en_o,
  input logic [31:0] inst1_l1_tx_data_o,
  input logic        inst1_l1_err_o,
  input logic [7:0]  inst1_l1_status_o,
  input logic        inst1_l1_pipe_rst_o,
  input logic [63:0] inst1_npu_sram_sym_word_i,
  input logic [31:0] inst1_main_sram_sym_word_i,

  // Instance 2 observables & memory tap
  input logic        inst2_zero_all_done_w,
  input logic        inst2_rom_exec_active_o,
  input logic        inst2_model_weights_verified_q,
  input logic [2:0]  inst2_pipe_state_q,
  input logic [15:0] inst2_hw_frame_timer_q,
  input logic        inst2_l1_tx_en_o,
  input logic [31:0] inst2_l1_tx_data_o,
  input logic        inst2_l1_err_o,
  input logic [7:0]  inst2_l1_status_o,
  input logic        inst2_l1_pipe_rst_o,
  input logic [63:0] inst2_npu_sram_sym_word_i,
  input logic [31:0] inst2_main_sram_sym_word_i,

  // Free initial symbolic addresses (unconstrained at t=0, held stable afterwards)
  input logic [10:0] sym_npu_addr_i,
  input logic [13:0] sym_main_addr_i
);

  localparam logic [2:0] ST_PIPE_ZERO = 3'b011;

  // A. Free initial symbolic witness constraint (unconstrained at t=0)
  assume_sym_addr_stable_after_t0:
    assume property (@(posedge clk_i)
      !$initstate |-> ($stable(sym_npu_addr_i) && $stable(sym_main_addr_i))
    );

  // B1. SVA-NI-ZERO-EXACT: Zeroization clears both NPU and Main SRAM to exact zero
  a_ni_zeroization_clears_to_exact_zero:
    assert property (@(posedge clk_i) disable iff (!rst_por_ni)
      (inst1_zero_all_done_w && inst2_zero_all_done_w)
      |=> ((inst1_npu_sram_sym_word_i  == 64'h0000_0000_0000_0000) &&
           (inst2_npu_sram_sym_word_i  == 64'h0000_0000_0000_0000) &&
           (inst1_main_sram_sym_word_i == 32'h0000_0000)           &&
           (inst2_main_sram_sym_word_i == 32'h0000_0000))
    );

  // B2. SVA-NI-ZERO-BOUNDED-LIVENESS: Zeroization completes within 49,152 cycles
  a_ni_zeroization_terminates_in_49152_cycles:
    assert property (@(posedge clk_i) disable iff (!rst_sys_ni)
      $rose(inst1_pipe_state_q == ST_PIPE_ZERO) |-> ##[1:49152] inst1_zero_all_done_w
    );

  // C1. SVA-NI-STAGE-A: Unconditional phase and control equality across both traces
  a_ni_stage_a_unconditional_phase_and_control_eq:
    assert property (@(posedge clk_i) disable iff (!rst_por_ni)
      (inst1_rom_exec_active_o        == inst2_rom_exec_active_o)        &&
      (inst1_model_weights_verified_q == inst2_model_weights_verified_q) &&
      (inst1_pipe_state_q             == inst2_pipe_state_q)             &&
      (inst1_hw_frame_timer_q         == inst2_hw_frame_timer_q)
    );

  // C2. SVA-NI-STAGE-B: Runtime L1 observable noninterference
  a_ni_stage_b_runtime_l1_equivalence:
    assert property (@(posedge clk_i) disable iff (!rst_por_ni)
      (!inst1_rom_exec_active_o && inst1_model_weights_verified_q)
      |-> ((inst1_l1_tx_en_o    == inst2_l1_tx_en_o)   &&
           (inst1_l1_tx_data_o  == inst2_l1_tx_data_o) &&
           (inst1_l1_err_o      == inst2_l1_err_o)     &&
           (inst1_l1_status_o   == inst2_l1_status_o)  &&
           (inst1_l1_pipe_rst_o == inst2_l1_pipe_rst_o))
    );

  // C3. Non-vacuity cover properties
  c_ni_zero_done_reachable:
    cover property (@(posedge clk_i) inst1_zero_all_done_w);

  c_ni_runtime_tx_reachable:
    cover property (@(posedge clk_i) (!inst1_rom_exec_active_o && inst1_model_weights_verified_q && inst1_l1_tx_en_o));

endmodule : zc_m7_m8_ni_sva
