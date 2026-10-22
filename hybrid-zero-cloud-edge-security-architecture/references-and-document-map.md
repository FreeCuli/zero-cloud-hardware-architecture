# Hybrid Zero-Cloud & Edge Security Architecture
## Cross-Reference Graph & Document Map

**Document ID:** `ZC-HYBRID-DOC-MAP-01`
**Classification:** Canonical Architecture Suite Reference Map
**Status:** `CANDIDATE BASELINE / UNRATIFIED`
**Parent Document:** [`README.md`](README.md)

---

## 1. Architectural Cross-Reference Graph

The **Hybrid Zero-Cloud & Edge Security Architecture** links all repository components into a coherent, verifiable hierarchy:

```
                                  [ ROOT GOVERNANCE & LICENSING ]
                                                 |
         +---------------------------------------+---------------------------------------+
         |                                       |                                       |
         v                                       v                                       v
[ zero-cloud-core-methodology-invariants.md ]  [ zero-cloud-dual-licensing.md ]  [ ZERO-CLOUD-RELEASE-MANIFEST.md ]
(M1-M10 Immutable Baseline)                    (CERN-OHL-S-2.0 / Route B)        (18/18 Cryptographic Seal)
         |                                                                               |
         +---------------------------------------+                                       v
         |                                       |                       [ RELEASE-MANIFEST-v3.3.0-rc2.md ]
         v                                       v                       (Archived Historical State)
[ zero-cloud-hardware-reference-architecture.md ] [ hybrid-zero-cloud-edge-security-architecture/ ]
(ZC-PROFILE-STRICT Baseline)                   (ZC-PROFILE-HYBRID Candidate Suite)
                                                 |
         +---------------------------------------+---------------------------------------+
         |                                       |                                       |
         v                                       v                                       v
[ docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md ]    [ rtl/ (Silicon Core) ]           [ fv/ & tb/ (Verification) ]
(Unratified Draft Standards Proposal)          - zc_spi_flash_firewall.sv         - Formal Harnesses (SVA t=20)
                                               - zc_obi_subordinate_bridge.sv     - Protocol E2E Testbenches
                                               - zc_aon_post_auth_ctrl.sv         - Codeword Equivalence
                                               - zc_otp_pkg.sv
```

---

## 2. Complete Inventory of Linked Repository Artifacts

### 2.1 Hybrid Architecture Specification Suite (`hybrid-zero-cloud-edge-security-architecture/`)
* **[`README.md`](README.md):** Main entry point, architectural motivation, profile overview, and boundary notice.
* **[`architecture-and-security-boundaries.md`](architecture-and-security-boundaries.md):** Trust domains, bus topology, data/control flows, and out-of-scope boundaries.
* **[`strict-hybrid-compatibility.md`](strict-hybrid-compatibility.md):** STRICT vs HYBRID comparative analysis, clause-by-clause M1–M10 mapping, and data taxonomy reconciliation.
* **[`implementation-and-evidence-matrix.md`](implementation-and-evidence-matrix.md):** Bidirectional traceability between architectural claims, RTL code, formal SVA properties, and simulation testbenches.
* **[`threat-model-and-control-flows.md`](threat-model-and-control-flows.md):** Physical/logical threat taxonomy (AT-001..AT-012), end-to-end operational flows, and reset/clock domain specifications.
* **[`open-decisions-and-limitations.md`](open-decisions-and-limitations.md):** Concrete disclosure of AON/CDC risks, Gate D physical silicon deferrals, and pending governance decisions.
* **[`references-and-document-map.md`](references-and-document-map.md):** This cross-reference graph and artifact inventory.

### 2.2 Canonical Root Normative Specifications (v3.x Baseline)
* **[`README.md`](../README.md):** Repository overview and candidate integration boundaries.
* **[`zero-cloud-core-methodology-invariants.md`](../zero-cloud-core-methodology-invariants.md):** M1–M10 immutable core identity test.
* **[`zero-cloud-hardware-reference-architecture.md`](../zero-cloud-hardware-reference-architecture.md):** Hardware reference architecture for `ZC-PROFILE-STRICT`.
* **[`zero-cloud-core-scope-boundary.md`](../zero-cloud-core-scope-boundary.md):** 4-class data taxonomy and explicit standard boundaries.
* **[`zero-cloud-core-attack-taxonomy.md`](../zero-cloud-core-attack-taxonomy.md):** Physical and electrical adversarial attack vectors (AT-001..AT-010).
* **[`zero-cloud-core-conformance-test-specification.md`](../zero-cloud-core-conformance-test-specification.md):** ISO 17025 physical laboratory test procedures.
* **[`zero-cloud-core-conformance-evidence-matrix.md`](../zero-cloud-core-conformance-evidence-matrix.md):** Mapping between invariants, attack vectors, and required physical evidence.
* **[`zero-cloud-core-implementation-coverage.md`](../zero-cloud-core-implementation-coverage.md):** Representative implementation families.
* **[`zero-cloud-core-defensive-publication.md`](../zero-cloud-core-defensive-publication.md):** Technical prior-art disclosures and patent examiner guidance.
* **[`zero-cloud-core-brand-and-trademark-policy.md`](../zero-cloud-core-brand-and-trademark-policy.md):** Certification hierarchy and trademark guidelines.
* **[`zero-cloud-core-versioning-and-governance.md`](../zero-cloud-core-versioning-and-governance.md):** SemVer rules, normative freeze process, and amendment rules.
* **[`ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md`](../ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md):** Formal evidence package and sign-off records.
* **[`ZC-CORE-HARDWARE-FORENSIC-AUDIT-PROTOCOL.md`](../ZC-CORE-HARDWARE-FORENSIC-AUDIT-PROTOCOL.md):** Forensic teardown protocol for physical devices.
* **[`CITATION.cff`](../CITATION.cff):** Academic citation metadata (v4.0.0-rc1).

