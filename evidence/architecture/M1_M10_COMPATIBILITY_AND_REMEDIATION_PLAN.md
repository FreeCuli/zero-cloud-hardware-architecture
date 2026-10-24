# FREECULI ZC-CORE — M1–M10 Invariant Compatibility Matrix & Documentation Remediation Plan

**Document ID:** ZC-CORE-EVIDENCE-M1-M10-COMPAT-PLAN-01
**Date:** 20 October 2026
**Revision:** 1.4.0 (Independent Auditor HAR-11..13 Findings Remediation)
**Target Repository:** `FreeCuli/zero-cloud-hardware-architecture`
**Working Branch:** `gate-c/formal-scope-audit`
**Technical Reference Baseline:** Commit [`eb3ed5a`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/eb3ed5ad9fddb551506d43d2692bd040843af06f) (Run #45)
**Governance Status (At Gate C Closure):** **Gate C: PARTIAL / QUALIFIED** | **Gate D: UNVERIFIED** | **DO NOT MERGE** | **RELEASE BLOCKED (Historical Planning Record)**

> [!NOTE]
> **Historical Planning Record:** This document is the initial planning analysis prepared prior to transitioning from RC1 to RC2. The "DO NOT MERGE / RELEASE BLOCKED" statements herein reflect the gate condition at that time and do not restrict the current `v4.0.0-rc2` release candidate process.

---

> [!WARNING]
> **GOVERNANCE AND SCOPE DISCLOSURE (HAR-02, HAR-06..HAR-13):**
> This document defines the compatibility status of the ZC-CORE normative invariants (M1–M10) across the **STRICT** and **HYBRID** operational profiles and establishes the remediation plan for normative documents in the repository.
> To prevent technical scope inflation and fully close auditor findings:
> 1. **`DESIGN-COMPATIBLE`:** Architectural design principle and target defined in specification prose.
> 2. **`IMPLEMENTATION-VERIFIED (PARTIAL)`:** Standalone RTL blocks (`zc_spi_flash_firewall`, `zc_obi_subordinate_bridge`, `zc_aon_post_auth_ctrl`) formally proven with open-source tools ($t=20$) under Gate C.
> 3. **`UNVERIFIED AT SOC/SILICON`:** Full-SoC DMA isolation, crossbar IOMMU, analog macro behaviors, and physical side-channel assurances belong strictly to **Gate D**.
> 4. **HAR-06 Evidence Demarcation:** The OBI 1,024-cycle continuous watchdog timeout behavior is verified at the digital RTL simulation level via `tb_zc_obi.sv` Test 2 (`SIMULATED`). Properties `F-OBI-04` and `F-OBI-05` are local RTL step-induction and deadlock-flag assertion proofs (`PROVEN` at local RTL step level), not a single unrolled 1,024-cycle temporal proof.
> 5. **HAR-07 & HAR-11 Implementation Demarcation:** The current Gate C RTL blocks do NOT contain a telemetry data classifier, allowlist inspector, packet encoder, or hardware rate-limiter. Requirements inside `M3-RFC-REVISED` are forward-looking mandatory architectural requirements (`SHALL`); they are not implemented in current RTL and remain proposed system requirements for Gate D SoC integration (`PROPOSED / NOT IMPLEMENTED IN CURRENT RTL`). Furthermore, local Gate C formal proofs do not constitute end-to-end HYBRID information-flow non-interference proofs.
> 6. **HAR-12 Defensive Publication and IP Boundaries:** A technical report on Zenodo serves to document publicly disclosed technical content and its date of public accessibility (timestamped documentary prior art). It does NOT provide automatic patent rights, patent filing priority, or an absolute worldwide guarantee against third-party patents. Pre-publication review by a patent attorney / IP legal counsel is recommended.
> 7. **HAR-13 Mutual Information Research Target:** The covert-channel statistical mutual information inequality ($\epsilon_{\text{target}}$) is an **`UNVERIFIED RESEARCH / VALIDATION TARGET`**, not an approved certification threshold; it does not mathematically prove the absence of all possible physical leakage paths.

---

## 1. M1–M10 Invariants Compatibility Matrix (STRICT vs. HYBRID)

The M1–M10 invariants forming the foundation of the ZC-CORE methodology have been evaluated independently against both the **STRICT** and **HYBRID** profiles and assigned to one of four categories:
- **`COMPATIBLE`:** The invariant applies 100% directly under the profile without exception or reinterpretation.
- **`CONDITIONAL`:** The invariant holds subject to explicitly defined hardware constraints, boundary conditions, or external trust assumptions.
- **`CONFLICT`:** A normative friction exists between the profile and the literal baseline wording (requiring a Methodology or Major-Version revision).
- **`UNRESOLVED`:** Validity cannot yet be finalized due to missing hardware or formal evidence.

### Consolidated Normative Compatibility and Scope Demarcation Table

| Invariant ID | Normative Invariant Definition | STRICT Profile | HYBRID Profile (Design Target) | Implemented RTL & Formal Scope (Gate C: PARTIAL) | Deferred System & Physical Scope (Gate D: UNVERIFIED) |
| :--- | :--- | :---: | :---: | :--- | :--- |
| **M1** | **Trusted Sensor Acquisition:** Raw sensor data (audio/video) SHALL NEVER leave the Trusted Domain. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible)* | M1 is a domain topology rule; Gate C digital RTL blocks are bus and memory bridges rather than sensor interfaces. | Physical PCB trace separation, sensor package tamper protection, analog trace impedance. |
| **M2** | **Hardware-Enforced Domain Boundary:** Separation between Trusted Domain and Network Domain MUST be enforced in hardware (not software). | **`COMPATIBLE`** | **`CONDITIONAL`** *(Design-Compatible)* | Hardware gating at the bus and SPI tiers is proven via `zc_obi_subordinate_bridge` (`F-OBI-01..07`) and `zc_spi_flash_firewall` (`F-SPI-01..04`). | Multi-master SoC crossbar DMA firewall, memory management unit (IOMMU), and PCB air-gap analysis. |
| **M3** | **One-Way Information Flow:** Protected information SHALL flow strictly unidirectionally. Authenticated control traffic MAY enter in reverse. | **`COMPATIBLE`** | **`CONDITIONAL`** *(Subject to Normative Revision — HAR-08/09/11)* | Reverse bus deadlock is prevented via OBI bridge orphan drain (`F-OBI-06`) and synthetic error trap (`F-OBI-04/05` step); unauthorized flash writes are blocked via SPI firewall (`F-SPI-01/02`). **WARNING (HAR-07/11):** The OBI bridge does NOT perform telemetry filtering, allowlisting, or rate-limiting (`PROPOSED / NOT IMPLEMENTED IN CURRENT RTL`). Local formal proofs are not end-to-end information-flow non-interference proofs. | Hardware allowlist filter and rate-limiter IP for Class 3 telemetry (Gate D SoC integration). CTS Annex B statistical mutual information upper bound ($I(S_{\text{raw}}; T_{\text{out}}) \le \epsilon_{\text{target}}$) research test. *(See Section 2)*. |
| **M4** | **Reverse-Read Impossibility:** It MUST be physically and logically impossible for the Network Domain to execute a raw-sensor reverse read from the Trusted Domain. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible / Implementation-Verified)* | `zc_obi_subordinate_bridge.sv` prevents read leakage upon peripheral fault or deadlock by returning deterministic `ST_TRAP` synthetic error data (`32'h0000_0000`) (`F-OBI-04/05` step properties `PROVEN`; 1,024-cycle continuous lock `SIMULATED` in `tb_zc_obi.sv` Test 2). | System-level crossbar protection preventing a malicious SoC DMA master from directly reading secure SRAM or NPU registers (`BLOCKED`). |
| **M5** | **Control-Plane Isolation:** The Trust Boundary MUST encompass reset, clock, power, DMA, and debug lines in addition to the data path. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible / Implementation-Verified)* | OBI bridge gates host requests to zero under warm reset (`rst_sys_ni`) (`F-OBI-07`). AON OTP controller preserves authorization lock across warm reset (`F-OTP-05`). | Physical clock/voltage glitch injection laboratory tests; asynchronous reset recovery/removal Static Timing Analysis (STA). |
| **M6** | **Hardware-Rooted Execution Integrity:** Secure boot and update chain MUST encompass AI weights and hardware inventory. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible / Implementation-Verified)* | `zc_aon_post_auth_ctrl.sv` enforces the 4-phase DAI handshake (`F-OTP-02/03`), single-cycle grant consumption (`F-OTP-06`), and SVN anti-rollback monotonicity (`F-OTP-01a/b`) in hardware. | Cryptographic correctness of the external Boot ROM signature verifier (`rom_img_verif_valid_i` is an external trust assumption); analog antifuse programming charge pump ($V_{\text{PP}} > 1.8\,\text{V}$). |
| **M7** | **Raw-Data Lifetime Enforcement:** Raw data lifetime SHALL be strictly bounded to the local inference cycle. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible)* | **`BLOCKED`**: Two-trace formal non-interference miter (`fv/zc_m7_m8_ni_sva.sv`) cannot be executed in Gate C without the full SoC and NPU netlist. | Hardware lifetime counter, end-of-inference hardware interrupt trigger, and SoC-level verification. |
| **M8** | **Post-Inference Destruction/Zeroization:** Immediately upon inference completion, all raw data and derived tensor copies SHALL be permanently zeroized. | **`COMPATIBLE`** | **`CONDITIONAL`** *(Physical Remanence Bound)* | **`BLOCKED`**: Digital RTL SRAM zeroization logic awaits full SoC integration. | Cryogenic and post-power-cutoff physical cell remanence rate ($R_{\text{rate}} \le 0.01\%$) testing is strictly deferred to Gate D laboratory validation. |
| **M9** | **Complete Sensor Inventory:** Every privacy-sensitive sensor on the device MUST be connected exclusively to the Trusted Domain. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design-Compatible)* | M9 is a system architecture rule; any secondary microphone or camera in the network domain is a direct non-conformance. | Physical PCB X-ray inspection, BOM component audit, and optical microscopy. |
| **M10** | **Independent Conformance Evidence:** Conformance claims MUST rely on independent, measurable evidence rather than vendor self-assertion. | **`COMPATIBLE`** | **`CONDITIONAL`** *(HAR-05: Consistent Across All Prose and Tables)* | The 3 digital RTL blocks in Gate C are proven with open-source formal tools ($t=20$) (`PARTIAL / QUALIFIED`). | Physical side-channel, covert-channel, glitch, and on-chip isolation assurances for the HYBRID profile require Gate D accredited laboratory testing. |

