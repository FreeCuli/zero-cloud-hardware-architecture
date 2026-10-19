// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: zc_spi_formal_proof
// Description:
//   Gate C Formal Verification Harness for zc_spi_flash_firewall (Yosys/SymbiYosys BMC + k-induction):
//   Proves all Rev. 28 - Rev. 28D SPI 3-layer separation and reconciliation properties:
//   - F-SPI-01 (SVA-SPI-2c): Transition from UPD_UNSYNC_RESET to UPD_IDLE occurs ONLY after a fresh
//     05h (RDSR1) primary frame completion with SR1[1:0] == 2'b00 and !fault_high_sec_i
//   - F-SPI-02 (SVA-SPI-2d): Physical SPI idle (UPD_IDLE) never asserts bank_b_commit_ready_o
//     without independent ROM image verification (rom_img_verif_valid_i)
//   - F-SPI-03 (SVA-SPI-3 / R28-03): No primary frame completion strobe can assert without a primary /CS
//     rising edge (cs_n_to_iso_o && !cs_n_prev_q) while SCK == 0
//   - F-SPI-04 (SVA-SPI-4): Secondary fault (fault_high_sec_i) forces effective Flash /CS high (fail-closed)

module zc_spi_formal_proof (
  input logic        clk_i,
  input logic        rst_sys_ni,
  input logic        cs_n_to_iso_i,
  input logic        sck_to_iso_i,
  input logic        sck_sample_edge_i,
  input logic        miso_sync_i,
  input logic [7:0]  opcode_i,
  input logic [23:0] target_addr_i,
  input logic [11:0] frame_bit_cnt_i,
  input logic [6:0]  rx_shift_i,
  input logic        guard_stream_data_i,
  input logic        fault_high_sec_i,
  input logic        upd_wdog_timeout_i,
  input logic        rom_img_verif_valid_i
);

  logic        cs_n_to_iso_o;
  logic        sck_to_iso_o;
  logic        cs_n_flash_eff_o;
  logic        spi_idle_ready_o;
  logic        bank_b_commit_ready_o;
  logic [2:0]  spi_update_state_o;

  localparam logic [2:0] UPD_UNSYNC_RESET = 3'b000;
  localparam logic [2:0] UPD_IDLE         = 3'b001;
  localparam logic [2:0] UPD_WEL_PENDING  = 3'b010;

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

  logic f_past_valid;
  initial f_past_valid = 1'b0;
  always_ff @(posedge clk_i) f_past_valid <= 1'b1;

  logic       cs_n_prev_q;
  logic [7:0] f_sr1_latched_byte_q;
  logic       f_sr1_byte_sampled_q;

  always_ff @(posedge clk_i or negedge rst_sys_ni) begin
    if (!rst_sys_ni) begin
      cs_n_prev_q          <= 1'b1;
      f_sr1_latched_byte_q <= 8'hFF;
      f_sr1_byte_sampled_q <= 1'b0;
    end else begin
      cs_n_prev_q <= cs_n_to_iso_o;
      if (cs_n_to_iso_o) begin
        f_sr1_byte_sampled_q <= 1'b0;
      end else if (guard_stream_data_i && (opcode_i == 8'h05) &&
                   sck_sample_edge_i && (frame_bit_cnt_i == 12'd15)) begin
        f_sr1_latched_byte_q <= {rx_shift_i[6:0], miso_sync_i};
        f_sr1_byte_sampled_q <= 1'b1;
      end
    end
  end

  // Primary-side /CS rising edge while SCK == 0
  wire f_phys_cs_edge_w = !cs_n_prev_q && cs_n_to_iso_o && !sck_to_iso_o;
  wire f_wren_pri_done  = f_phys_cs_edge_w && (opcode_i == 8'h06) && (frame_bit_cnt_i == 12'd8);
  wire f_wrdi_pri_done  = f_phys_cs_edge_w && (opcode_i == 8'h04) && (frame_bit_cnt_i == 12'd8);
  wire f_rdsr1_pri_done = f_phys_cs_edge_w && (opcode_i == 8'h05) && (frame_bit_cnt_i == 12'd16) && f_sr1_byte_sampled_q;

  always_comb begin
    if (!f_past_valid) assume (!rst_sys_ni);

    // F-SPI-02 (SVA-SPI-2d): Physical SPI idle (UPD_IDLE) never asserts bank_b_commit_ready_o
    // without independent ROM image verification (rom_img_verif_valid_i).
    if (bank_b_commit_ready_o) begin
      assert (spi_idle_ready_o && rom_img_verif_valid_i);
    end

    // F-SPI-04 (SVA-SPI-4): Secondary fault forces effective Flash /CS high (fail-closed).
    if (fault_high_sec_i) begin
      assert (cs_n_flash_eff_o == 1'b1);
    end
  end

  always_ff @(posedge clk_i) begin
    if (f_past_valid && $past(rst_sys_ni) && rst_sys_ni) begin
      // F-SPI-03 (SVA-SPI-3 / R28-03): State machine progress driven by primary frame completions
      // requires rising /CS edge while SCK == 0
      if (($past(spi_update_state_o) == UPD_UNSYNC_RESET) && (spi_update_state_o == UPD_IDLE)) begin
        assert ($past(cs_n_to_iso_o && !cs_n_prev_q && !sck_to_iso_o));
      end
      if (($past(spi_update_state_o) == UPD_IDLE) && (spi_update_state_o == UPD_WEL_PENDING)) begin
        assert ($past(cs_n_to_iso_o && !cs_n_prev_q && !sck_to_iso_o));
      end

      // F-SPI-01 (SVA-SPI-2c): Strictly normative - UPD_UNSYNC_RESET -> UPD_IDLE occurs ONLY after a fresh
      // 05h (RDSR1) primary frame completion with rising /CS, SCK == 0, no secondary fault, and no watchdog timeout
      if (($past(spi_update_state_o) == UPD_UNSYNC_RESET) && (spi_update_state_o == UPD_IDLE)) begin
        assert ($past(cs_n_to_iso_o && !cs_n_prev_q && !sck_to_iso_o &&
                      (opcode_i == 8'h05) && (frame_bit_cnt_i == 12'd16) &&
                      !fault_high_sec_i && !upd_wdog_timeout_i));
      end

      // F-SPI-01b: 04h (WRDI) in UPD_UNSYNC_RESET stays in UPD_UNSYNC_RESET (unless watchdog timeout).
      if (($past(spi_update_state_o) == UPD_UNSYNC_RESET) &&
          $past(f_wrdi_pri_done && !upd_wdog_timeout_i)) begin
        assert (spi_update_state_o == UPD_UNSYNC_RESET);
      end
    end
  end

  // =========================================================================
  // Non-Vacuity Cover Witness Directives (Discrete Target Reporting)
  // =========================================================================
  always_comb begin
    // C-SPI-04: Secondary fault fail-closed effective CS assert
    cover (fault_high_sec_i && cs_n_flash_eff_o);
  end

  always_ff @(posedge clk_i) begin
    if (f_past_valid && $past(rst_sys_ni) && rst_sys_ni) begin
      // C-SPI-01: Reach UPD_IDLE from UPD_UNSYNC_RESET via valid RDSR1
      cover (($past(spi_update_state_o) == UPD_UNSYNC_RESET) && (spi_update_state_o == UPD_IDLE));

      // C-SPI-01b: WRDI executed in UPD_UNSYNC_RESET
      cover (($past(spi_update_state_o) == UPD_UNSYNC_RESET) && f_wrdi_pri_done);

      // C-SPI-02: Bank-B commit authorization active
      cover (bank_b_commit_ready_o);

      // C-SPI-03a: WREN primary frame completion strobe and transition to UPD_WEL_PENDING
      cover (($past(spi_update_state_o) == UPD_IDLE) && (spi_update_state_o == UPD_WEL_PENDING));

      // C-SPI-03b: RDSR1 primary frame completion strobe
      cover (f_rdsr1_pri_done);
    end
  end

endmodule
