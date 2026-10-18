// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: zc_obi_subordinate_bridge
// Description:
//   Gate B Rev. 28C & Rev. 28D Final Normative OBI Subordinate Bridge:
//   - Separates normal 64-cycle transaction timeout (wait_cnt_q) from the
//     1,024-cycle orphan drain watchdog (drain_wdog_cnt_q)
//   - Unified orphan_active_w watchdog progression (Rev. 28C R28B-03 fix):
//     advances monotonically every clock cycle even while Warm Reset (!rst_sys_ni)
//     is held low or ST_TIMEOUT_ERR persists
//   - Permanently locks subsys_dead_locked_q <= 1'b1 after 1,024 cycles of
//     unanswered orphan drain (cleared only by Cold POR !rst_por_ni)
//   - Preserves Rev. 28D ST_TRAP synthetic error contract:
//     when subsys_dead_locked_q == 1'b1, accepts new CPU requests in ST_IDLE
//     (host_req_ready_o = 1'b1), issues zero physical peripheral requests
//     (periph_phys_req_o = 1'b0), transitions to ST_TRAP, and returns a
//     deterministic synthetic bus error (host_rvalid_o = 1'b1, host_err_o = 1'b1,
//     host_rdata_o = 32'h0000_0000) on the next cycle before returning to ST_IDLE

