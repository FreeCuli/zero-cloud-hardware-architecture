# FreeCuli ZC-CORE v3.1.0: Scope & Boundary Definition

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)
[![Standard](https://img.shields.io/badge/ZC--CORE-v3.1.0-black.svg)]()

To prevent misinterpretation of the methodology's capabilities and to strictly define the liability and security guarantees of the FreeCuli standard, this document outlines the absolute Scope Boundaries of ZC-CORE.

## 1. What ZC-CORE Standardizes (In-Scope)
*   **Hardware-Enforced Local Privacy:** The physical containment of raw sensor data (audio, video, biometrics) strictly within the local device's Trusted Domain.
*   **Irreversible Data Destruction:** The mandate that all local raw data is destroyed or mathematically zeroized immediately after inference.
*   **Unidirectional Information Flow:** The physical requirement that data flows only outwards from the Trusted Domain, preventing reverse-read commands.
*   **Physical Verification:** Laboratory-grade physical evidence (oscilloscope, X-Ray, logic analyzer) to prove compliance.

## 2. What ZC-CORE Does NOT Standardize (Out-of-Scope)
*   **Cloud & Server-Side Security:** ZC-CORE makes NO guarantees about the security of the semantic data (e.g., text, metadata) *after* it has been transmitted to a cloud server or external network. ZC-CORE is strictly an Edge/AIoT device-level standard.
*   **AI Model Accuracy or Bias:** ZC-CORE does not evaluate whether the AI model correctly interprets the sensor data, only that the raw data used by the model is destroyed.
*   **Cryptographic Protocols:** While ZC-CORE mandates Secure Boot (M6), it does not dictate specific cryptographic ciphers (e.g., AES-256 vs ChaCha20) for external network communications.
*   **Physical Tamper Resistance:** ZC-CORE prevents network-based remote extraction. It does NOT guarantee protection against a highly funded, state-level attacker with prolonged physical access to the device (e.g., physically decapping the silicon chips).

## 3. Known vs. Not Claimed (Coverage Boundary)
| Area | Status | Description |
| :--- | :--- | :--- |
| **Equivalent Hardware Implementations** | Covered | Optical, Electrical, FPGA, ASIC diodes are functionally covered under M3. |
| **Future Memory Technologies** | Covered | Functionally covered under the Technology-Neutral Equivalence Principle. |
| **Side-Channel Attacks (Power/Timing)** | Partially Covered | Mitigated at the Control-Plane (M5) level, but deep cryptographic DPA (Differential Power Analysis) is outside the primary scope. |
| **Software-Only Isolation (Hypervisors)** | Explicitly Banned | Explicitly outside the ZC-CORE trusted methodology. |

