# Hardware Attack Taxonomy

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S v2.0](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)
[![Standard](https://img.shields.io/badge/ZC--CORE-v3.2.0-black.svg)]()

This normative annex defines the standardized taxonomy of adversarial attack vectors threatening the Zero-Cloud (ZC-CORE) physical trust boundary. It establishes a formal `AT` (Attack Taxonomy) classification to cross-reference with M-Invariants and Conformance Tests.

## Terminology (RFC 2119)
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.


## Advanced Threat Model Matrix (T-Series Expansion)

In addition to direct physical vectors (AT-Series), ZC-CORE mitigates a broad spectrum of advanced systemic and side-channel threats.

| Threat ID | Description | ZC-CORE Scope | Primary Mitigation (FC-ZC) |
| :--- | :--- | :--- | :--- |
| **T1** | Remote network compromise (Wi-Fi SoC hack) | In-Scope | Physical Air-Gap (FC-ZC-002) + Network-Domain Read Isolation (FC-ZC-001) |
| **T2** | Malicious firmware payload | In-Scope | Trusted Execution Artifact Chain (FC-ZC-005) |
| **T3** | Supply-chain compromised component | In-Scope | Hardware Interface Manifest (FC-ZC-013) |
| **T4** | Physical invasive attack (Decapping) | Partial — C3 only | Covered under C3 High-Assurance Profile. C3 evaluators SHALL follow ISO/IEC 17025-accredited invasive physical security testing procedures (with assessment under an applicable ISO/IEC 17065 scheme where required). |
| **T5** | Fault injection (Glitching) | Partial — C3 only | Covered under C3 High-Assurance Profile. C3 evaluators SHALL follow ISO/IEC 17025-accredited fault injection testing procedures (with assessment under an applicable ISO/IEC 17065 scheme where required). |
| **T6** | Clock/power glitching via Main MCU | In-Scope | Control-Plane Isolation (FC-ZC-008) |
| **T7** | EM / Power side-channel extraction | In-Scope | Formal TVLA Assessment (FC-ZC-009) |
| **T8** | Malicious OTA update | In-Scope | Secure Update & Revocation (FC-ZC-007) |
| **T9** | Undocumented secondary microphone | In-Scope | Undocumented Interface Penalty (FC-ZC-014) |
| **T10** | Cold-boot latent RAM extraction | In-Scope | 10ms Raw-Data Destruction / Zeroization (FC-ZC-004) |


## Attack Classes (AT-000 Series)

### AT-001: Direct Memory Read
*   **Description:** The network or untrusted domain initiates a direct read request to the isolated memory domain containing raw sensor data.
*   **Vector:** System Bus, Shared Memory Aperture.

### AT-002: Direct Memory Access (DMA) Read
*   **Description:** An untrusted peripheral or master bypasses the CPU to directly read raw sensor buffers via DMA.
*   **Vector:** Unrestricted IOMMU, open bus master privileges.

### AT-003: Cache Residual Read (Cold-Boot / Warm-Boot)
*   **Description:** Raw sensor data remains in volatile caching layers (L1/L2/L3, scratchpad, NPU local memory) after inference, allowing extraction post-reset.
*   **Vector:** Improper zeroization, reset timing manipulation.

### AT-004: Shared Memory / IPC Leakage
*   **Description:** Insufficiently isolated shared memory partitions allow the non-secure world to infer or directly read raw sensor data.
*   **Vector:** Software-only sandboxes (VLANs, incomplete TrustZone).

### AT-005: Debug / Trace Extraction
*   **Description:** Extraction of raw sensor data or AI weights via physical hardware debugging interfaces left active in production.
*   **Vector:** JTAG, SWD, UART, Test Pads.

### AT-006: Peripheral Bridge Bypass
*   **Description:** An attacker utilizes a secondary bridging protocol (e.g., I2C/SPI) to bypass the main hardware diode and access the Trusted Domain.
*   **Vector:** I2C, SPI, GPIO side-channels.

### AT-007: Management Controller (Control-Plane) Leakage
*   **Description:** The data plane is isolated, but the management controller (BMC, MCU) leaks metadata, timing information, or raw data via the control plane.
*   **Vector:** Reset lines, Clock manipulation, Watchdog timers.

### AT-008: Reverse Channel Impossibility Bypass
*   **Description:** The physical diode is compromised, allowing a reverse-read operation from the untrusted network back into the trusted NPU domain.
*   **Vector:** Bi-directional physical transceivers, controllable isolator enable-pins.

### AT-009: Undocumented Interface (Hidden Sensor Path)
*   **Description:** A secondary sensor (e.g., wake-word microphone) is routed directly to the network SoC, bypassing the ZC-CORE trust boundary entirely.
*   **Vector:** PCB routing, undocumented I/O, auxiliary PMIC telemetry.

### AT-010: AI Output / Metadata Leakage
*   **Description:** The semantic output of the AI model is overly permissive, allowing the network domain to reconstruct the original raw sensor data.
*   **Vector:** Excessive diagnostic logging, over-parameterized output payloads.