module zc_obi_subordinate_bridge (
  input  logic        clk_i,
  input  logic        rst_por_ni,              // Cold POR (only reset that clears phys_req_active_q / subsys_dead_locked_q)
  input  logic        rst_sys_ni,              // System Warm Reset

  // Host (CPU) OBI interface (Upper Band)
  input  logic        host_req_i,
  output logic        host_req_ready_o,
  output logic        host_rvalid_o,
  output logic        host_err_o,
  output logic [31:0] host_rdata_o,

  // Physical Peripheral OBI interface (Lower Band)
  output logic        periph_phys_req_o,
  input  logic        periph_phys_gnt_i,
  input  logic        periph_phys_rvalid_i,
  input  logic        periph_phys_err_i,
  input  logic [31:0] periph_phys_rdata_i,

  // Status & Interrupt outputs
  output logic        subsys_fatal_fault_irq_o,
  output logic        orphan_drain_active_o,
  output logic [9:0]  drain_wdog_cnt_o,
  output logic [1:0]  bridge_state_o
);

  typedef enum logic [1:0] {
    ST_IDLE        = 2'b00,
    ST_WAIT_RVALID = 2'b01,
    ST_TIMEOUT_ERR = 2'b10,
    ST_TRAP        = 2'b11
  } obi_bridge_state_e;

  obi_bridge_state_e state_q;
  logic              phys_req_active_q;
  logic              orphan_drain_active_q;
  logic [9:0]        drain_wdog_cnt_q;
  logic [5:0]        wait_cnt_q;
  logic              subsys_dead_locked_q;
  logic              pending_tx_q;
  logic              cpu_resp_delivered_q;

  // 1. Physical Peripheral Transaction Accounting (Cold POR domain; preserved across Warm Reset)
  always_ff @(posedge clk_i or negedge rst_por_ni) begin
    if (!rst_por_ni) begin
      phys_req_active_q <= 1'b0;
    end else begin
      case ({periph_phys_req_o && periph_phys_gnt_i, periph_phys_rvalid_i})
        2'b10:   phys_req_active_q <= 1'b1;
        2'b01:   phys_req_active_q <= 1'b0;
        default: phys_req_active_q <= phys_req_active_q;
      endcase
    end
  end

  // 2. Orphan Transaction Trigger & Active Signals (Rev. 28C R28B-03 Closure)
  wire orphan_trigger_w    = phys_req_active_q && !periph_phys_rvalid_i &&
                             (!rst_sys_ni || (state_q == ST_TIMEOUT_ERR));
  wire orphan_active_w     = orphan_drain_active_q || orphan_trigger_w;
  wire drain_in_progress_w = orphan_active_w && !subsys_dead_locked_q;

  // 3. Unified Orphan Latch & 1,024-Cycle Watchdog Counter (Priority-Free Progression)
  always_ff @(posedge clk_i or negedge rst_por_ni) begin
    if (!rst_por_ni) begin
      orphan_drain_active_q <= 1'b0;
      drain_wdog_cnt_q      <= 10'd0;
      subsys_dead_locked_q  <= 1'b0;
    end else if (!phys_req_active_q || periph_phys_rvalid_i) begin
      orphan_drain_active_q <= 1'b0;
      drain_wdog_cnt_q      <= 10'd0;
    end else if (orphan_active_w) begin
      orphan_drain_active_q <= 1'b1;
      if (!subsys_dead_locked_q) begin
        if (drain_wdog_cnt_q == 10'd1023) begin
          subsys_dead_locked_q <= 1'b1;
        end else begin
          drain_wdog_cnt_q     <= drain_wdog_cnt_q + 10'd1;
        end
      end
    end
  end

  // 4. Normal Transaction 64-Cycle Response Timeout Counter (Warm Reset domain)
  wire resp_timeout_expired_w = (state_q == ST_WAIT_RVALID) && (wait_cnt_q == 6'd63);

  always_ff @(posedge clk_i or negedge rst_por_ni) begin
    if (!rst_por_ni || !rst_sys_ni) begin
      wait_cnt_q <= 6'd0;
    end else if (state_q == ST_WAIT_RVALID) begin
      if (periph_phys_rvalid_i || resp_timeout_expired_w)
        wait_cnt_q <= 6'd0;
      else
        wait_cnt_q <= wait_cnt_q + 6'd1;
    end else begin
      wait_cnt_q <= 6'd0;
    end
  end

  // 5. Upper-Band OBI State Machine (with Rev. 28D ST_TRAP Synthetic Error Path)
  always_ff @(posedge clk_i or negedge rst_por_ni) begin
    if (!rst_por_ni || !rst_sys_ni) begin
      state_q              <= ST_IDLE;
      pending_tx_q         <= 1'b0;
      cpu_resp_delivered_q <= 1'b0;
    end else begin
      case (state_q)
        ST_IDLE: begin
          if (host_req_i && host_req_ready_o) begin
            pending_tx_q         <= 1'b1;
            cpu_resp_delivered_q <= 1'b0;
            if (subsys_dead_locked_q) begin
              // Rev. 28D: In permanent deadlock, do NOT issue physical request; enter ST_TRAP
              state_q <= ST_TRAP;
            end else if (periph_phys_gnt_i) begin
              state_q <= ST_WAIT_RVALID;
            end
          end else if (host_rvalid_o) begin
            pending_tx_q         <= 1'b0;
            cpu_resp_delivered_q <= 1'b1;
          end
        end

        ST_WAIT_RVALID: begin
          if (periph_phys_rvalid_i) begin
            state_q              <= ST_IDLE;
            pending_tx_q         <= 1'b0;
            cpu_resp_delivered_q <= 1'b1;
          end else if (resp_timeout_expired_w) begin
            state_q              <= ST_TIMEOUT_ERR;
          end
        end

        ST_TIMEOUT_ERR: begin
          // Return 1-cycle synthetic timeout error to CPU and return to ST_IDLE
          state_q              <= ST_IDLE;
          pending_tx_q         <= 1'b0;
          cpu_resp_delivered_q <= 1'b1;
        end

        ST_TRAP: begin
          // Rev. 28D: Return 1-cycle synthetic trap error to CPU and return to ST_IDLE
          state_q              <= ST_IDLE;
          pending_tx_q         <= 1'b0;
          cpu_resp_delivered_q <= 1'b1;
        end

        default: begin
          state_q              <= ST_IDLE;
          pending_tx_q         <= 1'b0;
          cpu_resp_delivered_q <= 1'b1;
        end
      endcase
    end
  end

  // 6. Upper-Band & Lower-Band Output Assignments (Rev. 28D Section 1.2 + GCR-01 Warm Reset Gate)
  assign host_req_ready_o  = rst_sys_ni &&
                             (state_q == ST_IDLE) &&
                             (subsys_dead_locked_q ||
                              (!phys_req_active_q && !drain_in_progress_w && periph_phys_gnt_i));

  assign periph_phys_req_o = rst_sys_ni &&
                             (state_q == ST_IDLE) &&
                             host_req_i &&
                             !phys_req_active_q &&
                             !orphan_active_w &&
                             !subsys_dead_locked_q;

  wire normal_rvalid_ok_w  = rst_sys_ni &&
                             pending_tx_q && !cpu_resp_delivered_q &&
                             (state_q == ST_WAIT_RVALID) &&
                             periph_phys_rvalid_i &&
                             phys_req_active_q &&
                             !orphan_active_w &&
                             !subsys_dead_locked_q;

  wire synth_err_rvalid_w  = rst_sys_ni &&
                             pending_tx_q && !cpu_resp_delivered_q &&
                             ((state_q == ST_TIMEOUT_ERR) || (state_q == ST_TRAP));

  assign host_rvalid_o     = normal_rvalid_ok_w || synth_err_rvalid_w;
  assign host_err_o        = synth_err_rvalid_w ? 1'b1          : periph_phys_err_i;
  assign host_rdata_o      = synth_err_rvalid_w ? 32'h0000_0000 : periph_phys_rdata_i;

  assign subsys_fatal_fault_irq_o = subsys_dead_locked_q;
  assign orphan_drain_active_o    = orphan_drain_active_q;
  assign drain_wdog_cnt_o         = drain_wdog_cnt_q;
  assign bridge_state_o           = state_q;

endmodule : zc_obi_subordinate_bridge
