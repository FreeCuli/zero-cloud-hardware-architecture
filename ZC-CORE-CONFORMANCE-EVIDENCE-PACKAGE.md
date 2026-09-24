# ZC-CORE Conformance Evidence Package (Normative Template)

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S v2.0](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)

This document defines the normative structure of the **Conformance Evidence Package** that must be submitted to the FreeCuli Certification Scheme Owner or maintained by the manufacturer to claim ZC-CORE compliance.

## 1. Device Evaluation Identity (Target of Evaluation)
To ensure that physical laboratory testing is strictly bound to the production hardware, the evidence package MUST declare the cryptographic and physical identity of the tested device:
* **Manufacturer / Brand:**
* **Product Name / Model Number:**
* **Hardware Revision ID:**
* **PCB Layout Revision / Hash:**
* **BOM (Bill of Materials) Revision / Hash:**
* **Bootloader Firmware Hash (SHA-256):**
* **NPU OS/Firmware Hash (SHA-256):**
* **AI Model Hash (SHA-256):**
* **Evaluated Serial Number Range / Batch ID:**

## 2. Laboratory & Equipment Identity
To guarantee reproducibility and trace evidence provenance, the executing laboratory MUST declare:
* **Evaluating Laboratory Name:**
* **Accreditation (e.g., ISO/IEC 17025):**
* **Instrument IDs (Oscilloscopes, Probes):** MUST include serial numbers, calibration dates, and measurement uncertainty bounds.
* **Analysis Software Identity:** Tool name, version, and the cryptographic hash of the analysis scripts (e.g., Python TVLA scripts) used to process raw traces.

## 3. Test Configuration & Environmental Provenance
* **Dataset ID & Randomization Seed:**
* **Acquisition Timestamp(s):**
* **Environmental Conditions:** Constant temperature maintained, voltage baseline.

## 4. FC-ZC Test Results & Corrective Actions
For each mandatory test (FC-ZC-001 to FC-ZC-016 as dictated by the target C1/C2/C3 profile), the package MUST include:
1. **Pass/Fail Verdict.**
2. **Raw Evidence Pointers:** (e.g., "See TVLA_Dataset_A.zip, traces 1 to 1,000,000").
3. **Observed Deviations.**
4. **Corrective Actions Taken.**

## 5. Certification Decision
* **Target Assurance Profile:** (C1, C2, or C3)
* **Final Scheme Decision:**
* **Authorized Signatures:**