---

## 2. M1/M3 Normative Friction Analysis and Versioning Decision Matrix (HAR-09..HAR-13)

### 2.1 Verbatim Comparison of Baseline Texts and Normative Friction (HAR-09)
Inspecting the verbatim clauses in [`zero-cloud-core-methodology-invariants.md`](../../zero-cloud-core-methodology-invariants.md):

1. **M1 (Trusted Sensor Acquisition):**
   > *"Raw sensor data (audio/video) SHALL NEVER leave the Trusted Domain."*
2. **M3 (One-Way Information Flow):**
   > *"Protected raw-sensor information and derived representations SHALL flow strictly from the Trusted Domain to the Network Domain through a physically verifiable unidirectional channel. Authenticated control-plane and firmware-update traffic MAY enter the Trusted Domain, provided it cannot create a raw-sensor read-back path or a reverse raw-sensor information channel."*
3. **M4 (Reverse-Read Impossibility):**
   > *"It MUST be physically or logically impossible for the Network/Control Domain to execute a functional reverse read (raw sensor read-back) from the Trusted Domain over a physical reverse channel..."*
4. **M8 (Post-Inference Destruction/Invalidation):**
   > *"Once inference completes, all persistent and temporary copies of raw data SHALL become irreversibly unrecoverable (e.g., physically destroyed or cryptographically zeroized across all caching layers)."*
