# FREECULI ZC-CORE — v4.0.0 Audit Evidence Clarification Addendum

**Document ID:** ZC-CORE-ADDENDUM-AUDIT-01
**Project:** FreeCuli ZC-CORE Hardware Architecture & Methodology
**Original Target Commit (Historical Context):** `798277149ab59cfb8824f7128a85cc9eb1515b61`
**Original Parent Commit:** `96425c69376f27373c7b3819d28fc222f42f00cc`
**Original Review Branch:** `gate-c/formal-scope-audit`
**Document Classification:** Audit Evidence Clarification & Factual Verification Addendum
**Location:** `evidence/audit/V4_AUDIT_EVIDENCE_CLARIFICATION_ADDENDUM.md`
**Governance Mode:** `HISTORICAL AUDIT SNAPSHOT / NON-NORMATIVE EVIDENCE`
**Gate Status (Gate C Baseline):** `Gate C: PARTIAL / QUALIFIED` | `Gate D: UNVERIFIED`
**Release Constraint (Historical):** `DO NOT MERGE / RELEASE BLOCKED / STAND DOWN (Historical Gate C State)`

> [!NOTE]
> **Historical Audit Snapshot:** This addendum was originally prepared during the Gate C review on branch `gate-c/formal-scope-audit`. It is included in candidate v4.0.0-rc2 as non-normative supporting evidence; its former local-only / stand-down status describes its original authoring state and does not restrict the current repository archive.

---

## 1. Purpose & Mandate

This document serves as the formal **Evidence Clarification Addendum** to the Phase A–G Independent Audit reports (`evidence/audit/V4_*.md`).

In direct compliance with the Independent Auditor's review directives:
1. **Prior-Art Categorical Statements Qualified:** Categorical assertions that a prior publication definitively prevents patent grants are replaced with jurisdiction-qualified language ("Potential prior art; technical scope, public availability, and legal effect subject to determination under applicable national patent laws").
2. **Zenodo Provenance Disaggregated:** Concept DOI is strictly separated from specific Version DOIs; unverified external metadata is marked `UNVERIFIED`.
3. **PCB Scope Strictly Defined:** Search scope is precisely documented as "not found in the inspected Git repository history," without overreaching to universal claims.
4. **Copyright Ownership Status Clarified:** Sole authorship, third-party code absence, and trademark ownership are classified as **`UNVERIFIED — PENDING OWNER ATTESTATION`**.
5. **Technical Disclosure Sufficiency Calibrated:** Descriptive diagrams, FSM tables, and IPC/CPC codes are classified as discoverability and technical aids, avoiding over-claims of legal certainty.
6. **Licensing Status Boundary Maintained:** The frozen v3.3.0-rc2 baseline terms are kept distinct from draft v4 RFC proposals.
7. **Regression Execution Transparency:** Exact command line, commit SHA, runtime versions, and scope boundaries of the 20 PASS / 0 FAIL result are documented.
8. **Deliverable Integrity:** Full SHA-256 cryptographic hashes and local file status are recorded.

---

## 2. Item 1: Prior-Art Qualification & Precise Claim-to-Document Mapping

### 2.1 Legal Qualification Principle
Under 35 U.S.C. § 102 (United States) and Article 54 of the European Patent Convention (EPC):
- A public technical publication constitutes **potential prior art**.
- Whether a disclosure successfully anticipates a subsequent patent claim (novelty / 35 U.S.C. § 102) or renders it obvious (inventive step / 35 U.S.C. § 103 / EPC Art. 56) is **NOT automatic**. It is subject to formal examination by national patent offices (e.g., USPTO, EPO, Turkish Patent and Trademark Office (TÜRKPATENT)) based on the exact date of public accessibility, the specific disclosure language, and the standard of a Person Having Ordinary Skill in the Art (PHOSITA).
- Accordingly, all statements in this audit asserting that FreeCuli disclosures "guarantee" or "definitively defeat" patent claims are formally amended to:
  > **`QUALIFIED PRIOR-ART STATUS:`** *The disclosed subject matter provides documentary prior-art evidence of public technical disclosure as of the verifiable publication timestamp. Its effectiveness in defeating third-party patent claims depends on the specific claim scope, public accessibility proofs, and applicable national patent laws.*

