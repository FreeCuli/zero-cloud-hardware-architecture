# Versioning & Governance Policy

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S v2.0](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)
[![Standard](https://img.shields.io/badge/ZC--CORE-v3.1.0-black.svg)]()

This document outlines the formal governance model, versioning semantics, and amendment processes for the ZC-CORE Universal Zero-Cloud Hardware Methodology.

## 1. Version Numbering
ZC-CORE follows Semantic Versioning (`MAJOR.MINOR.PATCH`).
*   **MAJOR:** Normative changes to the Core Invariants (M1-M10) or architectural pillars that break backward compatibility.
*   **MINOR:** Informative additions, new Attack Taxonomies (AT-Series), or new CTS tests that do not alter the fundamental Invariants.
*   **PATCH:** Typographical fixes, clarifications, or document structure updates.

## 2. Normative vs. Informative
*   **Normative:** Sections defining the strict requirements for compliance. Uses RFC 2119 keywords (`SHALL`, `MUST`, `REQUIRED`).
*   **Informative:** Examples, representative implementations, and contextual explanations. Uses keywords like `MAY`, `RECOMMENDED`, or explicitly states "For example."

## 3. CTS Compatibility Policy
If a MAJOR version update alters an M-Invariant, the corresponding FC-ZC-CTS test version MUST be incremented, and prior test reports SHALL be considered deprecated for the new major version. 
Devices certified under previous major versions retain their certification *for that version only*, but cannot claim compliance with the latest ZC-CORE standard without passing the updated Evidence Matrix.

## 4. Amendment Process and Deprecation
Any proposal to amend the ZC-CORE methodology MUST address the `zero-cloud-core-attack-taxonomy.md` by proving how the proposed amendment mitigates existing or newly discovered attack classes. Technologies or mechanisms found vulnerable to new Attack Classes SHALL be formally deprecated in the next MINOR release.
