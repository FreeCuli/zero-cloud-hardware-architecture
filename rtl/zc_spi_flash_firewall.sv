// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: zc_spi_flash_firewall
// Description:
//   Gate B Rev. 28 / 28A / 28B Normative SPI NOR Flash Command Firewall & Update Reconciler:
//   - Strictly separates three distinct physical/architectural events:
//       1. Primary-side SPI frame completion (*_pri_frame_done_w on $rose(cs_n_to_iso_o) && !sck_to_iso_o)
//       2. Secondary-side Flash /CS electrical acceptance (cs_n_flash_Model_o = cs_n_iso | fault_high_sec_i)
//       3. Internal Flash completion (05h RDSR1 MISO sr1[1:0] == 2'b00) and independent
//          ROM image cryptographic verification (rom_img_verif_valid_i)
//   - Keeps UPD_UNSYNC_RESET on 04h (WRDI) until a fresh 16-bit 05h (RDSR1) frame confirms
//     WEL == 0 and WIP == 0 (sr1_latched_byte_q[1:0] == 2'b00)
//   - Enforces fail-closed Bank-B address alignment for 02h/20h/D8h write/erase operations

module zc_spi_flash_firewall (
  input  logic        clk_i,
  input  logic        rst_sys_ni,

  // Primary-side SPI controller signals (entering isolator / firewall)
  input  logic        cs_n_to_iso_i,
  input  logic        sck_to_iso_i,
  input  logic        sck_sample_edge_i,
  input  logic        miso_sync_i,
  input  logic [7:0]  opcode_i,
  input  logic [23:0] target_addr_i,
  input  logic [11:0] frame_bit_cnt_i,
  input  logic [6:0]  rx_shift_i,
  input  logic        guard_stream_data_i,

  // Secondary-side supervisor / isolation fault status & watchdog
  input  logic        fault_high_sec_i,        // U_SUP2 / U_OR_SEC secondary fault lock
  input  logic        upd_wdog_timeout_i,

  // Independent Boot ROM image cryptographic verifier status (Bank-B SHA-256 + Ed25519)
  input  logic        rom_img_verif_valid_i,

  // Outputs
  output logic        cs_n_to_iso_o,
  output logic        sck_to_iso_o,
  output logic        cs_n_flash_eff_o,        // Secondary-side effective /CS = cs_n_to_iso_o | fault_high_sec_i
  output logic        spi_idle_ready_o,        // Physical SPI bus idle (does NOT imply Bank-B verified)
  output logic        bank_b_commit_ready_o,   // Requires BOTH spi_idle_ready_o AND rom_img_verif_valid_i
  output logic [2:0]  spi_update_state_o
);

  typedef enum logic [2:0] {
    UPD_UNSYNC_RESET     = 3'b000,
    UPD_IDLE             = 3'b001,
    UPD_WEL_PENDING      = 3'b010,
    UPD_PROGRAM_BUSY     = 3'b011,
    UPD_VERIFY_CLEAR     = 3'b100,
    UPD_RECOVERY_LOCKOUT = 3'b111
  } spi_update_state_e;

  spi_update_state_e spi_update_fsm_q;
  logic              cs_n_prev_q;
  logic [7:0]        sr1_latched_byte_q;
  logic              sr1_byte_sampled_q;

  assign cs_n_to_iso_o    = cs_n_to_iso_i;
  assign sck_to_iso_o     = sck_to_iso_i;

  // Layer 2: Secondary-side electrical /CS acceptance gate (U_OR_SEC fail-closed barrier)
  assign cs_n_flash_eff_o = cs_n_to_iso_o | fault_high_sec_i;

  always_ff @(posedge clk_i or negedge rst_sys_ni) begin
    if (!rst_sys_ni) begin
      cs_n_prev_q <= 1'b1;
    end else begin
      cs_n_prev_q <= cs_n_to_iso_o;
    end
  end

  // Layer 1: Primary-side /CS rising edge while SCK == 0
  wire phys_cs_deassert_edge_w = !cs_n_prev_q && cs_n_to_iso_o && !sck_to_iso_o;

  // Bank-B address alignment check (24'h800000 .. 24'hFFFFFF)
  wire addr_is_bank_b_w = target_addr_i[23];
  wire addr_is_bank_b_aligned_w = addr_is_bank_b_w &&
    (((opcode_i == 8'h20) && (target_addr_i[11:0] == 12'h000)) ||
     ((opcode_i == 8'hD8) && (target_addr_i[15:0] == 16'h0000)) ||
     ((opcode_i == 8'h02) && (target_addr_i[7:0]  == 8'h00)));

  // Sample fresh SR1 byte on bit 15 of 05h (RDSR1) before primary /CS deassertion
  always_ff @(posedge clk_i or negedge rst_sys_ni) begin
    if (!rst_sys_ni) begin
      sr1_latched_byte_q <= 8'hFF;
      sr1_byte_sampled_q <= 1'b0;
    end else if (cs_n_to_iso_o) begin
      sr1_byte_sampled_q <= 1'b0;
    end else if (guard_stream_data_i && (opcode_i == 8'h05) &&
                 sck_sample_edge_i && (frame_bit_cnt_i == 12'd15)) begin
      sr1_latched_byte_q <= {rx_shift_i[6:0], miso_sync_i};
      sr1_byte_sampled_q <= 1'b1;
    end
  end

  // Layer 1 primary-side frame completion strobes (Rev. 28A / 28B)
  wire wren_pri_frame_done_w  = phys_cs_deassert_edge_w && (opcode_i == 8'h06) && (frame_bit_cnt_i == 12'd8);
  wire wrdi_pri_frame_done_w  = phys_cs_deassert_edge_w && (opcode_i == 8'h04) && (frame_bit_cnt_i == 12'd8);
  wire rdsr1_pri_frame_done_w = phys_cs_deassert_edge_w && (opcode_i == 8'h05) && (frame_bit_cnt_i == 12'd16) && sr1_byte_sampled_q;
  wire erase_pri_frame_done_w = phys_cs_deassert_edge_w && ((opcode_i == 8'h20) || (opcode_i == 8'hD8)) &&
                                (frame_bit_cnt_i == 12'd32) && addr_is_bank_b_aligned_w;
  wire prog_pri_frame_done_w  = phys_cs_deassert_edge_w && (opcode_i == 8'h02) &&
                                (frame_bit_cnt_i >= 12'd40) && (frame_bit_cnt_i <= 12'd2080) &&
                                (frame_bit_cnt_i[2:0] == 3'b000) && addr_is_bank_b_aligned_w;
  wire prog_or_erase_pri_done_w = erase_pri_frame_done_w || prog_pri_frame_done_w;

  // SPI Update Reconciliation State Machine (Rev. 28 / 28A / 28B)
  always_ff @(posedge clk_i or negedge rst_sys_ni) begin
    if (!rst_sys_ni) begin
      spi_update_fsm_q <= UPD_UNSYNC_RESET;
    end else begin
      case (spi_update_fsm_q)
        UPD_UNSYNC_RESET: begin
          if (upd_wdog_timeout_i) begin
            spi_update_fsm_q <= UPD_RECOVERY_LOCKOUT;
          end else if (wrdi_pri_frame_done_w) begin
            // 04h (WRDI) does NOT transition to UPD_IDLE; must verify via fresh 05h (RDSR1)
            spi_update_fsm_q <= UPD_UNSYNC_RESET;
          end else if (rdsr1_pri_frame_done_w) begin
            if (!fault_high_sec_i && (sr1_latched_byte_q[1:0] == 2'b00))
              spi_update_fsm_q <= UPD_IDLE;
            else
              spi_update_fsm_q <= UPD_UNSYNC_RESET;
          end
        end

        UPD_IDLE: begin
          if (upd_wdog_timeout_i) begin
            spi_update_fsm_q <= UPD_RECOVERY_LOCKOUT;
          end else if (fault_high_sec_i) begin
            spi_update_fsm_q <= UPD_UNSYNC_RESET;
          end else if (wren_pri_frame_done_w) begin
            spi_update_fsm_q <= UPD_WEL_PENDING;
          end
        end

        UPD_WEL_PENDING: begin
          if (upd_wdog_timeout_i) begin
            spi_update_fsm_q <= UPD_RECOVERY_LOCKOUT;
          end else if (fault_high_sec_i || wrdi_pri_frame_done_w) begin
            spi_update_fsm_q <= UPD_UNSYNC_RESET;
          end else if (prog_or_erase_pri_done_w) begin
            spi_update_fsm_q <= UPD_PROGRAM_BUSY;
          end
        end

        UPD_PROGRAM_BUSY: begin
          if (upd_wdog_timeout_i) begin
            spi_update_fsm_q <= UPD_RECOVERY_LOCKOUT;
          end else if (fault_high_sec_i) begin
            spi_update_fsm_q <= UPD_UNSYNC_RESET;
          end else if (rdsr1_pri_frame_done_w) begin
            if (sr1_latched_byte_q[1:0] == 2'b00)
              spi_update_fsm_q <= UPD_VERIFY_CLEAR;
            else
              spi_update_fsm_q <= UPD_PROGRAM_BUSY;
          end
        end

        UPD_VERIFY_CLEAR: begin
          if (upd_wdog_timeout_i) begin
            spi_update_fsm_q <= UPD_RECOVERY_LOCKOUT;
          end else if (fault_high_sec_i) begin
            spi_update_fsm_q <= UPD_UNSYNC_RESET;
          end else if (rdsr1_pri_frame_done_w && (sr1_latched_byte_q[1:0] == 2'b00)) begin
            spi_update_fsm_q <= UPD_IDLE;
          end else if (rdsr1_pri_frame_done_w && (sr1_latched_byte_q[1:0] != 2'b00)) begin
            spi_update_fsm_q <= UPD_UNSYNC_RESET;
          end
        end

        UPD_RECOVERY_LOCKOUT: begin
          spi_update_fsm_q <= UPD_RECOVERY_LOCKOUT;
        end

        default: begin
          spi_update_fsm_q <= UPD_RECOVERY_LOCKOUT;
        end
      endcase
    end
  end

  // Layer 3 separation: UPD_IDLE indicates physical SPI readiness only;
  // Bank-B commit authorization strictly requires independent rom_img_verif_valid_i.
  assign spi_idle_ready_o      = (spi_update_fsm_q == UPD_IDLE) && !fault_high_sec_i;
  assign bank_b_commit_ready_o = spi_idle_ready_o && rom_img_verif_valid_i;
  assign spi_update_state_o    = spi_update_fsm_q;

  // Explicit sink for upper Bank-B sector index bits [22:16] and upper SR1 status bits [7:2]
  wire unused_ok_w = &{1'b0, target_addr_i[22:16], sr1_latched_byte_q[7:2], 1'b0};

endmodule : zc_spi_flash_firewall