### 2.2 Traceable Claim-to-Document Mapping Table

| Claim ID / Subject Matter | First Disclosing Document & Exact Section | Verifiable Git Tag / Commit | Verifiable Publication Timestamp | Disclosing Venue & DOI Reference | Public Accessibility Evidence | Technical Disclosure Scope & Qualification |
| :--- | :--- | :---: | :---: | :--- | :--- | :--- |
| **CLM-01: Abstract Zero-Cloud Causal Sequence** (`Sensor -> Inference -> Semantic Release -> Zeroization -> Actuator`) | `zero-cloud-core-methodology-invariants.md` §2 (M1–M10 Composition Rule) | Tag `v3.2.0` (`214963d`) / Tag `v3.3.0-rc2` (`1935b93`) | 2026-09-24 19:53:32 +0300 (`v3.2.0`)<br>2026-09-25 18:54:14 +0300 (`v3.3.0-rc2`) | Public GitHub Repository & Zenodo Concept DOI [`10.5281/zenodo.22838473`](https://doi.org/10.5281/zenodo.22838473) | Git tag release tree; Zenodo record metadata. | **Potential Prior Art (Systems Architecture).** Discloses functional causal ordering and domain boundary. Does not disclose specific integrated circuit layouts. |
| **CLM-02: 4-Class Data Taxonomy** (`Raw Sensor Data`, `Metadata`, `Derived Representation`, `Semantic Result`) | `zero-cloud-core-scope-boundary.md` §1 | Tag `v3.2.0` (`214963d`) / Tag `v3.3.0-rc2` (`1935b93`) | 2026-09-24 19:53:32 +0300 | GitHub / Zenodo | Public markdown file in tagged commit. | **Potential Prior Art (Information Taxonomy).** Defines data classification boundaries for privacy compliance. |
| **CLM-03: Claim Families ZC-CORE-001..007** (Physical air-gap, unidirectional diode, reverse read impossibility) | `zero-cloud-core-defensive-publication.md` §2–§8 | Tag `v3.3.0-rc2` (`1935b93`) | 2026-09-25 18:54:14 +0300 | GitHub / Zenodo Concept DOI `10.5281/zenodo.22838473` | Signed cryptographic manifest `ZERO-CLOUD-RELEASE-MANIFEST.md` hash `F49D810...` | **Potential Prior Art (Claim-Style Functional Disclosures).** Discloses functional relationships and diode models; excludes specific RTL code. |
| **CLM-04: Synthesizable 3-Layer Inbound SPI Flash Firewall** (`zc_spi_flash_firewall.sv`) | `rtl/zc_spi_flash_firewall.sv` & `fv/zc_spi_sva.sv` | Commit [`1af8021`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/1af8021) / [`a8d2a71`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/a8d2a71) | 2026-10-18 21:00:00 +0300 to 2026-10-19 14:15:00 +0300 | Public GitHub Commit History (`gate-c/formal-scope-audit`) | GitHub public web interface and commit DAG. | **Potential Prior Art (Concrete RTL Circuit).** Fully discloses SystemVerilog FSM, status polling (`SR1[1:0]==2'b00`), and Boot ROM verification gate. **Not published in Zenodo v3.x.** |
| **CLM-05: OBI Subordinate Decoupling Bridge with 1024-Cycle Watchdog & Synthetic Error** (`zc_obi_subordinate_bridge.sv`) | `rtl/zc_obi_subordinate_bridge.sv` & `tb/tb_zc_obi.sv` | Commit [`11930f7`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/11930f7) / [`a8d2a71`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/a8d2a71) | 2026-10-18 20:45:00 +0300 to 2026-10-19 14:15:00 +0300 | Public GitHub Commit History | GitHub public commit DAG. | **Potential Prior Art (Bus Bridge RTL).** Discloses 10-bit counter, orphan absorption, and single-cycle `ST_TRAP` synthetic error. **Not published in Zenodo v3.x.** |
| **CLM-06: AON OTP Anti-Rollback Controller with 4-Phase DAI Handshake** (`zc_aon_post_auth_ctrl.sv`) | `rtl/zc_aon_post_auth_ctrl.sv` & `fv/zc_otp_sva.sv` | Commit [`7ca8b78`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/7ca8b78) | 2026-10-18 20:30:00 +0300 | Public GitHub Commit History | GitHub public commit DAG. | **Potential Prior Art (AON Hardware Security Controller).** Discloses 4-phase DAI protocol, persistent fatal lock across warm resets, and SVN monotonic comparator. |
| **CLM-07: Hsiao (22,16) Parity Generation & Collision-Free Seal Masks** (`zc_otp_pkg.sv`) | `rtl/zc_otp_pkg.sv` | Commit [`7ca8b78`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/7ca8b78) | 2026-10-18 20:30:00 +0300 | Public GitHub Commit History | GitHub public commit DAG; verified by script `verify_gate_b_rev28d.ps1` T1.1–T2.5. | **Potential Prior Art (ECC / Hardware Encoding).** Discloses explicit parity matrix, equations $p_0..p_5$, and seal masks `8'h5A` / `8'h3C`. |

---

## 3. Item 2: Zenodo Provenance & DOI Distinction

### 3.1 Concept DOI vs Version DOI Architecture
- **Concept DOI (`10.5281/zenodo.22838473`):**
  In Zenodo, a Concept DOI is a persistent meta-identifier that **dynamically resolves to the latest published version**. It does not lock a static historical file set or timestamp. Citing a Concept DOI alone does not prove to a patent examiner what exact files existed on a specific historical date.
- **Version DOIs (Immutable Snapshots):**
  Each individual Zenodo release is assigned a permanent, immutable **Version DOI** bound to a specific archived `.zip`/`.tar.gz` archive and cryptographic SHA-256 manifest.

### 3.2 Zenodo Archival Status Audit

| Release Tag | Git Tag Date | Expected Zenodo Identifier | Local Verification Status | Remote Archival Verification Status | Archived Technical Scope |
| :---: | :---: | :---: | :---: | :---: | :--- |
| `v3.2.0` | 2026-09-24 19:53:32 +0300 | Version DOI (under Concept `10.5281/zenodo.22838473`) | **VERIFIED IN GIT** (`214963d`) | `UNVERIFIED — PENDING EXTERNAL METADATA INSPECTION` | Systems specifications only. Zero RTL. |
| `v3.2.1` | 2026-09-25 14:02:22 +0300 | Version DOI (under Concept `10.5281/zenodo.22838473`) | **VERIFIED IN GIT** (`f4fd1d2`) | `UNVERIFIED — PENDING EXTERNAL METADATA INSPECTION` | Laboratory normative upgrade (Annex B). Zero RTL. |
| `v3.3.0-rc1`| 2026-09-25 15:21:20 +0300 | Version DOI (under Concept `10.5281/zenodo.22838473`) | **VERIFIED IN GIT** (`f919806`) | `UNVERIFIED — PENDING EXTERNAL METADATA INSPECTION` | Release candidate draft. Zero RTL. |
| `v3.3.0-rc2`| 2026-09-25 18:54:14 +0300 | Version DOI (under Concept `10.5281/zenodo.22838473`) | **VERIFIED IN GIT** (`1935b93`) | `UNVERIFIED — PENDING EXTERNAL METADATA INSPECTION` | Canonical 14-document specification manifest. **Zero RTL.** |
| `v4.0.0-rc1`| Not yet tagged | None (Future Release) | **NOT RELEASED / DRAFT** | **NO ZENODO RECORD EXISTS** | Will include synthesizable RTL (`rtl/*.sv`) once approved and archived. |

> **Audit Finding:** The local repository contains references to Concept DOI `10.5281/zenodo.22838473` in markdown headers, but does not store the specific Version DOI keys assigned by Zenodo. The remote Zenodo API/web metadata must be inspected directly prior to citing specific Version DOIs in formal legal submissions. Until inspected, Version DOI details are marked **`UNVERIFIED`**.

---

## 4. Item 3: PCB & Hardware File Search Scope & Precise Findings

### 4.1 Search Parameters & Methodology
To verify whether physical printed circuit board (PCB) design files, CAD schematics, or Gerber manufacturing archives ever existed in the repository, the following exhaustive queries were executed against the entire local Git repository:

1. **Query 1 (Targeted Extension History):**
   ```powershell
   git -C "C:\Users\ajiba\rentalais\zero-cloud-hardware-architecture" log --all --full-history -- "**.kicad*" "**.gbr*" "**.gerber*" "**.pcb*" "**.sch*" "**.brd*"
   ```
   - **Scope:** Every reachable commit across all local and remote-tracking branches (`--all`), including unparented or superseded branches (`--full-history`).
   - **Result:** **Exit Code 0 — Exactly 0 commits returned.**
2. **Query 2 (General CAD Name Regex Across All Commits):**
   ```powershell
   git -C "C:\Users\ajiba\rentalais\zero-cloud-hardware-architecture" log --all --name-only --oneline | Select-String -Pattern "\.(gbr|gerber|kicad|sch|brd|pcb|step|stp|dxf|dwg)"
   ```
   - **Scope:** Every file path ever added, modified, renamed, or deleted in any commit from repository creation (`4b62db8`) to head commit (`7982771`).
   - **Result:** **Exit Code 0 — Exactly 0 matching lines.**

### 4.2 Factual Finding & Qualified Scope Statement
- **Factual Determination:** **No PCB design files, electrical schematics, CAD layouts, or Gerber manufacturing archives were found in the inspected Git repository history across any branch, tag, or commit.**
- **Proper Scope Boundary:** This finding proves conclusively that **within this public Git repository, no physical board artwork has ever been published**. It does NOT prove that FreeCuli or its founders have "never disclosed PCB designs anywhere in the world" (e.g., in private emails, third-party repositories, conference slide decks, or printed brochures).
- **Remediation Requirement:** All v4 documents must state accurately:
  > *"Reference PCB layouts and Gerber manufacturing files are not published in this repository and are not currently part of the public open-hardware release."*

---

## 5. Item 4: Copyright Ownership & Attestation Protocol

In compliance with the Auditor's instructions, all matters of copyright ownership, chain of title, third-party code absence, and institutional grant conditions are classified as **`UNVERIFIED — PENDING OWNER ATTESTATION`** until formal written attestations and supporting evidence are provided.

### 5.1 Ownership and Development History Record
> **Ownership and Development History:** The founder represents that they are the sole developer and rights holder of ZC-CORE. The reviewed Git history is consistent with the founder's representation of sole development. This record documents the founder's representation and its comparison against the reviewed technical records.

- **Reviewed Git History:**
  A complete git log query of all commits touching `rtl/` (`eb3ed5a`, `8bbda51`, `a8d2a71`, `e70a062`, `bcb7c43`, `e3e806b`, `1f9934d`, `e062a09`, `1a8617b`, `5950933`, `9e53025`, `ffe7881`, `dae1369`, `fee02d1`, `11930f7`, `1af8021`, `7ca8b78`) indicates that 100% of commits were authored by `yemekyarismasi <ajibaoytun@gmail.com>`. This technical history is consistent with the founder's representation of sole development.
- **Technical and Legal Characterization:**
  No evidence of third-party code was identified in the reviewed files and Git history. This technical record documents the founder's representation and its comparison against the reviewed technical records; it is not characterized as an independent legal title deed, nor as absolute proof of the absence of third-party code across all unexamined contexts.

---

## 6. Item 5: Technical Disclosure Sufficiency (PHOSITA Calibration)

### 6.1 Calibration Against Technical Claim Types
A technical disclosure's sufficiency (enablement under 35 U.S.C. § 112 / EPC Art. 83) is evaluated based on whether a PHOSITA can implement the claimed invention without "undue experimentation." The required detail varies by subject matter:

| Claim Domain | Current Repository Disclosures | Supporting Verification Artifacts | Evaluated Enablement Level | Remaining Technical Gap for Prior Art |
| :--- | :--- | :--- | :---: | :--- |
| **System-Level Air-Gap & Isolation Invariants** (M1–M10) | Comprehensive functional specification in `zero-cloud-core-methodology-invariants.md` and `zero-cloud-core-scope-boundary.md`. | CTS tests FC-ZC-001..010; Attack Taxonomy AT-001..010. | **HIGH (System Architecture)** | None for system-level claims. Sufficient for PHOSITA to understand functional air-gap. |
| **SPI Flash Inbound Firewall** (`zc_spi_flash_firewall.sv`) | Complete synthesizable SystemVerilog RTL, port lists, FSM states (`UPD_IDLE`, `UPD_UNSYNC_RESET`), status reconciliation logic. | Formal proofs `fv/zc_spi_sva.sv` (`F-SPI-01..04`); simulation bench `tb/tb_zc_spi.sv`. | **HIGH (RTL Implementation)** | Waveform timing diagram showing MISO byte polling would further strengthen examiner comprehension. |
| **OBI Subordinate Decoupling Bridge** (`zc_obi_subordinate_bridge.sv`) | Synthesizable RTL, 10-bit watchdog counter, request clamping, `ST_TRAP` synthetic error generation. | Formal proof `fv/zc_obi_sva.sv`; simulation test `tb/tb_zc_obi.sv` (1024-cycle drain). | **HIGH (RTL Implementation)** | Explicit state transition graph illustrating deadlock recovery. |
| **AON OTP Anti-Rollback Controller** (`zc_aon_post_auth_ctrl.sv`) | Synthesizable RTL, 4-phase DAI handshake, persistent lock across warm resets, Hsiao (22,16) matrix. | SVA formal proofs (`F-OTP-01..06`); regression model T4.1; weight histogram tests T2.1..T2.5. | **VERY HIGH (Silicon/RTL)** | Complete syndrome decoding equations documented in text. |
| **SoC Crossbar DMA Firewall** | Conceptual description in `docs/architecture/zc-core-security-profiles.md`. | SVA file `fv/zc_m7_m8_ni_sva.sv` is declared `UNVERIFIED / BLOCKED`. | **LOW (Conceptual Only)** | Synthesizable RTL not written. Cannot claim enabling prior art over SoC DMA firewalling. |
| **Analog / Side-Channel Mutual Information Bounds** | Target inequality $\mathcal{I}(\text{Sensor}; \text{Egress}) \le \epsilon$ stated in Annex B. | No empirical measurement data or physical test fixture in repo. | **LOW (Research Target)** | Unverified target. Cannot defeat patents claiming specific analog filter hardware. |

### 6.2 Clarification Concerning IPC/CPC Codes & Diagrams
- **IPC/CPC Codes (`H04L 9/00`, `G06F 21/50` etc.):** Adding patent classification codes to repository metadata helps search engines and patent examiners *discover* FreeCuli disclosures. **It does NOT create legal rights, does NOT constitute patent protection, and does NOT guarantee that an examiner will reject a third-party patent.**
- **Diagrams & Waveforms:** Illustrative waveforms help demonstrate that timing relationships were genuinely conceived and enabled, reducing examiner skepticism. They are **evidentiary aids**, not independent legal protections.

---

## 7. Item 6: Licensing & Governance Separation

### 7.1 Effective vs Draft Governance Separation

```
+---------------------------------------------------------------------------------------------------+
|                                 GOVERNANCE STATUS DEMARCATION                                     |
+---------------------------------------------------------------------------------------------------+
|  [ EFFECTIVE / HISTORICAL BASELINE ]                                                              |
|  - Root LICENSE (SPDX composite identifier, v3.3.0-rc2 text).                                     |
|  - zero-cloud-dual-licensing.md (v3.3.0-rc2 text).                                                |
|  - zero-cloud-core-brand-and-trademark-policy.md (v3.3.0-rc2 text).                              |
|  - ZERO-CLOUD-RELEASE-MANIFEST.md (Cryptographic seal of 14 v3.3.0-rc2 markdown documents).      |
|  --> STATUS: FROZEN, UNCHANGED, 100% PRESERVED. DO NOT EDIT.                                      |
|                                                                                                   |
|  [ PROPOSED DRAFT RFC SUCCESSORS ]                                                                |
|  - docs/rfc/ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md (Draft RFC-ZC-CORE-0002).                     |
|  - docs/rfc/ZC-CORE-V4-TRADEMARK-AND-CONFORMANCE-RFC.md (Draft RFC-ZC-CORE-0003).                 |
|  - docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md (Draft RFC-ZC-CORE-0004).                              |
|  - evidence/legal/V4_*.md (Informational audit baselines).                                        |
|  --> STATUS: DRAFT PROPOSALS ONLY. NOT RATIFIED. NOT LEGALLY EFFECTIVE.                           |
+---------------------------------------------------------------------------------------------------+
```

### 7.2 Exact Clauses Identified for Review Prior to v4.0.0 Ratification

1. **`LICENSE` Lines 39–41:**
   *Clause:* *"Manufacturers seeking to build compliant Zero-Cloud appliances without releasing proprietary trade secrets... MUST execute a Commercial Exemption Agreement with FreeCuli prior to commercial distribution."*
   *Target Remediation:* Replace in v4 successor with Clean-Room Freedom Guarantee.
2. **`zero-cloud-dual-licensing.md` Lines 14–23:**
   *Clause:* Restricting Open Source Path to academics/startups and demanding commercial entities obtain Route B licenses.
   *Target Remediation:* Replace in v4 successor with non-discriminatory Route A (open to commercial entities complying with reciprocity) and voluntary Route B.
3. **`zero-cloud-core-brand-and-trademark-policy.md` Line 44:**
   *Clause:* Bundling CERN-OHL-S copyright exemption with "FreeCuli Certified" trademark license.
   *Target Remediation:* Decouple copyright from trademark in v4 successor.

---

## 8. Item 7: Regression Evidence & Execution Transparency

### 8.1 Exact Execution Details
- **Execution Date & Time:** 2026-10-21 01:39:11 +0300
- **Working Directory:** `C:\Users\ajiba\rentalais\zero-cloud-hardware-architecture`
- **Shell / Runtime:** PowerShell 5.1.19041.7802 on Microsoft Windows 10/11
- **Git Version:** `git version 2.54.0.windows.1`
- **Exact Command Invoked:**
  ```powershell
  Set-Location "C:\Users\ajiba\rentalais\zero-cloud-hardware-architecture"; powershell -ExecutionPolicy Bypass -File .\scripts\verify_gate_b_rev28d.ps1
  ```
- **Exit Status Code:** `0` (Success).
- **Target Repository Commit:** `798277149ab59cfb8824f7128a85cc9eb1515b61` (Tree clean).

### 8.2 Breakdown of All 20 Verified Assertions

```text
======================================================================
 FREECULI ZC-CORE GATE B REV. 28D VERIFICATION SUITE (POWERSHELL)
======================================================================
[PASS] T1.1_HSIAO_DMIN_4 : All 22 columns of H_6x22 have no 1-, 2-, or 3-column XOR sum equal to 0 (strict SECDED d_min=4)
[PASS] T1.2_HSIAO_EXPLICIT_EQ_MATCH : Explicit parity equations p[0]..p[5] in rtl/zc_otp_pkg.sv identically match H_data columns
[PASS] T2.1_OTP_SEAL_ZERO_COLLISIONS : Collisions across 4,080 (k,v) pairs: A==B:0, A==SVN:0, B==SVN:0
[PASS] T2.2_OTP_CODEWORD_WEIGHT_BOUNDS : 22-bit codeword Hamming weight range is [8..14] (w_H,min = 8)
[PASS] T2.3_OTP_SVN_HISTOGRAM : WORD_SVN histogram: w=8:128, w=10:1904, w=12:1920, w=14:128
[PASS] T2.4_OTP_SEAL_A_HISTOGRAM : WORD_COMMIT_A histogram: w=8:127, w=10:1914, w=12:1911, w=14:128
[PASS] T2.5_OTP_SEAL_B_HISTOGRAM : WORD_COMMIT_B histogram: w=8:128, w=10:1913, w=12:1911, w=14:128
[PASS] T3.1_RTL_OTP_SEAL_CONSTANTS : rtl/zc_otp_pkg.sv uses final Rev. 28B mask constants 8'h5A and 8'h3C
[PASS] T3.2_RTL_OTP_4PHASE_SIGNALS : rtl/zc_aon_post_auth_ctrl.sv implements all 4 distinct DAI handshake phase signals (Rev. 28C R28B-02)
[PASS] T3.3_RTL_OTP_RECOVERY_AND_NORMAL_DONE : rtl/zc_aon_post_auth_ctrl.sv separates normal and recovery completion and cleans grants on AUTH_SESSION_DONE (Rev. 28C R28B-01)
[PASS] T3.4_RTL_SPI_3LAYER_SEPARATION : rtl/zc_spi_flash_firewall.sv separates primary frame end, secondary /CS acceptance, and ROM image verification (Rev. 28B)
[PASS] T3.5_RTL_OBI_UNIFIED_ORPHAN_WDOG : rtl/zc_obi_subordinate_bridge.sv uses unified orphan_active_w watchdog progression (Rev. 28C R28B-03)
[PASS] T3.6_RTL_OBI_ST_TRAP_SYNTH_ERR : rtl/zc_obi_subordinate_bridge.sv preserves ST_TRAP synthetic error response when subsys_dead_locked_q == 1'b1 (Rev. 28D)
[PASS] T3.7_SVA_CANONICAL_BIND_DECLARATIONS : All module-bound SVA files (fv/zc_otp_sva.sv, fv/zc_spi_sva.sv, fv/zc_obi_sva.sv) contain canonical SystemVerilog bind declarations
[PASS] T3.8_RTL_OBI_WARM_RESET_GATING_GCR01 : rtl/zc_obi_subordinate_bridge.sv and fv/zc_obi_sva.sv gate host_req_ready_o and periph_phys_req_o with rst_sys_ni (GCR-01)
[PASS] T4.1_OTP_4PHASE_FSM_STRUCTURAL_REF_MODEL : Auxiliary PowerShell Behavioral FSM Reference Model (Normal 0->1->2 and Recovery 2-only state progression)
[PASS] T4.2_SPI_3LAYER_RECONCILE_AND_VERIF_GATE : 04h WRDI stays in UPD_UNSYNC_RESET, fresh 05h RDSR1(2'b00) enters UPD_IDLE, and bank_b_commit_ready_o requires rom_img_verif_valid_i
[PASS] T4.3_OBI_WDOG_1024_AND_ST_TRAP_SYNTH_ERR : Orphan watchdog reaches 1023->subsys_dead_locked_q=1 under continuous !rst_sys_ni, and ST_TRAP returns 1-cycle synthetic error (rvalid=1, err=1, rdata=0) with periph_phys_req_o=0
[PASS] T4.4_OBI_GCR01_WARM_RESET_BLOCKS_PHYS_REQ : Under rst_sys_ni=0, state_q=ST_IDLE, host_req_i=1, periph_phys_gnt_i=1, phys_req_active_q=0 -> periph_phys_req_o=0 and host_req_ready_o=0
[PASS] T4.5_RTL_NON_FORMAL_SOURCE_EQUIV : rtl/zc_aon_post_auth_ctrl.sv without FORMAL has identical normalized source text and SHA-256 to e57d16d (source-level regression equivalence)
----------------------------------------------------------------------
 SUMMARY: PASS=20, FAIL=0
 NOTE: Local HDL compilation/simulation/formal proof is [BLOCKED / UNVERIFIED]
       because no SystemVerilog simulator/formal tool (verilator/iverilog/sby)
       is installed on this host.
======================================================================
```

### 8.3 Exact Technical Scope & Limits of the Regression Result
- **What the Test Confirms:**
  1. *Mathematical Proof Verification:* Confirms that the Hsiao (22,16) parity check matrix $H_{6 \times 22}$ satisfies $d_{\min}=4$ SECDED bounds (no linear combination of 1, 2, or 3 columns XORs to zero).
  2. *Cryptographic Mask Verification:* Proves zero collisions across all 4,080 OTP seal pairs ($A \neq B \neq \text{SVN}$).
  3. *Structural Interface Integrity:* Verifies that port names, FSM phase signals, warm-reset gating expressions, and SVA bind declarations match architectural contracts.
  4. *Behavioral Equivalence:* Verifies that `zc_aon_post_auth_ctrl.sv` source matches commit `e57d16d`.
- **What the Test DOES NOT Establish:**
  1. *Not a Formal Proof:* It does not run SymbiYosys or Boolector/Z3; formal induction and bounded model checking remain verified under Gate C log records, not re-proven locally.
  2. *Not Physical Silicon Verification:* It does not prove tapeout readiness, clock tree synthesis, or analog side-channel immunity.
  3. *Not Legal Validation:* Passing 20 regression tests does not validate or ratify contractual licensing terms.

---

## 9. Item 8: Deliverable Integrity & Checksums

The following table preserves previously recorded audit-document metadata as a historical reference. These values are not asserted to represent the current filesystem state or an independently verified initial delivery baseline. Current integrity verification is performed against `evidence/audit/SHA256SUMS.txt`.

| Relative Document Path | Byte Length | SHA-256 Cryptographic Checksum | Local Working Tree Status | Git / Archival Directive |
| :--- | :---: | :---: | :---: | :---: |
| `evidence/audit/V4_STRATEGIC_IP_INDEPENDENT_AUDIT.md` | 20,495 | `FFAA88F817138471E417ACBA3E0ACC3D393AF9B9B2FAC6D2BEDB156DA78BE21E` | Local Untracked / Stand Down | Local only. Do not push, merge, or overwrite. |
| `evidence/audit/V4_DEFENSIVE_PUBLICATION_HARDENING_PLAN.md` | 9,177 | `B82108C6BA3AC8412FF79F76EF4DA48A64913F9D93065E571160CF60B619DD3A` | Local Untracked / Stand Down | Local only. Do not push, merge, or overwrite. |
| `evidence/audit/V4_LICENSE_AND_RIGHTS_RISK_REGISTER.md` | 10,436 | `8F67FB795FE017BA9205832E85D371EE268E274035A43A8EF2996946AB464A0A` | Local Untracked / Stand Down | Local only. Do not push, merge, or overwrite. |
| `evidence/audit/V4_NORMATIVE_CONFLICT_MATRIX.md` | 8,612 | `DB54C36C302EE1C842DAD28EE9AC97033D8A1AF1927DE69884E8FD91E8A22568` | Local Untracked / Stand Down | Local only. Do not push, merge, or overwrite. |
| `evidence/audit/V4_IMPLEMENTATION_AND_RELEASE_GATE_PLAN.md` | 12,587 | `7E7A0D3C4A6B06BDEB43B8186420F5E1D368F688F80936CB8FFF05D01D2C60CE` | Local Untracked / Stand Down | Local only. Do not push, merge, or overwrite. |
| `evidence/audit/V4_AUDIT_EVIDENCE_CLARIFICATION_ADDENDUM.md` | (This Document) | Verified via external manifest `evidence/audit/SHA256SUMS.txt` | Local Untracked / Stand Down | Local only. Do not push, merge, or overwrite. |

---

## 10. Summary of Unresolved Questions & Minimum Zero-Budget Next Steps

### 10.1 Status of Owner Representations & Remaining Inquiries
1. **Ownership and Development History (ATTEST-01):** The founder represents that they are the sole developer and rights holder of ZC-CORE. The reviewed Git history is consistent with the founder's representation of sole development. This record documents the founder's representation and its comparison against the reviewed technical records.
2. **Brand and Source Identification (ATTEST-02):** The brand marks `FreeCuli` and `ZC-CORE` serve as source identifiers under common-law ("™") principles, proprietary to the founder.
3. **Remote Zenodo Inspection (Open Inquiry):** Verification of exact historical Version DOIs for `v3.2.0`, `v3.2.1`, and `v3.3.0-rc2` under Concept DOI `10.5281/zenodo.22838473`.

### 10.2 Recommended Minimum Zero-Budget Next Steps
1. **Remain at Gate 0:** Maintain current `READ-ONLY / STAND DOWN` state; do not alter root normative documents.
2. **Review Clarified Audit Texts:** Review the reconciled evidence addendum and risk register incorporating the founder's factual representation.
3. **Draft Enablement Diagrams in RFCs:** Add ASCII timing waveforms for SPI status reconciliation and OBI state transition tables into draft `docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md`.
4. **Prepare for Specialist Review (Gate 2):** Submit the clarified audit package to qualified IP legal counsel for contractual verification before advancing to normative migration.

---
*End of V4_AUDIT_EVIDENCE_CLARIFICATION_ADDENDUM.md — Prepared for FreeCuli Architecture & Governance Review.*
