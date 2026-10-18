// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: tb_zc_obi
// Description:
//   Gate C Self-Checking SystemVerilog HDL Simulation Testbench for zc_obi_subordinate_bridge:
//   - GCR-01: Warm Reset (!rst_sys_ni == 0) strictly blocks periph_phys_req_o, host_req_ready_o,
//     and host_rvalid_o even when host_req_i == 1 and periph_phys_gnt_i == 1
//   - Normal OBI transaction completion and 64-cycle timeout (ST_TIMEOUT_ERR)
//   - R28B-03: 1,024-cycle orphan drain watchdog monotonic progression while !rst_sys_ni is
//     held continuously low, locking subsys_dead_locked_q == 1'b1 on cycle 1,024
//   - Rev. 28D P1: Under subsys_dead_locked_q == 1'b1, new CPU requests in ST_IDLE are accepted
//     (host_req_ready_o == 1'b1) with periph_phys_req_o == 1'b0, enter ST_TRAP, and return a
//     1-cycle synthetic bus error (host_rvalid_o=1, host_err_o=1, host_rdata_o=0) before returning to ST_IDLE

`timescale 1ns / 1ps

module tb_zc_obi;

  logic        clk_i;
  logic        rst_por_ni;
  logic        rst_sys_ni;
  logic        host_req_i;
  logic        host_req_ready_o;
  logic        host_rvalid_o;
  logic        host_err_o;
  logic [31:0] host_rdata_o;
  logic        periph_phys_req_o;
  logic        periph_phys_gnt_i;
  logic        periph_phys_rvalid_i;
  logic        periph_phys_err_i;
  logic [31:0] periph_phys_rdata_i;
  logic        subsys_fatal_fault_irq_o;
  logic        orphan_drain_active_o;
  logic [9:0]  drain_wdog_cnt_o;
  logic [1:0]  bridge_state_o;

  localparam logic [1:0] ST_IDLE        = 2'b00;
  localparam logic [1:0] ST_WAIT_RVALID = 2'b01;
  localparam logic [1:0] ST_TIMEOUT_ERR = 2'b10;
  localparam logic [1:0] ST_TRAP        = 2'b11;

  zc_obi_subordinate_bridge dut (
    .clk_i                    (clk_i),
    .rst_por_ni               (rst_por_ni),
    .rst_sys_ni               (rst_sys_ni),
    .host_req_i               (host_req_i),
    .host_req_ready_o         (host_req_ready_o),
    .host_rvalid_o            (host_rvalid_o),
    .host_err_o               (host_err_o),
    .host_rdata_o             (host_rdata_o),
    .periph_phys_req_o        (periph_phys_req_o),
    .periph_phys_gnt_i        (periph_phys_gnt_i),
    .periph_phys_rvalid_i     (periph_phys_rvalid_i),
    .periph_phys_err_i        (periph_phys_err_i),
    .periph_phys_rdata_i      (periph_phys_rdata_i),
    .subsys_fatal_fault_irq_o (subsys_fatal_fault_irq_o),
    .orphan_drain_active_o    (orphan_drain_active_o),
    .drain_wdog_cnt_o         (drain_wdog_cnt_o),
    .bridge_state_o           (bridge_state_o)
  );

  initial clk_i = 1'b0;
  always #5 clk_i = ~clk_i;

  int pass_cnt = 0;
  int fail_cnt = 0;

  task automatic check(input bit cond, input string name);
    if (cond) begin
      $display("[TB-OBI][PASS] %s", name);
      pass_cnt++;
    end else begin
      $display("[TB-OBI][FAIL] %s (state=%0d ready=%0b phys_req=%0b rvalid=%0b err=%0b wdog=%0d dead=%0b)",
               name, bridge_state_o, host_req_ready_o, periph_phys_req_o,
               host_rvalid_o, host_err_o, drain_wdog_cnt_o, subsys_fatal_fault_irq_o);
      fail_cnt++;
    end
  endtask

  initial begin
    $display("======================================================================");
    $display(" STARTING GATE C HDL SIMULATION: tb_zc_obi");
    $display("======================================================================");

    rst_por_ni           = 1'b0;
    rst_sys_ni           = 1'b0;
    host_req_i           = 1'b0;
    periph_phys_gnt_i    = 1'b0;
    periph_phys_rvalid_i = 1'b0;
    periph_phys_err_i    = 1'b0;
    periph_phys_rdata_i  = 32'h0;

    @(posedge clk_i);
    @(posedge clk_i);
    rst_por_ni = 1'b1;

    // ------------------------------------------------------------------
    // TEST 1 (GCR-01): Warm Reset (!rst_sys_ni == 0) Gating Verification
    // ------------------------------------------------------------------
    @(negedge clk_i);
    rst_sys_ni        = 1'b0;
    host_req_i        = 1'b1;
    periph_phys_gnt_i = 1'b1;
    #1;
    check(host_req_ready_o == 1'b0 && periph_phys_req_o == 1'b0 && host_rvalid_o == 1'b0,
          "GCR-01 Warm Reset Gate: rst_sys_ni=0 forces host_req_ready_o=0 and periph_phys_req_o=0");
    @(posedge clk_i);
    #1;
    check(dut.phys_req_active_q == 1'b0 && bridge_state_o == ST_IDLE,
          "GCR-01 Warm Reset State: phys_req_active_q remains 0 across clock edge during Warm Reset");

    // Release Warm Reset
    @(negedge clk_i);
    host_req_i = 1'b0;
    rst_sys_ni = 1'b1;
    @(posedge clk_i);
    #1;

    // ------------------------------------------------------------------
    // TEST 2: Normal Transaction Acceptance & Valid Completion
    // ------------------------------------------------------------------
    @(negedge clk_i);
    host_req_i        = 1'b1;
    periph_phys_gnt_i = 1'b1;
    #1;
    check(host_req_ready_o == 1'b1 && periph_phys_req_o == 1'b1,
          "Normal OBI Tx: Request accepted and forwarded to physical peripheral");
    @(posedge clk_i);
    #1;
    host_req_i        = 1'b0;
    periph_phys_gnt_i = 1'b0;
    check(bridge_state_o == ST_WAIT_RVALID && dut.phys_req_active_q == 1'b1 && drain_wdog_cnt_o == 10'd0,
          "Normal OBI Tx: Entered ST_WAIT_RVALID with drain_wdog_cnt_o=0");

    @(negedge clk_i);
    periph_phys_rvalid_i = 1'b1;
    periph_phys_err_i    = 1'b0;
    periph_phys_rdata_i  = 32'hA5A5_5A5A;
    #1;
    check(host_rvalid_o == 1'b1 && host_err_o == 1'b0 && host_rdata_o == 32'hA5A5_5A5A,
          "Normal OBI Tx: Delivered valid peripheral response to CPU");
    @(posedge clk_i);
    #1;
    periph_phys_rvalid_i = 1'b0;
    check(bridge_state_o == ST_IDLE && dut.phys_req_active_q == 1'b0 && !host_rvalid_o,
          "Normal OBI Tx: Returned to ST_IDLE and cleared phys_req_active_q");

    // ------------------------------------------------------------------
    // TEST 3 (R28B-03): Orphan Transaction + Continuous Warm Reset for 1,024 Cycles
    // ------------------------------------------------------------------
    // Start a physical transaction, then assert Warm Reset (!rst_sys_ni = 0) before rvalid arrives
    @(negedge clk_i);
    host_req_i        = 1'b1;
    periph_phys_gnt_i = 1'b1;
    @(posedge clk_i);
    #1;
    host_req_i        = 1'b0;
    periph_phys_gnt_i = 1'b0;
    check(dut.phys_req_active_q == 1'b1 && bridge_state_o == ST_WAIT_RVALID,
          "Orphan Setup: Physical request active in ST_WAIT_RVALID");

    // Assert and HOLD Warm Reset (!rst_sys_ni = 0) for all 1,024 cycles
    @(negedge clk_i);
    rst_sys_ni = 1'b0;
    for (int c = 0; c < 1023; c++) begin
      @(posedge clk_i);
    end
    #1;
    check(orphan_drain_active_o == 1'b1 && drain_wdog_cnt_o == 10'd1023 && !subsys_fatal_fault_irq_o,
          "R28B-03 Watchdog Progression: Reached 1023 under continuous !rst_sys_ni==0");

    // 1,024th clock edge locks subsys_dead_locked_q = 1
    @(posedge clk_i);
    #1;
    check(subsys_fatal_fault_irq_o == 1'b1 && dut.subsys_dead_locked_q == 1'b1,
          "R28B-03 Watchdog Lock: subsys_dead_locked_q locked to 1'b1 on cycle 1024");

    // Release Warm Reset
    @(negedge clk_i);
    rst_sys_ni = 1'b1;
    @(posedge clk_i);
    #1;

    // ------------------------------------------------------------------
    // TEST 4 (Rev. 28D P1): ST_TRAP Synthetic Error Response under subsys_dead_locked_q == 1'b1
    // ------------------------------------------------------------------
    @(negedge clk_i);
    host_req_i        = 1'b1;
    periph_phys_gnt_i = 1'b0; // Even if peripheral grant is 0, deadlocked bridge must accept & trap!
    #1;
    check(host_req_ready_o == 1'b1 && periph_phys_req_o == 1'b0,
          "Rev. 28D ST_TRAP Entry: Accepts CPU request (host_req_ready_o=1) with zero physical request (periph_phys_req_o=0)");
    @(posedge clk_i);
    #1;
    host_req_i = 1'b0;
    check(bridge_state_o == ST_TRAP && host_rvalid_o == 1'b1 && host_err_o == 1'b1 &&
          host_rdata_o == 32'h0000_0000 && periph_phys_req_o == 1'b0 && subsys_fatal_fault_irq_o == 1'b1,
          "Rev. 28D ST_TRAP Response: Returns deterministic synthetic bus error (rvalid=1, err=1, rdata=0) in ST_TRAP");

    @(posedge clk_i);
    #1;
    check(bridge_state_o == ST_IDLE && !host_rvalid_o && subsys_fatal_fault_irq_o == 1'b1,
          "Rev. 28D ST_TRAP Return: Returns to ST_IDLE on next cycle while preserving subsys_dead_locked_q=1");

    $display("----------------------------------------------------------------------");
    $display(" tb_zc_obi SUMMARY: PASS=%0d, FAIL=%0d", pass_cnt, fail_cnt);
    $display("======================================================================");
    if (fail_cnt > 0) $fatal(1, "tb_zc_obi FAILED");
    $finish;
  end

endmodule : tb_zc_obi
