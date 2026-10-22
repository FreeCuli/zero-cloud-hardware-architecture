# FreeCuli ZC-CORE: Universal Zero-Cloud Hardware Methodology

The Hardware-Enforced, privacy-first hardware reference methodology for Server-Independent AIoT and Edge AI devices (Smart Home, Medical, Industrial, Defense).

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S v2.0](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)
[![Release Candidate](https://img.shields.io/badge/ZC--CORE-v4.0.0--rc1-yellow.svg)](https://github.com/FreeCuli/zero-cloud-hardware-architecture/releases/tag/v4.0.0-rc1)

## Overview & Shared Foundation

This repository serves as the unified entry point for the **FreeCuli ZC-CORE v4.0.0-rc1 Release Candidate (Pending Experimental Validation)**. Originally pioneered as a smart-kitchen architecture (HFSCA), ZC-CORE has evolved into a universal, sector-agnostic methodology for designing autonomous smart devices that operate without mandatory centralized server or cloud dependency. As a member of the Open Invention Network (OIN), FreeCuli defends and promotes open-source hardware innovation.

### The Foundational Security Axiom
Across all implementations, ZC-CORE enforces one invariant principle: **Sensitive raw sensor data (audio PCM streams, raw camera frames, biometric signals) SHALL NOT leave the local hardware-enforced Trusted Processing Domain.**

Rather than relying on software promises, operating system sandboxes, or user policy, the trust boundary is enforced through:
- Hardware-enforced physical or bus-level isolation between the Trusted Processing Domain and external communication interfaces.
- Rapid, hardware-enforced post-inference raw-data destruction / invalidation (including power-cut, cryptographic zeroization, or independently validated equivalents).
- Mathematical non-interference and verification of the absence of reverse-read paths from the untrusted network processor.

---

## The Two Independent Architecture Families

Under the common ZC-CORE methodology umbrella, this repository hosts **two separate and independent architecture families**. They share foundational security invariants and core design principles, but serve distinct operational environments and threat models. **HYBRID is not a sub-version, subordinate profile, or retroactive modification of STRICT; both stand as co-equal architectural paths:**

```
                                  +---------------------------------------+
                                  |   FreeCuli ZC-CORE Common Foundation  |
                                  |   - Raw-Sensor Trust Boundary Axiom   |
                                  |   - M1-M10 Methodology Invariants    |
                                  |   - CERN-OHL-S-2.0 / Dual Licensing  |
                                  +-------------------+-------------------+
                                                      |
                         +----------------------------+----------------------------+
                         |                                                         |
                         v                                                         v
    +-----------------------------------------+               +-----------------------------------------+
    |           STRICT Architecture           |               |   Hybrid Zero-Cloud & Edge Security     |
    |          (`ZC-PROFILE-STRICT`)          |               |       Architecture (`ZC-PROFILE-HYBRID`) |
    +-----------------------------------------+               +-----------------------------------------+
    | - Complete physical air-gap             |               | - Hardware-gated bidirectional buses     |
    | - Unidirectional hardware data diode    |               | - Active SPI flash command firewall     |
    | - Zero outbound telemetry bits          |               | - Inbound authenticated OTA updates     |
    | - Physical maintenance update paths     |               | - Allowlisted outbound semantic telemetry|
    | - Ratified normative standard (v3.x)    |               | - Candidate specification (v4.0.0-rc1)  |
    +-----------------------------------------+               +-----------------------------------------+
```

### Architectural Comparison & Key Differences

| Architectural Dimension | STRICT Architecture (`ZC-PROFILE-STRICT`) | Hybrid Zero-Cloud & Edge Security Architecture (`ZC-PROFILE-HYBRID`) |
| :--- | :--- | :--- |
| **Primary Objective** | Absolute physical data isolation for mission-critical, zero-trust, or air-gapped environments. | Secure operational coexistence with external networks for connected edge appliances and smart products. |
| **Interconnect Topology** | Physical unidirectional data diode (optical isolator, TX-only serial line, or physical air-gap). | Hardware-gated bidirectional interconnects (`zc_obi_subordinate_bridge.sv`) and dual-bank SPI flash (`zc_spi_flash_firewall.sv`). |
| **Outbound Telemetry** | **Zero bits permitted.** No network interface exists on the trusted side of the diode. | **Conditional allowlisted telemetry permitted** (sanitized device health metrics, status, error codes). |
| **Firmware Update (OTA)** | Physical socket, factory programming header, or physical jumper only. Remote OTA is impossible by design. | Cryptographically validated inbound OTA via hardware SPI firewall, Boot ROM asymmetric verification, and OTP anti-rollback. |
| **Target Deployments** | Defense, medical implants, critical industrial infrastructure, high-assurance air-gapped sensors. | Commercial smart home appliances, fleet-managed commercial Edge-AI devices, connected industrial sensors. |
| **Standardization Status** | **Ratified Normative Standard** (v3.x root specifications; fully frozen and active). | **Candidate Architecture Baseline** (`v4.0.0-rc1` release candidate; RFC-0004 unratified proposal). |

### Documented Common Components & Compatibility Relationship
- **Shared Invariants:** Both architectures adhere to the core methodology invariants (M1, M2, M4, M6, M7, M8, M9, M10). Invariant M3 is strictly one-way for STRICT, while HYBRID specifies `M3-RFC-REVISED` as an unratified candidate adaptation for gated bidirectional coordination.
- **Detailed Compatibility Specification:** Clause-by-clause mapping and data taxonomy reconciliation (Root 4-Class vs. V4 RFC 5-Class) are documented in [`hybrid-zero-cloud-edge-security-architecture/strict-hybrid-compatibility.md`](hybrid-zero-cloud-edge-security-architecture/strict-hybrid-compatibility.md).
- **Independent Compliance Boundaries:** Certifications are profile-specific. An implementation achieving STRICT compliance is not automatically HYBRID-compliant, nor does failure to adopt HYBRID firewalls invalidate an existing STRICT certification.

---

## 1. STRICT Architecture (`ZC-PROFILE-STRICT`)

The **STRICT Architecture** defines the immutable normative foundation of the ZC-CORE standard. It relies on unidirectional physical boundaries to guarantee that sensitive sensor telemetry can never egress to an external network.

### Normative Specifications & Core Documents (RFC 2119 Stricture)

#### 🏗️ Architecture & Invariants
1. **[The ZC-CORE Hardware Fortress (Reference Architecture)](zero-cloud-hardware-reference-architecture.md)**
   * Mandatory normative specifications for Physical Air-Gap, Hardware Data Diode, and Trust Boundary security pillars.
2. **[ZC-CORE Methodology Invariants](zero-cloud-core-methodology-invariants.md)**
   * The foundational rules of the standard (M1–M10) defining hardware-enforced privacy guarantees.
3. **[ZC-CORE Scope & Boundary Definition](zero-cloud-core-scope-boundary.md)**
   * The 4-class normative data taxonomy and explicit standard boundaries (device privacy vs. external networks).

#### 🔬 Testing, Threat Modeling & Evidence
4. **[FC-ZC Conformance Test Specification (CTS)](zero-cloud-core-conformance-test-specification.md)**
   * Physical laboratory procedures (oscilloscope, multimeter, X-Ray, VNA) required to prove hardware compliance.
5. **[ZC-CORE Conformance Evidence Matrix](zero-cloud-core-conformance-evidence-matrix.md)**
   * Maps each methodology invariant and attack vector to required physical laboratory evidence.
6. **[ZC-CORE Attack Taxonomy](zero-cloud-core-attack-taxonomy.md)**
   * Standard classification of physical, side-channel, and electrical threat vectors (AT-001 through AT-010).
7. **[ZC-CORE Implementation Coverage Matrix](zero-cloud-core-implementation-coverage.md)**
   * Matches normative requirements to representative technology implementation classes (Optical, FPGA, ASIC).
8. **[ZC-CORE Conformance Evidence Package](ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md)**
   * Evidence package index and formal gate closure sign-offs.
9. **[ZC-CORE Hardware Forensic Audit Protocol](ZC-CORE-HARDWARE-FORENSIC-AUDIT-PROTOCOL.md)**
   * Destructive and non-destructive physical teardown protocol for physical device audits.

#### 🛡️ Prior Art & Defensive Publication
10. **[Zero-Cloud Defensive Publication (Prior Art Specification)](zero-cloud-core-defensive-publication.md)**
    * Timestamped technical disclosure establishing public prior art to protect the open hardware ecosystem from patent trolling.

---

## 2. Hybrid Zero-Cloud & Edge Security Architecture (`ZC-PROFILE-HYBRID`)

The **Hybrid Zero-Cloud & Edge Security Architecture** extends the ZC-CORE methodology to devices requiring bidirectional network communication. It achieves this without compromising raw-sensor privacy through active digital silicon firewalls, atomic OTP write controllers, and bus-level transaction trapping.

### Canonical Specification Suite (`hybrid-zero-cloud-edge-security-architecture/`)
1. **[Architecture Suite Overview & Boundaries](hybrid-zero-cloud-edge-security-architecture/README.md)**
   * Canonical entry point, architectural motivation, profile definition, and boundary notice.
2. **[Architecture & Security Boundaries Specification](hybrid-zero-cloud-edge-security-architecture/architecture-and-security-boundaries.md)**
   * Three-domain decomposition (Domain 0/1/AON), bus topology, data/control flow boundaries, and out-of-scope declarations.
3. **[STRICT vs. HYBRID Compatibility Analysis](hybrid-zero-cloud-edge-security-architecture/strict-hybrid-compatibility.md)**
   * Detailed clause-by-clause evaluation against M1–M10 and data classification reconciliation.
4. **[Implementation & Technical Evidence Matrix](hybrid-zero-cloud-edge-security-architecture/implementation-and-evidence-matrix.md)**
   * Bidirectional traceability linking security claims to synthesizable RTL modules, formal SVA proofs, and testbenches.
5. **[Threat Model & Operational Control Flows](hybrid-zero-cloud-edge-security-architecture/threat-model-and-control-flows.md)**
   * Extended attack taxonomy (AT-001..AT-012), end-to-end control sequences for OTA staging, commit, and error recovery.
6. **[Open Decisions, Silicon Limitations & Gate D Roadmap](hybrid-zero-cloud-edge-security-architecture/open-decisions-and-limitations.md)**
   * Detailed disclosure of clock domain crossing risks, Gate D physical silicon deferrals, and pending governance decisions.
7. **[Cross-Reference & Artifact Graph Map](hybrid-zero-cloud-edge-security-architecture/references-and-document-map.md)**
   * Complete inventory and dependency graph of all linked repository artifacts.

### Synthesizable Silicon IP Implementation (`rtl/`)
* **[`rtl/zc_spi_flash_firewall.sv`](rtl/zc_spi_flash_firewall.sv):** Active SPI flash firewall enforcing Bank B containment, rising `/CS` edge gating while `SCK=0`, `05h RDSR1` WIP status polling reconciliation, and secondary-side isolation (`spi_update_state_e`).
* **[`rtl/zc_obi_subordinate_bridge.sv`](rtl/zc_obi_subordinate_bridge.sv):** Decoupled Open Bus Interface (OBI) slave bridge with a 1024-cycle orphan transaction drain watchdog and `ST_TRAP` synthetic error injection.
* **[`rtl/zc_aon_post_auth_ctrl.sv`](rtl/zc_aon_post_auth_ctrl.sv):** Always-On power domain controller enforcing a 4-phase atomic Direct Access Interface (DAI) handshake and sticky session-mismatch lockout for OTP memory.
* **[`rtl/zc_otp_pkg.sv`](rtl/zc_otp_pkg.sv):** Hsiao (22,16) SECDED encoding functions, state enums, and codeword generators ($d_{\min}=4$).

### Verification Evidence & Known Technical Limitations
* **Formally Verified (Gate C HDL Level):**
  - Formal SVA properties verified under Yosys 0.33 / yosys-smtbmc / Z3 ($t=20$ $k$-induction) in [`fv/`](fv/).
  - Cycle-accurate testbenches in [`tb/`](tb/) executed under Verilator and Icarus Verilog.
  - Automated Gate B regression suite: [`scripts/verify_gate_b_rev28d.ps1`](scripts/verify_gate_b_rev28d.ps1) (20/20 PASS).
* **Known Silicon Limitations — Gate D: UNVERIFIED:**
  > [!WARNING]
  > **Physical Silicon & SoC Integration Boundary**
  > The RTL implementations and formal models must be evaluated strictly within their documented digital scope. Specifically:
  > 1. **Clock Domain Crossing (CDC):** In `zc_aon_post_auth_ctrl.sv`, `rst_sys_ni` and `rom_exec_active_i` cross between asynchronous clock domains without dedicated dual-rank synchronizers; formal proofs assume the `async2sync` abstraction.
  > 2. **SoC Crossbar DMA Firewalls:** Standalone IP blocks do not replace top-level IOMMU or multi-master bus crossbar firewalls.
  > 3. **Physical Foundry Physics:** High-voltage OTP programming pulses ($V_{\text{PP}}$), analog PVT variations, flash trace capacitive reflections, and silicon side-channel analysis (DPA/EMA) are unverified and formally deferred to Gate D.
  > 4. **RFC Status:** Proposed V4 architecture enhancements ([`docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md`](docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md)) remain in draft status (`DRAFT / NOT RATIFIED`).

---

## 3. Governance, Integrity & Licensing

### 🏛️ Governance & Certification Framework
- **[ZC-CORE Brand, Trademark & Certification Policy](zero-cloud-core-brand-and-trademark-policy.md):** 4-tier certification hierarchy (Self-Declared to FreeCuli Certified™) and trademark usage rights.
- **[ZC-CORE Versioning and Governance Policy](zero-cloud-core-versioning-and-governance.md):** Strict SemVer governance rules, normative freeze mechanisms, and standards committee amendment procedures.
- **[Academic Citation Metadata (`CITATION.cff`)](CITATION.cff):** Formal citation specification for academic and scientific publications.

### 🔐 Cryptographic Integrity & Release Anchors
- **[ZC-CORE Release Manifest (`ZERO-CLOUD-RELEASE-MANIFEST.md`)](ZERO-CLOUD-RELEASE-MANIFEST.md):** Cryptographic SHA-256 seal over all 14 canonical specifications and 4 RTL blocks for candidate `v4.0.0-rc1`.
- **[Historical Release Manifest (`RELEASE-MANIFEST-v3.3.0-rc2.md`)](RELEASE-MANIFEST-v3.3.0-rc2.md):** Cryptographically archived state of previous release candidate.

### ⚖️ Legal Grounding & Licensing Terms
This repository employs a carefully differentiated legal structure to protect open hardware collaboration while enabling commercial adoption:
- **Hardware Source Code & Synthesizable RTL (`rtl/`, `fv/`, `tb/`):** Licensed under the **CERN Open Hardware Licence Version 2 - Strongly Reciprocal ([CERN-OHL-S-2.0](LICENSE))**.
- **Normative Architectural Specifications & Documentation:** Governed by the open standard licensing terms set forth in [`zero-cloud-dual-licensing.md`](zero-cloud-dual-licensing.md).
- **Commercial Dual-Licensing (Route B):** Commercial manufacturers desiring to implement proprietary closed-source ASICs/SoCs without reciprocal design disclosure may obtain a commercial exemption license.
- **Patent Non-Aggression & Founder Attestation:** Backed by Open Invention Network (OIN) membership commitments and the founder's sworn non-aggression representation (`ATTEST-01`).
- **Commercial Certification:** Industrial AIoT manufacturers seeking official certification and trademark usage rights for the #FreeCULI badge should consult [FreeCuli.com](https://freeculi.com).
