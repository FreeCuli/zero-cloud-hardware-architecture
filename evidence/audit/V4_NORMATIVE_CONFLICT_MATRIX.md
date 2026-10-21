# FREECULI ZC-CORE  --  v4.0.0 Normative Conflict Matrix

**Document ID:** ZC-CORE-MAT-CONFLICT-01
**Project:** FreeCuli ZC-CORE Hardware Architecture & Methodology
**Target Release:** v4.0.0 Architecture & Licensing Transition
**Document Classification:** Cross-Document Conflict Analysis & Resolution Matrix
**Location:** `evidence/audit/V4_NORMATIVE_CONFLICT_MATRIX.md`
**Governance Status:** `DRAFT CONFLICT MATRIX / INFORMATIONAL / NOT RATIFIED`
**Related Documents:**
- `zero-cloud-core-methodology-invariants.md` (Legacy Baseline Invariants)
- `zero-cloud-dual-licensing.md` (Legacy Baseline Policy File)
- `docs/rfc/ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md` (v4 Successor RFC)
- `evidence/audit/V4_STRATEGIC_IP_INDEPENDENT_AUDIT.md`
- `evidence/audit/V4_LICENSE_AND_RIGHTS_RISK_REGISTER.md`
- `evidence/legal/V4_LEGACY_LICENSING_BASELINE_AUDIT.md`
- `evidence/architecture/M1_M10_COMPATIBILITY_AND_REMEDIATION_PLAN.md`

---

## 1. Executive Summary

This matrix identifies, analyzes, and proposes formal resolutions for all internal contradictions, conflicting normative requirements, and divergent legal statements identified across the FreeCuli ZC-CORE repository (v3.3.0-rc2 baseline versus Gate C/D engineering realities).

To preserve historical audit integrity while preparing the codebase for v4.0.0, **no historical root files are modified directly**; all proposed resolutions are formulated as draft successor language in `docs/rfc/` and `evidence/audit/`.

---

## 2. Comprehensive Normative Conflict Table

| Conflict ID | Domain | File A (Location & Text) | File B (Location & Text) | Nature of Contradiction | Severity | Proposed v4 Resolution |
| :---: | :--- | :--- | :--- | :--- | :---: | :--- |
| **NC-01** | **Methodology vs Expression** | `zero-cloud-core-methodology-invariants.md:35-39` | `LICENSE:39-41` (Demands commercial agreement for compliance) | Invariants permit clean-room; LICENSE overreaches by demanding agreement | **CRITICAL** | Ratify Dual-Licensing RFC Section 3.3 (Clean-Room Freedom Guarantee) |
| **NC-02** | **Open Source Discrimination** | `README.md:22-24` (CTS conformance != code ownership) | `zero-cloud-dual-licensing.md:14-23` (Route A barred for commercial) | Breaches OSD #5 & #6 by banning commercial entities from Route A | **HIGH** | In Dual-Licensing RFC, open Route A unconditionally to commercial entities |
| **NC-03** | **Hardware Scope (Phantom Assets)** | `LICENSE:17-22` (Claims CERN-OHL-S covers PCB layouts & Gerbers) | `Git History` (Zero .kicad*, .sch, .brd, or .gbr files exist in repo) | License covers PCB layouts and Gerbers never published in repository | **HIGH** | Scope v4 open hardware strictly to synthesizable RTL and formal proofs |
| **NC-04** | **M1 / M3 Telemetry Strictness** | `zero-cloud-core-methodology-invariants.md:20-24` (Zero outbound) | `docs/architecture/zc-core-security-profiles.md:4.1` (Hybrid release) | Legacy invariants conflate pure diodes with firewalled bidirectional buses | **HIGH** | Adopt M3 profile stratification (STRICT vs HYBRID) in Architecture RFC |
| **NC-05** | **Trademark vs Copyright** | `zero-cloud-core-brand-and-trademark-policy.md:26-31` (Compulsory bundle) | `Legal Doctrine & README.md` (Copyright != Trademark certification) | Compulsory bundle locks clean-room vendors out of trademark certification | **MEDIUM** | Decouple copyright (Route A/B) from trademark (Level 1..4) in Trademark RFC |
| **NC-06** | **Phantom Software License** | `LICENSE:24-28` (Claims controller/scripts use AGPL-3.0-or-later) | `scripts/verify_gate_b_rev28d.ps1:2` (Script header cites CERN-OHL-S-2.0) | Root license claims AGPL-3.0 scripts; zero AGPL code exists in repo | **MEDIUM** | Re-label hardware repo as pure CERN-OHL-S-2.0; reserve AGPL for software |
| **NC-07** | **Watchdog Evidence Level** | `Legacy Docs` (Claims 1024-cycle watchdog timeout proven in formal) | `evidence/gate-c/MODELING_LIMITS.md` (Rollover exceeds BMC horizon k=25) | Documentation over-claimed formal proof status for large monotonic counter | **RESOLVED (GATE C)** | Document watchdog as verified by simulation bench tb/tb_zc_obi.sv (fb8e124) |
| **NC-08** | **Release Freeze vs RFCs** | `zero-cloud-core-versioning-and-governance.md:29-37` (Normative freeze) | `gate-c/formal-scope-audit` (RFC drafts prepared alongside baseline) | Risk that draft RFC proposals are mistaken for normative alterations | **LOW** | Maintain strict isolation: RFCs reside in docs/rfc/ and evidence/ |

---

## 3. Analysis & Harmonization Sequence

### 3.1. Primary Legal Faultline: Methodology vs. Expression (NC-01 & NC-02)
The greatest risk to FreeCuli's commercial viability and community trust was the conflation of the *abstract security standard* with the *concrete reference RTL files*.
- In intellectual property law, FreeCuli cannot own or license the general concept of "putting a data diode between a sensor processor and a network chip". Anyone can build that from scratch.
- What FreeCuli **does own** is the concrete SystemVerilog source code in `rtl/zc_aon_post_auth_ctrl.sv`, `rtl/zc_obi_subordinate_bridge.sv`, `rtl/zc_spi_flash_firewall.sv`, and `rtl/zc_otp_pkg.sv`.
- By establishing this exact boundary, FreeCuli:
  1. Grants clean-room freedom to the industry, accelerating ZC-CORE standard adoption;
  2. Protects its legitimate Route B commercial revenue by licensing its proven, formally verified RTL blocks to companies seeking faster time-to-market.

### 3.2. Primary Technical Faultline: Inbound Updates vs. Air-Gap (NC-04)
The tension between absolute physical isolation (M1/M2) and in-field firmware updates (M6) is formally resolved through **Profile Bifurcation**:
- **STRICT Profile:** Traditional hardwired unidirectional diode; absolute zero inbound/outbound communication.
- **HYBRID Profile:** Bidirectional bus mediated by hardware firewalls (`zc_spi_flash_firewall`, `zc_obi_subordinate_bridge`), allowing authenticated OTA updates and rate-limited semantic status release.

---
*End of V4_NORMATIVE_CONFLICT_MATRIX.md  --  Prepared for FreeCuli Architecture & Governance Review.*
