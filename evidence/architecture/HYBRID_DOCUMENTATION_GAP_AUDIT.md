# FREECULI ZC-CORE — Hybrid Architecture Documentation Gap Audit Report

**Document ID:** ZC-CORE-EVIDENCE-ARCH-GAP-AUDIT-01
**Date:** 20 October 2026
**Revision:** 1.0.0 (Governance Review Prior to Zenodo Defensive Publication Preflight)
**Target Repository:** `FreeCuli/zero-cloud-hardware-architecture`
**Working Branch:** `gate-c/formal-scope-audit`
**Governance Status (Historical Review):** **Gate C: PARTIAL / QUALIFIED** | **Gate D: UNVERIFIED** | **DO NOT MERGE** | **RELEASE BLOCKED (Historical Analysis)**

---

## 1. Executive Summary and Purpose

This report conducts a systematic gap analysis of the existing architectural, methodological, normative, and defensive publication documentation in the FreeCuli ZC-CORE GitHub repository against the project's **STRICT and HYBRID operational profiles** and the **hardware blocks verified in Gate C (SPI Flash Firewall, OBI Subordinate Bridge, AON OTP Controller)**.

### Core Problem and Demarcation:
1. **What Does the ZC-CORE Architecture Define?**
   STRICT and HYBRID profiles, information flow policies, Trust Boundaries, separation between the Network Co-Processor and the Host MCU/NPU, inbound OTA update verification mechanisms, and permitted semantic telemetry behaviors.
2. **What Did Gate C Actually Verify?**
   Strictly the local logical, inductive ($t=20$), and cycle-accurate simulation properties of specific open-source digital RTL IP blocks (`zc_spi_flash_firewall.sv`, `zc_obi_subordinate_bridge.sv`, `zc_aon_post_auth_ctrl.sv`) across 33 claims (19 PROVEN, 4 SIMULATED, 4 BOUNDED, 2 BLOCKED, 4 UNVERIFIED).

Unless these two domains are clearly demarcated, a defensive publication on Zenodo could create a **misleading impression before readers or patent examiners that the hybrid architecture is fully implemented and certified at the physical, analog, and full-SoC levels**.

This analysis identifies the normative and architectural gaps that must be resolved prior to Zenodo publication without retroactively altering the historical Gate C closure decision (`PARTIAL / QUALIFIED`).

---

## 2. Read-Only Documentation Inventory (14 Baseline Documents)