5. **Composition Rule:**
   > *"Sensor Acquisition → Trusted Local Inference → Controlled Semantic Release → Absolute Raw-Data Destruction → Network/Actuator Operation."*

#### Normative Friction / Conflated Drafting Analysis:
- **Friction:** While M1 explicitly mandates that raw sensor data `SHALL NEVER leave` the Trusted Domain and M8 mandates irreversible destruction upon inference completion, legacy M3 wording literally stated *"Protected raw-sensor information and derived representations SHALL flow strictly from the Trusted Domain to the Network Domain..."*!
- **Intended Meaning (Composition Rule):** The document's own Composition Rule clarifies the actual architectural flow: only **"Controlled Semantic Release"** (Class 2 commands, Class 3 telemetry) crosses the boundary, while raw data undergoes **"Absolute Raw-Data Destruction"**.
- **Conclusion:** This represents historical conflated drafting in legacy v3.x prose. Clarifying this in v4.0.0 requires an explicit normative contract revision (`M3-RFC-REVISED`).

---

### 2.2 Proposed Revised M3 Contract (`M3-RFC-REVISED`)
Prepared for the v4.0.0 architectural specification:

> #### Revised M3 Invariant: `M3-RFC-REVISED`
> 1. **Prohibition of Protected Sensor Egress:**
>    Raw sensor data (Class 0) and high-dimensional derived tensor/embedding representations (Class 1) SHALL NEVER exit the Trust Boundary under M1 and M8.
> 2. **Permitted Unidirectional Semantic Release:**
>    Only verified discrete physical actuation commands generated by local inference (Class 2) and hardware-rate-limited, fixed-schema system telemetry (Class 3) MAY flow outbound across a hardware-enforced boundary.
> 3. **Hardware-Policed Reverse Ingress (Inbound):**
>    Authenticated control-plane and firmware-update traffic MAY enter the Trusted Domain through hardware firewalls (SPI dual `/CS` and Boot ROM signature verification), provided it cannot under any circumstance create a reverse-read path (M4) or raw-data exfiltration channel.
> 4. **Physical Enforcement Split:**
>    - **STRICT Profile:** Outbound egress is enforced strictly via a unidirectional physical hardware diode (optocoupler / air-gap).
>    - **HYBRID Profile:** Bidirectional physical buses (OBI / SPI) are permitted only when bounded by formally verified bus firewalls (orphan drain, synthetic error trap) and independent hardware rate-limiters.

