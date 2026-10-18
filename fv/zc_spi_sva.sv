// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: zc_spi_sva
// Status: [GATE-C VERIFICATION OBLIGATION / UNVERIFIED]
// Description:
//   Bindable SystemVerilog Assertions (SVA) for zc_spi_flash_firewall
//   covering Gate B Rev. 28 - Rev. 28D SPI 3-layer event separation,
//   UPD_UNSYNC_RESET reconciliation, and independent ROM image verification gating.

module zc_spi_sva (
  input logic       clk_i,
  input logic       rst_sys_ni,
  input logic       cs_n_to_iso_o,
  input logic       sck_to_iso_o,
  input logic       cs_n_flash_eff_o,
  input logic       fault_high_sec_i,
  input logic       upd_wdog_timeout_i,
  input logic       rom_img_verif_valid_i,
  input logic       spi_idle_ready_o,
  input logic       bank_b_commit_ready_o,
  input logic [2:0] spi_update_state_o,
  input logic [7:0] sr1_latched_byte_q,
  input logic       wren_pri_frame_done_w,
  input logic       wrdi_pri_frame_done_w,
  input logic       rdsr1_pri_frame_done_w,
  input logic       prog_or_erase_pri_done_w
);

  localparam logic [2:0] UPD_UNSYNC_RESET = 3'b000;
  localparam logic [2:0] UPD_IDLE         = 3'b001;

  // SVA-SPI-2c: Transition from UPD_UNSYNC_RESET to UPD_IDLE occurs ONLY after a fresh
  // 05h (RDSR1) primary frame completion with SR1[1:0] == 2'b00 and no secondary fault.
  a_spi_reset_reconciles_fresh_sr1_before_idle:
    assert property (@(posedge clk_i) disable iff (!rst_sys_ni)
      ((spi_update_state_o == UPD_UNSYNC_RESET) ##1 (spi_update_state_o == UPD_IDLE))
      |-> $past(rdsr1_pri_frame_done_w && (sr1_latched_byte_q[1:0] == 2'b00) &&
                !fault_high_sec_i && !upd_wdog_timeout_i)
    );

  // SVA-SPI-2d: Physical SPI idle (UPD_IDLE) alone never asserts bank_b_commit_ready_o
  // without independent ROM image verifier confirmation (rom_img_verif_valid_i).
  a_spi_idle_does_not_bypass_img_verifier:
    assert property (@(posedge clk_i) disable iff (!rst_sys_ni)
      bank_b_commit_ready_o |-> (spi_idle_ready_o && rom_img_verif_valid_i)
    );

  // SVA-SPI-3 (R28-03): No primary frame completion strobe can assert without a primary /CS
  // rising edge while SCK == 0.
  a_spi_no_frame_done_without_pri_cs_deassert:
    assert property (@(posedge clk_i) disable iff (!rst_sys_ni)
      (wren_pri_frame_done_w || wrdi_pri_frame_done_w || rdsr1_pri_frame_done_w || prog_or_erase_pri_done_w)
      |-> ($rose(cs_n_to_iso_o) && !sck_to_iso_o)
    );

  // SVA-SPI-4: Secondary fault (fault_high_sec_i) forces effective Flash /CS high (fail-closed).
  a_spi_sec_fault_forces_cs_high:
    assert property (@(posedge clk_i)
      fault_high_sec_i |-> cs_n_flash_eff_o
    );

endmodule : zc_spi_sva

// Canonical SystemVerilog bind into zc_spi_flash_firewall
bind zc_spi_flash_firewall zc_spi_sva u_zc_spi_sva (
  .clk_i                    (clk_i),
  .rst_sys_ni               (rst_sys_ni),
  .cs_n_to_iso_o            (cs_n_to_iso_o),
  .sck_to_iso_o             (sck_to_iso_o),
  .cs_n_flash_eff_o         (cs_n_flash_eff_o),
  .fault_high_sec_i         (fault_high_sec_i),
  .upd_wdog_timeout_i       (upd_wdog_timeout_i),
  .rom_img_verif_valid_i    (rom_img_verif_valid_i),
  .spi_idle_ready_o         (spi_idle_ready_o),
  .bank_b_commit_ready_o    (bank_b_commit_ready_o),
  .spi_update_state_o       (spi_update_state_o),
  .sr1_latched_byte_q       (sr1_latched_byte_q),
  .wren_pri_frame_done_w    (wren_pri_frame_done_w),
  .wrdi_pri_frame_done_w    (wrdi_pri_frame_done_w),
  .rdsr1_pri_frame_done_w   (rdsr1_pri_frame_done_w),
  .prog_or_erase_pri_done_w (prog_or_erase_pri_done_w)
);