| Document | Baseline Version & Status | STRICT/HYBRID Profile Definition | Inbound OTA & Telemetry Scope | Raw Sensor Isolation Boundary | M1–M10 Compatibility | Gate C Evidence Link | Assessment |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **`README.md`** | v3.3.0-rc2 (Sept 2026) | **NONE** (Focuses solely on unidirectional air-gap/optocoupler) | **NONE** | Physical air-gap and power cutoff defined | M1–M10 summarized without profile split | No reference to RTL blocks | **Incomplete & Legacy:** STRICT/HYBRID distinction needed. |
| **`Zero-Cloud-Smart-Home-Edge-AI-Architecture.md`** | v3.1.0 Obsolete Stub | **NONE** | **NONE** | None (4-line redirect stub) | N/A | None | **Legacy Pointer:** Preserve as archival stub. |
| **`zero-cloud-hardware-reference-architecture.md`** | v3.3.0-rc2 (v3.2.1 locks) | **NONE** (Classic unidirectional NPU->Opto->MCU model) | Conceptual OTA in §2.7; no bus definition | M1/M8 absolute power cutoff/zeroization | Compatible with M1–M10 but STRICT-focused | Gate C SPI/OBI/OTP blocks absent | **Critical Gap:** Hybrid interconnect and RTL blocks needed. |
| **`zero-cloud-core-methodology-invariants.md`** | v3.3.0-rc2 | **NONE** (Single-sentence inbound OTA exception in M3) | Single-sentence exception in M3; no telemetry rules | M1, M7, M8 absolute | Core DNA; assumes STRICT | No reference to Gate C miter properties | **Normative Gap:** Clarify M3 telemetry and profile split. |
| **`zero-cloud-core-scope-boundary.md`** | v3.3.0-rc2 | **NONE** (Only mentions "Zero-Cloud Telemetry / OTA" term) | General telemetry permission in §1.20; no rate/allowlist bounds | 4-class data taxonomy defined | Compatible | RTL boundaries undefined | **Incomplete Definition:** Define permitted and prohibited telemetry. |
| **`zero-cloud-core-conformance-test-specification.md`** | v3.3.0-rc2 (28 KB) | **NONE** (Has C1/C2/C3 lab assurance levels, no profile split) | Conceptual update test in FC-ZC-007 | Annex B TVLA and MI < 10^-4 bound | Compatible | Unlinked to Gate C RTL testbenches | **Mismatch:** CTS focuses on PCB/lab, omits RTL tier. |
| **`zero-cloud-core-defensive-publication.md`** | v3.3.0-rc2 | **NONE** (Claims ZC-CORE-001..007 focus on unidirectional opto) | ZC-CORE-003 covers unidirectional transfer | ZC-CORE-005 absolute zeroization | Compatible | Gate C hardware mechanisms (SPI/OBI/OTP) unclaimed | **Strategic Gap:** New RTL-level mechanisms not claimed. |
| **`ZERO-CLOUD-RELEASE-MANIFEST.md`** | v3.3.0-rc2 (2026-09-24) | **NONE** | **NONE** | SHA-256 hashes of 14 docs locked | Compatible | Gate C files absent from manifest | **Locked:** Does not include Gate C or Hybrid files. |
| **`zero-cloud-core-attack-taxonomy.md`** | v3.3.0-rc2 | **NONE** | T8 (Malicious OTA) and AT-008/AT-010 defined | AT-001..AT-010 comprehensive | Compatible | Hybrid covert-channel and side-channel risks missing | **Needs Expansion:** Add hybrid telemetry leakage vectors. |
| **`zero-cloud-core-implementation-coverage.md`** | v3.3.0-rc2 | **NONE** | Table lists general optical/FPGA/ASIC classes | M1–M10 mapping present | Compatible | RTL IP block tier absent | **Incomplete:** Add hybrid interconnect classes. |
| **`zero-cloud-core-conformance-evidence-matrix.md`** | v3.3.0-rc2 | **NONE** | FC-ZC test evidence listed | Physical laboratory evidence | Compatible | Gate C simulation and formal evidence missing | **Incomplete:** Separate physical evidence from formal proofs. |
| **`docs/gate-b/ZC-CORE-GATE-B-REV28D-ARCHITECTURE-CONTRACT.md`** | Rev. 28D (Draft) | Partial (RTL block contract defined, no profile name) | SPI, OBI, OTP contracts defined | M7/M8 miter target present | Compatible | Design baseline of Gate C RTL files | **Technical Bridge:** Contains architectural contract for RTL blocks. |
| **`evidence/gate-c/CONSOLIDATED_NORMATIVE_EVIDENCE_MATRIX.md`** | Rev. 2.0.0 (Run #45) | Partial (33 claims defined, no profile split) | SPI, OBI, OTP formal/sim proofs complete | M7/M8 BLOCKED, physical UNVERIFIED | Fully compatible | Direct technical evidence of Gate C (`eb3ed5a`) | **Completed:** Documents defined RTL scope only. |
| **`evidence/gate-c/GATE_C_FINAL_AUDIT_CLOSURE.md`** | Rev. 1.0.0 (`afde531`) | Partial (Gate C boundaries explicitly declared) | Scope limits and Gate D deferral explicit | Fully demarcated | Fully compatible | Final independent acceptance record of Gate C | **Completed:** Scope and governance locked. |

---

## 3. Systematic Gap Analysis Matrix (Findings Matrix)

| File | Baseline Statement | Identified Gap or Conflict | Recommended Remediation | Normative Impact | Evidence Status | Priority |
| :--- | :--- | :--- | :--- | :--- | :---: | :---: |
| **`README.md`** | *"By enforcing Physical Data Diodes, Trust Boundaries... optocouplers, FPGA, ASICs"* | Describes only the strict unidirectional air-gap model; makes no mention of STRICT and HYBRID profiles. | Introduce STRICT (full air-gap/zero-telemetry) and HYBRID (bounded telemetry/hardware firewall) profiles. | Informative | Gate C RTL Evidence Available | **P1 (High)** |
| **`zero-cloud-hardware-reference-architecture.md`** | Section 2.2: *"The transmission cable MUST be isolated using a physical data diode (e.g., an Optocoupler)"* | Controlled interconnect blocks developed and verified in Gate C (SPI Flash Firewall, OBI Subordinate Bridge, AON OTP Controller) are absent from the architecture. | Add Section 2.10 covering ZC-CORE Secure Interconnect and Hardware Firewall Architecture (SPI, OBI, OTP) and separate STRICT and HYBRID topologies. | Normative (Architecture Spec) | Proven at RTL Level (Gate C) / Physically UNVERIFIED | **P0 (Critical)** |
| **`zero-cloud-hardware-reference-architecture.md`** | Section 3: *Data Flow Schematic (Mermaid)* | Schematic shows only `NPU -> Opto -> Main MCU` flow. Secure inbound update (OTA) and bounded status flows are omitted. | Update schematic to model (a) STRICT unidirectional flow and (b) HYBRID bounded OBI/SPI flow as distinct sub-graphs. | Architectural | Compatible with Gate C Models | **P1 (High)** |
| **`zero-cloud-core-methodology-invariants.md`** | M3: *"Authenticated control-plane and firmware-update traffic MAY enter the Trusted Domain..."* | M3 does not explicitly address outbound telemetry; assumes outbound flow is strictly actuator commands. Permitted hybrid telemetry bounds are undefined. | Preserve M3 while defining normative requirements for STRICT and HYBRID profiles governing M3 enforcement. | Normative Stricture | Analytical / Methodological | **P0 (Critical)** |
| **`zero-cloud-core-scope-boundary.md`** | Section 1.20: *"Zero-Cloud Telemetry / OTA... provided such channels are cryptographically bound and strictly comply with M3"* | "Telemetry" is overly broad; lacks allowlist, rate-limiting, minimum entropy, and covert-channel constraints. | Add Permitted Hybrid Telemetry Specification: telemetry payload must never contain raw sensor data, only verified system health/statistical payloads. | Normative Policy | Outside Gate C Scope (Gate D) | **P1 (High)** |
| **`zero-cloud-core-conformance-test-specification.md`** | Section 2: *"For ZC-CORE-C1/C2 profiles... MI_upper_bound is fixed at 10^-4 bits"* | C1/C2/C3 profiles are TVLA/MI sample-count assurance levels; no test procedure (FC-ZC-XXX) tests whether a device is STRICT or HYBRID. | Add two test procedures to CTS: (1) `FC-ZC-017: STRICT Profile Conformance (Zero Outbound Telemetry)`, (2) `FC-ZC-018: HYBRID Profile Telemetry Conformance & Covert Channel Bounding`. | Normative Test Specification | UNVERIFIED (Laboratory Test) | **P1 (High)** |
| **`zero-cloud-core-defensive-publication.md`** | Claim Family ZC-CORE-001..007 | Existing defensive claims cover only optocoupler, power cutoff, and air-gap combinations. The 3-layer SPI Flash Firewall and OBI subordinate orphan drain architecture from Gate C are absent. | Add Claim Family `ZC-CORE-008: Hardware-Enforced Bus Isolation & Secure Inbound Update Firewall` (SPI Firewall, OBI Orphan Drain, 4-Phase DAI OTP Handshake). | Defensive Prior-Art | Formally PROVEN / SIMULATED in Gate C | **P0 (Critical)** |
| **`ZERO-CLOUD-RELEASE-MANIFEST.md`** | Full Document (v3.3.0-rc2 Hashes) | The 24 September 2026 v3.3.0-rc2 hash set does not include Gate C evidence, formal models, or hybrid architecture documents. | Preserve v3.3.0-rc2 manifest as historical record and generate updated v4.0.0-rc2 release manifest covering canonical documents and RTL files. | Governance Integrity | Cryptographic Hash | **P2 (Medium)** |
| **`zero-cloud-core-attack-taxonomy.md`** | AT-008 & AT-010 | Covert-channel exfiltration over hybrid telemetry, timing side-channel modulation, and flash wear-out / desynchronization attacks over OTA are missing. | Add threat classes `AT-011: Telemetry Covert Channel Exfiltration` and `AT-012: Inbound Update Desynchronization / Flash Denial of Service`. | Informative Taxonomy | Analytical | **P2 (Medium)** |

---

## 4. Deep-Dive Analysis of Architectural Gaps Across 8 Dimensions

### 4.1 STRICT vs. HYBRID Information Flow Separation
- **Baseline State:** Legacy documents imply all ZC-CORE devices follow a single monolithic rule ("Sensor data never leaves").
- **Gap:** While raw sensor non-egress holds universally, the information flow distinction between *sending zero outbound telemetry* (**STRICT**) and *sending hardware-policed statistical/health telemetry across the trust boundary* (**HYBRID**) was not codified.
- **Architectural Resolution:**
  - **STRICT Profile:** Zero outbound telemetry even if a network module exists. Strictly local physical actuation and unidirectional hardware diode.
  - **HYBRID Profile:** Outbound telemetry is subject to hardware-enforced allowlisting and rate-limiting; raw sensor data or high-dimensional embeddings are blocked at the boundary.

### 4.2 Network Co-Processor vs. Host Trust Boundary
- **Baseline State:** `zero-cloud-hardware-reference-architecture.md` depicts the "Wi-Fi Module" and "Main MCU" inside a single shared box.
- **Gap:** If the network processor (e.g., ESP32, nRF5340 network core) is compromised, how the SPI/OBI bus between the Host MCU and NPU prevents lateral movement — and the exact role of the Gate C RTL blocks (SPI Firewall, OBI Bridge) — was not explicitly mapped.
- **Architectural Resolution:** Classify the Network Co-Processor as an Untrusted External Interface and bound the interconnect to the Host MCU/NPU via `zc_obi_subordinate_bridge` and `zc_spi_flash_firewall` hardware barriers.

### 4.3 Actual Scope of Gate C Hardware Blocks vs. System Claims
- **Baseline State:** Gate C closure reports list 33 verified claims.
- **Gap:** An external reader might assume those 33 claims cover the entire hybrid SoC and physical layer.
- **Reality:** Gate C proved local protocol behaviors of 3 standalone digital IP blocks. Full-SoC non-interference (M7/M8), analog OTP physics, and physical timing belong to **Gate D**.
- **Architectural Resolution:** Explicitly scope the 3 IP blocks under "Gate C Verified Subsystem" and reference system-level/physical claims as deferred to Gate D.

### 4.4 Telemetry Allowlisting, Rate-Limiting, and Covert-Channel Risks
- **Baseline State:** `zero-cloud-core-scope-boundary.md` permits telemetry conceptually without specifying hardware policing rules.
- **Gap:** A compromised enclave could modulate inference timing or packet lengths to exfiltrate audio/video features (covert channel).
- **Architectural Resolution:** Mandate deterministic packet sizes, fixed-interval transmission schedules, and strict schema field constraints as normative requirements for hybrid telemetry.

### 4.5 Inbound OTA Verification, Anti-Rollback, and Key Lifecycle
- **Baseline State:** M6 mandates Secure Boot; `zc_aon_post_auth_ctrl.sv` implements SVN (Security Version Number) commit logic.
- **Gap:** Where signature verification of the external Flash image occurs (Boot ROM), safe fallback upon interrupted updates (A/B bank recovery), and key revocation were not unified in the architectural prose.
- **Architectural Resolution:** Document the relationship between `bank_b_commit_ready_o` in `zc_spi_flash_firewall` and `rom_img_verif_valid_i` with an explicit state flow.

### 4.6 Control-Plane Bypass Paths (DMA, Debug, Reset, Clock)
- **Baseline State:** M5 and AT-007 state control-plane isolation in general terms.
- **Gap:** Hardware protections implemented in the OBI Subordinate Bridge — such as `rst_sys_ni` warm reset gating (`F-OBI-07`) and `ST_TRAP` synthetic error generation — were absent from the reference architecture document.
- **Architectural Resolution:** Incorporate OBI bridge warm reset gating and orphan transaction drain timeout into the control-plane specification.

### 4.7 Absence of PCB, FPGA, and Analog Hardware Evidence
- **Baseline State:** Conformance documentation emphasizes physical laboratory evidence (CTS).
- **Gap:** Physical PCB or silicon laboratory testing has not yet been performed; current repository evidence consists of digital RTL simulations and formal SMT proofs.
- **Architectural Resolution:** Clearly separate "Stage 1: Formal RTL Verification (Completed — Gate C)" from "Stage 2: Physical Hardware / Silicon Validation (Deferred — Gate D)".

### 4.8 Versioning, Licensing, and Intellectual Property (IP) Implications
- **Baseline State:** Legacy documents were tagged `v3.3.0-rc2`.
- **Gap:** Formal models and RTL blocks developed in Gate C were not part of `v3.3.0-rc2`.
- **Architectural Resolution:** Transition the hybrid architecture and RTL reference blocks into the `v4.0.0-rc2` release candidate architecture with explicit Gate C / Gate D boundary disclosures.

---

## 5. Evaluation of Candidate New Documents

To prevent unnecessary documentation sprawl, four candidate documents were evaluated:

| Candidate Document | Required? | Recommended Approach | Rationale |
| :--- | :---: | :--- | :--- |
| **`zc-core-security-profiles.md`** | **YES (Mandatory)** | Create as a standalone architectural specification. | Provides a clean home to define STRICT and HYBRID security objectives, data flow rules, and permitted bounds without distorting M1–M10. |
| **`zc-core-information-flow-policy.md`** | **NO (Consolidate)** | Integrate directly into `zero-cloud-core-scope-boundary.md` and the hybrid suite. | Enriching existing scope boundary documentation with telemetry and OTA policies simplifies governance. |
| **`zc-core-hybrid-interconnect.md`** | **YES (Mandatory)** | Create as a technical reference architecture specification. | Specifies how the Gate C SPI Firewall, OBI Bridge, and AON OTP Controller interconnect with the CPU/NPU. |
| **`zc-core-threat-model.md`** | **NO (Consolidate)** | Expand `zero-cloud-core-attack-taxonomy.md` and `threat-model-and-control-flows.md`. | Extending the existing attack taxonomy with AT-011 and AT-012 avoids duplicate threat registries. |

---

## 6. Change Discipline and Governance Commitment

Throughout the preparation of this gap audit report, strict governance rules were enforced:
1. No baseline normative document (`zero-cloud-*.md`) was silently altered without audit tracking.
2. Invariants M1–M10 were preserved without weakening their core security guarantees.
3. The Gate C closure verdict (`PARTIAL / QUALIFIED`) was not retroactively expanded.
4. The hybrid architecture is never represented as physically certified or complete at the silicon level.
5. Production RTL and formal harnesses remain frozen.
6. The Zenodo publication hold (stand-down) remains strictly enforced.

---

## 7. Action Plan Summary

1. Establish `zc-core-security-profiles.md` and the `hybrid-zero-cloud-edge-security-architecture/` suite to codify the STRICT vs. HYBRID distinction.
2. Establish `zc-core-hybrid-interconnect.md` to map the Gate C SPI/OBI/OTP blocks into the hybrid architecture.
3. Add Claim Family 8 (`ZC-CORE-008`) to `zero-cloud-core-defensive-publication.md`.
4. Submit the consolidated `v4.0.0-rc2` candidate package for independent audit verification prior to any external archival release.

---

## 8. Summary Status of Historical Gaps (v4.0.0-rc2 Resolution Tracking)

| Review Area | Assessment & Status | Associated Files & Boundaries |
| :--- | :--- | :--- |
| **Hybrid architecture documentation** | **CLOSED (STANDALONE CANDIDATE SUITE)** | The hybrid architecture is defined in a dedicated candidate documentation suite (`hybrid-zero-cloud-edge-security-architecture/`), with its relationship to root normative text mapped in `strict-hybrid-compatibility.md`. |
| **Source RTL / SVA / Testbench availability** | **CLOSED (PRESENT IN ARCHIVE)** | `rtl/` (4 files), `fv/` (9 files), and `tb/` (5 files) are present in full within the repository and distribution archive. |
| **Referencing of historical Gate C evidence** | **RECORDED** | Historical Gate C Run #45 (`eb3ed5a`, 2026-10-20) formal proof records are explicitly cited. |
| **RTL simulation and formal proof on current RC2** | **UNVERIFIED (NOT RERUN LOCALLY)** | Because no EDA simulator (Verilator/ModelSim/VCS) or formal solver (`sby`/`smtbmc`) is installed in the current host environment, HDL simulation and formal solvers were not re-executed in this session. |
| **Physical hardware / silicon (Gate D)** | **DEFERRED / UNVERIFIED** | Analog PVT corners, clock skew, PCB trace reflections, and physical optocoupler bounds are strictly deferred to Gate D. |
| **CTS profile conformance and telemetry bounds** | **CLOSED / DEFERRED TO GATE D** | STRICT and HYBRID profile test boundaries are documented in CTS (`zero-cloud-core-conformance-test-specification.md`) Annex A and B; physical netlist/laboratory validation is deferred to Gate D. |
| **Root manifest scope separation** | **SCOPE DEMARCATION CLARIFIED** | The 18-artifact root manifest (`ZERO-CLOUD-RELEASE-MANIFEST.md`) seals the root normative standard and 4 RTL blocks, while the 7-document hybrid suite is explicitly scoped as a standalone candidate suite (`README.md` line 154). |
