# Conformance Evidence Matrix

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)
[![Standard](https://img.shields.io/badge/ZC--CORE-v3.1.0-black.svg)]()

This document establishes the audit framework for the ZC-CORE methodology. It normatively links the core invariants (M-Series) to specific adversarial attacks (AT-Series), maps them to the required Conformance Test Specification (FC-ZC-CTS), and defines the exact physical evidence required for compliance.

## Terminology (RFC 2119)
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

## The Conformance Matrix

| Invariant | Attack Class | CTS Test ID | Required Physical Evidence (Normative) |
| :--- | :--- | :--- | :--- |
| **M1, M9** | AT-009 | FC-ZC-013 | Signed BOM and PCB Schematic proving exclusive sensor routing to Trusted Domain. |
| **M2** | AT-004 | FC-ZC-002, FC-ZC-011 | PCB X-Ray, Vector Network Analyzer (VNA) demonstrating <-80 dBm coupling. |
| **M3, M4** | AT-001, AT-008 | FC-ZC-003 | Oscilloscope injection logs showing 0 bits of reverse data transmission. |
| **M5** | AT-007 | FC-ZC-008 | Trusted-Domain Control Surface Inventory proving network SoC cannot halt/reset NPU. |
| **M6** | AT-005 | FC-ZC-005, FC-ZC-006 | Fused JTAG/SWD physical verification; Signed bootloader hashes. |
| **M7, M8** | AT-003 | FC-ZC-004, FC-ZC-012 | High-speed logic analyzer traces of SRAM/Cache zeroization occurring within <10ms. |
| **M10** | All | FC-ZC-014 | Complete Interface Inventory; Independent third-party laboratory certification report. |

## Interpretation
Manufacturers claiming ZC-CORE compliance SHALL provide the specific physical evidence listed in this matrix. Software assertions or documentation-only claims are strictly insufficient for M-Invariant validation.