### 2.3 Legal, Licensing & Cryptographic Manifests
* **[`LICENSE`](../LICENSE):** Official CERN-OHL-S-2.0 legal text.
* **[`zero-cloud-dual-licensing.md`](../zero-cloud-dual-licensing.md):** CERN-OHL-S-2.0 §7.2 patent termination, Route B commercial exemption, and kurucu beyanı (`ATTEST-01`).
* **[`ZERO-CLOUD-RELEASE-MANIFEST.md`](../ZERO-CLOUD-RELEASE-MANIFEST.md):** SHA-256 cryptographic seal over 14 canonical specs and 4 RTL blocks.
* **[`RELEASE-MANIFEST-v3.3.0-rc2.md`](../RELEASE-MANIFEST-v3.3.0-rc2.md):** Frozen cryptographic state of previous RC2 milestone.

### 2.4 Synthesizable Route B Silicon RTL Blocks (`rtl/`)
* **[`rtl/zc_spi_flash_firewall.sv`](../rtl/zc_spi_flash_firewall.sv):** Gated /CS, SCK=0 rising edge strobe, 05h RDSR1 status reconciler, Bank B commit logic.
* **[`rtl/zc_obi_subordinate_bridge.sv`](../rtl/zc_obi_subordinate_bridge.sv):** Decoupled OBI slave interface, 1024-cycle orphan watchdog, `ST_TRAP` synthetic error injection.
* **[`rtl/zc_aon_post_auth_ctrl.sv`](../rtl/zc_aon_post_auth_ctrl.sv):** Always-on 4-phase DAI handshake controller, single-cycle grant consumption, session mismatch fatal lock.
* **[`rtl/zc_otp_pkg.sv`](../rtl/zc_otp_pkg.sv):** Hsiao (22,16) SECDED encoding functions, state machine enums, codeword parity generators.

### 2.5 Formal Verification Suites (`fv/`)
* **[`fv/zc_spi_formal_proof.sv`](../fv/zc_spi_formal_proof.sv):** Bounded model checking and $k$-induction harness for SPI firewall (`F-SPI-01..04`).
* **[`fv/zc_obi_formal_proof.sv`](../fv/zc_obi_formal_proof.sv):** Formal proof harness for OBI subordinate bridge (`F-OBI-01..07`).
* **[`fv/zc_otp_formal_proof.sv`](../fv/zc_otp_formal_proof.sv):** Formal proof harness for AON OTP controller (`F-OTP-01..06`).
* **[`fv/zc_m7_m8_ni_sva.sv`](../fv/zc_m7_m8_ni_sva.sv):** 2-trace miter equivalence specification for top-level SoC non-interference (Gate D target).

### 2.6 Simulation Testbenches & Verification Scripts (`tb/`, `scripts/`)
* **[`tb/tb_zc_spi.sv`](../tb/tb_zc_spi.sv):** SPI firewall cycle-accurate functional testbench.
* **[`tb/tb_zc_obi.sv`](../tb/tb_zc_obi.sv):** OBI bridge testbench verifying 1,024-cycle orphan timeout and `ST_TRAP`.
* **[`tb/tb_zc_otp_protocol_e2e.sv`](../tb/tb_zc_otp_protocol_e2e.sv):** End-to-end 7-scenario cycle-accurate protocol testbench for OTP DAI controller.
* **[`tb/tb_zc_otp_fn_equiv.sv`](../tb/tb_zc_otp_fn_equiv.sv):** 12,240-word exhaustive mathematical equivalence testbench.
* **[`scripts/verify_gate_b_rev28d.ps1`](../scripts/verify_gate_b_rev28d.ps1):** Automated regression verification suite.

### 2.7 Standards Proposals & Architecture Drafts (`docs/rfc/`, `docs/architecture/`)
* **[`docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md`](../docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md):** Proposed V4 architecture specification (RFC-0004 DRAFT).
* **[`docs/rfc/ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md`](../docs/rfc/ZC-CORE-V4-DUAL-LICENSING-POLICY-RFC.md):** Proposed dual-licensing governance updates (DRAFT).
* **[`docs/rfc/ZC-CORE-V4-TRADEMARK-AND-CONFORMANCE-RFC.md`](../docs/rfc/ZC-CORE-V4-TRADEMARK-AND-CONFORMANCE-RFC.md):** Proposed certification tier updates (DRAFT).
* **[`docs/architecture/zc-core-security-profiles.md`](../docs/architecture/zc-core-security-profiles.md):** Technical specification for STRICT and HYBRID security profiles.
* **[`docs/architecture/zc-core-hybrid-interconnect.md`](../docs/architecture/zc-core-hybrid-interconnect.md):** Technical specification for hybrid bus interconnects.
