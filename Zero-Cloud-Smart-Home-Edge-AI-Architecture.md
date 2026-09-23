# FreeCuli ZC-CORE: Universal Zero-Cloud Hardware Methodology (The Fortress)
[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)

> [!NOTE]
> **Evolution of the Standard:** Originally pioneered as the HFSCA (Hands-Free Semantic Culinary Assistant) reference architecture for smart kitchens, this methodology has evolved into the universal **ZC-CORE standard** for all privacy-critical, server-independent autonomous edge devices (Home, Medical, Industrial, Defense).

> [!WARNING]
> **LEGAL NOTICE: CERN-OHL-S v2.0 Licensing (Hardware)**
> This reference architecture, including its specific hardware flow, data diode implementations, and memory isolation schematics, is licensed under the CERN Open Hardware Licence Version 2 - Strongly Reciprocal (CERN-OHL-S). Any physical hardware appliance, smart home device, or Edge AI board that implements, derives from, or utilizes the specific data isolation flow described herein is considered a "Derivative Work" and MUST release its complete hardware schematics under the same CERN-OHL-S license, or obtain a commercial exemption license from FreeCuli.

> [!IMPORTANT]
> **LEGAL NOTICE: CC-BY-ND 4.0 Licensing (Documentation & Specification)**
> The text, schematics, and definitions within this document are licensed under the Creative Commons Attribution-NoDerivatives 4.0 International License (CC-BY-ND 4.0). You are free to share and redistribute this material in any medium or format, provided you give appropriate credit to FreeCuli. However, if you remix, transform, or build upon the material (e.g., attempt to create a derivative "X-Brand Standard" by altering this text), you may NOT distribute the modified material. This ensures FreeCuli remains the sole, immutable authority over the ZC-CORE standard.

