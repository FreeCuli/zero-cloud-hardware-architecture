# Methodology Invariants

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S v2.0](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)
[![Standard](https://img.shields.io/badge/ZC--CORE-v3.2.1-black.svg)]()

## 1. Purpose & Terminology
This document normatively defines the **immutable core identity** (Invariants) of the ZC-CORE Methodology. 
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

For specific implementation classes, attack vectors, and conformance evidence mapping, this document MUST be read in conjunction with:
* `zero-cloud-core-attack-taxonomy.md`
* `zero-cloud-core-implementation-coverage.md`
* `zero-cloud-core-conformance-evidence-matrix.md`

## 2. ZC-CORE Methodology Identity Test (M1-M10)
To be considered a functional implementation of the ZC-CORE methodology, a system MUST meet the following causal sequence and constraints. 

* **M1 (Trusted Sensor Acquisition):** Raw sensor data (audio/video) SHALL NEVER leave the Trusted Domain.
* **M2 (Hardware-Enforced Domain Boundary):** The separation between the Trusted Domain and the Network/Control Domain MUST be enforced physically, not merely via software isolation (VLANs, sandboxes).
* **M3 (One-Way Information Flow):** Protected raw-sensor information and derived representations SHALL flow strictly from the Trusted Domain to the Network Domain through a physically verifiable unidirectional channel. Authenticated control-plane and firmware-update traffic MAY enter the Trusted Domain, provided it cannot create a raw-sensor read-back path or a reverse raw-sensor information channel.
* **M4 (Reverse-Read Impossibility):** It MUST be physically or logically impossible for the Network/Control Domain to execute a functional reverse read (raw sensor read-back) from the Trusted Domain over a physical reverse channel. This is distinct from derived-data inference, reconstruction attacks, or side-channel leakage, which are mitigated by M1, M3, and M5.
* **M5 (Control-Plane Isolation):** The Trust Boundary MUST encompass not just the data path, but the control, memory, power, reset, clock, DMA, and debug paths.
* **M6 (Hardware-Rooted Execution Integrity):** The secure boot and update trust chain SHALL strictly cover the entire Trusted Domain, including the AI model weights and parameters.
* **M7 (Raw-Data Lifetime Enforcement):** The availability of raw data MUST be strictly bound to the local inference lifecycle.
* **M8 (Post-Inference Destruction/Invalidation):** Once inference completes, all persistent and temporary copies of raw data SHALL become irreversibly unrecoverable (e.g., physically destroyed or cryptographically zeroized across all caching layers).
* **M9 (Complete Sensor Inventory):** ALL privacy-sensitive sensors on the device MUST share the same absolute trusted boundary. Auxiliary sensors SHALL NOT bypass this.
* **M10 (Independent Conformance Evidence):** Conformance MUST be based strictly on objective, measurable physical laboratory evidence, never on unverified manufacturer declarations.

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
* **Reference Hardware (CERN-OHL-S v2.0):** The specific open-source hardware schematics, PCB layouts, and data diode board designs provided by FreeCuli.

Independent manufacturers may adopt the ZC-CORE methodology using their own proprietary hardware designs. However, utilizing FreeCuli's specific Reference Hardware schematics immediately binds the manufacturer to the **Strongly Reciprocal** open-source obligations of the CERN-OHL-S v2.0 license, unless a Commercial Exemption is acquired. 

## 5. IPC/CPC Classification Candidates (Patent Search Optimization)
To ensure this methodology and its associated Defensive Publication are highly discoverable by patent examiners (WIPO, USPTO, EPO) and successfully establish Prior Art against third-party patent attempts, the ZC-CORE methodology maps to the following International Patent Classifications (IPC) and Cooperative Patent Classifications (CPC):
* **H04L 9/00:** Cryptographic mechanisms or secret arrangements.
* **G06F 21/50:** Monitoring users, programs or devices to maintain the integrity of platforms.
* **G06F 21/70:** Protecting specific internal or peripheral components, in which the protection is tied to hardware.
* **G06N 3/04:** Architecture, e.g., network topology (AI edge processing).
* **H04W 12/00:** Security arrangements; Authentication; Data privacy in wireless networks (AIoT).