> [!IMPORTANT]
> **Implementation Gap Disclosure (HAR-11 Resolution):**
> The rules inside `M3-RFC-REVISED` are **forward-looking mandatory architectural requirements (`SHALL` requirements)** for the ZC-CORE v4.0.0 HYBRID profile.
> In the current digital RTL baseline (`eb3ed5a` / Gate C):
> 1. The implemented RTL modules (`zc_obi_subordinate_bridge`, `zc_spi_flash_firewall`, `zc_aon_post_auth_ctrl`) provide bus-level protocol decoupling, orphan response drain, and flash commit authorization gating only; they do NOT implement telemetry allowlist inspection, payload validation, hardware rate-limiting, or a full-SoC DMA firewall. Those mechanisms remain strictly **`PROPOSED / NOT IMPLEMENTED OR UNVERIFIED`** (deferred to Gate D SoC integration).
> 2. Local formal proofs in Gate C (`F-SPI-01..04`, `F-OBI-01..07`, `F-OTP-01..06`) verify block-level protocol invariants; they are NOT end-to-end information-flow non-interference proofs across the hybrid system (`BLOCKED` under `fv/zc_m7_m8_ni_sva.sv`).

---

### 2.3 Separation of Four Independent Milestones (HAR-10 & HAR-12)
To maintain clear legal, verification, and engineering boundaries, the roadmap is partitioned into 4 independent milestones:

1. **Milestone 1: Architectural Specification and RFC Governance (`GOVERNANCE-RFC`)**
   - Completion of STRICT and HYBRID profile definitions, threat models (`AT-011`, `AT-012`), interconnect contracts, and `M3-RFC-REVISED` prose.
   - *Status:* Completed at the specification/candidate documentation level. Zero silicon fabrication dependency.
2. **Milestone 2: Defensive Technical Publication and Intellectual Property (Zenodo DOI / Prior-Art — HAR-12)**
   - Timestamped DOI registration of the ZC-CORE methodology, revised M3 contract, and `ZC-CORE-008` (Hardware Bus Firewall and Inbound Update Architecture) disclosures.
   - *Documentary Nature:* Establishes verifiable evidence of publicly disclosed technical content and its date of public accessibility (documentary prior art under 35 U.S.C. § 102 and EPC Art. 54).
   - *Legal and IP Boundaries:* **Does not grant automatic patent protection, does not establish patent filing priority, and does not guarantee an absolute worldwide patent bar.** FreeCuli operates under an open-hardware B2B dual-licensing model (CERN-OHL-S) and founder representations record no conflicting institutional or TÜBİTAK patent filing obligations.
   - *Boundary:* **Does not require physical silicon tape-out.** Design targets are transparently disclosed as architectural specifications rather than physical silicon guarantees.
3. **Milestone 3: Digital FPGA and Full-SoC Verification (`FPGA-SOC-GATE-C`)**
   - Gate C open-source formal proofs (`PROVEN`: `F-SPI-01..04`, `F-OBI-01..07`, `F-OTP-01..06`).
   - RTL digital simulations (`SIMULATED`: 1,024-cycle OBI watchdog).
   - Full-SoC netlist verification on FPGA encompassing dual-core Ibex CPUs + NPU + DMA crossbar.
