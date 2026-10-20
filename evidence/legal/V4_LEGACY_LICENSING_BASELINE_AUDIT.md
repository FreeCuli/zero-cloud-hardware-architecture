# FREECULI ZC-CORE — v4.0.0 Legacy Licensing Baseline Audit

**Project:** FreeCuli ZC-CORE Hardware Architecture & Methodology  
**Target:** v4.0.0 Normative Migration & RFC Transition  
**Document Classification:** Legal & Governance Audit Baseline  
**File Location:** `evidence/legal/V4_LEGACY_LICENSING_BASELINE_AUDIT.md`  
**Baseline Commit:** `96425c69376f27373c7b3819d28fc222f42f00cc`  
**Branch:** `gate-c/formal-scope-audit`  

**Governance Status:** `DRAFT / INFORMATIONAL AUDIT / NOT NORMATIVE / NOT RATIFIED`  
**Gate Status:** `Gate C: PARTIAL / QUALIFIED` | `Gate D: UNVERIFIED`  
**Release Constraint:** `DO NOT MERGE / RELEASE BLOCKED`  
**Legal Disclaimer:** This audit is an engineering and architectural analysis prepared to support formal legal review. It does NOT constitute formal legal advice. A qualified intellectual property attorney must review and approve all legal RFCs and license instruments prior to v4.0.0 ratification.

---

## 1. Executive Summary

This document performs an exhaustive audit of all legacy licensing, IP, trademark, and defensive publication assertions in the FreeCuli ZC-CORE repository (v3.3.0-rc2 baseline). The objective is to identify all legal ambiguities, overreaches, internal contradictions, and misalignments with the **Confirmed Corporate Strategy** established by FreeCuli's Founder, and to define exact remediations for the upcoming v4.0.0 RFC governance package.

### Confirmed Strategic Foundation
1. **Route A (Strongly Reciprocal Open Hardware):** FreeCuli-authored reference hardware designs, schematics, and production RTL are released under `CERN-OHL-S v2.0`. Licensees distributing covered hardware or derivative works must provide Corresponding Source under the same license.
2. **Route B (Commercial B2B Exemption):** Organizations requiring proprietary exemptions from CERN-OHL-S reciprocity may negotiate a paid commercial license with FreeCuli—*strictly where FreeCuli has the legal authority and copyright ownership to grant such rights*. Route B is an alternative pathway, NOT a compulsory levy on independent implementations.
3. **Open Standards & Clean-Room Freedom:** The ZC-CORE abstract methodology, RFC specifications, and architectural invariants (M1–M10) constitute an open specification and public technical prior art. Any third party may independently design, implement, and manufacture clean-room hardware compliant with the standard without licensing FreeCuli's covered RTL or paying commercial fees.
4. **Defensive Publication (Prior Art):** Timestamped disclosures via GitHub and Zenodo establish publicly available prior art under 35 U.S.C. § 102 and EPC Art. 54. FreeCuli does not hold active patent filings and does not assert patent monopolies or TÜBİTAK patent obligations.
5. **Decoupled Trademark & Certification:** Trademark usage ("FreeCuli Certified™") is strictly separate from open-source copyright permissions and is governed by an objective 4-level conformance model.

---

## 2. Critical Findings Summary

