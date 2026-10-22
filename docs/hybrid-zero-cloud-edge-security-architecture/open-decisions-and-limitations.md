# Hybrid Zero-Cloud & Edge Security Architecture
## Open Decisions, Integration Risks & Limitations

**Document ID:** `ZC-HYBRID-LIMITATIONS-01`  
**Classification:** Canonical Architecture Suite Technical Disclosure  
**Status:** `CANDIDATE BASELINE / UNRATIFIED`  
**Parent Document:** [`README.md`](README.md)  

---

## 1. Executive Disclosure Statement

To prevent overstatement of architectural maturity and protect the integrity of the FreeCuli Zero-Cloud Hardware Core (ZC-CORE) defensive publication, this document records all unresolved technical risks, unverified physical boundaries, and pending governance decisions.

A property is disclosed as a **Limitation** where it is either:
1. Necessary for full-chip production but omitted from standalone Gate C RTL blocks.
2. Verified under mathematical abstractions (e.g., `async2sync`) that do not reflect physical analog or silicon behaviors.
3. An architectural proposal in the V4 RFC that has not yet undergone physical implementation.

---

## 2. Technical Integration Risks (Hardware & RTL Level)

### 2.1 AON Clock Domain Crossing (CDC) & Synchronizer Absence
- **Affected Module:** [`rtl/zc_aon_post_auth_ctrl.sv`](../../rtl/zc_aon_post_auth_ctrl.sv) (Lines 158–163)
- **Concrete Technical Issue:**
  The authorization logic evaluates:
  ```systemverilog
  wire write_authorized_w = (aon_auth_state_q == AUTH_GRANT) &&
                            (wstep_q == WSTEP_AUTH_READY) &&
                            word_grant_avail_q &&
                            rst_sys_ni &&
                            rom_exec_active_i;
  ```
  Here, `clk_aon_i` is the Always-On clock (typically ~32 kHz), while `rst_sys_ni` (system warm reset) and `rom_exec_active_i` (Boot ROM execution indicator) originate from the high-speed system clock domain (`clk_sys_i`, typically 50–200 MHz).
  These signals cross between asynchronous clock domains without a two-stage flip-flop synchronizer or a formal handshaking bridge inside `zc_aon_post_auth_ctrl.sv`.
- **Formal Toolchain Abstraction:**
  Under the Gate C formal harness ([`evidence/gate-c/MODELING_LIMITS.md`](../../evidence/gate-c/MODELING_LIMITS.md)), Yosys executes the `async2sync` pass. This transforms all reset paths into idealized, synchronous transitions aligned to `clk_aon_i` clock edges.
- **Physical Silicon Risk:**
  In physical silicon, a warm reset asserted asynchronously during a write handshake could induce metastability in combinational logic, potentially causing runt pulses on `otp_word_auth_valid_o` or indeterminate state transitions.
- **Current Status:** **`Gate D (UNVERIFIED)`** — Dual-rank synchronization flip-flops and Glitch-Free Reset Bridges are marked as mandatory top-level integration tasks prior to tape-out.

### 2.2 Full-SoC DMA Isolation & Multi-Master Crossbar Security
- **Affected Scope:** Top-Level SoC Interconnect
- **Concrete Technical Issue:**
  The implemented OBI subordinate bridge ([`rtl/zc_obi_subordinate_bridge.sv`](../../rtl/zc_obi_subordinate_bridge.sv)) cleanly decouples point-to-point transactions between the Network Co-Processor and the host interconnect. However, it does not provide an Input-Output Memory Management Unit (IOMMU) or Physical Memory Protection (PMP) crossbar.
  If a third-party SoC implements bus-mastering DMA engines inside Domain 0 without strict hardware bus firewalls, a compromised network processor could theoretically instruct an un-firewalled DMA engine to read Secure SRAM directly.
- **Current Status:** **`Gate D (UNVERIFIED)`** — Formal proof `fv/zc_m7_m8_ni_sva.sv` requires top-level SoC netlist instantiating dual Ibex cores and memory crossbars; it remains unverified on standalone IP blocks.

