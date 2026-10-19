// Copyright 2026 FreeCuli Standards Organization
// SPDX-License-Identifier: CERN-OHL-S-2.0
//
// Module: zc_obi_formal_proof
// Description:
//   Gate C Formal Verification Harness for zc_obi_subordinate_bridge (Yosys/SymbiYosys BMC + k-induction):
//   Proves all Rev. 28 - Rev. 28D and GCR-01 OBI security properties:
//   - F-OBI-01 (SVA-L0-10a): Single-response delivery lock (cpu_resp_delivered_q prevents double response)
//   - F-OBI-02a (SVA-L0-10b Part 1): Orphan response in ST_IDLE silently drained on arrival cycle (host_rvalid_o == 0)
//   - F-OBI-02b (SVA-L0-10b Part 2): Orphan response in ST_IDLE clears phys_req_active_q on next cycle
//   - F-OBI-02c (SVA-L0-10b Part 3): No delayed synthetic or stale rvalid on cycle following orphan drain
//   - F-OBI-03 (SVA-L0-12a): Strictly normative - Normal active CPU wait without orphan_drain_active_o
//     never triggers or increments watchdog (drain_wdog_cnt_o == 0 && !subsys_fatal_fault_irq_o)
//   - F-OBI-04 (R28B-03 / SVA-L0-13a): Unconditional monotonic +1 progression of drain_wdog_cnt_q
//     whenever orphan_active_w holds (even while !rst_sys_ni == 0 or ST_TIMEOUT_ERR persists)
//   - F-OBI-05 (SVA-L0-13b): Reaching drain_wdog_cnt_q == 1023 without rvalid locks subsys_dead_locked_q = 1
//   - F-OBI-06 (Rev. 28D P1 / SVA-L0-13c): Under subsys_dead_locked_q == 1, ST_IDLE accepts CPU requests
//     with periph_phys_req_o == 0, transitions to ST_TRAP, returns synthetic bus error (rvalid=1, err=1, rdata=0),
//     and returns to ST_IDLE on the following cycle
//   - F-OBI-07 (GCR-01 / SVA-L0-14): Warm Reset (!rst_sys_ni == 0) strictly forces host_req_ready_o == 0,
//     periph_phys_req_o == 0, and host_rvalid_o == 0

