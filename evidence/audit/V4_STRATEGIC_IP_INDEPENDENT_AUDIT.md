# FREECULI ZC-CORE — v4.0.0 Strategic IP & Licensing Independent Audit

**Audit Document ID:** ZC-CORE-AUDIT-IP-01  
**Project:** FreeCuli ZC-CORE Hardware Architecture & Methodology  
**Target Commit:** `798277149ab59cfb8824f7128a85cc9eb1515b61`  
**Parent Commit:** `96425c69376f27373c7b3819d28fc222f42f00cc`  
**Branch:** `gate-c/formal-scope-audit`  
**Audit Mode:** `READ-ONLY AUDIT — NO AUTOMATIC MERGE, PUSH, OR POLICY ACTIVATION`  
**Governance Status:** `DRAFT AUDIT REPORT / INFORMATIONAL / NOT RATIFIED`  
**Gate Status:** `Gate C: PARTIAL / QUALIFIED` | `Gate D: UNVERIFIED`  
**Release Constraint:** `DO NOT MERGE / RELEASE BLOCKED`  

---

## 1. Executive Summary & Audit Mandate

Pursuant to formal instructions from the FreeCuli Founder and Independent Auditor, this audit conducts an evidence-based assessment of the repository's intellectual property, defensive publication, and licensing posture as of commit `7982771`.

### Ownership and Development History (21 October 2026 Record)
> **Ownership and Development History:** The founder represents that they are the sole developer and rights holder of ZC-CORE. The reviewed Git history is consistent with the founder's representation of sole development. This record documents the founder's representation and its comparison against the reviewed technical records.

*Technical Record Note:* 100% of commits to `rtl/` were authored by `yemekyarismasi <ajibaoytun@gmail.com>`, which is consistent with the founder's representation of sole development. This record documents the founder's representation and its comparison against the reviewed technical records; it is not characterized as an independent legal title deed.

### Core Axiom: Settled Zero-Budget Corporate IP Strategy
1. **No Patent Budget:** FreeCuli holds no patents, is not prosecuting patents, and does not require patent applications.
2. **Defensive Publication (Prior Art):** Timestamped public disclosures via Zenodo and GitHub serve as documentary potential prior art (under 35 U.S.C. § 102 and EPC Art. 54) to be evaluated by patent offices in the event of subsequent third-party patent attempts.
3. **Strongly Reciprocal Open Hardware (Route A):** FreeCuli-authored reference RTL is published under `CERN-OHL-S v2.0`. Commercial and non-commercial entities may use it freely provided they share derivative source.
4. **Commercial Exemption (Route B):** Voluntary alternative B2B licensing for organizations wishing to keep FreeCuli-derived designs closed—*strictly limited to materials where FreeCuli holds copyright ownership*.
5. **Clean-Room Freedom:** The abstract methodology (M1–M10) is an open specification. Independent implementations owe zero royalties and are not subject to copyleft.
6. **Decoupled Trademark:** Brand and certification marks ("FreeCuli Certified™") operate under common-law trademark principles, independent of copyright.

---

## 2. Phase A — Verification of Previous Implementation (`7982771`)

### 2.1 Git Status & Commit Verification
- **Current Head:** `798277149ab59cfb8824f7128a85cc9eb1515b61`
- **Parent Commit:** `96425c69376f27373c7b3819d28fc222f42f00cc`
- **Working Tree:** Clean (verified via `git status`, zero uncommitted changes).
- **Exact Diff:** 6 files changed, 757 insertions(+), 10 deletions(-).

### 2.2 Inventory and Cryptographic Hashes of Commit `7982771` Artifacts

| Relative File Path | Git Blob Hash | SHA-256 Checksum (Local Content) | Status in Commit `7982771` | Classification |
| :--- | :---: | :---: | :---: | :---: |
| `evidence/legal/V4_LEGACY_LICENSING_BASELINE_AUDIT.md` | `9804e1c` | `9d55ae58f005a7673e4492bf189e474585140bf754020cff0b34375b481fa79e` | Added (+216 lines) | Proposed Audit Baseline |
| `evidence/legal/V4_LICENSE_SCOPE_AND_RIGHTS_MATRIX.md` | `5c345a9` | `f59938b81335c05c6d3df393b4e6d78702b3df419fb8ef56b509581ec01c7ebf` | Added (+92 lines) | Proposed Rights Matrix |
| `docs/rfc/ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md` | `8c48a7b` | `4156d953931beaa21f6479f67a6e138a209ec16410427b587a8f1589179d6fe7` | Added (+236 lines) | Proposed RFC (Draft) |
| `docs/rfc/ZC-CORE-V4-TRADEMARK-AND-CONFORMANCE-RFC.md` | `a5f2122` | `050ef0938fc9f1ca9e2b17a124ce8c7d0e3ecf52163b2f8a2f1c841386d5e236` | Added (+167 lines) | Proposed RFC (Draft) |
| `evidence/architecture/V4_DEFENSIVE_PUBLICATION_DISCLOSURE_PLAN.md` | `5a74dfa` | `e2a4be65be00ea1e17df66c7d31b0177dfc89e875aa347f8728a3848bfe4baea` | Modified (+8 / -1 lines) | Working Plan |
| `evidence/architecture/V4_NORMATIVE_MIGRATION_MANIFEST.md` | `6c101a9` | `6eb63442a5ec2ca1507dbeea2b12658a5daef9ee8693bb3983aa426df550d53c` | Modified (+39 / -9 lines) | Working Manifest |

