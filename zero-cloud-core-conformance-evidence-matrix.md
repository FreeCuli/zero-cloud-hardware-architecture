# Conformance Evidence Matrix

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S v2.0](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)
[![Standard](https://img.shields.io/badge/ZC--CORE-v3.2.0-black.svg)]()

This document establishes the audit framework for the ZC-CORE methodology. It normatively links the core invariants (M-Series) to specific adversarial attacks (AT-Series), maps them to the required Conformance Test Specification (FC-ZC-CTS), and defines the exact physical evidence required for compliance.

## Terminology (RFC 2119)
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

## The Conformance Matrix

| Invariant | Attack Class | CTS Test ID | Required Physical Evidence (Normative) |
| :--- | :--- | :--- | :--- |
| **M2, M4, M5** | AT-001, AT-002, AT-006, AT-007 | FC-ZC-001 | DMA/bus-master isolation evidence; proof zero read-capable path exists from Network Domain to Trusted Domain. |
| **M1, M9** | AT-001, AT-009 | FC-ZC-013, FC-ZC-014 | Signed BOM and PCB Schematic proving exclusive sensor routing to Trusted Domain. Complete Interface Inventory. |
| **M2** | AT-004 | FC-ZC-002, FC-ZC-009, FC-ZC-011 | PCB X-Ray, Vector Network Analyzer (VNA) demonstrating <-80 dBm coupling (evaluated under CTS Annex B measurement and uncertainty rules). |
| **M3, M4** | AT-001, AT-008 | FC-ZC-003 | Oscilloscope injection logs showing 0 bits of reverse data transmission. |
| **M5** | AT-007 | FC-ZC-008 | Trusted-Domain Control Surface Inventory proving network SoC cannot halt/reset NPU. |
| **M6** | AT-005 | FC-ZC-005, FC-ZC-006, FC-ZC-007 | Fused JTAG/SWD physical verification; Signed bootloader hashes. |
| **M7, M8** | AT-003 | FC-ZC-004, FC-ZC-012 | High-speed logic analyzer traces of SRAM/Cache zeroization occurring within <10ms. |
| **M10** | All | FC-ZC-001–016 as applicable | Independent laboratory evidence mapping to verifiable report provenance. |
| **C3-Specific** | T4, T5 | FC-ZC-015, FC-ZC-016 | Multi-lab ISO/IEC 17025 testing reports (under applicable ISO/IEC 17065 scheme) for invasive decapping and fault injection. |


## Normative Traceability Matrix (M-Series - AT-Series - FC-ZC-CTS)

This matrix establishes absolute traceability for independent auditors, mapping each mandatory security invariant to its mitigated attack vector, required test protocol, and expected evidence.

| Invariant | Attack Class | CTS Test ID | Required Evidence | Pass/Fail Criteria |
| :--- | :--- | :--- | :--- | :--- |
| **M2, M4, M5** | AT-001, AT-002, AT-006, AT-007 | FC-ZC-001 | DMA/peripheral bridge isolation logs, bus-master audit | Zero read-capable path from Network Domain to Trusted Domain. |
| **M1 (Trusted Acquisition)** | AT-001, AT-009 | FC-ZC-013, FC-ZC-014 | Hardware Interface Manifest (HIM), Signed BOM | Zero undocumented sensory paths. |
| **M2 (Physical Boundary)** | AT-004 | FC-ZC-002, FC-ZC-009, FC-ZC-011 | VNA, TDR, PCB X-Ray | Leakage < -80 dBm (evaluated under CTS Annex B). |
| **M3 (One-Way Flow)** | AT-008, AT-010 | FC-ZC-003, FC-ZC-010 | Oscilloscope, Signal Generator | Mutual Info bound I(X;Y) < MI_upper_bound. |
| **M4 (Reverse-Read Block)** | AT-001, AT-008 | FC-ZC-003 | Oscilloscope injection logs | Strictly < 5mVpp upon reverse probe. |
| **M5 (Control-Plane Isolate)**| AT-007 | FC-ZC-008 | Trusted-Domain Control Surface Inventory | Zero indirect NPU reset/clock overrides. |
| **M6 (Hardware Integrity)** | AT-005 | FC-ZC-005, FC-ZC-006, FC-ZC-007 | Signed Bootloader hashes, eFuse maps | Rollback prevention verified. |
| **M7 (Lifetime Enforcement)** | AT-003 | FC-ZC-004, FC-ZC-012 | High-speed logic analyzer traces | Volatile destruction sequence initiated. |
| **M8 (Data Destruction)** | AT-003, AT-004 | FC-ZC-004, FC-ZC-012 | Forensic recovery analysis | Remanence Rate R_rate <= 0.01%. |
| **M9 (Complete Inventory)** | AT-009, AT-006 | FC-ZC-013, FC-ZC-014 | Complete BOM, Peripheral accounting | Zero bypass channels exist. |
| **M10 (Independent Evidence)**| All | FC-ZC-001–016 as applicable | Third-party (ISO 17025) lab reports | Empirical compliance vs vendor claims. |
| **C3 High-Assurance Profile** | T4 (Decapping), T5 (Glitching) | FC-ZC-015, FC-ZC-016 | ISO/IEC 17065 Scheme / 17025 Testing | Multi-lab verified resilience. |

## Interpretation
Manufacturers claiming ZC-CORE compliance SHALL provide the specific physical evidence listed in this matrix. Software assertions or documentation-only claims are strictly insufficient for M-Invariant validation.