4. **Milestone 4: Physical Silicon Conformance and Commercial Release (Gate D)**
   - Foundry antifuse analog macro characterization ($V_{\text{PP}} > 1.8\,\text{V}$).
   - Cryogenic / power-cutoff SRAM remanence analysis ($R_{\text{rate}} \le 0.01\%$).
   - Accredited ISO 17025 laboratory RF anechoic chamber EM side-channel and statistical mutual information leakage validation:
     $$\max_{\mathcal{A} \in \mathcal{M}_{\text{threat}}} I(S_{\text{raw}}; T_{\text{out}} \mid \mathcal{O}_{\text{side-channel}}) \le \epsilon_{\text{target}}$$

---

### 2.4 Comprehensive Versioning Decision Matrix and Strategic Recommendation

| Evaluation Dimension | Option A: v3.x Normative Profile Annex | Option B: v4.0.0 Breaking Architectural RFC |
| :--- | :--- | :--- |
| **Normative M3 Resolution** | Attempts to reinterpret legacy M1/M3 wording; leaves literal friction residue. | Enacts `M3-RFC-REVISED` cleanly; eliminates M1/M3 wording friction at the root. |
| **Zenodo Defensive Publication (MS 2)** | Published as a v3.3.x addendum; risks terminological confusion with unidirectional v3.x prior art. | **Documented Prior-Art Disclosure:** Published under the v4.0.0 architecture line; establishes independent prior art for `ZC-CORE-008` without muddying v3.x records. |
| **Legacy Device Status** | Retains all v3.x devices under a single umbrella. | Freezes v3.3.0-rc2 as the immutable STRICT baseline and positions HYBRID cleanly under the v4.0.0 line. |
| **CTS Test Suite** | Patches the v3 CTS suite. | Establishes modular CTS profiles (`CTS-Core`, `CTS-Strict`, `CTS-Hybrid`). |
| **Strategic Recommendation** | Feasible, but open to literal interpretation disputes. | **RECOMMENDED:** Cleanest architectural path with lowest legal and technical ambiguity. |

---

### 2.5 Covert-Channel Mutual Information Research Target Status (HAR-13)
Target mutual information inequality in the HYBRID telemetry leakage model:
$$\max_{\mathcal{A} \in \mathcal{M}_{\text{threat}}} I(S_{\text{raw}}; T_{\text{out}} \mid \mathcal{O}_{\text{side-channel}}) \le \epsilon_{\text{target}}$$
> [!WARNING]
> **Metric Boundaries and Verification Status (HAR-13 Resolution):**
> 1. **Unverified Research Target:** The numerical threshold $\epsilon_{\text{target}}$, physical sampling methodology, sample size, measurement protocols, and statistical confidence intervals ($1 - \alpha$) constitute an **`UNVERIFIED RESEARCH / VALIDATION TARGET`** that has not yet been standardized as a commercial pass/fail gate.
> 2. **Scope Boundary:** Observing near-zero mutual information under a bounded adversary model ($\mathcal{M}_{\text{threat}}$) and finite observation set ($\mathcal{O}$) does not mathematically prove the absolute absence of all physical, hardware, or logical covert-channel pathways under real-world conditions.

---

## 3. Hardware Isolation Boundaries: Gate C Proofs vs. System Reality (HAR-02, HAR-06..HAR-11)

To prevent standalone RTL block capabilities from being misconstrued as a full-SoC DMA firewall, memory controller, or telemetry filter, the following technical boundaries are recorded:

