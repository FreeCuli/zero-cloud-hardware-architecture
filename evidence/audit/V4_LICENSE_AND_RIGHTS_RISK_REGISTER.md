# FREECULI ZC-CORE — v4.0.0 License & Rights Risk Register

**Document ID:** ZC-CORE-REG-RISK-01  
**Project:** FreeCuli ZC-CORE Hardware Architecture & Methodology  
**Target Release:** v4.0.0 Architecture & Licensing Transition  
**Document Classification:** Legal Risk Register & Rights Audit  
**Location:** `evidence/audit/V4_LICENSE_AND_RIGHTS_RISK_REGISTER.md`  
**Governance Status:** `DRAFT RISK REGISTER / AUDIT BASELINE / NOT RATIFIED`  
**Related Documents:**
- `evidence/audit/V4_STRATEGIC_IP_INDEPENDENT_AUDIT.md`
- `evidence/legal/V4_LEGACY_LICENSING_BASELINE_AUDIT.md`
- `evidence/legal/V4_LICENSE_SCOPE_AND_RIGHTS_MATRIX.md`
- `docs/rfc/ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md`

---

## 1. Executive Summary

This register catalogs all document-specific licensing, ownership, sublicensing, and contractual risks identified across the FreeCuli repository. Each risk is evaluated based on verifiable facts from the codebase, legal implications under open-source and copyright jurisprudence, and corporate commercialization objectives.

Risks are classified into four severity tiers:
- **`CRITICAL`**: Immediate threat to legal integrity, rights ownership, or publication validity.
- **`HIGH`**: Material ambiguity or contradiction capable of impairing adoption or B2B commercial licensing.
- **`MEDIUM`**: Important documentation, licensing mismatch, or verification weakness.
- **`LOW`**: Editorial, terminology, or maintainability issue.

---

## 2. Comprehensive Risk Register

| Risk ID | Asset / Document Location | Severity | Category | Description of Legal / Commercial Risk | Evidentiary Basis in Repo | Probability & Impact | Proposed Mitigation | Verification Status |
| :---: | :--- | :---: | :--- | :--- | :--- | :---: | :--- | :---: |
| **LRR-01** | `LICENSE` (Lines 17-22); `zero-cloud-dual-licensing.md` (Line 17) | **CRITICAL** | Phantom Asset / False Representation | Claims CERN-OHL-S covers reference PCB layouts, component placement, schematics, and Gerber files. In reality, **zero CAD/Gerber files exist in git history**. | Verified by `git log --all --full-history` returning 0 CAD/PCB files. | High Prob / Severe Impact (Destroys credibility; false prior art). | Remove PCB/Gerber claims from v4 license notices; scope license strictly to `rtl/*.sv`. | **VERIFIED FACT** |
| **LRR-02** | `LICENSE` (Lines 39-41); `zero-cloud-dual-licensing.md` (Lines 36-38) | **HIGH** | Scope Overreach / Copyright Misuse | Implies that any organization building a device conforming to ZC-CORE principles MUST buy a commercial license if proprietary. Copyright cannot protect ideas or methods. | Contradicts 17 U.S.C. Section 102(b), TRIPS Art. 9.2, and `zero-cloud-core-methodology-invariants.md` Section 4. | High Prob / High Impact (Chills adoption; legally unenforceable). | In `ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md`, affirm absolute freedom for clean-room implementations. | **VERIFIED FACT** |
| **LRR-03** | `zero-cloud-dual-licensing.md` (Lines 14-23) | **HIGH** | Open Source Definition (OSD) Breach | Restricts Route A (Open Hardware) to academics/startups; demands that commercial companies (Bosch, Samsung) must purchase Route B licenses. | Violates OSD #5 (No Discrimination Against Persons), OSD #6 (Fields of Endeavor), and CERN-OHL-S v2.0 Section 3.1. | High Prob / High Impact (Invalidates open-source claims; antitrust exposure). | Open Route A unconditionally to commercial entities willing to reciprocate source under CERN-OHL-S v2.0. | **VERIFIED FACT** |
| **LRR-04** | `LICENSE` (Line 1, 24-28); `CITATION.cff` (Line 12) | **MEDIUM** | Phantom License Header / Mismatch | Claims composite license `(CERN-OHL-S-2.0 AND AGPL-3.0-or-later)`. Automated scanners (Snyk, Black Duck) flag AGPL-3.0, scaring away commercial partners. | Exact grep reveals zero AGPL code in the entire repository. | Med Prob / High Impact (Enterprise legal departments block repository usage). | Clarify in v4 successor that hardware repository is 100% `CERN-OHL-S-2.0`. | **VERIFIED FACT** |
| **LRR-05** | `rtl/*.sv`, `fv/*.sv`, `tb/*.sv` | **LOW** | Provenance & Chain of Title | Production RTL modules author headers cite "FreeCuli Standards Organization". Founder reports sole development. | Git commit history (100% of commits to `rtl/` authored by `yemekyarismasi <ajibaoytun@gmail.com>`) is consistent with founder representation. Zero 3rd-party code identified. | Low Prob / Low Impact | Retain founder representation in audit records; obtain formal written attestation document if required for B2B contract closing. | **FOUNDER REPRESENTATION RECORDED (ATTEST-01 COMPLETED)** |
| **LRR-06** | `zero-cloud-core-brand-and-trademark-policy.md` | **LOW** | Trademark Status Ambiguity | Uses "FreeCuli Certified(TM)". Must ensure nobody assumes "(TM)" denotes a registered government trademark certificate. | Repo contains no trademark registration serial numbers. | Low Prob / Low Impact (Potential consumer protection inquiry if mislabeled). | Explicitly state in trademark RFC that (TM) represents an unregistered common-law brand claim. | **VERIFIED FACT** |
| **LRR-07** | `CONTRIBUTING.md` | **MEDIUM** | Inbound Contribution Contamination | Future open-source PRs accepted into `rtl/` under standard CERN-OHL-S without a CLA would prevent FreeCuli from offering Route B commercial licenses on that code. | `CONTRIBUTING.md` currently lacks a Contributor License Agreement (CLA) mechanism. | Med Prob / High Impact (Inbound code permanently locks repository into copyleft-only). | Implement lightweight inbound CLA or restrict Route B to FreeCuli-authored core. | **RECOMMENDED MITIGATION** |
| **LRR-08** | `zero-cloud-dual-licensing.md` (Lines 29-35) | **MEDIUM** | Patent Retaliation Overreach | Asserts worldwide license revocation beyond the express terms of CERN-OHL-S v2.0 Section 4.4. | CERN-OHL-S v2.0 Section 4.4 has precise legal drafting; unilateral extra-contractual additions are void. | Low Prob / Med Impact (Unenforceable over-breadth). | Re-align patent retaliation clause strictly with CERN-OHL-S v2.0 Section 4.4 terms. | **VERIFIED FACT** |
| **LRR-09** | `zero-cloud-core-brand-and-trademark-policy.md` (Line 44) | **MEDIUM** | IP Regime Commingling | Bundles copyright exemption (Route B) with trademark certification (Level 4 Badge) as a single compulsory package. | Copyright and trademark are distinct legal disciplines under international IP treaties. | Med Prob / Med Impact (Prevents clean-room vendors from certifying; limits adoption). | Decouple trademark certification from hardware copyright in v4 RFCs. | **VERIFIED FACT** |

