# Hybrid Zero-Cloud & Edge Security Architecture
## Canonical Architectural Specification, Boundary Definitions & Evidence Baseline

**Architecture Identifier:** `ZC-ARCH-HYBRID-V4`  
**Standardization Status:** `PROPOSED / CANDIDATE SPECIFICATION / NOT RATIFIED AS FINAL STANDARD`  
**Release Context:** Part of the `v4.0.0-rc2` Release Candidate Package (Pending Experimental Validation)
**Historical Normative Baseline:** Preserves [`zero-cloud-core-methodology-invariants.md`](../zero-cloud-core-methodology-invariants.md) and [`zero-cloud-hardware-reference-architecture.md`](../zero-cloud-hardware-reference-architecture.md) as immutable STRICT reference
**Classification:** Canonical Architecture Suite  

---

> [!IMPORTANT]
> **NORMATIVE BOUNDARY & GOVERNANCE NOTICE:**  
> 1. **Architectural Coexistence:** The **Hybrid Zero-Cloud & Edge Security Architecture** specifies the formal extension of the FreeCuli Zero-Cloud Hardware Core (ZC-CORE) methodology to connected edge platforms requiring bidirectional network coordination. It does **NOT** repeal, replace, or retroactively amend the immutable v3.x normative standard or the STRICT profile.
> 2. **Candidate Status:** The specifications in this directory are published as a candidate architectural baseline within the `v4.0.0-rc2` release candidate. They do **not** constitute an approved or ratified industry standard until formal standards committee ratification.
> 3. **Verification Boundary:** The digital RTL IP blocks (`zc_spi_flash_firewall`, `zc_obi_subordinate_bridge`, `zc_aon_post_auth_ctrl`, `zc_otp_pkg`) are verified via bounded formal proofs ($t=20$) and cycle-accurate RTL testbenches (Gate C). All full-SoC bus integration, clock-domain crossing (CDC) synchronizers, and physical silicon behaviors are strictly **`Gate D (UNVERIFIED)`**.

---

## 1. Architectural Motivation & Executive Summary

The foundational axiom of the FreeCuli Zero-Cloud Hardware Core (ZC-CORE) methodology is an absolute privacy guarantee: **sensitive raw sensory information (microphone audio waveforms, camera video frames, biometric scans) SHALL NEVER leave the local hardware-enforced Trusted Processing Domain.**

In the baseline **STRICT Profile (`ZC-PROFILE-STRICT`)**, this guarantee is enforced via a complete physical air-gap or hardware-unidirectional data diode (optocoupler / TX-only UART). While impenetrable against remote exfiltration, pure unidirectional air-gapping creates operational barriers for connected edge IoT devices:
- Devices cannot receive verified Over-The-Air (OTA) firmware or security updates without physical socket access.
- Fleet management, uptime telemetry, and remote crash diagnostics are impossible.
- Inter-processor coordination between an untrusted Network Co-Processor (Wi-Fi / BLE / Ethernet) and the local Edge AI core cannot execute.

The **Hybrid Zero-Cloud & Edge Security Architecture** addresses this operational challenge by introducing **hardware-gated bidirectional coordination**. At the block level, synthesizable silicon firewalls provide hardware gating for inbound firmware staging (`zc_spi_flash_firewall.sv`), bus decoupling and orphan transaction draining (`zc_obi_subordinate_bridge.sv`), and atomic anti-rollback OTP authorization (`zc_aon_post_auth_ctrl.sv`). Outbound semantic telemetry rate-limiting and end-to-end Boot ROM update agents are architectural design goals proposed in the V4 RFC and deferred to Gate D SoC integration, establishing architectural safeguards against raw sensor egress and execution hijacking without relying on unverified claims.

```
+---------------------------------------------------------------------------------------------------------+
|                       HYBRID ZERO-CLOUD & EDGE SECURITY ARCHITECTURE (ZC-PROFILE-HYBRID)                |
+---------------------------------------------------------------------------------------------------------+
|                                                                                                         |
|   [ UNTRUSTED EXTERNAL DOMAIN ]                                                                         |
|     Network Co-Processor (Wi-Fi / BLE / Ethernet)                                                       |
|        |                                       |                                                        |
|        | (Protected SPI Bus)                   | (OBI Bus)                                              |
|        v                                       v                                                        |
|   +---------------------------------+     +----------------------------------+                          |
|   |   zc_spi_flash_firewall         |     |   zc_obi_subordinate_bridge      |                          |
|   |   - Pass-through / Gated /CS    |     |   - Synchronous Bus Decoupling   |                          |
|   |   - Rising /CS + SCK=0 Strobe   |     |   - 1024-Cycle Orphan Watchdog   |                          |
|   |   - 05h RDSR1 Status Tracking   |     |   - ST_TRAP Synthetic Error Trap |                          |
|   |   - Bank-B Commit Gating        |     |   - Warm Reset (rst_sys_ni) Gate |                          |
|   +----------------+----------------+     +-----------------+----------------+                          |
|                    |                                        |                                           |
|                    v                                        v                                           |
|          [ Shared SPI Flash ]                      [ Secure Host Subsystem ]                            |
|                                                             |                                           |
|                                                             v (DAI Interface)                           |
|                                                   +----------------------------------+                  |
|                                                   |   zc_aon_post_auth_ctrl          |                  |
|                                                   |   - 4-Phase Atomic DAI Handshake |                  |
|                                                   |   - Single-Cycle Grant Egress    |                  |
|                                                   |   - Permanent AON Fatal Lock     |                  |
|                                                   |   - Hsiao (22,16) Parity Verif   |                  |
|                                                   +-----------------+----------------+                  |
|                                                                     |                                   |
|                                                                     v                                   |
|                                                           [ AON Physical OTP / Fuse ]                   |
|                                                                                                         |
|   [ TRUSTED PROCESSING DOMAIN (ISOLATED) ]                                                              |
|     Edge NPU + Secure SRAM (M8 Zeroization) + Privacy Sensors (M1/M9 Air-Gap)                           |
|                                                                                                         |
+---------------------------------------------------------------------------------------------------------+
```