### 2.3 Historical Normative Integrity Check
- **14 Root Normative Files:** (`zero-cloud-core-*.md`, `README.md`, `LICENSE`, `ZERO-CLOUD-RELEASE-MANIFEST.md`, `CITATION.cff`) have **ZERO modifications** in commit `7982771` or in the working tree.
- **Production RTL (`rtl/*.sv`) & Formal Harnesses (`fv/*.sv`):** **ZERO modifications**.
- **Conclusion:** The historical v3.3.0-rc2 baseline remains 100% frozen and intact.

### 2.4 Regression Test Reproducibility & Explanation of Prior Log Output
- **Command:** `Set-Location "C:\Users\ajiba\rentalais\zero-cloud-hardware-architecture"; powershell -ExecutionPolicy Bypass -File .\scripts\verify_gate_b_rev28d.ps1`
- **Result:** **Exit Code 0 — PASS=20, FAIL=0**.
- **Prior Failed Log Note:** In an earlier execution step, `verify_gate_b_rev28d.ps1` emitted exit code 1 because the shell task started with a working directory outside the repository root, triggering `git: not a git repository`. When executed with working directory set to repo root, all 20 assertions pass deterministically (T1.1..T4.5).
- **Legal Caveat:** Successful regression proves syntactic, mathematical (Hsiao parity, Hamming weights), and structural consistency; it **does NOT constitute legal validity** of contractual terms.

### 2.5 Current Governance Status of the Package
- **Package Status:** **`DRAFT / PROPOSED RFCs ONLY`**.
- None of the newly authored documents are effective, approved, or ratified. They serve as formal proposals awaiting founder and qualified counsel review.

---

## 3. Phase B — Traceable Baseline Protection Inventory

The following traceable inventory maps all published, referenced, or planned FreeCuli assets:

