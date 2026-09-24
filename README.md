# FreeCuli ZC-CORE: Universal Zero-Cloud Hardware Methodology

The Hardware-Enforced, privacy-first hardware reference methodology for Server-Independent AIoT and Edge AI devices (Smart Home, Medical, Industrial, Defense).

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S v2.0](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)
[![Standard](https://img.shields.io/badge/ZC--CORE-v3.2.1-black.svg)](https://github.com/FreeCuli/zero-cloud-hardware-architecture/releases/tag/v3.2.1)

## Overview
This repository contains the official, strictly falsifiable **ZC-CORE v3.2.1 Methodology**. Originally pioneered as a smart-kitchen architecture, it has evolved into a universal, sector-agnostic framework for designing smart devices that operate without centralized server/cloud dependency. As a proud member of the Open Invention Network (OIN), FreeCuli protects the open-source hardware ecosystem.

By enforcing Physical Data Diodes, Trust Boundaries, and Hardware-Enforced Raw-Data Destruction / Invalidation (including power-cut, cryptographic zeroization, or independently validated equivalent mechanisms), this methodology is designed to mitigate raw-sensor exposure across the trust boundary (microphone/camera streams) from any AIoT appliance. It is designed to mitigate remote network-based raw-sensor extraction, including attacks originating from compromised network infrastructure, and structurally enforces Privacy-by-Design, providing a hardware-enforced trust boundary for local inference.

## The Core Philosophy: Implementation Freedom & Methodological Consistency

**1. Implementation Freedom & Methodological Consistency**
ZC-CORE does not prescribe or restrict any particular end-user appliance, hardware component, semiconductor vendor, processor, memory technology, or implementation stack. Conformance is determined by the achievement of defined functional security outcomes and their verifiable evidence, rather than by the use of any specific component or implementation technology. 

This principle applies across the AIoT value chain, including semiconductor, module, device, appliance, platform, and system-level implementations. 

**2. Conformance ≠ Code Ownership**
Passing the ZC-CORE Conformance Test Specification (CTS) does not grant FreeCuli any ownership over a manufacturer's implementation. A manufacturer retains full Intellectual Property (IP) rights over their proprietary codebase, custom ASIC/SoC designs, and firmware. ZC-CORE standardizes the *security properties and verification methodology*, NOT the vendor's implementation.

## Core Documents (RFC 2119-Style Normative Specification)

### 🏗️ Primary Architecture
1. **[The ZC-CORE Hardware Fortress (Architecture Document)](zero-cloud-hardware-reference-architecture.md)**
   * Mandatory specifications for Physical Air-Gap, Hardware Data Diode, and Trust Boundary security pillars for Edge AI.
2. **[ZC-CORE Methodology Invariants](zero-cloud-core-methodology-invariants.md)**
   * The absolute DNA of the standard (M1-M10). The normative technological rules that define ZC-CORE.

### 🛡️ Prior Art & Legal
3. **[Zero-Cloud Defensive Publication (Prior Art Specification)](zero-cloud-core-defensive-publication.md)**
   * A timestamped technical disclosure establishing public prior-art baseline to prevent third-party patenting.
4. **[ZC-CORE Dual-Licensing Framework](zero-cloud-dual-licensing.md)**
   * Open-source (CERN-OHL-S v2.0) rules vs. Commercial Exemption (B2B) licensing models and patent retaliation clauses.
5. **[ZC-CORE Scope & Boundary Definition](zero-cloud-core-scope-boundary.md)**
   * Explicit definitions of what the standard guarantees (on-device privacy) vs. what it does not (cloud security).

### 🔬 Testing & Evidence
6. **[FC-ZC-Conformance-Test-Specification (CTS)](zero-cloud-core-conformance-test-specification.md)**
   * The physical laboratory procedures (oscilloscope, multimeter, X-Ray) required to prove hardware compliance.
7. **[ZC-CORE Conformance Evidence Matrix](zero-cloud-core-conformance-evidence-matrix.md)**
   * Maps every invariant and attack vector to the required physical evidence for verification.

### ⚔️ Threat Modeling & Coverage
8. **[ZC-CORE Attack Taxonomy](zero-cloud-core-attack-taxonomy.md)**
   * The official classification of physical and side-channel threats (AT-001 to AT-010) mitigated by the methodology.
9. **[ZC-CORE Implementation Coverage Matrix](zero-cloud-core-implementation-coverage.md)**
   * Matches normative requirements to representative technology classes (Optical, FPGA, ASICs).

### 🏛️ Governance & Certification
10. **[ZC-CORE Brand, Trademark & Certification Policy](zero-cloud-core-brand-and-trademark-policy.md)**
    * The 4-tier certification hierarchy (Self-Declared to FreeCuli Certified™) and trademark usage rights.
11. **[ZC-CORE Versioning and Governance Policy](zero-cloud-core-versioning-and-governance.md)**
    * The rigid rules governing how the standard evolves, deprecates old methods, and manages change control.
12. **[ZC-CORE Release Manifest (v3.2.1)](ZERO-CLOUD-RELEASE-MANIFEST.md)**
    * The cryptographic SHA-256 seal of this release, binding all documents to a verifiable timeline.

## Commercial Certification
Industrial AIoT manufacturers utilizing this architecture in proprietary hardware must acquire a B2B Certification and Trademark License to obtain the official FreeCuli certification and trademark usage rights for the #FreeCULI badge. See [FreeCuli.com](https://freeculi.com) for details.