---

## 2. Document Suite Navigation Map

This directory forms the authoritative, self-contained specification suite for the Hybrid Zero-Cloud & Edge Security Architecture. It is organized into seven modular technical specifications:

| Document | Primary Focus & Normative Coverage | Key Artifacts & References |
| :--- | :--- | :--- |
| **[`README.md`](README.md)** | Architectural entry point, executive summary, profile scope, and governance boundary notice. | Root overview, status hierarchy. |
| **[`architecture-and-security-boundaries.md`](architecture-and-security-boundaries.md)** | Formal trust domain boundaries, data and control flows, bus interconnections, and out-of-scope declarations. | Hardware boundary topology, domain classifications. |
| **[`strict-hybrid-compatibility.md`](strict-hybrid-compatibility.md)** | Comparative analysis between STRICT and HYBRID profiles, clause-by-clause M1–M10 compatibility mapping, and data taxonomy reconciliation. | M1–M10 Invariant mapping, Data Classes 0–4 vs Class 0 Inbound. |
| **[`implementation-and-evidence-matrix.md`](implementation-and-evidence-matrix.md)** | Traceability linking architectural claims to synthesizable RTL (`rtl/`), formal SVA properties (`fv/`), and testbenches (`tb/`). | Bounded proofs ($t=20$), verified properties vs unverified limits. |
| **[`threat-model-and-control-flows.md`](threat-model-and-control-flows.md)** | Physical and logical threat taxonomy (AT-001..AT-012), authentication vs authorization flows, reset/clock domains, and recovery. | Threat vectors, A/B flash rollback, session-ID tracking. |
| **[`open-decisions-and-limitations.md`](open-decisions-and-limitations.md)** | Technical risk disclosures, AON CDC/reset synchronizer gap, Gate D physical silicon deferrals, and pending governance decisions. | AON CDC limitation, STAPVT limits, tape-out prerequisites. |
| **[`references-and-document-map.md`](references-and-document-map.md)** | Complete cross-reference graph connecting this suite to the 14 canonical root specs, V4 RFCs, verification evidence, and manifests. | Link graph, file paths, license anchors. |

---

## 3. Relationship to Canonical Standard & STRICT Baseline

To prevent ambiguity regarding standard ratification:
1. **Normative Supremacy of Root Standard:** The 14 canonical specifications in the repository root (anchored by [`zero-cloud-core-methodology-invariants.md`](../zero-cloud-core-methodology-invariants.md)) define the immutable baseline. Nothing in this directory amends, weakens, or overrides the root standard.
2. **Profile Stratification:**
   - **`ZC-PROFILE-STRICT`:** Corresponds to the architecture documented in [`zero-cloud-hardware-reference-architecture.md`](../zero-cloud-hardware-reference-architecture.md). It remains fully normative, valid, and required for maximum-security or air-gapped deployments.
   - **`ZC-PROFILE-HYBRID`:** Corresponds to the architecture documented in this directory and [`docs/architecture/`](../docs/architecture/). It represents an opt-in architectural extension for networked devices.
3. **No Retrospective Compliance Claims:** An implementation certified under v3.x STRICT rules does not automatically achieve HYBRID compliance, nor does non-implementation of HYBRID firewalls invalidate existing STRICT certifications.

---

## 4. Verification & Implementation Boundaries (Gate C vs. Gate D)

The architectural claims in this suite are rigorously grounded in empirical and formal evidence, subject to precise scope boundaries:

* **Gate C Proven (Digital RTL Logic):**
  - Synthesizable SystemVerilog IP cores located in [`rtl/`](../rtl/) (`zc_spi_flash_firewall.sv`, `zc_obi_subordinate_bridge.sv`, `zc_aon_post_auth_ctrl.sv`, `zc_otp_pkg.sv`).
  - Mathematical formal proofs under SymbiYosys / Yosys 0.33 / Z3 over bounded cycles ($t=20$, $k$-induction).
  - Cycle-accurate digital testbenches in [`tb/`](../tb/) executed under Verilator and Icarus Verilog.
* **Gate D Unverified (Physical Silicon & System SoC):**
  - Asynchronous reset filtering and Clock Domain Crossing (CDC) synchronizers between `clk_sys` and `clk_aon_i` in `zc_aon_post_auth_ctrl.sv`.
  - Full-SoC multi-master crossbar arbitrasyon and IOMMU/PMP memory protection.
  - Analog PVT corners, flash pin capacitive reflections, and high-voltage OTP programming physics.
  - Silicon-level side-channel leakage (DPA/EMA) and physical SRAM remanence.

---

## 5. Licensing & Legal Grounding

The hardware source code, architectural specifications, and verification harnesses comprising the Hybrid Zero-Cloud & Edge Security Architecture are licensed under the **CERN Open Hardware Licence Version 2 - Strongly Reciprocal (CERN-OHL-S-2.0)**. 

For commercial licensing exemptions, patent non-aggression commitments under Open Invention Network (OIN), and the founder's factual representation (`ATTEST-01`), refer strictly to the root licensing specification:
- [`zero-cloud-dual-licensing.md`](../zero-cloud-dual-licensing.md)
- [`LICENSE`](../LICENSE)
