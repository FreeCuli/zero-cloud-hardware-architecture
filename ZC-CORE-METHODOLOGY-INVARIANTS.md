# ZC-CORE Methodology Invariants (v3.0)
[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)

## 1. Purpose: The DNA of the Methodology
This document legally and technically defines the **immutable core identity** (Invariants) of the ZC-CORE Methodology. It protects the methodology from being cloned or repackaged under different terminology. Any third-party system, standard, or hardware architecture that implements the functional combination of these invariants is operating within the ZC-CORE prior-art domain, regardless of the specific components, testing laboratory, or nomenclature used.

## 2. ZC-CORE Methodology Identity Test (M1-M10)
To be considered a functional implementation of the ZC-CORE methodology, a system MUST meet the following causal sequence and constraints. 

* **M1 (Trusted Sensor Acquisition):** Raw sensor data (audio/video) NEVER leaves the Trusted Domain.
* **M2 (Hardware-Enforced Domain Boundary):** The separation between the Trusted Domain and the Network/Control Domain is enforced physically, not merely via software isolation (VLANs, sandboxes).
* **M3 (One-Way Information Flow):** Information flows strictly from the Trusted Domain to the Network Domain through a physically verifiable unidirectional channel (e.g., Data Diode).
* **M4 (Reverse-Read Impossibility):** The Network/Control Domain cannot physically or logically request raw data from the Trusted Domain.
* **M5 (Control-Plane Isolation):** The Trust Boundary encompasses not just the data path, but the control, memory, power, reset, clock, DMA, and debug paths.
* **M6 (Hardware-Rooted Execution Integrity):** The secure boot and update trust chain strictly covers the entire Trusted Domain, including the AI model weights and parameters.
* **M7 (Raw-Data Lifetime Enforcement):** The availability of raw data is strictly bound to the local inference lifecycle.
* **M8 (Post-Inference Destruction/Invalidation):** Once inference completes, raw data is hardware-terminated (physically destroyed or cryptographically zeroized across all caching layers).
* **M9 (Complete Sensor Inventory):** ALL privacy-sensitive sensors on the device share the same absolute trusted boundary. No auxiliary wake-word sensors bypass this.
* **M10 (Independent Conformance Evidence):** Conformance is based strictly on objective, measurable physical laboratory evidence (BOM, schematics, oscilloscope outputs, firmware hashes), never on unverified manufacturer declarations.

**Composition Rule:** ZC-CORE is NOT merely the presence of these isolated components. It is the mandatory causal sequence: `Sensor Acquisition → Trusted Local Inference → Controlled Semantic Release → Absolute Raw-Data Destruction → Network/Actuator Operation`. Any system mirroring this sequence falls under the ZC-CORE methodology.

## 3. Negative Space Exclusions
If a hardware design incorporates any of the following, it explicitly **EXITS** the ZC-CORE methodology and is deemed non-compliant:
* Software-only isolation between the sensor and the network.
* An undocumented or hidden reverse data path (diagnostic loopbacks).
* Shared memory architectures allowing non-secure domains raw-data access.
* Controllable bidirectional isolation (where the diode can be turned off via software).
* Network-side sensor acquisition (e.g., a secondary Wi-Fi microphone).
* Firmware-dependent physical isolation (where a crash breaks the diode).
* Recoverable raw-data retention (where SRAM is not fully zeroized/powered off).
* Undocumented DMA, Reset, or Clock control paths accessible from the untrusted domain.

## 4. Hardware vs. Methodology Boundary
It is critical to distinguish between the **Methodology** and the **Covered Hardware Source**:
* **ZC-CORE Framework (Methodology):** Comprises this Invariants document, the Architecture, Defensive Publication, and CTS. It defines the public technical standard and prior art.
* **Reference Hardware (CERN-OHL-S):** The specific open-source hardware schematics, PCB layouts, and data diode board designs provided by FreeCuli.

Independent manufacturers may adopt the ZC-CORE methodology using their own proprietary hardware designs. However, utilizing FreeCuli's specific Reference Hardware schematics immediately binds the manufacturer to the **Strongly Reciprocal** open-source obligations of the CERN-OHL-S license, unless a Commercial Exemption is acquired. 

## 5. IPC/CPC Classification Candidates (Patent Search Optimization)
To ensure this methodology and its associated Defensive Publication are highly discoverable by patent examiners (WIPO, USPTO, EPO) and successfully establish Prior Art against third-party patent attempts, the ZC-CORE methodology maps to the following International Patent Classifications (IPC) and Cooperative Patent Classifications (CPC):
* **H04L 9/00:** Cryptographic mechanisms or secret arrangements.
* **G06F 21/50:** Monitoring users, programs or devices to maintain the integrity of platforms.
* **G06F 21/70:** Protecting specific internal or peripheral components, in which the protection is tied to hardware.
* **G06N 3/04:** Architecture, e.g., network topology (AI edge processing).
* **H04W 12/00:** Security arrangements; Authentication; Data privacy in wireless networks (AIoT).
