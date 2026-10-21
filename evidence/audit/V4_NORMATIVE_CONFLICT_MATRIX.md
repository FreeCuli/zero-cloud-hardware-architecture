# FREECULI ZC-CORE — v4.0.0 Normative Conflict Matrix

**Document ID:** ZC-CORE-MAT-CONFLICT-01  
**Project:** FreeCuli ZC-CORE Hardware Architecture & Methodology  
**Target Release:** v4.0.0 Architecture & Licensing Transition  
**Document Classification:** Cross-Document Conflict Analysis & Resolution Matrix  
**Location:** `evidence/audit/V4_NORMATIVE_CONFLICT_MATRIX.md`  
**Governance Status:** `DRAFT CONFLICT MATRIX / INFORMATIONAL / NOT RATIFIED`  
**Related Documents:**
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
| **NC-01** | **Methodology vs. Expression** | `zero-cloud-core-methodology-invariants.md` Section 4 (Lines 48-49): *"Independent manufacturers may adopt the ZC-CORE methodology using their own proprietary hardware designs..."* | `LICENSE` Section 2 (Lines 39-41): *"Manufacturers seeking to build compliant Zero-Cloud appliances without releasing proprietary trade secrets... MUST execute a Commercial Exemption Agreement..."* | File A correctly states that independent clean-room designs are unencumbered, whereas File B overreaches by demanding a commercial license for abstract compliance. | **CRITICAL** | Formally ratify `ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md` Section 3.3 (Clean-Room Freedom Guarantee), overriding File B's overreaching language in the v4 release. |
| **NC-02** | **Open Source Discrimination** | `README.md` Core Philosophy (Lines 22-24): *"Conformance != Code Ownership: Passing the ZC-CORE CTS does not grant FreeCuli any ownership... retains full IP rights..."* | `zero-cloud-dual-licensing.md` Section 1-2 (Lines 14-23): *"1. Open Source Path: If you are an academic institution, independent developer... 2. Commercial Exemption Path: If you are a commercial manufacturer... You MUST obtain a Commercial Exemption..."* | File A promises vendor IP autonomy, while File B breaches OSD #5 & #6 by banning commercial companies from using the free open-source path. | **HIGH** | In `ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md`, open Route A (CERN-OHL-S v2.0) to all commercial companies willing to share source code. |
| **NC-03** | **Hardware Scope (Phantom Assets)** | `LICENSE` Section 1.A (Lines 17-22): *"Scope: Reference PCB layouts, component placement, electrical schematics, Gerber files, and hardware data diode..."* | Codebase Reality (Commit `7982771` & Git History): *Exact git log search confirms ZERO `.kicad*`, `.sch`, `.brd`, or `.gbr` files exist anywhere in the repository.* | Document claims CERN-OHL-S protects physical PCB layouts and Gerbers that were never published, creating phantom legal claims. | **HIGH** | In v4 license successor, explicitly state that current published open hardware consists strictly of synthesizable RTL (`rtl/*.sv`) and formal proofs (`fv/*.sv`). |
| **NC-04** | **M1 / M3 Telemetry Strictness** | `zero-cloud-core-methodology-invariants.md` M1 & M3 (Lines 20-24): *"M1: Raw sensor data SHALL NEVER leave... M3: Information SHALL flow strictly from Trusted to Network... Authenticated control traffic MAY enter..."* | `docs/architecture/zc-core-security-profiles.md` Section 4.1 & `M3-RFC-REVISED`: *Distinguishes STRICT (diode, 0 outbound telemetry) from HYBRID (inbound OTA + allowlisted semantic telemetry).* | Legacy M1/M3 text did not formally distinguish between pure unidirectional diodes and hardware-firewalled bidirectional buses. | **HIGH** | Adopt `M3-RFC-REVISED` profile stratification (M3-STRICT vs M3-HYBRID) in `docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md`. |
| **NC-05** | **Trademark vs. Copyright** | `zero-cloud-core-brand-and-trademark-policy.md` Commercial Exemption (Line 44): *"To bypass these obligations and keep hardware designs proprietary while obtaining the official certification badge, manufacturers must acquire a Commercial Exemption and B2B Trademark License."* | Legal Doctrine & `README.md`: *Copyright governs design schematics; trademark governs brand marks. A clean-room vendor owes no copyright royalty but may seek official certification.* | Legacy policy treats copyright exemption and trademark certification as an indivisible bundle, locking out clean-room vendors from certification. | **MEDIUM** | Formally decouple copyright (Route A/B) from trademark (Level 1..4) in `ZC-CORE-V4-TRADEMARK-AND-CONFORMANCE-RFC.md`. |
| **NC-06** | **Phantom Software License** | `LICENSE` Section 1.B (Lines 24-28): *"CONTROLLER SOFTWARE, FIRMWARE & SCRIPTS (SPDX: AGPL-3.0-or-later)"* | `scripts/verify_gate_b_rev28d.ps1` Header (Line 2): `SPDX-License-Identifier: CERN-OHL-S-2.0` | Root license claims repository scripts and firmware use AGPL-3.0, but the only script in the repo is labeled CERN-OHL-S-2.0. | **MEDIUM** | Re-label hardware repository as pure `CERN-OHL-S-2.0` in v4; reserve AGPL for separate companion software repositories if ever published. |
| **NC-07** | **Watchdog Evidence Level** | Legacy Documentation Claims: *"1024-cycle watchdog timeout proven in Gate C formal verification."* | Evidence Reality (`evidence/gate-c/MODELING_LIMITS.md`): *1024-cycle rollover exceeds bounded model checking horizon (k=25); proven via simulation bench `tb/tb_zc_obi.sv`.* | Documentation over-claimed formal proof status for large monotonic counter behavior. | **RESOLVED (GATE C)** | Fixed in commit `fb8e124` (HAR-06): Watchdog is correctly documented as verified by simulation and behavioral model. |
| **NC-08** | **Release Freeze Stricture vs. RFCs** | `zero-cloud-core-versioning-and-governance.md` Section 5 (Lines 29-37): *"Normative Freeze: Once a release is frozen and tagged, normative files SHALL NOT change without a new release identifier."* | Development Practice in `gate-c/formal-scope-audit`: *RFC proposals being prepared while maintaining v3.3.0-rc2 root files intact.* | Risk that draft RFCs are mistaken for live normative alterations to the frozen baseline. | **LOW** | Maintained strict separation: RFCs live in `docs/rfc/` and `evidence/`, leaving root files frozen until v4.0.0 ratification. |

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
*End of V4_NORMATIVE_CONFLICT_MATRIX.md — Prepared for FreeCuli Architecture & Governance Review.*
