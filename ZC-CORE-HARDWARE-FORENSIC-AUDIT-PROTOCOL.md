# ZC-CORE-HARDWARE-FORENSIC-AUDIT-PROTOCOL

**Version:** v3.3.0-rc1 (Pending Experimental Validation)
**License:** CERN-OHL-S v2.0
**Scope:** Evidence Acquisition, Preservation, Chain of Custody, and Independent Review

---

## 1. Introduction and Scope
This Forensic Audit Protocol defines the mandatory procedures for acquiring, preserving, identifying, hashing, and transferring physical measurement evidence in compliance with ZC-CORE.

**Important Note on Scope:** This protocol does *not* define what is tested, nor does it define the normative pass/fail acceptance thresholds. For normative measurement requirements, refer to the Conformance Test Specification (CTS). This protocol solely governs the lifecycle, provenance, and integrity of the evidence.

## 2. Core Metrology & Metacognitive Principles
The forensic audit is built strictly upon the separation of four validity layers:
1. **Measurement Validity:** Was the physical event measured correctly and reproducibly by a calibrated instrument?
2. **Threshold Validity:** Is the normative acceptance threshold scientifically sufficient for security?
3. **Decision Validity:** How is the decision rule (guard-banding) applied to measurement uncertainty?
4. **Evidence Integrity:** Has the collected measurement record been altered since acquisition?

> **WARNING - HASH INTEGRITY SEMANTICS:**
> The calculation of a SHA-256 hash guarantees the *integrity* of a file against subsequent alteration. It does **not** prove Measurement Validity, Threshold Validity, or Authenticity. A mathematically flawless SHA-256 hash of an improperly calibrated oscilloscope trace only proves that the improper trace has not been altered.

## 3. Evidence Hierarchy
Forensic evidence MUST be categorized and preserved according to the following strict hierarchy:

### 3.1 Primary Evidence (Mandatory)
The primary record of the measurement. 
*Note: Primary Evidence ≠ Ground Truth. A faulty calibration yields faulty Primary Evidence.*
* Raw binary measurement data directly from instruments
* Raw CSV or machine-readable data acquisition outputs
* Instrument-native measurement files (e.g., .wfm, .h5)
* Machine-readable execution logs (e.g., Python TVLA logs)

### 3.2 Supporting Evidence (Auxiliary)
Visual or supplemental documentation to aid independent review. **Supporting evidence SHALL NOT replace Primary Evidence.**
* Oscilloscope display captures (Screenshots)
* Photographs of the Device Under Test (DUT) and measurement fixture
* Laboratory examiner notes

### 3.3 Metadata (Context)
The contextual record required to achieve experimental reproducibility.
* DUT Identity (Hardware/PCB Revision, BOM Configuration, Firmware Version/Hash)
* Instrument Identity (Make, Model, Serial Number)
* Calibration Status (Date, Certificate ID)
* Environmental Conditions (Temperature, Supply Voltage, Ambient Noise)
* Operator/Examiner Identity
* High-precision Timestamps (Clock synchronization source documented)
* Explicit instrument configuration (Bandwidth, Sampling Rate, Reference Impedance)

## 4. Formal Chain of Custody Record
To ensure evidence traceabilty, a formal Chain of Custody (CoC) record must be maintained for each evidence package. The CoC MUST record the lifecycle and provenance of the evidence:

Evidence ID -> Creation -> Acquisition -> Hash -> Storage -> Transfer -> Access -> Review -> Final Archive

### 4.1 Transformation Hashing (Provenance)
For every derived data transformation, the child file must reference the parent file and include its own hash. 
Example: instrument-native [Hash A] -> CSV Export [Hash B] -> Analysis Dataset [Hash C] -> Result.

For every transaction in the chain, the laboratory MUST log:
* **Timestamp:** (ISO 8601 UTC + synchronization source)
* **Actor:** (Examiner or automated system)
* **Action:** (e.g., "Exported from Oscilloscope", "Transferred to Cold Storage")
* **Resulting Hash/State:** (The SHA-256 of the artifact at the moment of action)

## 5. Independent Review and Repeatability
**Evidence Integrity ≠ Experimental Reproducibility.**
The evidence package must be robust enough that an independent, qualified engineering reviewer can:
1. Validate the derived-data transformation chain strictly from the Primary Evidence (Raw Data) and Metadata.
2. Verify the cryptographic hashes in the Chain of Custody.
3. Configure an equivalent instrument and DUT to attempt experimental reproduction of the measurement validity, if required.