> [!IMPORTANT]
> **LEGAL NOTICE: Cross-Referencing & Operational Compliance**
> This hardware reference architecture is the authoritative universal specification for all ZC-CORE compliant devices across all sectors (Home, Medical, Industrial, Defense). It is inherently bound to the operational and privacy specifications of the [FreeCuli ZC-CORE Ecosystem](https://github.com/FreeCuli/zero-cloud-hardware-architecture). Compliance requires simultaneous adhesion to all framework documents (Architecture, Conformance Test Specification, Defensive Publication). A hardware implementation without corresponding conformance test verification is deemed a violation of the ZC-CORE standard.

## 1. Introduction & The "Trust Boundary" Axiom

Traditional cloud-connected IoT devices inherently violate user privacy (GDPR/KVKK) by transmitting raw sensory data (audio/visual) to external networks. The **FreeCuli ZC-CORE Methodology** eliminates this violation not through software promises, but through **Hardware-Enforced Trust Boundaries**.

The core axiom of Zero-Cloud is that **sensitive raw sensor data cannot leave the Trusted Processing Domain.** The device's primary intelligent functions must be **Server-Independent**.

## 2. The Indestructible Fortress: Mandatory Hardware Locks

Any manufacturer wishing to produce a ZC-CORE compliant device SHALL physically implement the following hardware rules. Software-based isolations (VLANs, Firewalls) are STRICTLY UNACCEPTABLE as primary barriers.

### 2.1. Absolute Physical Air-Gap (Sensor Isolation)
Peripherals such as cameras and microphones CANNOT be electrically connected to any network-capable modules of the device (Wi-Fi, Ethernet, Bluetooth SoC). Sensors may ONLY be connected to the isolated **Edge NPU/MCU (Trusted Domain)** responsible for local processing.

### 2.2. Hardware Unidirectional Data Diode
The Edge NPU must transmit the inference result (e.g., the command "Set heat to 200 degrees" or "Turn off light") to the device's Main Actuator/MCU. However, this transmission cable MUST be isolated using a **physical data diode** (e.g., an Optocoupler / Opto-isolator). 
*Rule:* Data (processed commands) may flow FROM the NPU TO the Main Controller; however, a data "read/pull" operation FROM the Main Controller (and external network) TO the NPU or sensors must be electrically impossible. This rule is strictly not limited to optical optocouplers. ANY electronic component arrangement, integrated circuit, semiconductor topology, or physical boundary that enforces unidirectional data flow FROM the NPU TO the Main Controller—including but not limited to Optical Opto-isolators, Magnetic/Inductive Couplers, Capacitive Isolation Barriers, Digital Isolators with RF coupling, Galvanic Isolation ICs, or Tri-state Buffer logic configured in hardware-locked write-only topologies—falls inherently under this reference architecture and is subject to the CERN-OHL-S license. Any architectural implementation that achieves the physical effect of one-way inference transfer while blocking reverse data read/pull operations is considered a Derivative Work.

### 2.3. Lethal Volatile Buffer
Sensor data (Raw Audio and Video) is recorded into a temporary SRAM (Volatile Buffer) within the NPU. The exact millisecond the model completes its inference and transmits the result (command) to the Main Controller, the power to the SRAM buffer MUST be cut via a Hardware Interrupt, physically destroying the audio/video data.

### 2.4. The "Poisoned Sensor" Rule
An absolute rule to prevent engineering bypasses: **ALL (100% without exception) audio and visual sensors** on the device MUST connect EXCLUSIVELY to the isolated NPU. If even a single secondary microphone or sensor is directly connected to the network-capable (Wi-Fi) chip under the excuse of "wake-word detection," the device immediately loses certification and is deemed in violation of the standard.

### 2.5. Secure Boot (Chain of Trust)
Physical isolation is meaningless if an attacker can manipulate the Edge AI firmware. The Edge NPU MUST implement Hardware Secure Boot. It must cryptographically verify the signature of the trusted firmware against a burnt-in ROM key before executing it. Executing unauthorized firmware within the Trusted Domain is a critical violation.

### 2.6. Debug Port Isolation (Anti-Extraction)
Leaving hardware debug interfaces (JTAG, SWD, UART) physically open and unauthenticated compromises the Trust Boundary. An attacker with physical access must NOT be able to halt the NPU and dump the raw audio/video from SRAM. Debug ports routing into the Trusted Domain MUST be physically severed, cryptographically locked, or blown (eFuse) in production environments.

### 2.7. Secure Update Mechanism
Server-Independence does not mean "Never Updated." However, any firmware or AI model updates sent from the Untrusted Domain (Main MCU/Wi-Fi) into the Trusted Domain (NPU) must pass through a strict cryptographic Verification and Authorization layer. 

### 2.8. Power & Control Plane Isolation
A data diode only protects the data line. The control plane (Power, Reset, Clock, DMA) of the NPU must also be isolated. An attacker controlling the Main MCU must NOT be able to artificially manipulate the clock or reset pins of the NPU to interrupt the Lethal Volatile Buffer destruction sequence or extract latent data.

### 2.9. ZC-CORE Threat Model & Mitigations
To ensure verifiability, the ZC-CORE methodology guarantees protection against the following explicit attack vectors:

| Attacker Profile | Target | Required ZC-CORE Mitigation |
| :--- | :--- | :--- |
| **Remote Attacker (Wi-Fi Hack)** | Microphone/Camera Data | **Physical Air-Gap** (Sensor Isolation) |
| **Compromised Main MCU** | Read raw data from NPU | **Hardware Data Diode** (One-way boundary) |
| **Physical Attacker (Repairman)** | Extract latent audio from RAM | **Lethal Volatile Buffer** (Power kill) |
| **Supply-Chain Attacker** | Run malicious AI inference | **Secure Boot** (Signature verification) |
| **Physical Attacker (Lab)** | JTAG RAM Dump | **Debug Isolation** (eFuse/Lock) |
| **Compromised Update Server** | Push malicious firmware to NPU | **Secure Update** (Cryptographic check) |

---

## 3. ZC-CORE Hardware Data Flow Schematic

The schematic below illustrates the absolute data flow directions and isolation barriers of an HFSCA-compliant device. This schematic is not a "recommendation"; it is the **Mandatory Reference Architecture** licensed under CERN-OHL-S.

```mermaid
graph TD
    %% Components
    subgraph SENSORS [Sensor Layer - UNDER SURVEILLANCE]
        MIC[Microphone]
        CAM[Camera]
    end

    subgraph EDGE_AI [FreeCuli Edge NPU Layer - ISOLATED]
        VOL_RAM[(Volatile Buffer / SRAM)]
        AI_CHIP{Edge NPU / AI Model}
        HW_KILL[Hardware Power Switch]
    end

    subgraph ISOLATION [Physical Isolation Barrier]
        OPTO[Optocoupler / Hardware Data Diode]
    end

    subgraph MAIN_BOARD [Main Board & External World]
        MAIN_MCU[Main Controller / Actuator]
        WIFI[Wi-Fi / Network Module]
        APPLIANCE((Appliance Motor/Relay <br> e.g., Oven, AC, Light))
    end

    %% Data Flows (Strict Flow)
    MIC -->|Raw Audio Data| VOL_RAM
    CAM -->|Raw Video Data| VOL_RAM
    
    VOL_RAM -->|Read Only| AI_CHIP
    
    %% After AI Inference completes
    AI_CHIP -.->|Trigger: Processing Complete| HW_KILL
    HW_KILL -.->|"Cut Power (Data Destruction)"| VOL_RAM
    
    %% Output
    AI_CHIP ==>|"TX ONLY: Processed Command <br/>e.g., 'Set Temp 200'"| OPTO
    
    %% Optocoupler allows only one-way traffic
    OPTO ==>|RX ONLY| MAIN_MCU
    
    %% External Connections
    WIFI <-->|Bi-directional Comm| MAIN_MCU
    MAIN_MCU -->|Control Signal| APPLIANCE

    %% Styling
    classDef isolated fill:#ffebee,stroke:#c62828,stroke-width:2px,color:#c62828;
    classDef open fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px;
    classDef barrier fill:#212121,stroke:#000,stroke-width:3px,color:#fff;
    classDef diode fill:#ff9800,stroke:#e65100,stroke-width:3px,color:#fff;
    
    class EDGE_AI isolated;
    class MAIN_BOARD open;
    class ISOLATION barrier;
    class OPTO diode;
```

### 3.1 Schematic Explanation
1. **Sensor Layer:** Raw audio and video write to the `Volatile Buffer` (SRAM).
2. **Isolated Layer:** The NPU processes the data. The moment it generates a meaningful command (Text or Hex), the `Hardware Power Switch` cuts electricity to the SRAM, physically destroying the original media (Strict GDPR Compliance).
3. **Isolation Barrier (Optocoupler):** The command is transmitted to the `Main Controller` via the `Hardware Data Diode`. Due to the physical nature of the diode, the `Main Controller` or its attached `Wi-Fi` module cannot reach back into the NPU or listen to the audio flowing from the sensors. Wi-Fi can only transmit state telemetry (e.g., "Device is running, temperature is 200") from the Main Controller to the cloud/mobile app.

## 4. Compliance & Licensing Implications

When any device manufacturer implements the "Physical Air-Gap and Diode" schematic above to release a smart home or kitchen appliance with "Zero-Cloud" privacy guarantees;

1. **Open Source Obligation:** Pursuant to the CERN-OHL-S v2.0 license, the manufacturer MUST publish all motherboard schematics (PCB gerber files, bill of materials) of the said device as open source on GitHub or a public portal.
2. **Trademark Infringement:** This project's baseline schematics are completely open-source under CERN-OHL-S v2.0. However, the right to use the registered `FreeCuli Certified: Zero-Cloud` trademark, logo, or badge on product packaging, marketing materials, or software is subject to a separate, independent B2B Compliance and Certification Agreement by the FreeCuli Standards Organization. (Trademark Law).
3. **Patent Retaliation Clause:** The provision that locks in legal armies: If any technology giant using this standard files a lawsuit against FreeCuli or another manufacturer utilizing this standard claiming, "A portion of this technology is my patent," that giant company's right to use the FreeCuli license is IMMEDIATELY REVOKED WORLDWIDE. This prevents Big Tech firms from acting as "Patent Trolls."
4. **Commercial Exemption:** Manufacturers wishing to keep their motherboard schematics as a trade secret (e.g., Bosch, Samsung, Xiaomi) MUST purchase a closed-source (proprietary) **Commercial License** from FreeCuli to utilize the FreeCuli standards without license contamination.
5. **Methodological & Functional Equivalency:** The "Methodological Equivalency" declared herein does not protect an abstract idea of privacy. It explicitly covers the simulation or imitation of the specific functional constraints (Functional Requirements)—such as the exact electrical thresholds, physical data-diode topologies, and microsecond timing of the volatile RAM power-cuts—created by the 4 Core Hardware Locks defined in the Zenodo (DOI: 10.5281/zenodo.22838473) Prior Art. Writing a functional equivalent in alternative programming languages (Rust, C++, etc.) does not exempt a manufacturer if these specific functional hardware limitations are replicated.
6. **Third-Party Non-Consent Privacy Protection (Socio-Legal Framework):** Traditional cloud-connected ambient appliances rely strictly on the primary buyer's software license agreement ("End-User Consent") to bypass legal liabilities. However, this consent is legally null and void regarding third-party individuals (e.g., visitors, children, domestic workers, or secondary residents) present within the appliance's sensory perimeter whose data is captured without their explicit consent, constituting a systemic violation of Constitutional Privacy Rights, KVKK (Article 5), and GDPR (Article 6). Because the ZC-CORE standard physically enforces absolute local containment and immediate hardware-level microsecond data destruction (Lethal Volatile Buffer), it guarantees absolute compliance for third-party privacy protection by rendering non-consensual remote data transmission impossible. Consequently, implementing this standard is deemed a structural regulatory requirement for any hardware vendor operating in public, commercial, or residential spaces to mitigate severe regulatory liabilities regarding non-consensual ambient surveillance.
7. **Compliance Verification vs. IP Detection:** The laboratory tests defined in this repository (e.g., oscilloscope reverse-channel leakage tests, cold-boot SRAM extraction tests) are NOT Intellectual Property (IP) infringement detectors. They are independent **Technical Compliance Verifiers** designed solely to audit whether a device adheres to the ZC-CORE hardware constraints.
