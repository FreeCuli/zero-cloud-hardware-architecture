# Scope & Boundary Definition

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S v2.0](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)
[![Standard](https://img.shields.io/badge/ZC--CORE-v3.2.0-black.svg)]()

To prevent misinterpretation of the methodology's capabilities and to strictly define the liability and security guarantees of the FreeCuli standard, this document outlines the absolute Scope Boundaries of ZC-CORE.

## 1. What ZC-CORE Standardizes (In-Scope)
*   **Hardware-Enforced Local Privacy:** The physical containment of raw sensor data (audio, video, biometrics) strictly within the local device's Trusted Domain.
*   **Data Taxonomy Definitions:** To ensure strict boundaries, ZC-CORE formally categorizes data into four normative classes:
    * **Raw Sensor Data:** The uncompressed, unmodified analog or digital output directly from a privacy-sensitive sensor.
    * **Metadata:** Contextual or environmental data (e.g., timestamp, ambient temperature) that does not inherently leak raw sensor states.
    * **Derived Sensor Representation:** Intermediate features (e.g., embeddings, Mel-spectrograms) that might indirectly allow reconstruction of raw data. Must be treated with the exact same containment rules as Raw Sensor Data.
    * **Semantic Result:** The irreversible, abstracted text or low-bandwidth state (e.g., "Person recognized", "Turn on light") that cannot be reversed to raw data. A Semantic Result SHALL NOT be considered compliant merely because it is not raw sensor data. Compliance additionally requires that the released representation does not provide a practical, statistically significant reconstruction channel for the protected raw-sensor information under the declared threat model.
    * **Actuator Command:** The final control signal sent outside the Trusted Domain.
*   **Operational Taxonomy:** 
    * **Server-Independent Core Function:** The device possesses the full capability to acquire raw data, perform inference, and execute the final semantic Actuator Command without any network connectivity.
    * **Zero-Cloud Telemetry / OTA:** The device may connect to a server for non-inference tasks (e.g., OTA updates, encrypted semantic state syncing), provided such channels are cryptographically bound and strictly comply with M3 (Unidirectional Flow) ensuring no raw sensor data is ever transmitted. **M3 governs protected raw-sensor information flow only.** Authenticated control and update channels MAY enter the Trusted Domain, but only through separately specified secure-update mechanisms as defined by M6 and FC-ZC-007. Such channels SHALL NOT create a raw-sensor read-back path or a reverse raw-sensor information channel.
*   **Irreversible Data Destruction:** The mandate that all local raw data (and derived representations) is destroyed or mathematically zeroized immediately after inference.
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
