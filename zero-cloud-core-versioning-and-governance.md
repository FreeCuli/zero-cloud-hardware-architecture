# Versioning & Governance Policy

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S v2.0](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)
[![Standard](https://img.shields.io/badge/ZC--CORE-v3.2.0-black.svg)]()

This document outlines the formal governance model, versioning semantics, and amendment processes for the ZC-CORE Universal Zero-Cloud Hardware Methodology.

## 1. Version Numbering
ZC-CORE follows Semantic Versioning (`MAJOR.MINOR.PATCH`).
*   **MAJOR:** Normative changes to the Core Invariants (M1-M10) or architectural pillars that break backward compatibility.
*   **MINOR:** Informative additions, new Attack Taxonomies (AT-Series), or new CTS tests that do not alter the fundamental Invariants. **A new CTS test that introduces a new mandatory conformance obligation SHALL NOT be classified as purely informative. If it changes the compliance surface of existing implementations, the release SHALL be versioned as MINOR or MAJOR according to the compatibility rules above.**
*   **PATCH:** Typographical fixes, clarifications, or document structure updates that do not affect conformance outcomes.

> **Normative Threshold Rule:** Any change to an existing mandatory PASS/FAIL criterion, measurement threshold (e.g., MI_upper_bound, TVLA t-value, R_rate), required evidence class, or test procedure that can alter conformance outcomes SHALL NOT be released as a PATCH. Such changes MUST be versioned as MINOR or MAJOR depending on whether they alter a Core Invariant.

## 2. Normative vs. Informative
*   **Normative:** Sections defining the strict requirements for compliance. Uses RFC 2119 keywords (`SHALL`, `MUST`, `REQUIRED`).
*   **Informative:** Examples, representative implementations, and contextual explanations. Uses keywords like `MAY`, `RECOMMENDED`, or explicitly states "For example."

## 3. CTS Compatibility Policy
If a MAJOR version update alters an M-Invariant, the corresponding FC-ZC-CTS test version MUST be incremented, and prior test reports SHALL be considered deprecated for the new major version. 
Devices certified under previous major versions retain their certification *for that version only*, but cannot claim compliance with the latest ZC-CORE standard without passing the updated Evidence Matrix.

## 4. Amendment Process and Deprecation
Any proposal to amend the ZC-CORE methodology MUST address the `zero-cloud-core-attack-taxonomy.md` by proving how the proposed amendment mitigates existing or newly discovered attack classes. Technologies or mechanisms found vulnerable to new Attack Classes SHALL be formally deprecated in the next MINOR release.

## 5. Release Freeze & Artifact Generation
To ensure the integrity of the methodology, FreeCuli enforces a strict Release Freeze process for canonical standard releases:
1. **Release Candidate** & Technical Review
2. **Normative Freeze:** No further changes to requirements.
3. **SHA-256 Manifest Generation:** Creating the verifiable `ZERO-CLOUD-RELEASE-MANIFEST.md`.
4. **Git Tag:** Annotated tag creation (e.g., `v3.2.0`).
5. **Zenodo Publication:** Archival and DOI assignment.

> **Integrity Rule:** Once a release is frozen and tagged, normative files SHALL NOT change without a new release identifier. The final Zenodo artifact package SHA-256 MUST be traceable back to the corresponding Git commit.
