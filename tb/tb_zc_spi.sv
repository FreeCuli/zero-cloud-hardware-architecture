// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: tb_zc_spi
// Description:
//   Gate C Self-Checking SystemVerilog HDL Simulation Testbench for zc_spi_flash_firewall:
//   - 04h (WRDI) in UPD_UNSYNC_RESET stays in UPD_UNSYNC_RESET (does not jump to UPD_IDLE)
//   - 05h (RDSR1) with WIP/WEL != 2'b00 stays in UPD_UNSYNC_RESET
//   - Fresh 16-bit 05h (RDSR1) with SR1[1:0] == 2'b00 transitions UPD_UNSYNC_RESET -> UPD_IDLE
//   - Layer 3 separation: UPD_IDLE asserts spi_idle_ready_o, but bank_b_commit_ready_o stays 0
//     until rom_img_verif_valid_i == 1'b1
//   - Layer 2 separation: fault_high_sec_i forces cs_n_flash_eff_o = 1'b1 (fail-closed) and
//     drops FSM back to UPD_UNSYNC_RESET
//   - Full Bank-B update cycle (06h WREN -> 20h Sector Erase -> 05h RDSR1 busy -> 05h RDSR1 clear -> 05h confirm)

`timescale 1ns / 1ps

module tb_zc_spi;

  logic        clk_i;
  logic        rst_sys_ni;
  logic        cs_n_to_iso_i;
  logic        sck_to_iso_i;
  logic        sck_sample_edge_i;
  logic        miso_sync_i;
  logic [7:0]  opcode_i;
  logic [23:0] target_addr_i;
  logic [11:0] frame_bit_cnt_i;
  logic [6:0]  rx_shift_i;
  logic        guard_stream_data_i;
  logic        fault_high_sec_i;
  logic        upd_wdog_timeout_i;
  logic        rom_img_verif_valid_i;

  logic        cs_n_to_iso_o;
  logic        sck_to_iso_o;
  logic        cs_n_flash_eff_o;
  logic        spi_idle_ready_o;
  logic        bank_b_commit_ready_o;
  logic [2:0]  spi_update_state_o;

  localparam logic [2:0] UPD_UNSYNC_RESET     = 3'b000;
  localparam logic [2:0] UPD_IDLE             = 3'b001;
  localparam logic [2:0] UPD_WEL_PENDING      = 3'b010;
  localparam logic [2:0] UPD_PROGRAM_BUSY     = 3'b011;
  localparam logic [2:0] UPD_VERIFY_CLEAR     = 3'b100;
  localparam logic [2:0] UPD_RECOVERY_LOCKOUT = 3'b111;

  zc_spi_flash_firewall dut (
    .clk_i                 (clk_i),
    .rst_sys_ni            (rst_sys_ni),
    .cs_n_to_iso_i         (cs_n_to_iso_i),
    .sck_to_iso_i          (sck_to_iso_i),
    .sck_sample_edge_i     (sck_sample_edge_i),
    .miso_sync_i           (miso_sync_i),
    .opcode_i              (opcode_i),
    .target_addr_i         (target_addr_i),
    .frame_bit_cnt_i       (frame_bit_cnt_i),
    .rx_shift_i            (rx_shift_i),
    .guard_stream_data_i   (guard_stream_data_i),
    .fault_high_sec_i      (fault_high_sec_i),
    .upd_wdog_timeout_i    (upd_wdog_timeout_i),
    .rom_img_verif_valid_i (rom_img_verif_valid_i),
    .cs_n_to_iso_o         (cs_n_to_iso_o),
    .sck_to_iso_o          (sck_to_iso_o),
    .cs_n_flash_eff_o      (cs_n_flash_eff_o),
    .spi_idle_ready_o      (spi_idle_ready_o),
    .bank_b_commit_ready_o (bank_b_commit_ready_o),
    .spi_update_state_o    (spi_update_state_o)
  );

  initial clk_i = 1'b0;
  always #5 clk_i = ~clk_i;

  int pass_cnt = 0;
  int fail_cnt = 0;

  task automatic check(input bit cond, input string name);
    if (cond) begin
      $display("[TB-SPI][PASS] %s", name);
      pass_cnt++;
    end else begin
      $display("[TB-SPI][FAIL] %s (state=%0d idle=%0b commit=%0b cs_eff=%0b)",
               name, spi_update_state_o, spi_idle_ready_o, bank_b_commit_ready_o, cs_n_flash_eff_o);
      fail_cnt++;
    end
  endtask

  task automatic send_cmd_8b(input logic [7:0] op);
    @(negedge clk_i);
    cs_n_to_iso_i   = 1'b0;
    sck_to_iso_i    = 1'b0;
    opcode_i        = op;
    frame_bit_cnt_i = 12'd8;
    @(posedge clk_i);
    @(negedge clk_i);
    cs_n_to_iso_i   = 1'b1; // Rising /CS edge with SCK == 0
    sck_to_iso_i    = 1'b0;
    @(posedge clk_i);
    #1;
  endtask

  task automatic send_rdsr1_16b(input logic [7:0] sr1_val);
    @(negedge clk_i);
    cs_n_to_iso_i       = 1'b0;
    sck_to_iso_i        = 1'b0;
    opcode_i            = 8'h05;
    guard_stream_data_i = 1'b1;
    frame_bit_cnt_i     = 12'd15;
    rx_shift_i          = sr1_val[7:1];
    miso_sync_i         = sr1_val[0];
    sck_sample_edge_i   = 1'b1;
    @(posedge clk_i); // Samples SR1 on bit 15
    @(negedge clk_i);
    sck_sample_edge_i   = 1'b0;
    frame_bit_cnt_i     = 12'd16;
    cs_n_to_iso_i       = 1'b1; // Deassert /CS on bit 16 with SCK == 0
    sck_to_iso_i        = 1'b0;
    @(posedge clk_i);
    #1;
    guard_stream_data_i = 1'b0;
  endtask

  task automatic send_erase_32b(input logic [7:0] op, input logic [23:0] addr);
    @(negedge clk_i);
    cs_n_to_iso_i   = 1'b0;
    sck_to_iso_i    = 1'b0;
    opcode_i        = op;
    target_addr_i   = addr;
    frame_bit_cnt_i = 12'd32;
    @(posedge clk_i);
    @(negedge clk_i);
    cs_n_to_iso_i   = 1'b1;
    sck_to_iso_i    = 1'b0;
    @(posedge clk_i);
    #1;
  endtask

  initial begin
    $display("======================================================================");
    $display(" STARTING GATE C HDL SIMULATION: tb_zc_spi");
    $display("======================================================================");

    rst_sys_ni            = 1'b0;
    cs_n_to_iso_i         = 1'b1;
    sck_to_iso_i          = 1'b0;
    sck_sample_edge_i     = 1'b0;
    miso_sync_i           = 1'b0;
    opcode_i              = 8'h00;
    target_addr_i         = 24'h0;
    frame_bit_cnt_i       = 12'd0;
    rx_shift_i            = 7'h0;
    guard_stream_data_i   = 1'b0;
    fault_high_sec_i      = 1'b0;
    upd_wdog_timeout_i    = 1'b0;
    rom_img_verif_valid_i = 1'b0;

    @(posedge clk_i);
    @(posedge clk_i);
    rst_sys_ni = 1'b1;
    @(posedge clk_i);
    #1;
    check(spi_update_state_o == UPD_UNSYNC_RESET && !spi_idle_ready_o && !bank_b_commit_ready_o,
          "Reset State: Starts in UPD_UNSYNC_RESET with ready=0");

    // 1. Send 04h (WRDI) in UPD_UNSYNC_RESET -> MUST remain in UPD_UNSYNC_RESET
    send_cmd_8b(8'h04);
    check(spi_update_state_o == UPD_UNSYNC_RESET && !spi_idle_ready_o,
          "WRDI in Reset: 04h (WRDI) stays in UPD_UNSYNC_RESET until fresh RDSR1");

    // 2. Send 05h (RDSR1) with WIP=1 (8'h01) -> MUST remain in UPD_UNSYNC_RESET
    send_rdsr1_16b(8'h01);
    check(spi_update_state_o == UPD_UNSYNC_RESET && !spi_idle_ready_o,
          "RDSR1 Busy in Reset: 05h with SR1[1:0]=2'b01 stays in UPD_UNSYNC_RESET");

    // 3. Send fresh 05h (RDSR1) with WIP=0, WEL=0 (8'h00) -> Transitions to UPD_IDLE
    send_rdsr1_16b(8'h00);
    check(spi_update_state_o == UPD_IDLE && spi_idle_ready_o && !bank_b_commit_ready_o,
          "RDSR1 Clear Reconciliation: Transitions to UPD_IDLE; bank_b_commit_ready_o stays 0 without ROM verifier");

    // 4. Assert rom_img_verif_valid_i -> bank_b_commit_ready_o becomes 1
    @(negedge clk_i);
    rom_img_verif_valid_i = 1'b1;
    #1;
    check(spi_idle_ready_o && bank_b_commit_ready_o,
          "Layer 3 ROM Verifier Gate: bank_b_commit_ready_o asserts when both UPD_IDLE and rom_img_verif_valid_i hold");
    rom_img_verif_valid_i = 1'b0;

    // 5. Full Bank-B Erase & Reconciliation Cycle (UPD_IDLE -> UPD_WEL_PENDING -> UPD_PROGRAM_BUSY -> UPD_VERIFY_CLEAR -> UPD_IDLE)
    send_cmd_8b(8'h06); // WREN
    check(spi_update_state_o == UPD_WEL_PENDING, "Update Cycle: 06h (WREN) -> UPD_WEL_PENDING");

    send_erase_32b(8'h20, 24'h80_1000); // Aligned 4KB Bank-B sector erase
    check(spi_update_state_o == UPD_PROGRAM_BUSY, "Update Cycle: Aligned Bank-B 20h Erase -> UPD_PROGRAM_BUSY");

    send_rdsr1_16b(8'h03); // WIP=1, WEL=1
    check(spi_update_state_o == UPD_PROGRAM_BUSY, "Update Cycle: RDSR1(WIP=1) remains in UPD_PROGRAM_BUSY");

    send_rdsr1_16b(8'h00); // WIP=0, WEL=0 -> UPD_VERIFY_CLEAR
    check(spi_update_state_o == UPD_VERIFY_CLEAR, "Update Cycle: First RDSR1(2'b00) -> UPD_VERIFY_CLEAR");

    send_rdsr1_16b(8'h00); // Second confirming RDSR1(2'b00) -> UPD_IDLE
    check(spi_update_state_o == UPD_IDLE && spi_idle_ready_o, "Update Cycle: Second RDSR1(2'b00) -> UPD_IDLE");

    // 6. Secondary Fault Injection (fault_high_sec_i = 1)
    @(negedge clk_i);
    cs_n_to_iso_i    = 1'b0;
    fault_high_sec_i = 1'b1;
    #1;
    check(cs_n_flash_eff_o == 1'b1 && !spi_idle_ready_o,
          "Layer 2 Secondary Fault Barrier: fault_high_sec_i forces cs_n_flash_eff_o=1 even when cs_n_to_iso_o=0");
    @(posedge clk_i);
    #1;
    check(spi_update_state_o == UPD_UNSYNC_RESET,
          "Secondary Fault Recovery: fault_high_sec_i returns FSM to UPD_UNSYNC_RESET");

    // 7. Watchdog Timeout Lockout (upd_wdog_timeout_i = 1 -> UPD_RECOVERY_LOCKOUT)
    @(negedge clk_i);
    fault_high_sec_i   = 1'b0;
    cs_n_to_iso_i      = 1'b1;
    upd_wdog_timeout_i = 1'b1;
    @(posedge clk_i);
    #1;
    upd_wdog_timeout_i = 1'b0;
    send_rdsr1_16b(8'h00);
    check(spi_update_state_o == UPD_RECOVERY_LOCKOUT && !spi_idle_ready_o,
          "Watchdog Lockout: upd_wdog_timeout_i permanently locks UPD_RECOVERY_LOCKOUT until rst_sys_ni");

    $display("----------------------------------------------------------------------");
    $display(" tb_zc_spi SUMMARY: PASS=%0d, FAIL=%0d", pass_cnt, fail_cnt);
    $display("======================================================================");
    if (fail_cnt > 0) $fatal(1, "tb_zc_spi FAILED");
    $finish;
  end

endmodule : tb_zc_spi