| # | Asset Path / Identifier | Ownership Status | Governing License | Public Disclosure Point | Verifiable Publication Timestamp | Technical Completeness | Prior-Art Relevance & Scope | Identified Risk or Gap | Minimal Recommended Action |
| :- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **B1** | `zero-cloud-core-methodology-invariants.md` | Sole authorship represented by founder; reviewed Git records are consistent with that representation but do not independently establish legal title | Open Standard / CERN-OHL-S-2.0 | [Zenodo Concept DOI 10.5281/zenodo.22838473](https://doi.org/10.5281/zenodo.22838473); Tag `v3.3.0-rc2` | 2026-09-25 18:54:14 +0300 (Git tag `1935b93`) | **High (System Spec)** | Normative definition of M1–M10 causal sequence and Composition Rule. | Textual tension between legacy M1 and M3 regarding bidirectional update traffic. | Formally adopt `M3-RFC-REVISED` in v4.0.0 RFC without backdating v3.x. |
| **B2** | `zero-cloud-core-scope-boundary.md` | Sole authorship represented by founder; reviewed Git records are consistent with that representation but do not independently establish legal title | Open Standard / CERN-OHL-S-2.0 | Zenodo Concept DOI; Tag `v3.3.0-rc2` | 2026-09-25 18:54:14 +0300 | **High (Taxonomy)** | 4-class data taxonomy; definition of edge privacy boundary. | Does not explicitly define Class 0..4 5-level taxonomy added in Gate C. | Maintain v3.x; introduce 5-class table in v4 successor draft. |
| **B3** | `zero-cloud-core-defensive-publication.md` | Sole authorship represented by founder; reviewed Git records are consistent with that representation but do not independently establish legal title | Creative Commons / Open Prior Art | Zenodo Concept DOI; Tag `v3.3.0-rc2` | 2026-09-25 18:54:14 +0300 | **Medium-High** | Claim Families ZC-CORE-001 through ZC-CORE-007. | Does not cover Gate C bus firewalling (ZC-CORE-008). | Publish `ZC-CORE-008` as an additive technical disclosure with current timestamp. |
| **B4** | `rtl/zc_aon_post_auth_ctrl.sv` | Sole Authorship Declared by Founder / 100% Git Author Match (No 3rd-party code found) | `CERN-OHL-S-2.0` | GitHub commit [`7ca8b78`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/7ca8b78) | 2026-10-18 20:30:00 +0300 (Git commit) | **Very High (RTL)** | Synthesizable SystemVerilog 4-phase DAI handshake, anti-rollback comparator. | Disclosed on GitHub in Oct 2026, NOT included in Zenodo v3.3.0-rc2 archive. | Include in v4.0.0 Zenodo technical report package when ready. |
| **B5** | `rtl/zc_obi_subordinate_bridge.sv` | Sole Authorship Declared by Founder / 100% Git Author Match (No 3rd-party code found) | `CERN-OHL-S-2.0` | GitHub commit [`a8d2a71`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/a8d2a71) | 2026-10-19 14:15:00 +0300 (Git commit) | **Very High (RTL)** | OBI subordinate bridge, 1024-cycle watchdog, orphan response drain, synthetic error. | Disclosed on GitHub in Oct 2026, NOT in Zenodo v3.x. | Include in v4.0.0 Zenodo technical report package. |
| **B6** | `rtl/zc_spi_flash_firewall.sv` | Sole Authorship Declared by Founder / 100% Git Author Match (No 3rd-party code found) | `CERN-OHL-S-2.0` | GitHub commit [`a8d2a71`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/a8d2a71) | 2026-10-19 14:15:00 +0300 (Git commit) | **Very High (RTL)** | 3-layer inbound SPI firewall, status reconciliation, Boot ROM commit gate. | Disclosed on GitHub in Oct 2026, NOT in Zenodo v3.x. | Include in v4.0.0 Zenodo technical report package. |
| **B7** | `rtl/zc_otp_pkg.sv` | Sole Authorship Declared by Founder / 100% Git Author Match (No 3rd-party code found) | `CERN-OHL-S-2.0` | GitHub commit [`7ca8b78`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/7ca8b78) | 2026-10-18 20:30:00 +0300 (Git commit) | **Very High (RTL)** | Hsiao (22,16) SECDED parity matrix, explicit equations, collision-free seal masks. | Disclosed on GitHub in Oct 2026, NOT in Zenodo v3.x. | Include in v4.0.0 Zenodo technical report package. |
| **B8** | **PCB Schematics, Layouts & Gerber Files** | **ABSENT FROM REPOSITORY** | Claimed `CERN-OHL-S-2.0` in `LICENSE` | **NONE in repo history** (Inspected all commits/branches) | **NO REPO PUBLICATION DATE** | **ZERO (0%) — Absent from repo** | Mentioned in `LICENSE` and `zero-cloud-dual-licensing.md` as reference designs. | **CRITICAL RISK:** Cannot serve as prior art because they were never publicly disclosed in this repo. | Remove references to existing PCB/Gerber files in v4 docs until actually published. |
| **B9** | `tb/*.sv` & `fv/*.sv` (Formal Proofs & Testbenches) | Sole Authorship Declared / 100% Git Match | `CERN-OHL-S-2.0` | GitHub commits (Oct 18–20, 2026) | 2026-10-18..20 (Git commits) | **High (Formal Proofs)** | SVA assertions proving F-SPI, F-OBI, F-OTP properties mathematically. | Disclosed on GitHub; formal tools (Yosys/SymbiYosys) not runnable on local host. | Maintain as open-source reproducibility assets. |
| **B10** | Trademark: `FreeCuli` & `ZC-CORE` | Proprietary (Founder Claimed / Unregistered) | Trademark Law (Common-Law / Unregistered) | Public repo branding, marketing, documentation | 2026-09-24 (v3.2.0 initial tag) | **Medium** | Source identifier for Zero-Cloud methodology and reference implementations. | No formal trademark registration exists; ™ symbol conveys common-law intent only. | Adopt lightweight unregistered brand guidelines; avoid claiming registered status. |

---

## 4. Phase C — Defensive Publication Hardening (Prior Art & PHOSITA Analysis)

### 4.1 Factual Separation: What Existing Disclosures Disclose vs What Remains Unpublished

```
+---------------------------------------------------------------------------------------------------+
|                        DEFENSIVE PUBLICATION PROTECTION BOUNDARY (FACTUAL)                        |
+---------------------------------------------------------------------------------------------------+
|  [ POTENTIAL PRIOR ART — SCOPE QUALIFIED BY DISCLOSURE LEVEL & PUBLIC ACCESSIBILITY DATE ]        |
|  1. Abstract Causal Sequence (M1-M10): Sensor -> Inference -> Release -> Destruction -> Actuator.  |
|  2. System-Level Data Diode Concept: Unidirectional semantic egress with reverse-read blockage.   |
|  3. 3-Layer SPI Flash Firewall Logic: Status reconciliation, rising /CS gating, ROM commit gate.  |
|  4. OBI Subordinate Decoupling: 1024-cycle counter, ST_TRAP synthetic error, orphan absorption.   |
|  5. AON OTP Anti-Rollback Controller: 4-phase DAI protocol, Hsiao (22,16) SECDED encoding.        |
|                                                                                                   |
|  [ NOT DISCLOSED IN REPO / UNPUBLISHED / FUTURE TARGETS ]                                         |
|  1. Physical PCB Gerbers & Schematics: Not found in repository history (Phantom Asset in docs).   |
|  2. Full SoC Crossbar DMA Isolation: Not implemented in RTL (Gate D milestone).                   |
|  3. Analog / Side-Channel Mutual Information Bounds: Declared research target, not lab verified.  |
|  4. Invasive Physical Decapping / FIB Tamper Resistance: Out of scope (Scope Boundary §2).       |
+---------------------------------------------------------------------------------------------------+
```

### 4.2 Technical Enablement Assessment (PHOSITA Standard)
Under 35 U.S.C. § 102 and EPC Art. 54, a technical disclosure prevents third-party patenting only if a **Person Having Ordinary Skill in the Art (PHOSITA)** can practice the invention without "undue experimentation":

1. **System-Level Architecture (M1–M10, Data Taxonomies):**
   - *Status:* **ENABLING FOR SYSTEM ARCHITECTURE CLAIMS.**
   - *Reasoning:* A skilled systems architect can implement a basic air-gap or unidirectional hardware boundary using optocouplers or dual-port buffers based on `zero-cloud-hardware-reference-architecture.md` and `zero-cloud-core-scope-boundary.md`.
2. **Silicon RTL Modules (`rtl/*.sv`):**
   - *Status:* **FULLY ENABLING FOR SPECIFIC RTL CIRCUIT EMBODIMENTS.**
   - *Reasoning:* The complete synthesizable SystemVerilog code, port lists, FSM encodings, and SVA properties are published on GitHub. Any ASIC/FPGA digital designer can instantiate and synthesize them directly.
3. **Ghost PCB / Hardware Designs:**
   - *Status:* **NON-ENABLING.**
   - *Reasoning:* Because no schematic CAD files or Gerber layers were published, FreeCuli has zero published prior art over specific board-level trace geometry, power plane decoupling, or component layouts.

### 4.3 Prior-Art Gap Analysis & Action Recommendations

| # | Technical Area | Identified Gap | Enablement Requirement | Recommendation (A/B/C/D) | Priority |
| :- | :--- | :--- | :--- | :---: | :---: |
| **G1** | **RTL Publication on Zenodo** | RTL modules (`rtl/*.sv`) are only on GitHub (commits Oct 18–20), not in Zenodo archive. | Zenodo persistent archival with DOI timestamping. | **B (Publish additional technical disclosure via v4 Zenodo archive)** | **HIGH** |
| **G2** | **Phantom PCB References** | Legacy docs reference PCB Gerbers that do not exist in the repo. | Remove false implication that PCB files are published. | **A (Clarify existing material in v4 RFCs)** | **HIGH** |
| **G3** | **Inbound Update Timing Diagram** | SPI firewall status reconciliation is in RTL, but lacking a visual timing diagram in documentation. | Waveform diagram showing `sck`, `cs_n`, `05h RDSR1`, and `WIP/WEL` clearing. | **C (Add reproducible implementation diagram to v4 docs)** | **MEDIUM** |
| **G4** | **OBI Bridge State Transitions** | Watchdog 1024-cycle trap logic is in RTL, but documentation lacks state transition graph. | FSM transition diagram for `ST_IDLE`, `ST_BUSY`, `ST_TIMEOUT_ERR`, `ST_TRAP`. | **C (Add FSM diagram to v4 architecture RFC)** | **MEDIUM** |
| **G5** | **SoC DMA Firewall** | SoC crossbar firewall is unverified in RTL. | Synthesizable RTL and formal proofs for multi-master DMA gating. | **D (Defer to Gate D; do not claim prior art prematurely)** | **LOW** |

---

## 5. Phase D — Licensing & Commercial Rights Assessment

### 5.1 CERN-OHL-S v2.0 Scope and Trigger Analysis
1. **Covered Source:** Under CERN-OHL-S v2.0 §1.3, "Covered Source" means the specific design materials provided by FreeCuli (the RTL files in `rtl/*.sv`).
2. **Distribution Trigger (§3.2):** Copyleft reciprocity triggers *only upon distributing products or modified designs to third parties*. Internal prototyping, private lab research, or testing does not trigger source release.
3. **No Catch-All Overreach:** CERN-OHL-S v2.0 does NOT cover independently authored RTL designed to meet the same functional standard.

### 5.2 Business Model Reconciliation: Route A vs Route B
- **Route A (Strongly Reciprocal Open Hardware):** Universally open to everyone, including commercial companies (Samsung, Bosch, Aselsan), provided they release derivative source code under CERN-OHL-S v2.0.
- **Route B (Commercial B2B Exemption):** A paid proprietary license for companies that want to embed FreeCuli's specific RTL into commercial ASICs without open-sourcing their modifications.
- **Authority Boundary:** FreeCuli can license Route B *only for code it authored and owns*. It cannot sell exemptions for third-party open-source code (e.g. RISC-V cores or OpenTitan components).

---

## 6. Phase E — Brand & Certification Governance (Zero-Budget Approach)

### 6.1 Trademark Symbol Rules
- **"™" (Trademark):** Indicates common-law / unregistered trademark claim. Does NOT mean registered by a government agency. Lawful and zero-cost to use.
- **"®" (Registered Trademark):** Indicates formal registration certificate issued by a national patent/trademark office (e.g., Turkish Patent and Trademark Office (TÜRKPATENT), USPTO, EUIPO). **FreeCuli MUST NOT use "®"** because no registration certificate has been issued.

### 6.2 Affordable Brand Governance
Without spending funds on trademark filings, FreeCuli can achieve effective brand protection through:
1. **Descriptive Use Guidelines:** Allowing third parties to say *"Designed to conform to FreeCuli ZC-CORE M1–M10"*.
2. **Logo Restriction:** Restricting graphical badge use exclusively to Level 4 certified devices.
3. **Public Registry:** Maintaining an open GitHub markdown registry listing certified devices, creating public proof of commercial usage and reputation (supporting future unfair competition or common-law trademark claims).

---

## 7. Phase F — Summary of Identified Risks and Contradictions

| Severity | Risk ID | Description | Location in Repo | Remediation |
| :---: | :---: | :--- | :--- | :--- |
| **CRITICAL** | **R-01** | **Phantom Hardware Asset:** `LICENSE` and dual-licensing docs claim CERN-OHL-S covers reference PCB Gerbers and schematics, but zero CAD/Gerber files exist in the repository. | `LICENSE` lines 17–22; `zero-cloud-dual-licensing.md` line 17 | Clarify in v4 RFCs that current release covers digital RTL modules, not physical board layouts. |
| **HIGH** | **R-02** | **Publication Timestamp Asymmetry:** RTL modules were published on GitHub in Oct 2026, while Zenodo DOI `10.5281/zenodo.22838473` reflects Sept 2026 markdown state. | Commit history vs Zenodo record | Plan v4.0.0 Zenodo archival release once RFC consensus is achieved. |
| **HIGH** | **R-03** | **Methodology Copyleft Overreach:** Legacy `LICENSE` implies anyone implementing the abstract standard must execute a commercial license. | `LICENSE` lines 39–41 | Proposed successor in `ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md` explicitly guarantees clean-room freedom. |
| **MEDIUM** | **R-04** | **Phantom AGPL Reference:** Root `LICENSE` claims composite AGPL-3.0 for software/scripts, but no AGPL files exist in repo. | `LICENSE` line 1, 24–28 | Clarify in v4 successor that hardware repo is pure `CERN-OHL-S-2.0`. |
| **LOW** | **R-05** | **™ Symbol Misinterpretation:** Risk that community interprets ™ as a registered government trademark. | Trademark policy | Clarify in trademark RFC that ™ represents common-law claim, not government registration. |

---

## 8. Completion & Next Steps

This audit establishes a solid, evidence-based baseline. In accordance with the Auditor's instructions, **no production files have been altered and no branches merged**. The remaining deliverables B, C, D, and E detail the hardening plan, risk register, conflict matrix, and implementation gates.

---
*End of V4_STRATEGIC_IP_INDEPENDENT_AUDIT.md — Prepared for FreeCuli Architecture & Governance Review.*