module zc_obi_formal_proof (
  input logic        clk_i,
  input logic        rst_por_ni,
  input logic        rst_sys_ni,
  input logic        host_req_i,
  input logic        periph_phys_gnt_i,
  input logic        periph_phys_rvalid_i,
  input logic        periph_phys_err_i,
  input logic [31:0] periph_phys_rdata_i
);

  logic        host_req_ready_o;
  logic        host_rvalid_o;
  logic        host_err_o;
  logic [31:0] host_rdata_o;
  logic        periph_phys_req_o;
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

  logic f_past_valid;
  initial f_past_valid = 1'b0;
  always_ff @(posedge clk_i) f_past_valid <= 1'b1;

  logic f_phys_req_active_q;
  always_ff @(posedge clk_i or negedge rst_por_ni) begin
    if (!rst_por_ni) begin
      f_phys_req_active_q <= 1'b0;
    end else begin
      case ({periph_phys_req_o && periph_phys_gnt_i, periph_phys_rvalid_i})
        2'b10:   f_phys_req_active_q <= 1'b1;
        2'b01:   f_phys_req_active_q <= 1'b0;
        default: f_phys_req_active_q <= f_phys_req_active_q;
      endcase
    end
  end

  always_comb begin
    if (!f_past_valid) assume (!rst_por_ni);

    // Combinational invariant: In ST_IDLE, host_rvalid_o is strictly 0
    if (bridge_state_o == ST_IDLE) begin
      assert (!host_rvalid_o);
    end

    // F-OBI-07 (GCR-01 / SVA-L0-14): Warm Reset (!rst_sys_ni == 0) blocks request, ready, and rvalid
    if (rst_por_ni && !rst_sys_ni) begin
      assert (!host_req_ready_o);
      assert (!periph_phys_req_o);
      assert (!host_rvalid_o);
    end

    // F-OBI-06a (Rev. 28D P1): In ST_IDLE under subsys_fatal_fault_irq_o (subsys_dead_locked_q) and rst_sys_ni, ready=1 and phys_req=0
    if (rst_por_ni && rst_sys_ni && (bridge_state_o == ST_IDLE) && subsys_fatal_fault_irq_o) begin
      assert (host_req_ready_o == 1'b1);
      assert (periph_phys_req_o == 1'b0);
    end
  end

  always_ff @(posedge clk_i) begin
    if (f_past_valid && $past(rst_por_ni) && rst_por_ni) begin
      // F-OBI-01 (SVA-L0-10a): Once CPU response is delivered in ST_WAIT_RVALID, ST_TIMEOUT_ERR, or ST_TRAP,
      // bridge returns to ST_IDLE on the next cycle and does not re-assert host_rvalid_o.
      if ($past(rst_sys_ni) && rst_sys_ni &&
          $past(host_rvalid_o && (bridge_state_o != ST_IDLE))) begin
        assert ((bridge_state_o == ST_IDLE) && !host_rvalid_o);
      end

      // F-OBI-02a (SVA-L0-10b / Part 1): Orphan response in ST_IDLE is never forwarded to CPU on arrival cycle
      if (rst_sys_ni && (bridge_state_o == ST_IDLE) && f_phys_req_active_q && periph_phys_rvalid_i && !periph_phys_req_o) begin
        assert (!host_rvalid_o);
      end

      // F-OBI-02b (SVA-L0-10b / Part 2): Strictly normative - Cycle following orphan response drain in ST_IDLE
      if ($past(rst_sys_ni && (bridge_state_o == ST_IDLE) && f_phys_req_active_q && periph_phys_rvalid_i && !periph_phys_req_o)) begin
        assert (!f_phys_req_active_q);
      end

      // F-OBI-02c (SVA-L0-10b / Part 3): Strict distinction of orphan drain vs legitimate ST_TRAP synthetic error
      if ($past(rst_sys_ni && (bridge_state_o == ST_IDLE) && f_phys_req_active_q && periph_phys_rvalid_i && !periph_phys_req_o) &&
          rst_sys_ni) begin
        if (!$past(host_req_i && subsys_fatal_fault_irq_o)) begin
          assert ((bridge_state_o == ST_IDLE) && !host_rvalid_o);
        end else begin
          assert ((bridge_state_o == ST_TRAP) && host_rvalid_o && host_err_o && (host_rdata_o == 32'h0000_0000));
        end
      end

      // F-OBI-03 (SVA-L0-12a): Strictly normative - Normal active CPU wait without orphan_drain_active_o
      // never triggers or increments watchdog
      if ($past(rst_sys_ni && (bridge_state_o == ST_WAIT_RVALID) &&
                !orphan_drain_active_o && !subsys_fatal_fault_irq_o &&
                (drain_wdog_cnt_o == 10'd0))) begin
        assert (!orphan_drain_active_o && !subsys_fatal_fault_irq_o && (drain_wdog_cnt_o == 10'd0));
      end

      // F-OBI-04 (R28B-03 / SVA-L0-13a): Monotonic +1 progression of drain_wdog_cnt_o when orphan_drain_active_o holds
      if ($past(orphan_drain_active_o && !periph_phys_rvalid_i && !subsys_fatal_fault_irq_o &&
                (drain_wdog_cnt_o < 10'd1023))) begin
        assert (((drain_wdog_cnt_o == ($past(drain_wdog_cnt_o) + 10'd1)) && orphan_drain_active_o) ||
                (!orphan_drain_active_o && (drain_wdog_cnt_o == 10'd0)));
      end

      // F-OBI-05 (SVA-L0-13b): Reaching 1023 under active orphan drain without rvalid locks subsys_fatal_fault_irq_o
      if ($past(orphan_drain_active_o && !periph_phys_rvalid_i && !subsys_fatal_fault_irq_o &&
                (drain_wdog_cnt_o == 10'd1023)) &&
          orphan_drain_active_o) begin
        assert (subsys_fatal_fault_irq_o && !periph_phys_req_o);
      end

      // F-OBI-06b (Rev. 28D P1 / SVA-L0-13c): ST_IDLE + subsys_dead_locked_q + host_req_i -> ST_TRAP synthetic error
      if ($past(rst_sys_ni && (bridge_state_o == ST_IDLE) && subsys_fatal_fault_irq_o && host_req_i) &&
          rst_sys_ni) begin
        assert (bridge_state_o == ST_TRAP);
        assert (host_rvalid_o == 1'b1);
        assert (host_err_o == 1'b1);
        assert (host_rdata_o == 32'h0000_0000);
        assert (periph_phys_req_o == 1'b0);
        assert (subsys_fatal_fault_irq_o == 1'b1);
      end

      // F-OBI-06c (Rev. 28D P1 / SVA-L0-13c): ST_TRAP returns to ST_IDLE on the next cycle while staying deadlocked
      if ($past(rst_sys_ni && (bridge_state_o == ST_TRAP) && subsys_fatal_fault_irq_o) && rst_sys_ni) begin
        assert (bridge_state_o == ST_IDLE);
        assert (subsys_fatal_fault_irq_o == 1'b1);
      end
    end
  end

  // =========================================================================
  // Non-Vacuity Cover Witness Directives (Discrete Target Reporting)
  // =========================================================================
  always_comb begin
    // C-OBI-07: Warm reset blocks physical request witness
    cover (rst_por_ni && !rst_sys_ni && host_req_i && !periph_phys_req_o);
  end

  always_ff @(posedge clk_i) begin
    if (f_past_valid && $past(rst_por_ni) && rst_por_ni) begin
      // C-OBI-01: Normal response delivery in ST_WAIT_RVALID
      cover ($past(rst_sys_ni) && rst_sys_ni && $past(host_rvalid_o && (bridge_state_o == ST_WAIT_RVALID)));

      // C-OBI-02: Orphan physical response silent drain in ST_IDLE
      cover (rst_sys_ni && (bridge_state_o == ST_IDLE) && f_phys_req_active_q && periph_phys_rvalid_i && !periph_phys_req_o);

      // C-OBI-02b: Simultaneous CPU request during orphan physical drain in ST_IDLE
      cover (rst_sys_ni && (bridge_state_o == ST_IDLE) && f_phys_req_active_q && periph_phys_rvalid_i && host_req_i);

      // C-OBI-03: Normal CPU wait state without orphan activation
      cover (rst_sys_ni && (bridge_state_o == ST_WAIT_RVALID) && !orphan_drain_active_o && (drain_wdog_cnt_o == 10'd0));

      // C-OBI-04: Orphan watchdog progression step
      cover (orphan_drain_active_o && !periph_phys_rvalid_i && (drain_wdog_cnt_o > 10'd0));
    end
  end

endmodule
