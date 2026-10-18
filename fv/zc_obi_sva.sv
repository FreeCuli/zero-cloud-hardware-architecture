// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: zc_obi_sva
// Status: [GATE-C VERIFICATION OBLIGATION / UNVERIFIED]
// Description:
//   Bindable SystemVerilog Assertions (SVA) for zc_obi_subordinate_bridge
//   covering Gate B Rev. 28 - Rev. 28D OBI transaction isolation,
//   unconditional orphan watchdog progression (R28B-03), and
//   Rev. 28D ST_TRAP synthetic error response under subsys_dead_locked_q.

module zc_obi_sva (
  input logic        clk_i,
  input logic        rst_por_ni,
  input logic        rst_sys_ni,
  input logic        host_req_i,
  input logic        host_req_ready_o,
  input logic        host_rvalid_o,
  input logic        host_err_o,
  input logic [31:0] host_rdata_o,
  input logic        periph_phys_req_o,
  input logic        periph_phys_rvalid_i,
  input logic [1:0]  state_q,
  input logic        phys_req_active_q,
  input logic        orphan_drain_active_q,
  input logic        orphan_active_w,
  input logic [9:0]  drain_wdog_cnt_q,
  input logic        subsys_dead_locked_q,
  input logic        pending_tx_q,
  input logic        cpu_resp_delivered_q
);

  localparam logic [1:0] ST_IDLE        = 2'b00;
  localparam logic [1:0] ST_WAIT_RVALID = 2'b01;
  localparam logic [1:0] ST_TIMEOUT_ERR = 2'b10;
  localparam logic [1:0] ST_TRAP        = 2'b11;

  // SVA-L0-10a: Once a CPU response is delivered, cpu_resp_delivered_q locks out a second response.
  a_l0_resp_delivered_locks_out_second_response:
    assert property (@(posedge clk_i) disable iff (!rst_por_ni || !rst_sys_ni)
      (host_rvalid_o && !(host_req_i && host_req_ready_o))
      |=> (cpu_resp_delivered_q && !pending_tx_q && !host_rvalid_o)
    );

  // SVA-L0-10b: An orphan physical response arriving in ST_IDLE after Warm Reset is never forwarded to CPU.
  a_l0_orphan_phys_resp_silently_drained:
    assert property (@(posedge clk_i) disable iff (!rst_por_ni)
      (rst_sys_ni && (state_q == ST_IDLE) && phys_req_active_q && periph_phys_rvalid_i && !periph_phys_req_o)
      |-> (!host_rvalid_o) ##1 (!phys_req_active_q)
    );

  // SVA-L0-12a: During a normal active CPU wait (state_q == ST_WAIT_RVALID && !orphan_active_w),
  // the orphan watchdog counter stays at 0.
  a_l0_normal_wait_never_increments_orphan_wdog:
    assert property (@(posedge clk_i) disable iff (!rst_por_ni)
      (rst_sys_ni && (state_q == ST_WAIT_RVALID) && !orphan_active_w && !subsys_dead_locked_q)
      |=> (drain_wdog_cnt_q == 10'd0) && !subsys_dead_locked_q
    );

  // SVA-L0-13a (R28B-03): Whenever orphan_active_w holds (even if !rst_sys_ni stays low or
  // ST_TIMEOUT_ERR persists), drain_wdog_cnt_q increments by +1 every cycle unless rvalid arrives.
  a_obi_orphan_wdog_monotonic_progress:
    assert property (@(posedge clk_i) disable iff (!rst_por_ni)
      (orphan_active_w && !periph_phys_rvalid_i && !subsys_dead_locked_q && (drain_wdog_cnt_q < 10'd1023))
      |=> (orphan_drain_active_q && (drain_wdog_cnt_q == ($past(drain_wdog_cnt_q) + 10'd1))) ||
          periph_phys_rvalid_i
    );

  // SVA-L0-13b (Rev. 28D): When drain_wdog_cnt_q reaches 1023 without rvalid, subsys_dead_locked_q
  // locks to 1'b1 on the next cycle and physical requests are permanently blocked.
  a_obi_orphan_wdog_locks_dead_subsys:
    assert property (@(posedge clk_i) disable iff (!rst_por_ni)
      (orphan_active_w && !periph_phys_rvalid_i && !subsys_dead_locked_q && (drain_wdog_cnt_q == 10'd1023))
      |=> (subsys_dead_locked_q && !periph_phys_req_o)
    );

  // SVA-L0-13c (Rev. 28D Final P1 Closure): When subsys_dead_locked_q == 1'b1 in ST_IDLE,
  // any new CPU request (host_req_i) is immediately accepted (host_req_ready_o == 1'b1),
  // zero physical peripheral requests are issued (periph_phys_req_o == 1'b0), and on the
  // next cycle ST_TRAP returns a synthetic error (host_rvalid_o == 1, host_err_o == 1, host_rdata_o == 0)
  // before returning to ST_IDLE while keeping subsys_dead_locked_q == 1'b1.
  a_obi_dead_locked_returns_synthetic_trap_err:
    assert property (@(posedge clk_i) disable iff (!rst_por_ni || !rst_sys_ni)
      ((state_q == ST_IDLE) && subsys_dead_locked_q && host_req_i)
      |-> (host_req_ready_o && !periph_phys_req_o)
      ##1 ((state_q == ST_TRAP) && host_rvalid_o && host_err_o &&
           (host_rdata_o == 32'h0000_0000) && !periph_phys_req_o && subsys_dead_locked_q)
      ##1 ((state_q == ST_IDLE) && subsys_dead_locked_q)
    );

  // SVA-L0-14 (GCR-01 Closure): Warm Reset (!rst_sys_ni == 1'b0) strictly blocks new request
  // acceptance (host_req_ready_o == 1'b0), physical peripheral requests (periph_phys_req_o == 1'b0),
  // and CPU response strobes (host_rvalid_o == 1'b0), preventing any new phys_req_active_q latch.
  a_obi_warm_reset_blocks_req_and_ready:
    assert property (@(posedge clk_i) disable iff (!rst_por_ni)
      !rst_sys_ni
      |-> (!host_req_ready_o && !periph_phys_req_o && !host_rvalid_o)
    );

endmodule : zc_obi_sva

// Canonical SystemVerilog bind into zc_obi_subordinate_bridge
bind zc_obi_subordinate_bridge zc_obi_sva u_zc_obi_sva (
  .clk_i                 (clk_i),
  .rst_por_ni            (rst_por_ni),
  .rst_sys_ni            (rst_sys_ni),
  .host_req_i            (host_req_i),
  .host_req_ready_o      (host_req_ready_o),
  .host_rvalid_o         (host_rvalid_o),
  .host_err_o            (host_err_o),
  .host_rdata_o          (host_rdata_o),
  .periph_phys_req_o     (periph_phys_req_o),
  .periph_phys_rvalid_i  (periph_phys_rvalid_i),
  .state_q               (bridge_state_o),
  .phys_req_active_q     (phys_req_active_q),
  .orphan_drain_active_q (orphan_drain_active_q),
  .orphan_active_w       (orphan_active_w),
  .drain_wdog_cnt_q      (drain_wdog_cnt_q),
  .subsys_dead_locked_q  (subsys_dead_locked_q),
  .pending_tx_q          (pending_tx_q),
  .cpu_resp_delivered_q  (cpu_resp_delivered_q)
);

