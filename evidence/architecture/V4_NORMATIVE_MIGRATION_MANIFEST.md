# FREECULI ZC-CORE — Normative Migration Manifest for v4.0.0 Architecture
## Comprehensive File-by-File Inventory, Disposition Decisions, Proposed Normative Diff Specifications & Phased Migration Sequencing

**Manifest Document ID:** ZC-CORE-MANIFEST-V4-MIGRATION-01
**Date:** 20 October 2026
**Status:** `DRAFT / PROPOSED MIGRATION MANIFEST / NOT AUTHORIZED FOR MERGE`
**Target Milestone:** Preparation for ZC-CORE v4.0.0 Migration (Post-RFC Consensus)
**Reference Technical Baseline:** Commit [`eb3ed5a`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/eb3ed5ad9fddb551506d43d2692bd040843af06f) (Run #45)
**Governance Level:** Normative Transition Planning

---

> [!NOTE]
> **Tarihsel Geçiş Planı Açıklaması:**
> Bu belge, v4.0.0 geçişinden önce hazırlanmış planlama kaydıdır. İçindeki eski "DO NOT MERGE / RELEASE BLOCKED" ifadeleri, kendi tarihsel karar bağlamını açıklar; güncel Git etiketi, yayın yetkilendirmesi veya Gate D tamamlanma durumu hakkında tek başına hüküm oluşturmaz. v4.0.0-rc2 aday sürümü, normatif standardın nihai ratifikasyonu anlamına gelmez.

> [!CAUTION]
> **GOVERNANCE DIRECTIVE — ZERO UNAUTHORIZED EDITS TO NORMATIVE DOCUMENTS:**
> This manifest is a **planning specification and audit inventory ONLY**.
> **NO ROOT NORMATIVE DOCUMENTS (`zero-cloud-*.md`, `README.md`, `ZERO-CLOUD-RELEASE-MANIFEST.md`) MAY BE MODIFIED AT THIS STAGE.**
> Any modification to existing normative documents requires prior independent auditor sign-off and formal standards committee ratification of `RFC-ZC-CORE-0004-DRAFT`.
> Current status remains: **`DO NOT MERGE / RELEASE BLOCKED`**.

---

## 1. Executive Summary & Inventory Disposition Strategy

To prepare for the transition from **ZC-CORE v3.3.0-rc2** to **ZC-CORE v4.0.0** without retroactively breaking published prior art or invalidating the qualified Gate C formal verification baseline, this manifest establishes an exhaustive, file-by-file disposition strategy for all 18 root Markdown documents and 9 architectural/evidence documents in the repository.

### 1.1 Disposition Categories
Every document in the repository is assigned one of three immutable disposition decisions:
- **`PRESERVE (IMMUTABLE)`:** The file remains untouched to preserve historical integrity, prior Zenodo publication hashes, or immutable audit records.
- **`UPDATE (PHASED)`:** The file will be updated in a controlled, phased atomic sequence once the v4.0.0 RFC is formally ratified.
- **`SUPERSEDE (ARCHIVE)`:** The file represents a legacy or redundant draft that will be deprecated and replaced by a modular v4.0.0 specification.

---

## 2. Exhaustive Document Inventory & Migration Specifications

Below is the exhaustive, file-by-file specification covering every Markdown document in the repository:

### 2.1 Core Methodology & Invariants

#### 1. `zero-cloud-core-methodology-invariants.md` (and alias `ZC-CORE-METHODOLOGY-INVARIANTS.md`)
* **Current Version & Purpose:** v3.3.0-rc2; defines the immutable core identity (Invariants M1–M10) of the ZC-CORE methodology.
* **Disposition:** **`PRESERVE (IMMUTABLE)` for v3.x branch / `UPDATE (PHASED)` for v4.x migration branch**.
* **Required STRICT/HYBRID References:** Add formal definition of Profile Stratification (M3-S vs. M3-H).
* **Exact Proposed Normative Change:**
  - Replace legacy M3 text with `M3-RFC-REVISED` clauses (establishing non-egress of Classes 0 & 1, unidirectional semantic release of Classes 2 & 3, hardware-gated inbound OTA, and profile-stratified physical enforcement).
  - Update Composition Rule to include hardware-gated bus coordination.
  - Bump document badge from `v3.3.0-rc2` to `v4.0.0-rc1`.
* **Potential M1–M10 Conflict:** Resolves the historical M1 vs. M3 textual contradiction (HAR-09).
* **Impact on Existing Claims:** Preserves 100% compliance for legacy STRICT devices; establishes formal legal basis for HYBRID devices.
* **Evidence References:** Gate C SVA proofs (`F-SPI-01..04`, `F-OBI-01..07`, `F-OTP-01..06`); `RFC-ZC-CORE-0004-DRAFT`.
* **Migration Phase:** **Phase 1 (Foundational Identity)**.

#### 2. `zero-cloud-core-scope-boundary.md`
* **Current Version & Purpose:** v3.3.0-rc2; defines what is in-scope vs. out-of-scope for ZC-CORE compliance.
* **Disposition:** **`UPDATE (PHASED)`**.
* **Required STRICT/HYBRID References:** Section 1.20 and Section 2 scope boundaries.
* **Exact Proposed Normative Change:**
  - Add "Section 1.21: Scope of HYBRID Profile Telemetry and Inbound OTA Updates".
  - Insert the 5-class Data Classification Table (Classes 0 to 4).
  - Explicitly define unverified scope boundaries (SoC crossbar DMA isolation and analog covert-channel bounds remain Gate D deliverables).
* **Potential M1–M10 Conflict:** None; provides detailed boundaries enforcing M1, M2, and M3.
* **Impact on Existing Claims:** Clarifies that raw video/audio streaming (Class 4) remains an immediate, non-negotiable disqualification.
* **Evidence References:** `docs/architecture/zc-core-security-profiles.md`; `RFC-ZC-CORE-0004-DRAFT`.
* **Migration Phase:** **Phase 1 (Foundational Identity)**.

---

### 2.2 Threat Taxonomy & Hardware Architecture

#### 3. `zero-cloud-core-attack-taxonomy.md`
* **Current Version & Purpose:** v3.3.0-rc2; catalogs threat vectors AT-001 through AT-010.
* **Disposition:** **`UPDATE (PHASED)`**.
* **Required STRICT/HYBRID References:** New attack vectors arising from bidirectional bus coordination and in-field flash updates.
* **Exact Proposed Normative Change:**
  - Add `AT-011: Telemetry Steganographic Covert Channel (Statistical Modulation & Timing Packing)`. Mitigated by epoch-quantised rate limiting and fixed binary schemas.
  - Add `AT-012: Inbound Update Flash Desynchronization & DoS (SPI Frame Truncation & Wear-Out)`. Mitigated by `zc_spi_flash_firewall.sv` rising /CS validation and status reconciliation.
* **Potential M1–M10 Conflict:** Directly reinforces M4 and M5 control-plane isolation.
* **Impact on Existing Claims:** Expands defense scope to modern connected Edge-AI threat vectors.
* **Evidence References:** SVA assertions in `fv/zc_spi_sva.sv` and `fv/zc_obi_sva.sv`.
* **Migration Phase:** **Phase 2 (Threat & Architecture)**.

#### 4. `zero-cloud-hardware-reference-architecture.md`
* **Current Version & Purpose:** v3.3.0-rc2; specifies reference schematics, domain separation, and data diode circuitry.
* **Disposition:** **`UPDATE (PHASED)`**.
* **Required STRICT/HYBRID References:** Section 2 and Section 3 architecture topologies.
* **Exact Proposed Normative Change:**
  - Add Section 2.10: "Hardware Interconnect Architecture for HYBRID Operational Profile".
  - Add Mermaid block diagram illustrating the dual-domain interconnect topology mediated by `zc_spi_flash_firewall`, `zc_obi_subordinate_bridge`, and `zc_aon_post_auth_ctrl`.
  - Include signal connection rules and external Boot ROM cryptographic verification trust assumptions.
* **Potential M1–M10 Conflict:** Confirms physical hardware enforcement (M2).
* **Impact on Existing Claims:** Provides verifiable reference design for hybrid systems.
* **Evidence References:** `rtl/zc_spi_flash_firewall.sv`, `rtl/zc_obi_subordinate_bridge.sv`, `rtl/zc_aon_post_auth_ctrl.sv`.
* **Migration Phase:** **Phase 2 (Threat & Architecture)**.

#### 5. `zero-cloud-core-implementation-coverage.md`
* **Current Version & Purpose:** v3.3.0-rc2; maps implementation classes (Optical, FPGA, ASIC) to methodology invariants.
* **Disposition:** **`UPDATE (PHASED)`**.
* **Required STRICT/HYBRID References:** Implementation Class Matrix.
* **Exact Proposed Normative Change:**
  - Add new Implementation Class: `Class D-H (Digital RTL Hardware-Gated Bus Interconnect)`.
  - Map OBI bridge, SPI firewall, and AON controller to M2, M3, M4, M5, and M6.
* **Potential M1–M10 Conflict:** None.
* **Impact on Existing Claims:** Extends implementation coverage from discrete optocouplers to integrated SoC IP.
* **Evidence References:** Gate C SVA proofs.
* **Migration Phase:** **Phase 2 (Threat & Architecture)**.

---

### 2.3 Testing, Evidence & Forensic Protocols

#### 6. `zero-cloud-core-conformance-test-specification.md` (and alias `FC-ZC-Conformance-Test-Specification.md`)
* **Current Version & Purpose:** v3.3.0-rc2; specifies laboratory conformance test procedures FC-ZC-001 through FC-ZC-016.
* **Disposition:** **`UPDATE (PHASED)`**.
* **Required STRICT/HYBRID References:** Profile-specific test procedures.
* **Exact Proposed Normative Change:**
  - Restructure test suite into modular suites (`CTS-Core`, `CTS-Strict`, `CTS-Hybrid`).
  - Add `FC-ZC-017: STRICT Profile Zero-Outbound Leakage Anechoic RF Audit`.
  - Add `FC-ZC-018: HYBRID Profile Hardware Bus Firewall & Error Trap Test`.
  - Add `FC-ZC-019: Telemetry Allowlist Schema Clamping & Epoch Rate-Limit Verification`.
  - Add `FC-ZC-020: Covert-Channel Mutual Information Leakage Test (Gate D Lab Protocol)`.
* **Potential M1–M10 Conflict:** Enforces objective conformance evidence (M10).
* **Impact on Existing Claims:** Provides reproducible pass/fail criteria for both profiles.
* **Evidence References:** `scripts/verify_gate_b_rev28d.ps1`; `tb/tb_zc_obi.sv`.
* **Migration Phase:** **Phase 3 (Testing & Evidence)**.

#### 7. `zero-cloud-core-conformance-evidence-matrix.md`
* **Current Version & Purpose:** v3.3.0-rc2; matrices physical laboratory test claims.
* **Disposition:** **`UPDATE (PHASED)`**.
* **Required STRICT/HYBRID References:** Gate C formal verification integration.
* **Exact Proposed Normative Change:**
  - Establish explicit traceability link to `evidence/gate-c/CONSOLIDATED_NORMATIVE_EVIDENCE_MATRIX.md`.
  - Integrate 33 normative security claims, clearly distinguishing `PROVEN` formal properties, `SIMULATED` testbench behaviors, and `UNVERIFIED` Gate D deliverables.
* **Potential M1–M10 Conflict:** Eliminates scope inflation; maintains M10 CONDITIONAL status.
* **Impact on Existing Claims:** Prevents claiming digital RTL proofs as physical silicon verification.
* **Evidence References:** Commit `eb3ed5a` (Run #45).
* **Migration Phase:** **Phase 3 (Testing & Evidence)**.

#### 8. `ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md` & `ZC-CORE-HARDWARE-FORENSIC-AUDIT-PROTOCOL.md`
* **Current Version & Purpose:** Forensic physical audit protocols and laboratory checklists.
* **Disposition:** **`UPDATE (PHASED)`**.
* **Required STRICT/HYBRID References:** Add inspection steps for shared SPI Flash and OBI bus routing.
* **Exact Proposed Normative Change:**
  - Add X-ray inspection protocol for secondary SoC bus traces.
  - Add verification checklist for antifuse AON power domain physical routing.
* **Potential M1–M10 Conflict:** None.
* **Impact on Existing Claims:** Ensures forensic inspectors can audit hybrid PCB layouts.
* **Evidence References:** Hardware schematics; Gate D laboratory guidelines.
* **Migration Phase:** **Phase 3 (Testing & Evidence)**.

---

### 2.4 Defensive Publication, IP & Governance

#### 9. `zero-cloud-core-defensive-publication.md` (and alias `Zero-Cloud-Defensive-Publication.md`)
* **Current Version & Purpose:** v3.3.0-rc2; defensive patent disclosure covering Claim Families ZC-CORE-001 through ZC-CORE-007.
* **Disposition:** **`UPDATE (PHASED)`**.
* **Required STRICT/HYBRID References:** New Claim Family `ZC-CORE-008`.
* **Exact Proposed Normative Change:**
  - Add **`Claim Family ZC-CORE-008: Hardware-Enforced Bus Isolation & Secure Inbound Update Firewall`**.
  - Formulate claims in standard patent format covering 3-layer SPI firewalling, OBI subordinate decoupling with orphan draining, and AON OTP 4-phase DAI handshakes.
  - Insert mandatory Patent-Counsel Review checkpoint notice (HAR-12).
* **Potential M1–M10 Conflict:** Preempts third-party patent attempts on hybrid zero-cloud hardware.
* **Impact on Existing Claims:** Preserves priority of ZC-CORE-001..007; expands prior-art defense.
* **Evidence References:** `evidence/architecture/V4_DEFENSIVE_PUBLICATION_DISCLOSURE_PLAN.md`.
* **Migration Phase:** **Phase 4 (IP & Release)**.

#### 10. `zero-cloud-core-versioning-and-governance.md`
* **Current Version & Purpose:** Governance lifecycle and SemVer strictures.
* **Disposition:** **`UPDATE (PHASED)`**.
* **Required STRICT/HYBRID References:** Major-version evolution criteria.
* **Exact Proposed Normative Change:**
  - Document the justification for ZC-CORE v4.0.0 (Profile Bifurcation and M3 restatement).
  - Define the deprecation and transition timeline from v3.x to v4.x.
* **Potential M1–M10 Conflict:** None.
* **Impact on Existing Claims:** Formally ratifies the major-version governance process.
* **Evidence References:** `RFC-ZC-CORE-0004-DRAFT`.
* **Migration Phase:** **Phase 4 (IP & Release)**.

#### 11. `README.md`
* **Current Version & Purpose:** Project front-page overview.
* **Disposition:** **`UPDATE (PHASED)`**.
* **Required STRICT/HYBRID References:** Section 1 overview.
* **Exact Proposed Normative Change:**
  - Introduce Section 1.1: "Security Profiles: STRICT vs. HYBRID".
  - Link to `docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md`.
  - Clarify current release status: Gate C is `PARTIAL / QUALIFIED`, Gate D is `UNVERIFIED`.
* **Potential M1–M10 Conflict:** Informative only.
* **Impact on Existing Claims:** Provides immediate technical clarity to new contributors and auditors.
* **Evidence References:** Project repository links.
* **Migration Phase:** **Phase 1 (Foundational Identity)**.

#### 12. `ZERO-CLOUD-RELEASE-MANIFEST.md`
* **Current Version & Purpose:** Release authorization manifest.
* **Disposition:** **`UPDATE (PHASED)`**.
* **Required STRICT/HYBRID References:** Release gating checklist.
* **Exact Proposed Normative Change:**
  - Retain `RELEASE BLOCKED / DO NOT MERGE` until Gate D laboratory evidence is submitted.
  - Add v4.0.0-rc1 pre-flight validation gates.
* **Potential M1–M10 Conflict:** None.
* **Impact on Existing Claims:** Prevents premature commercial release.
* **Evidence References:** Gate C closure reports.
* **Migration Phase:** **Phase 4 (IP & Release)**.

---

### 2.5 Supporting, Licensing & Architecture Documents

#### 13. `LICENSE` & `zero-cloud-dual-licensing.md` (and alias `DUAL-LICENSING.md`)
* **Current Version & Purpose:** v3.3.0-rc2 baseline; dual-licensing terms, open-source obligations, and commercial exemption clauses.
* **Disposition:** **`PRESERVE HISTORICAL BASELINE (v3.3.0-rc2) / PROPOSE V4 SUCCESSOR`**.
* **Rationale:** As identified in `evidence/legal/V4_LEGACY_LICENSING_BASELINE_AUDIT.md` (Findings L-01, L-02, L-03), legacy text contains legal overreaches regarding abstract methodology scope and entity discrimination. To preserve historical audit integrity and Zenodo DOI provenance, the root v3.3.0-rc2 files remain untouched in this branch. The normative successor is proposed via `docs/rfc/ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md`.
* **Exact Proposed Normative Change in v4 Successor:**
  - Scope CERN-OHL-S v2.0 reciprocity strictly to FreeCuli-authored covered RTL and schematics.
  - Reaffirm absolute freedom for independent clean-room implementations (zero royalties, zero copyleft).
  - Eliminate commercial entity discrimination in Route A (OSD #5/#6 compliance).
  - Clarify that Route B commercial exemptions apply strictly to FreeCuli-owned assets.
* **Evidence References:** `evidence/legal/V4_LEGACY_LICENSING_BASELINE_AUDIT.md`; `evidence/legal/V4_LICENSE_SCOPE_AND_RIGHTS_MATRIX.md`; `docs/rfc/ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md`.
* **Migration Phase:** **Phase 5 (Legal & Licensing Successor Integration)**.

#### 14. `zero-cloud-core-brand-and-trademark-policy.md`
* **Current Version & Purpose:** v3.3.0-rc2 baseline; trademark usage and 4-tier conformance levels.
* **Disposition:** **`PRESERVE HISTORICAL BASELINE (v3.3.0-rc2) / PROPOSE V4 SUCCESSOR`**.
* **Rationale:** Legacy text commingled trademark licensing with copyright exemptions (Finding L-04). Root document is preserved as historical baseline; successor is proposed via `docs/rfc/ZC-CORE-V4-TRADEMARK-AND-CONFORMANCE-RFC.md`.
* **Exact Proposed Normative Change in v4 Successor:**
  - Formally decouple trademark licensing from hardware copyright paths (Route A vs Route B vs Clean-Room).
  - Clarify FreeCuli's legal status as Scheme Owner, relying on ISO/IEC 17025 accredited third-party test reports.
  - Retain 4-level conformance hierarchy and C1–C3 assurance profiles.
* **Evidence References:** `docs/rfc/ZC-CORE-V4-TRADEMARK-AND-CONFORMANCE-RFC.md`.
* **Migration Phase:** **Phase 5 (Legal & Licensing Successor Integration)**.

#### 15. `CONTRIBUTING.md`, `SECURITY.md`, `CITATION.cff`
* **Current Version & Purpose:** Contributor guidelines, security reporting, citation metadata.
* **Disposition:** **`PRESERVE (IMMUTABLE)` for v3.x / `UPDATE (PHASED)` for v4.x migration**.
* **Rationale:** Retain governance stability; harmonize `CITATION.cff` license tags with single canonical hardware license in v4.
* **Migration Phase:** **Phase 5 (Legal & Licensing Successor Integration)**.

#### 16. `Zero-Cloud-Smart-Home-Edge-AI-Architecture.md`
* **Current Version & Purpose:** Informational application note.
* **Disposition:** **`SUPERSEDE (ARCHIVE)`**.
* **Rationale:** Deprecated early draft; content fully superseded by `docs/architecture/zc-core-security-profiles.md` and `RFC-ZC-CORE-0004-DRAFT`.
* **Migration Phase:** **Phase 4 (Cleanup)**.

---

## 3. Phased Migration Execution Plan (5 Causal Phases)

To ensure zero downtime, unbroken Git history, and complete auditability, the normative update will proceed in five strictly sequential, causal phases **ONLY AFTER** formal auditor and standards committee authorization:

```
+---------------------------------------------------------------------------------------------------------+
|                                    PHASED NORMATIVE MIGRATION SEQUENCE                                  |
+---------------------------------------------------------------------------------------------------------+
|                                                                                                         |
|   [ PHASE 1: FOUNDATIONAL IDENTITY & SCOPE ]                                                            |
|     1. zero-cloud-core-methodology-invariants.md (M3-RFC-REVISED integration)                           |
|     2. zero-cloud-core-scope-boundary.md (Class 0..4 data classification)                               |
|     3. README.md (STRICT / HYBRID introductory section)                                                 |
|                                                                                                         |
|   [ PHASE 2: THREAT MODELING & REFERENCE ARCHITECTURE ]                                                 |
|     4. zero-cloud-hardware-reference-architecture.md (HYBRID bus interconnect topology)                |
|     5. zero-cloud-core-attack-taxonomy.md (AT-011 and AT-012 threat classes)                            |
|     6. zero-cloud-core-implementation-coverage.md (Class D-H implementation mapping)                    |
|                                                                                                         |
|   [ PHASE 3: CONFORMANCE TESTING & FORENSIC EVIDENCE ]                                                  |
|     7. zero-cloud-core-conformance-test-specification.md (Modular CTS-v4 suite: FC-ZC-017..020)          |
|     8. zero-cloud-core-conformance-evidence-matrix.md (Gate C formal trace mapping)                     |
|     9. ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md & ZC-CORE-HARDWARE-FORENSIC-AUDIT-PROTOCOL.md             |
|                                                                                                         |
|   [ PHASE 4: DEFENSIVE PUBLICATION, GOVERNANCE & RELEASE ]                                              |
|     10. zero-cloud-core-defensive-publication.md (ZC-CORE-008 claim family)                             |
|     11. zero-cloud-core-versioning-and-governance.md (v4.0.0 SemVer justification)                      |
|     12. ZERO-CLOUD-RELEASE-MANIFEST.md (v4.0.0-rc1 pre-flight sign-off)                                 |
|                                                                                                         |
|   [ PHASE 5: LEGAL, LICENSING & TRADEMARK INTEGRATION ]                                                 |
|     13. LICENSE (SPDX harmonization to CERN-OHL-S-2.0 & clean-room freedom guarantee)                    |
|     14. zero-cloud-dual-licensing.md (Route A vs Route B non-discriminatory policy)                     |
|     15. zero-cloud-core-brand-and-trademark-policy.md (Decoupled trademark licensing & 4-level model)     |
|     16. CITATION.cff (Harmonized license metadata)                                                      |
|                                                                                                         |
+---------------------------------------------------------------------------------------------------------+
```

---

## 4. Governance Directives & Freeze Notice

1. **Strict Freeze Maintained:** No commit modifying any file in Section 2 is permitted on branch `gate-c/formal-scope-audit` or `main` until this manifest is reviewed and formally accepted by the independent auditor.
2. **Atomic Execution:** When authorized, Phase 1 through Phase 4 will be executed as structured, atomic commits referencing this manifest document.
3. **Traceability:** Every proposed change maps directly to verified RTL blocks in `eb3ed5a` or declared Gate D deliverables.