---

## 3. Deep-Dive on Top-Tier Risks

### 3.1. LRR-01: The Phantom PCB Asset (Critical Vulnerability)
- **The Issue:** Root `LICENSE` asserts that CERN-OHL-S v2.0 governs "Reference PCB layouts, component placement, electrical schematics, Gerber files". In truth, not a single schematic file (`.kicad_sch`, `.sch`), PCB layout (`.kicad_pcb`, `.brd`), or Gerber archive (`.gbr`) has ever been committed to this repository.
- **Why It Matters:** If FreeCuli sends a legal notice to a competitor claiming they infringed FreeCuli's CERN-OHL-S license on a hardware board, the competitor will immediately discover that FreeCuli never published the PCB files in this repository. This damages credibility and renders copyleft claims on hardware boards void.
- **Remediation:** In v4.0.0, eliminate all claims of published reference PCB Gerbers. Explicitly define that the published open hardware consists strictly of synthesizable SystemVerilog RTL modules (`rtl/*.sv`), formal proofs (`fv/*.sv`), and systems specifications.

### 3.2. LRR-02: Scope Overreach on the Abstract Methodology (High Risk)
- **The Issue:** `LICENSE` lines 39–41 state: *"Manufacturers seeking to build compliant Zero-Cloud appliances without releasing proprietary trade secrets... MUST execute a Commercial Exemption Agreement with FreeCuli prior to commercial distribution."*
- **Legal Fact:** Under 17 U.S.C. § 102(b), TRIPS Article 9.2, and EU Directive 2009/24/EC, copyright does NOT protect ideas, concepts, principles, or methodologies. A company that writes its own RTL and designs its own PCB to achieve M1–M10 compliance (clean-room engineering) does NOT infringe FreeCuli's copyright and cannot be forced to buy a commercial license.
- **Remediation:** `ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md` has already drafted the explicit Clean-Room Freedom Guarantee. When ratified, this will remediate LRR-02 completely.

### 3.3. LRR-03: Open Source Discrimination (OSD #5 & #6 Breach)
- **The Issue:** Legacy text claims Route A is only for universities and open-source startups, while commercial companies must buy a commercial license.
- **Legal Fact:** Under the Open Source Definition (OSD) and CERN-OHL-S v2.0 §3.1, anyone (including Fortune 500 corporations) has the right to use the open-source hardware for free, provided they comply with the copyleft source-sharing obligations.
- **Remediation:** Reframe Route A as universally available to any commercial entity that is willing to share its derivative source code publicly under CERN-OHL-S v2.0. Route B is an elective commercial alternative, not a compulsory fee.

---

## 4. Ownership and Development History (21 October 2026 Record)

> **Ownership and Development History:** The founder represents that they are the sole developer and rights holder of ZC-CORE. The reviewed Git history is consistent with the founder's representation of sole development. This record documents the founder's representation and its comparison against the reviewed technical records.

- [x] **ATTEST-01 (RTL Authorship Representation):** The founder represents that they are the sole developer and rights holder of ZC-CORE RTL modules (`rtl/*.sv`), testbenches, and technical specifications. The reviewed Git history (100% of commits to `rtl/` authored by `yemekyarismasi <ajibaoytun@gmail.com>`) is consistent with the founder's representation of sole development. This record documents the founder's representation and its comparison against the reviewed technical records; it is not characterized as an independent legal title deed.
- [x] **ATTEST-02 (Brand & Trademark Representation):** The brand marks `FreeCuli` and `ZC-CORE` serve as source identifiers under common-law ("™") principles, proprietary to the founder.

---
*End of V4_LICENSE_AND_RIGHTS_RISK_REGISTER.md — Prepared for FreeCuli Architecture & Governance Review.*