### 2.3 Absence of Telemetry Allowlist & Rate-Limiting Silicon
- **Affected Scope:** Outbound Semantic Telemetry Path
- **Concrete Technical Issue:**
  While the HYBRID architecture specifies allowlisted, entropy-bounded semantic telemetry as an architectural goal, the current Gate C digital RTL (`eb3ed5a`) contains **no hardware schema comparator or rate-limiting packetizer**. The OBI bridge acts as a transport decoupling block, not a semantic payload inspector.
- **Current Status:** **`TBD — Technical Evidence or Design Decision Required`** (Target for Gate D SoC integration). Until such hardware is physically integrated, outbound telemetry cannot claim hardware-enforced semantic bounding.

---

## 3. Physical Silicon Deferrals (Gate D Horizon)

The following areas are outside the mathematical capability of open-source discrete-time formal solvers (Yosys / Z3) and are formally deferred to **Gate D (Physical Silicon Validation)**:

| Silicon Boundary Dimension | Technical Constraint & Horizon | Required Gate D Verification Mechanism | Current Status |
| :--- | :--- | :--- | :---: |
| **Static Timing Analysis (STA)** | Setup/hold timing closure across PVT corners (Process: SS/TT/FF, Voltage: $\pm 10\%$, Temp: $-40^\circ\text{C}$ to $+125^\circ\text{C}$). | OpenSTA / Commercial Primetime sign-off on foundry PDK netlists. | **`Gate D (UNVERIFIED)`** |
| **Foundry OTP Macro Physics** | High-voltage charge pump ramp-up ($V_{\text{PP}} \approx 1.8\text{V} - 2.5\text{V}$), analog programming pulse soak ($t_{\text{PROG}} \approx 10\,\mu\text{s}$), and sense amplifier margins. | Physical wafer probe testing and lab characterization on fabricated silicon test chips. | **`Gate D (UNVERIFIED)`** |
| **Flash Pin Capacitive Reflections** | High-speed SPI clock ringing, trace impedance mismatch, and runt pulses on external board traces. | Vector Network Analyzer (VNA) and 4 GHz oscilloscope eye-diagram measurements. | **`Gate D (UNVERIFIED)`** |
| **SRAM Physical Remanence** | Silicon-level data remanence in CMOS volatile memory cells post-power-down at cryogenic/sub-zero temperatures. | Physical thermal chamber testing and residual charge probing under CTS Annex C. | **`Gate D (UNVERIFIED)`** |
| **Differential Power Analysis (DPA)** | Cryptographic key or weight extraction via power supply current side-channel modulation. | Test Vector Leakage Assessment (TVLA) with $>100,000$ traces under CTS §6. | **`Gate D (UNVERIFIED)`** |

---

## 4. Pending Governance & Architectural Decisions

| Decision Topic | Current State & Trade-Off | Alternatives Under Consideration | Impact on Release Candidate |
| :--- | :--- | :--- | :--- |
| **V4 Standard Ratification** | [`docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md`](../../docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md) is currently `DRAFT / NOT RATIFIED`. | **Option 1:** Ratify V4 as a standalone major standard once Gate D silicon is proven.<br>**Option 2:** Maintain v3.x as the immutable normative core and ratify HYBRID as an optional annex profile. | In `v4.0.0-rc1`, V4 remains an architectural draft proposal; root v3.x specs remain normative baseline. |
| **Data Class 0 Inbound Formalization** | Class 0 (Inbound Control) is defined in RFC-0004 but omitted from root [`zero-cloud-core-scope-boundary.md`](../../zero-cloud-core-scope-boundary.md). | Keep root scope boundary 4-class taxonomy frozen to preserve backward compatibility; treat Class 0 as a candidate extension. | No change to root documents. Resolved via reconciliation in `strict-hybrid-compatibility.md`. |
| **Hardware Rate Limiter Specification** | Exact telemetry packet transmission frequency (e.g., max 1 packet per 60 s vs 1 packet per 300 s) is unspecified in RTL. | `TBD — Technical Evidence or Design Decision Required`: Must be fixed in hardware register specification during Gate D top-level architecture sign-off. | Documented as an open design target; not claimed as an active hardware feature. |
