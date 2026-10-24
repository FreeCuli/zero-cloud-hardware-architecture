// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: tb_zc_obi
// Description:
//   Gate C Self-Checking SystemVerilog HDL Simulation Testbench for zc_obi_subordinate_bridge:
//   - TEST 1 (GCR-01): Warm Reset (rst_sys_ni == 1'b0) strictly blocks periph_phys_req_o, host_req_ready_o,
//     and host_rvalid_o even when host_req_i == 1 and periph_phys_gnt_i == 1
//   - TEST 2: Normal OBI transaction acceptance and valid completion
//   - TEST 2B: 64-cycle normal transaction timeout (ST_TIMEOUT_ERR synthetic error) and early orphan
//     physical response silent drain in ST_IDLE
//   - TEST 2C: Ongoing physical request across Warm Reset, post-reset request blocking while orphan
//     drains, and silent drain of post-reset orphan response
//   - TEST 3 (R28B-03): 1,024-cycle orphan drain watchdog monotonic progression while rst_sys_ni is
//     held continuously low, locking subsys_dead_locked_q == 1'b1 on cycle 1,024 and saturating at 1023
//   - TEST 4 (Rev. 28D P1): Under subsys_dead_locked_q == 1'b1, new CPU requests in ST_IDLE are accepted
//     (host_req_ready_o == 1'b1) with periph_phys_req_o == 1'b0, enter ST_TRAP, return a 1-cycle
//     synthetic bus error (host_rvalid_o=1, host_err_o=1, host_rdata_o=0), and preserve permanent
//     deadlock even if a late physical peripheral response arrives after cycle 1,024

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
    // TEST 1 (GCR-01): Warm Reset (rst_sys_ni == 1'b0) Gating Verification
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
    // TEST 2B: 64-Cycle Normal Timeout (ST_TIMEOUT_ERR) & Early Orphan Drain
    // ------------------------------------------------------------------
    @(negedge clk_i);
    host_req_i        = 1'b1;
    periph_phys_gnt_i = 1'b1;
    @(posedge clk_i);
    #1;
    host_req_i        = 1'b0;
    periph_phys_gnt_i = 1'b0;
    check(bridge_state_o == ST_WAIT_RVALID && dut.phys_req_active_q == 1'b1,
          "64-Cycle Timeout Setup: Entered ST_WAIT_RVALID with phys_req_active_q=1");

    // Wait 64 cycles without periph_phys_rvalid_i (wait_cnt_q counts 0..63 -> ST_TIMEOUT_ERR)
    for (int w = 0; w < 64; w++) begin
      @(posedge clk_i);
    end
    #1;
    check(bridge_state_o == ST_TIMEOUT_ERR && host_rvalid_o == 1'b1 && host_err_o == 1'b1 &&
          host_rdata_o == 32'h0000_0000 && dut.phys_req_active_q == 1'b1,
          "64-Cycle Timeout Response: Entered ST_TIMEOUT_ERR and delivered 1-cycle synthetic timeout error to CPU");

    // Next clock edge returns to ST_IDLE with orphan_drain_active_o = 1
    @(posedge clk_i);
    #1;
    check(bridge_state_o == ST_IDLE && !host_rvalid_o && orphan_drain_active_o == 1'b1 && !host_req_ready_o,
          "Post-Timeout Orphan State: Returned to ST_IDLE with orphan_drain_active_o=1 and host_req_ready_o=0");

    // Deliver late orphan response in ST_IDLE prior to 1,024-cycle watchdog expiration
    @(negedge clk_i);
    periph_phys_rvalid_i = 1'b1;
    periph_phys_rdata_i  = 32'hDEAD_BEEF;
    #1;
    check(host_rvalid_o == 1'b0,
          "Early Orphan Drain (Arrival Cycle): Late peripheral response after timeout is never forwarded to CPU");
    @(posedge clk_i);
    #1;
    periph_phys_rvalid_i = 1'b0;
    check(dut.phys_req_active_q == 1'b0 && orphan_drain_active_o == 1'b0 &&
          drain_wdog_cnt_o == 10'd0 && !host_rvalid_o && !subsys_fatal_fault_irq_o,
          "Early Orphan Drain (Clearance Cycle): Cleared phys_req_active_q, orphan_drain_active_o, and drain_wdog_cnt_o");

    // ------------------------------------------------------------------
    // TEST 2C: Mid-Transaction Warm Reset, Post-Reset Request Block, & Orphan Drain
    // ------------------------------------------------------------------
    @(negedge clk_i);
    host_req_i        = 1'b1;
    periph_phys_gnt_i = 1'b1;
    @(posedge clk_i);
    #1;
    host_req_i        = 1'b0;
    periph_phys_gnt_i = 1'b0;
    check(dut.phys_req_active_q == 1'b1 && bridge_state_o == ST_WAIT_RVALID,
          "Mid-Tx Warm Reset Setup: Physical request active in ST_WAIT_RVALID");

    // Pulse Warm Reset (rst_sys_ni = 0) for 2 cycles while physical request is in flight
    @(negedge clk_i);
    rst_sys_ni = 1'b0;
    @(posedge clk_i);
    @(posedge clk_i);
    #1;
    check(bridge_state_o == ST_IDLE && dut.phys_req_active_q == 1'b1 &&
          orphan_drain_active_o == 1'b1 && drain_wdog_cnt_o == 10'd1,
          "Mid-Tx Warm Reset Active: Upper FSM reset to ST_IDLE while phys_req_active_q=1 and orphan watchdog advances");

    // Release Warm Reset (rst_sys_ni = 1) and attempt a new CPU request while orphan is still active
    @(negedge clk_i);
    rst_sys_ni        = 1'b1;
    host_req_i        = 1'b1;
    periph_phys_gnt_i = 1'b1;
    #1;
    check(host_req_ready_o == 1'b0 && periph_phys_req_o == 1'b0 && !host_rvalid_o,
          "Post-Reset Orphan Protection: New CPU request blocked (host_req_ready_o=0, periph_phys_req_o=0) while orphan drains");
    @(posedge clk_i);
    #1;
    host_req_i        = 1'b0;
    periph_phys_gnt_i = 1'b0;

    // Now deliver the delayed physical response from the pre-reset transaction
    @(negedge clk_i);
    periph_phys_rvalid_i = 1'b1;
    periph_phys_rdata_i  = 32'h1234_5678;
    #1;
    check(host_rvalid_o == 1'b0,
          "Post-Reset Orphan Drain (Arrival): Delayed pre-reset response silently absorbed (host_rvalid_o=0)");
    @(posedge clk_i);
    #1;
    periph_phys_rvalid_i = 1'b0;
    periph_phys_gnt_i    = 1'b1;
    #1;
    check(dut.phys_req_active_q == 1'b0 && orphan_drain_active_o == 1'b0 &&
          drain_wdog_cnt_o == 10'd0 && host_req_ready_o == 1'b1,
          "Post-Reset Orphan Drain (Recovery): Cleared orphan state and restored normal host_req_ready_o=1");
    periph_phys_gnt_i = 1'b0;

    // ------------------------------------------------------------------
    // TEST 3 (R28B-03): Orphan Transaction + Continuous Warm Reset for 1,024 Cycles
    // ------------------------------------------------------------------
    // Start a physical transaction, then assert Warm Reset (rst_sys_ni = 0) before rvalid arrives
    @(negedge clk_i);
    host_req_i        = 1'b1;
    periph_phys_gnt_i = 1'b1;
    @(posedge clk_i);
    #1;
    host_req_i        = 1'b0;
    periph_phys_gnt_i = 1'b0;
    check(dut.phys_req_active_q == 1'b1 && bridge_state_o == ST_WAIT_RVALID,
          "Orphan Setup: Physical request active in ST_WAIT_RVALID");

    // Assert and HOLD Warm Reset (rst_sys_ni = 0) for all 1,024 cycles
    @(negedge clk_i);
    rst_sys_ni = 1'b0;
    for (int c = 0; c < 1023; c++) begin
      @(posedge clk_i);
    end
    #1;
    check(orphan_drain_active_o == 1'b1 && drain_wdog_cnt_o == 10'd1023 && !subsys_fatal_fault_irq_o,
          "R28B-03 Watchdog Progression: Reached 1023 under continuous rst_sys_ni==0");

    // 1,024th clock edge locks subsys_dead_locked_q = 1
    @(posedge clk_i);
    #1;
    check(subsys_fatal_fault_irq_o == 1'b1 && dut.subsys_dead_locked_q == 1'b1 && drain_wdog_cnt_o == 10'd1023,
          "R28B-03 Watchdog Lock: subsys_dead_locked_q locked to 1'b1 on cycle 1024");

    // 1,025th clock edge verifies counter saturation at 1023 (no wrap-around / overflow to 0)
    @(posedge clk_i);
    #1;
    check(subsys_fatal_fault_irq_o == 1'b1 && drain_wdog_cnt_o == 10'd1023,
          "R28B-03 Watchdog Saturation: drain_wdog_cnt_o saturates at 1023 without overflow wrap-around");

    // Release Warm Reset
    @(negedge clk_i);
    rst_sys_ni = 1'b1;
    @(posedge clk_i);
    #1;

    // ------------------------------------------------------------------
    // TEST 4 (Rev. 28D P1): ST_TRAP Synthetic Error Response, Late Response After Lock, & Repeat Request
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

    // Late physical response arriving AFTER subsys_dead_locked_q == 1'b1
    @(negedge clk_i);
    periph_phys_rvalid_i = 1'b1;
    periph_phys_rdata_i  = 32'hCAFE_BABE;
    #1;
    check(host_rvalid_o == 1'b0 && subsys_fatal_fault_irq_o == 1'b1,
          "Late Response After Deadlock (Arrival): Late rvalid is blocked (host_rvalid_o=0) and deadlock remains active");
    @(posedge clk_i);
    #1;
    periph_phys_rvalid_i = 1'b0;
    check(dut.phys_req_active_q == 1'b0 && subsys_fatal_fault_irq_o == 1'b1 && dut.subsys_dead_locked_q == 1'b1,
          "Late Response After Deadlock (Sticky Lock): subsys_dead_locked_q remains permanently 1'b1 until Cold POR");

    // Repeated CPU request after late response still enters ST_TRAP
    @(negedge clk_i);
    host_req_i = 1'b1;
    #1;
    check(host_req_ready_o == 1'b1 && periph_phys_req_o == 1'b0,
          "Repeated CPU Request Under Deadlock: Immediately accepted into ST_TRAP without physical request");
    @(posedge clk_i);
    #1;
    host_req_i = 1'b0;
    check(bridge_state_o == ST_TRAP && host_rvalid_o == 1'b1 && host_err_o == 1'b1 &&
          host_rdata_o == 32'h0000_0000 && subsys_fatal_fault_irq_o == 1'b1,
          "Repeated CPU Request ST_TRAP Response: Returns deterministic synthetic bus error");
    @(posedge clk_i);
    #1;
    check(bridge_state_o == ST_IDLE && !host_rvalid_o && subsys_fatal_fault_irq_o == 1'b1,
          "Repeated CPU Request ST_TRAP Return: Cleanly returns to ST_IDLE keeping subsys_dead_locked_q=1");

    $display("----------------------------------------------------------------------");
    $display(" tb_zc_obi SUMMARY: PASS=%0d, FAIL=%0d", pass_cnt, fail_cnt);
    $display("======================================================================");
    if (fail_cnt > 0) $fatal(1, "tb_zc_obi FAILED");
    $finish;
  end

endmodule : tb_zc_obi