| Evaluated RTL Block | Actual Boundaries Proven in Gate C (Formal Proof Scope & Simulation) | External Trust Assumptions | Unverified System, Telemetry & Physical Risks (Gate D Deliverables) |
| :--- | :--- | :--- | :--- |
| **`zc_spi_flash_firewall`** | - RDSR1 status reconciliation (`SR1[1:0] == 00`).<br>- Primary frame completion on rising `/CS` while `SCK=0` (`F-SPI-03`).<br>- Secondary fault combinational `/CS` deselect (`cs_n_flash_eff_o`, `F-SPI-04`).<br>- Bank-B commit authorization gating (`bank_b_commit_ready_o`, `F-SPI-02`). | **HAR-04:** Cryptographic signature verification is NOT inside this RTL module. `rom_img_verif_valid_i` is assumed to originate from a trusted Boot ROM engine.<br>`bank_b_commit_ready_o = spi_idle_ready_o && rom_img_verif_valid_i`. | - Analog delays of the external SPI Flash IC.<br>- Multi-master bus contention.<br>- PCB transmission-line impedance reflections and glitch injection. |
| **`zc_obi_subordinate_bridge`** | - Single-response delivery lock (`F-OBI-01`).<br>- Orphan response absorption (`F-OBI-02a/b/c`).<br>- Request blocking under warm reset (`rst_sys_ni`) (`F-OBI-07`).<br>- `ST_TRAP` synthetic error response generation (`F-OBI-06a/b/c`).<br>- **HAR-06 Evidence Classification:** Continuous 1,024-cycle watchdog timeout behavior is verified in digital RTL simulation (`tb_zc_obi.sv` Test 3, `SIMULATED`). `F-OBI-04` and `F-OBI-05` are local RTL step-induction and deadlock-flag assertion proofs (`PROVEN` at local RTL step level). | Incoming OBI host requests are assumed to originate from a valid CPU/DMA master port. | - **HAR-07 & HAR-11 Hardware Boundary:** This block does NOT perform telemetry filtering, allowlist inspection, or rate-limiting (`PROPOSED / NOT IMPLEMENTED IN CURRENT RTL`). It provides bus-protocol decoupling only. Local Gate C proofs are not end-to-end non-interference proofs.<br>- **HAR-02 Hardware Boundary:** This block is NOT a SoC DMA firewall or MPU. Memory access arbitration across a multi-master crossbar remains deferred to Gate D (`BLOCKED`). |
| **`zc_aon_post_auth_ctrl`** | - 4-phase DAI handshake protocol (`F-OTP-01a/b`, `F-OTP-02`, `F-OTP-03a/b`).<br>- Single-cycle grant consumption.<br>- Permanent fatal lock preserved across warm reset (`F-OTP-05`).<br>- Hsiao (22,16) codeword parity equivalence.<br>- Sequential word commit progression. | Assumes the DAI interface connects to the physical OTP macro controller and external environmental fault signals (`volt_supervisor_fault_i`, `tamper_alert_i`) operate correctly. | - Physical antifuse programming charge pump ($V_{\text{PP}} > 1.8\,\text{V}$) analog pulse duration.<br>- Foundry OTP macro cell reliability and data retention physics. |

---

## 4. File-by-File Documentation Remediation Plan

1. **`README.md`:** Introduce STRICT and HYBRID security profiles, reference the Gate C RTL blocks, and demarcate the standalone hybrid candidate suite.
2. **`zero-cloud-hardware-reference-architecture.md`:** Add Section 2.10 covering ZC-CORE Hardware Firewall and Secure Interconnect Architecture (SPI, OBI, AON OTP) and update data-flow schematics.
3. **`zero-cloud-core-scope-boundary.md`:** Define permitted hybrid telemetry and information-flow policy across data classes (Class 0..4).
4. **`zero-cloud-core-attack-taxonomy.md`:** Add `AT-011` (Telemetry Steganographic Covert Channel) and `AT-012` (Inbound Update Flash Desynchronization / DoS).
5. **`zero-cloud-core-conformance-test-specification.md`:** Document STRICT and HYBRID profile conformance test boundaries (`FC-ZC-017`, `FC-ZC-018`) and Annex B statistical bounds.
6. **`zero-cloud-core-implementation-coverage.md`:** Add Hybrid Interconnect Hardware Class mapping (OBI Bridge, SPI Flash Firewall, AON Controller).
7. **`zero-cloud-core-conformance-evidence-matrix.md`:** Link Gate C digital formal evidence with Gate D physical laboratory test requirements.
8. **`zero-cloud-core-defensive-publication.md`:** Add Claim Family `ZC-CORE-008: Hardware-Enforced Bus Isolation & Secure Inbound Update Firewall`.

---

## 5. Change Discipline and Governance Control (Historical Context)

1. This planning record was originally authored on `gate-c/formal-scope-audit` to guide the structured transition to `v4.0.0-rc2`.
2. All architectural specifications in `docs/architecture/` and `hybrid-zero-cloud-edge-security-architecture/` explicitly distinguish implemented RTL mechanisms from proposed SoC/Gate D targets.
3. Synthesizable RTL (`rtl/*.sv`) and formal verification harnesses (`fv/*.sv`) remain strictly frozen at the verified Gate C baseline.