| ID | Category | Summary of Legacy Issue | Severity | Proposed v4 Remediation |
| :--- | :--- | :--- | :--- | :--- |
| **L-01** | **Scope Overreach** | Root `LICENSE` (lines 39–41) and `zero-cloud-dual-licensing.md` assert that *any* manufacturer building a compliant appliance without open-sourcing *must* execute a Commercial Exemption. This improperly extends copyleft to independent implementations of an abstract methodology. | **HIGH** | In `ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md`, explicitly restrict copyleft and commercial exemptions to FreeCuli-copyrighted RTL/designs. Independent clean-room implementations are free of CERN-OHL-S obligations. |
| **L-02** | **OSD Discrimination** | `zero-cloud-dual-licensing.md` (lines 14–22) restricts the Open Source Path to "academic institutions, independent developers, or open-source startups", while forcing commercial companies to buy commercial licenses. This violates Open Source Definition (OSD #5 & #6) and CERN-OHL-S v2.0 §3.1. | **HIGH** | Remove entity-type discrimination. Any commercial enterprise MAY utilize Route A freely, provided they strictly comply with CERN-OHL-S v2.0 reciprocal source-sharing obligations. |
| **L-03** | **Phantom License** | Root `LICENSE` asserts composite SPDX identifier `(CERN-OHL-S-2.0 AND AGPL-3.0-or-later)` for firmware/scripts. In reality, zero AGPL files exist in the repository; all RTL, formal harnesses, and scripts use CERN-OHL-S-2.0. | **MEDIUM** | Harmonize SPDX headers. Clarify in v4 RFC that AGPL applies only to standalone companion software repositories if released, while the hardware repository is governed cleanly by CERN-OHL-S-2.0. |
| **L-04** | **IP Commingling** | `zero-cloud-core-brand-and-trademark-policy.md` (§4) conflates copyright copyleft exemption with trademark licensing ("FreeCuli Certified"). | **MEDIUM** | Decouple copyright from trademark in `ZC-CORE-V4-TRADEMARK-AND-CONFORMANCE-RFC.md`. A commercial license may bundle both, but their legal grounds are distinct. |
| **L-05** | **Patent Overstatement** | Defensive publication and patent retaliation texts imply automatic worldwide legal protection or patent immunity, which is legally unfounded without active patents. | **HIGH** | Frame defensive publication strictly as defensive prior art (35 U.S.C. § 102 / EPC Art. 54). Scope patent retaliation strictly to FreeCuli's copyright licenses. |
| **L-06** | **Duplicate Files** | Five pairs of duplicate/divergent root files exist (`DUAL-LICENSING.md`, `Zero-Cloud-Defensive-Publication.md`, etc.), causing cross-reference drift and audit confusion. | **LOW** | Preserve v3.3.0-rc2 files as historical baseline; consolidate canonical references in v4 migration manifest. |

---

## 3. Exhaustive File-by-File Audit Table

The table below audits all root governance, legal, architectural, and specification files in the repository.

| # | File & Section | Current Legacy Text / Assertion | Legal & Technical Implication | Alignment | Ambiguity / Contradiction | Sev | Proposed v4 Remediation | Counsel Review |
| :- | :--- | :--- | :--- | :-: | :--- | :-: | :--- | :-: |
| 1 | `LICENSE` §1 (Line 1) | `SPDX-License-Identifier: (CERN-OHL-S-2.0 AND AGPL-3.0-or-later)` | Claims composite license for the entire repository. | Partially Aligned | No AGPL code is present in the repository (`scripts/` and `rtl/` use CERN-OHL-S). Creates audit confusion for automated compliance scanners. | Med | Set repository root SPDX to `CERN-OHL-S-2.0` for hardware/RTL, and reference dedicated software license if software is added. | Mandatory |
| 2 | `LICENSE` §1.C (Lines 29–35) | `Normative Methodology... Conformance != Code Ownership: Implementing the standard grants FreeCuli NO intellectual property rights...` | Correctly protects implementers' IP over proprietary designs. | **Aligned** | Sound principle, but contradicts §2 immediately below it. | Low | Retain invariant in v4 Dual-Licensing RFC and reinforce that methodology conformance is unencumbered. | Recommended |
| 3 | `LICENSE` §2 (Lines 39–41) | `Manufacturers seeking to build compliant Zero-Cloud appliances without releasing proprietary trade secrets... MUST execute a Commercial Exemption Agreement` | Implies abstract standard compliance requires a commercial license if proprietary. | **Misaligned** | Copyright law does not allow copylefting an abstract methodology; only the expression (specific RTL/schematics) is protected. Contradicts §1.C. | **High** | Clarify that Commercial Exemption applies *only* when using FreeCuli-authored covered RTL/schematics, not independent clean-room implementations. | Mandatory |
| 4 | `zero-cloud-dual-licensing.md` §1 (Lines 14–18) | `The Open Source Path (Free): If you are an academic institution, an independent developer, or an open-source hardware startup...` | Discriminates based on field of endeavor and entity type. | **Misaligned** | Violates Open Source Definition (OSD #5, #6) and CERN-OHL-S v2.0 §3.1 (everyone has right to use if complying with reciprocity). | **High** | Reframe Route A as universally available to any entity (commercial or non-commercial) willing to comply with reciprocal source disclosure. | Mandatory |
| 5 | `zero-cloud-dual-licensing.md` §2 (Lines 19–23) | `If you are a commercial AIoT manufacturer (e.g., Bosch, Samsung, Aselsan, Siemens)... You MUST obtain a Commercial Exemption License` | Mandatory licensing demand on named commercial corporations. | **Misaligned** | Legally unenforceable against independent implementations; suggests mandatory tax rather than voluntary license for covered source. | **High** | State that commercial enterprises utilizing FreeCuli reference source may *elect* Route B to avoid reciprocity, or use Route A under reciprocity. | Mandatory |
| 6 | `zero-cloud-dual-licensing.md` §3 (Lines 29–35) | `Patent Retaliation Clause: ...right to use the CERN-OHL-S v2.0 / ZC-CORE license is subject to worldwide revocation` | Threatens total license revocation upon patent assertion against standard. | Partially Aligned | CERN-OHL-S v2.0 contains its own patent retaliation clause (§4.4); FreeCuli cannot unilaterally modify terms of third-party upstream licenses. | Med | Align retaliation clause with standard CERN-OHL-S v2.0 §4.4 and clarify it applies to FreeCuli-owned patents/copyrights. | Mandatory |
| 7 | `zero-cloud-dual-licensing.md` §4 (Lines 36–38) | `Enforcement Notice: A device found implementing the ZC-CORE physical isolation hardware locks... without a commercial license AND without open-sourcing its schematics may be subject to strict enforcement...` | Claims physical isolation principles belong exclusively to FreeCuli. | **Misaligned** | Physical air-gaps and data diodes are known prior art; only specific proprietary implementations are protectable. | **High** | Scope enforcement strictly to unauthorized distribution of FreeCuli-authored covered files without source disclosure. | Mandatory |
| 8 | `DUAL-LICENSING.md` (Lines 1–4) | `[OBSOLETED / SUPERSEDED] This document link has been updated... [zero-cloud-dual-licensing.md]` | Obsoleted pointer stub. | Partially Aligned | Harmless redirect, but clutters repository root. | Low | Maintain as historical baseline; formalize canonical routing in v4 Migration Manifest. | None |
| 9 | `zero-cloud-core-brand-and-trademark-policy.md` §Target Profiles (Lines 13–20) | Normative assurance profiles: C1 (Consumer), C2 (Industrial), C3 (Defense/Aerospace). | Establishes domain-specific assurance tiers. | **Aligned** | Sound architectural profile segmentation. | Low | Preserve C1–C3 profiles in v4 Trademark and Conformance RFC. | Recommended |
| 10 | `zero-cloud-core-brand-and-trademark-policy.md` §Claim Levels (Lines 22–42) | 4 Conformance Levels: Self-Declared, CTS Tested, Independently Verified, FreeCuli Certified™. | Establishes 4-tier governance hierarchy. | **Aligned** | Excellent governance separation. Explicitly states FreeCuli is not ISO 17065 CB. | Low | Retain and elevate into `ZC-CORE-V4-TRADEMARK-AND-CONFORMANCE-RFC.md`. | Recommended |
| 11 | `zero-cloud-core-brand-and-trademark-policy.md` §Commercial Exemption (Lines 43–45) | `To bypass these obligations and keep hardware designs proprietary while obtaining the official certification badge, manufacturers must acquire a Commercial Exemption and B2B Trademark License.` | Commingles copyright exemption with trademark license. | Partially Aligned | A manufacturer could build an independent design (no copyright exemption needed) yet still desire official certification badge (trademark license). | Med | Separate copyright exemption (Route B) from trademark certification license (Level 4 Badge). They may be co-packaged or separate. | Mandatory |
| 12 | `zero-cloud-core-defensive-publication.md` §1 (Lines 22–32) | `Defensive Publication / Prior-Art Establishment... establishes publicly accessible technical prior art for the disclosed combinations...` | Discloses claim-style prior art to prevent third-party patenting. | **Aligned** | Solid legal mechanism under 35 U.S.C. § 102 and EPC Art. 54. | Low | Affirm defensive nature; ensure no assertion of patent ownership is made. Harmonize with Zenodo DOI. | Recommended |
| 13 | `Zero-Cloud-Defensive-Publication.md` (Lines 1–4) | Duplicate / legacy pointer or alternate casing of defensive publication. | Redundant root file. | Partially Aligned | Divergence risk between the two files. | Low | Keep in v3 historical baseline; designate `zero-cloud-core-defensive-publication.md` as canonical prior-art source. | None |
| 14 | `zero-cloud-core-methodology-invariants.md` §2 (Lines 17–31) | Normative M1–M10 Invariants and Composition Rule. | Core technical DNA of ZC-CORE. | **Aligned** | Solid architectural foundation, though M3/M4/M7/M8 required Gate C qualification for SoC/RTL. | Med | Add formal qualification notes in v4 RFC reflecting Gate C formal boundaries (OBI watchdog, formal observation ports). | Recommended |
| 15 | `zero-cloud-core-methodology-invariants.md` §4 (Lines 44–50) | `Independent manufacturers may adopt the ZC-CORE methodology using their own proprietary hardware designs... utilizing FreeCuli's specific Reference Hardware schematics immediately binds... to CERN-OHL-S v2.0...` | Correctly distinguishes abstract methodology from reference hardware. | **Aligned** | This section is legally flawless. It directly contradicts the overreaching language in `LICENSE` and `zero-cloud-dual-licensing.md`. | Med | Adopt this exact phrasing as the normative foundation for `ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md`. | Recommended |
| 16 | `zero-cloud-core-methodology-invariants.md` §5 (Lines 51–57) | IPC/CPC Classifications for patent search discoverability (H04L 9/00, G06F 21/50, etc.). | Prior art discoverability metadata. | **Aligned** | Excellent tool for USPTO/EPO patent examiner searches. | Low | Retain in v4 architecture and defensive publication documents. | None |
| 17 | `ZC-CORE-METHODOLOGY-INVARIANTS.md` | Legacy upper-case naming of invariants document. | Redundant root file. | Partially Aligned | Historical artifact. | Low | Note in v4 Migration Manifest. | None |
| 18 | `zero-cloud-core-scope-boundary.md` §1–§3 | Defines in-scope (on-device privacy, data taxonomy) vs out-of-scope (cloud security, model bias, deep decapping). | Sets realistic security guarantees and prevents unbounded liability. | **Aligned** | Critical for limiting legal liability and false marketing claims. | Low | Retain intact in v4 specifications. | Recommended |
| 19 | `zero-cloud-core-versioning-and-governance.md` §1–§5 | SemVer governance, Normative Threshold Rule, Release Freeze process. | Establishes rigorous versioning control. | **Aligned** | Protects standard stability. | Low | Fully enforced during v4.0.0 RFC and migration activities. | None |
| 20 | `README.md` §Core Philosophy (Lines 15–24) | `Implementation Freedom & Methodological Consistency... Conformance != Code Ownership` | Reassures vendors of IP retention. | **Aligned** | Essential commercial reassurance. Must not be undermined by dual-licensing overreaches. | Low | Reinforce across all v4 RFCs. | None |
| 21 | `CONTRIBUTING.md` (Lines 1–20) | Contribution guidelines, distinction between normative and non-normative PRs, frozen release immutability. | Governance rules for contributors. | **Aligned** | Sound open-source contribution policy. | Low | Retain. Note that contributor assignment/CLA may be needed for Route B commercial sublicensing. | Recommended |
| 22 | `SECURITY.md` (Lines 1–12) | Vulnerability disclosure policy and supported versions. | Security reporting protocol. | **Aligned** | Standard security practice. | Low | Update supported version table to reflect v4.0.0 roadmap when ratified. | None |
| 23 | `CITATION.cff` (Lines 1–12) | CFF metadata referencing Zenodo DOI and `license: CERN-OHL-S-2.0 AND AGPL-3.0`. | Scholarly citation metadata. | Partially Aligned | Contains phantom AGPL-3.0 reference. | Low | Update in v4 release candidate to reflect single canonical hardware license. | None |
| 24 | `ZERO-CLOUD-RELEASE-MANIFEST.md` | Cryptographic SHA-256 seal for v3.3.0-rc2 normative files. | Integrity sealing instrument. | **Aligned** | Preserves historical immutable baseline. | Low | Keep completely untouched. New v4 manifest will cover v4 artifacts. | None |
| 25 | `zero-cloud-hardware-reference-architecture.md` | Primary architectural specification of physical data diodes and domains. | Technical reference architecture. | **Aligned** | Reference architecture; does not impose legal overreach. | Low | Retain. | None |
| 26 | `Zero-Cloud-Smart-Home-Edge-AI-Architecture.md` | Domain-specific application document for smart kitchen / smart home. | Informative application notes. | **Aligned** | Useful reference implementation. | Low | Retain as informative application guide. | None |
| 27 | `zero-cloud-core-conformance-test-specification.md` / `FC-ZC-Conformance-Test-Specification.md` | Physical lab test procedures (FC-ZC-001 through FC-ZC-010). | Normative physical laboratory testing rules. | **Aligned** | Technical test definitions; unencumbered by legal flaws. | Low | Retain. Update CTS tests in v4 if M-invariants undergo normative evolution. | None |
| 28 | `zero-cloud-core-conformance-evidence-matrix.md` / `ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md` | Maps M-invariants and attack vectors to physical evidence artifacts. | Normative conformance evidence package. | **Aligned** | Required for Level 3/4 conformance claims. | Low | Retain and maintain alignment with Gate C/D evidence matrices. | None |
| 29 | `ZC-CORE-HARDWARE-FORENSIC-AUDIT-PROTOCOL.md` | Procedures for forensic teardowns and hardware verification. | Independent lab audit manual. | **Aligned** | Crucial for Level 3 independent lab audits. | Low | Retain. | None |
| 30 | `zero-cloud-core-implementation-coverage.md` | Technology-neutral mapping (optical, ASIC, FPGA). | Informative implementation coverage. | **Aligned** | Demonstrates technology neutrality. | Low | Retain. | None |
| 31 | `zero-cloud-core-attack-taxonomy.md` | Threat vectors AT-001 through AT-010. | Normative security threat baseline. | **Aligned** | Crucial for security justifications and amendment reviews. | Low | Retain. | None |

---

## 4. In-Depth Legal Analysis of Critical Misalignments

### 4.1. Finding L-01: Scope Overreach on the Abstract Methodology

#### Legacy Text Analysis
- **`LICENSE` (Lines 39–41):**  
  > *"Manufacturers seeking to build compliant Zero-Cloud appliances without releasing proprietary trade secrets, firmware, or silicon designs MUST execute a Commercial Exemption Agreement with FreeCuli prior to commercial distribution."*
- **`zero-cloud-dual-licensing.md` (Lines 36–38):**  
  > *"A device found implementing the ZC-CORE physical isolation hardware locks (Data Diode/Cryptographic Zeroization) without a commercial license AND without open-sourcing its schematics may be subject to strict enforcement under applicable license obligations for violating the CERN-OHL-S v2.0 license obligations."*

#### Legal & Architectural Conflict
Under universal copyright and intellectual property jurisprudence (e.g., 17 U.S.C. § 102(b) in the United States; TRIPS Agreement Article 9.2; EU Software Directive 2009/24/EC Recital 11):
- **Copyright protects only the specific expression** of an idea (the concrete RTL source code, the specific PCB schematic files, the exact artwork and layouts).
- **Copyright DOES NOT protect ideas, concepts, principles, architectures, causal sequences, or functional methodologies.**
- A patent is the sole legal instrument that can grant exclusive rights over a functional method or architecture. Because FreeCuli holds no patents on the ZC-CORE methodology, FreeCuli cannot use copyright licenses (`CERN-OHL-S v2.0`) to restrict third parties from independently implementing the methodology from scratch (clean-room engineering).

#### Internal Contradiction in Legacy Repository
The legacy repository contains a direct contradiction between documents:
- `zero-cloud-core-methodology-invariants.md` §4 correctly states:  
  > *"Independent manufacturers may adopt the ZC-CORE methodology using their own proprietary hardware designs. However, utilizing FreeCuli's specific Reference Hardware schematics immediately binds the manufacturer to the Strongly Reciprocal open-source obligations..."*
- `README.md` §Philosophy correctly states:  
  > *"Conformance != Code Ownership: Passing the ZC-CORE Conformance Test Specification (CTS) does not grant FreeCuli any ownership over a manufacturer's implementation. A manufacturer retains full Intellectual Property (IP) rights over their proprietary codebase, custom ASIC/SoC designs, and firmware."*

The overreaching clauses in `LICENSE` and `zero-cloud-dual-licensing.md` directly contradict these sound statements.

#### Proposed v4 Remediation
In `ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md`, establish unambiguous boundaries:
1. **Clean-Room Implementations:** Third-party organizations that implement the ZC-CORE invariants (M1–M10) using their own independently authored RTL, schematics, and software owe NO royalty, NO commercial fee, and NO source-disclosure obligation to FreeCuli under copyright law.
2. **Covered Source Material:** Route B (Commercial Exemption) applies solely and exclusively to organizations that incorporate, modify, or distribute FreeCuli's *copyright-covered reference hardware source files* (RTL modules in `rtl/`, reference schematics, and layout designs) without releasing their own derivative works under `CERN-OHL-S v2.0`.

---

### 4.2. Finding L-02: Open Source Discrimination (OSD #5 & #6 Violation)

#### Legacy Text Analysis
- **`zero-cloud-dual-licensing.md` (Lines 14–23):**  
  > *"1. The Open Source Path (Free): If you are an academic institution, an independent developer, or an open-source hardware startup: You may implement the FreeCuli ZC-CORE hardware flow completely free of charge... 2. The Commercial Exemption Path (B2B License): If you are a commercial AIoT manufacturer (e.g., Bosch, Samsung, Aselsan, Siemens)... You MUST obtain a Commercial Exemption License..."*

#### Legal & Community Conflict
This phrasing directly violates the Open Source Definition (OSD) and the fundamental terms of `CERN-OHL-S v2.0`:
- **OSD Clause 5 (No Discrimination Against Persons or Groups):** The license must not discriminate against any person or group of persons.
- **OSD Clause 6 (No Discrimination Against Fields of Endeavor):** The license must not restrict anyone from making use of the program in a specific field of endeavor (e.g., commercial business).
- **CERN-OHL-S v2.0 §3.1:** Grants any licensee worldwide, royalty-free, non-exclusive rights to use, copy, modify, and distribute the Covered Work, subject only to the reciprocal source distribution obligations of §3.2–§3.4.

By asserting that commercial entities *cannot* use the open-source path and *must* pay for a commercial exemption, the legacy text invalidates its own claim to be an open-source project and creates severe legal exposure (e.g., false advertising, unenforceability of copyleft).

#### Proposed v4 Remediation
In `ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md`:
1. **Universal Route A Availability:** Any entity—including multinational corporations (e.g., Samsung, Bosch, Siemens)—has the absolute legal right to use FreeCuli's CERN-OHL-S v2.0 hardware designs completely free of licensing fees, provided they fully comply with CERN-OHL-S v2.0 reciprocal source code release obligations.
2. **Voluntary Route B Exemption:** Route B is an elective, paid contractual exemption designed for commercial entities that *prefer* to keep their modifications and derivative designs proprietary.

---

### 4.3. Finding L-03: The Ghost AGPL-3.0 License Reference

#### Legacy Text Analysis
- **`LICENSE` §1.B:** Asserts `SPDX: AGPL-3.0-or-later` governs "All reference firmware drivers, NPU lifecycle hooks, evaluation scripts, and CI validation tools provided by FreeCuli."
- **`CITATION.cff` (Line 12):** `license: "CERN-OHL-S-2.0 AND AGPL-3.0"`.

#### Verification Against Repository Reality
A complete audit of every source file in the repository shows:
- Production RTL (`rtl/*.sv`): Licensed under `CERN-OHL-S-2.0`.
- Formal harnesses (`fv/*.sv`): Licensed under `CERN-OHL-S-2.0`.
- Testbenches (`tb/*.sv`): Licensed under `CERN-OHL-S-2.0`.
- Verification scripts (`scripts/verify_gate_b_rev28d.ps1`): Licensed under `CERN-OHL-S-2.0`.
- **AGPL Files Present:** **ZERO (0)**. There is not a single line of AGPL-licensed code in this repository.

#### Risk & Impact
Automated open-source compliance tooling (e.g., FOSSology, Black Duck, Snyk) scanning this repository flags AGPL-3.0, triggering corporate legal red flags for potential commercial adopters who fear network copyleft contamination, despite no AGPL software actually existing in the hardware repo.

#### Proposed v4 Remediation
1. In the v4 RFC governance documents, clarify that the hardware repository is governed strictly by `CERN-OHL-S-2.0`.
2. Document that if FreeCuli subsequently develops and releases standalone server-side controller software or management dashboards, those distinct software packages may be distributed in dedicated repositories under AGPL-3.0 or Apache-2.0, with their own independent licensing instruments.

---

### 4.4. Finding L-04: Trademark and Copyright Commingling

#### Legacy Text Analysis
- **`zero-cloud-core-brand-and-trademark-policy.md` §Commercial Exemption (Line 44):**  
  > *"To bypass these obligations and keep hardware designs proprietary while obtaining the official certification badge, manufacturers must acquire a Commercial Exemption and B2B Trademark License."*

#### Legal Clarification
Copyright and Trademark operate under completely separate legal doctrines:
- **Copyright (`CERN-OHL-S v2.0` / Commercial Exemption):** Governs rights to copy, modify, and distribute schematics, layout, and RTL.
- **Trademark (`FreeCuli Certified™` / Brand Policy):** Protects source identity, consumer trust, and quality certification.

A commercial manufacturer could easily fall into one of four distinct quadrats:
1. **Open Source + Self-Declared:** Uses FreeCuli RTL under CERN-OHL-S; states textual compliance (Level 1); no trademark license needed.
2. **Open Source + FreeCuli Certified:** Uses FreeCuli RTL under CERN-OHL-S (releases source); undergoes accredited testing and obtains a trademark license to carry the official "FreeCuli Certified" badge.
3. **Clean-Room + FreeCuli Certified:** Develops 100% proprietary silicon/PCB (no FreeCuli copyright involved); passes accredited CTS testing; obtains a trademark license to carry the official badge.
4. **Proprietary Derivative + FreeCuli Certified:** Uses FreeCuli reference RTL under a paid Commercial Exemption (Route B) AND obtains a trademark license for the badge.

By bundling the two into an inseparable requirement, the legacy text creates confusion and prevents clean-room vendors from pursuing legitimate certification.

#### Proposed v4 Remediation
In `ZC-CORE-V4-TRADEMARK-AND-CONFORMANCE-RFC.md`:
- Normatively decouple the Trademark Licensing Scheme from the Hardware Copyright License.
- Conformance Level 4 ("FreeCuli Certified™") requires a formal Trademark License Agreement and verification audit, regardless of whether the underlying hardware was built via Route A, Route B, or clean-room engineering.

---

### 4.5. Finding L-05: Defensive Publication and Patent Retaliation Realism

#### Legacy Text Analysis
- **`zero-cloud-dual-licensing.md` §3 (Lines 29–35):**  
  > *"Patent Retaliation Clause: ...right to use the CERN-OHL-S v2.0 / ZC-CORE license is subject to worldwide revocation under applicable license terms... Furthermore, as an official Open Invention Network (OIN) member, FreeCuli leverages cross-licensing..."*

#### Legal Boundary Analysis
1. **Upstream License Bounds:** `CERN-OHL-S v2.0` §4.4 already includes a carefully drafted patent retaliation clause. FreeCuli cannot invent a broader, extra-contractual revocation power over third-party licensees beyond what CERN-OHL-S v2.0 provides, except with respect to FreeCuli's own proprietary materials.
2. **Defensive Publication Power:** Public technical disclosures (Zenodo Concept DOI 10.5281/zenodo.22838473, GitHub commits) provide excellent defensive prior art to invalidate subsequent third-party patent claims (35 U.S.C. § 102(a)(1); EPC Art. 54(2)). However, prior art does NOT give FreeCuli an affirmative patent monopoly or the power to sue third parties for patent infringement.
3. **OIN Protection Scope:** OIN non-aggression protects the "Linux System" definitions. Edge AI hardware data diodes and physical ASIC gates fall outside standard core Linux System definitions unless explicitly covered.

#### Proposed v4 Remediation
In `ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md` and `evidence/architecture/V4_DEFENSIVE_PUBLICATION_DISCLOSURE_PLAN.md`:
- Clarify that FreeCuli relies on defensive disclosure (prior art) to keep the technology unencumbered by patent trolls.
- Re-align the patent retaliation clause with `CERN-OHL-S v2.0 §4.4`, clarifying that any entity that asserts patent claims against FreeCuli or its licensees regarding the covered reference designs forfeits their rights under FreeCuli's copyright licenses.

---

## 5. Transition Action Plan for v4.0.0

| Phase | Target Document | Action & Remediation | Status |
| :---: | :--- | :--- | :---: |
| **Phase 1** | `evidence/legal/V4_LEGACY_LICENSING_BASELINE_AUDIT.md` | Full baseline audit of all 18 root files and legacy clauses (This Document). | **COMPLETED** |
| **Phase 2** | `evidence/legal/V4_LICENSE_SCOPE_AND_RIGHTS_MATRIX.md` | 10-category rights chain & material classification matrix. | **IN PROGRESS** |
| **Phase 3** | `docs/rfc/ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md` | Formal RFC establishing Route A (CERN-OHL-S) vs Route B (Commercial B2B) and clean-room protections. | **PENDING** |
| **Phase 4** | `docs/rfc/ZC-CORE-V4-TRADEMARK-AND-CONFORMANCE-RFC.md` | Formal RFC decoupling trademark rights and formalizing 4-level conformance model. | **PENDING** |
| **Phase 5** | `evidence/architecture/V4_DEFENSIVE_PUBLICATION_DISCLOSURE_PLAN.md` | Update prior-art alignment, enablement limits, and legal review gates. | **PENDING** |
| **Phase 6** | `evidence/architecture/V4_NORMATIVE_MIGRATION_MANIFEST.md` | Mark legacy licensing files as `PRESERVE HISTORICAL BASELINE / PROPOSE V4 SUCCESSOR`. | **PENDING** |
| **Phase 7** | Cross-Document Verification & Git Commit | Run `verify_gate_b_rev28d.ps1`, stage, commit, and deliver final report. | **PENDING** |

---
*End of Legacy Licensing Baseline Audit — Generated for FreeCuli ZC-CORE Architecture Review.*
