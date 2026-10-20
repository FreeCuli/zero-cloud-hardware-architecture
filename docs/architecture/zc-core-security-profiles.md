# FREECULI ZC-CORE — Security Profiles Specification (STRICT & HYBRID)
## Normative Security Profile Definitions, Information Flow Policies & Boundary Strictures

**Status:** `PROPOSED / NOT RELEASED / NOT SOC-VERIFIED`  
**Document ID:** ZC-CORE-SPEC-SECURITY-PROFILES-DRAFT  
**Revision:** 0.9.0-draft  
**Target Milestone:** Post-Gate C Governance / Gate D Preparation  
**Reference Technical Baseline:** Commit [`eb3ed5a`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/eb3ed5ad9fddb551506d43d2692bd040843af06f) (Run #45)  
**Classification:** Architectural Security Specification (Draft)  

---

> [!WARNING]
> **GOVERNANCE & REVIEW NOTICE:**  
> This specification is an architectural draft (`PROPOSED / NOT RELEASED / NOT SOC-VERIFIED`). It defines the normative requirements for the **STRICT** and **HYBRID** operational profiles. It does NOT assert that full-SoC, physical silicon, or analog telemetry channels are verified. All physical and full-SoC guarantees remain strictly deferred to **Gate D (UNVERIFIED)**.

---

## 1. Scope & Objective

The FreeCuli Zero-Cloud Hardware Core (ZC-CORE) methodology guarantees that raw sensor data (audio, visual, biometrics) never leaves the local hardware-enforced Trusted Processing Domain.

To reconcile real-world IoT deployment requirements (such as fleet health monitoring, crash diagnostics, and cryptographically verified inbound firmware updates) with uncompromising zero-cloud privacy, ZC-CORE formally establishes two distinct operational profiles:

1. **STRICT Profile (`ZC-PROFILE-STRICT`):** The pure air-gap / zero-outbound operational model.
2. **HYBRID Profile (`ZC-PROFILE-HYBRID`):** The hardware-gated semantic telemetry and bidirectional bus coordination model.

Both profiles strictly enforce invariants **M1, M2, M4, M5, M6, M7, M8, M9, and M10**. They differ exclusively in the governance of outbound information flow (**M3**) and external telemetry permissions.

---

## 2. Profile Definitions & Taxonomy

```
+--------------------------------------------------------------------------------------------------+
|                                    FREECULI ZC-CORE ARCHITECTURE                                 |
+--------------------------------------------------------------------------------------------------+
|                                                                                                  |
|   +---------------------------------------+      +-------------------------------------------+   |
|   |         STRICT PROFILE (M3-S)         |      |          HYBRID PROFILE (M3-H)            |   |
|   +---------------------------------------+      +-------------------------------------------+   |
|   | - Zero Outbound Telemetry             |      | - Strictly Allowlisted Semantic Telemetry |   |
|   | - Physical Air-Gap / Data Diode       |      | - Hardware-Gated Bus Interconnect (OBI)   |   |
|   | - Local Actuation Only                |      | - SPI Flash Firewall Inbound OTA          |   |
|   | - Inbound Update via Physical/Fused   |      | - AON Post-Auth Anti-Rollback Controller  |   |
|   |   Dedicated Maintenance Port Only     |      | - Rate-Limited, Fixed-Entropy Egress      |   |
|   +---------------------------------------+      +-------------------------------------------+   |
|                                                                                                  |
+--------------------------------------------------------------------------------------------------+
```

### 2.1 STRICT Profile (`ZC-PROFILE-STRICT`)
* **Core Philosophy:** Absolute network isolation. Zero bits of telemetry leave the physical boundary under any operational state.
* **Outbound Information Flow:** Strictly prohibited. Only local electrical actuation (relays, motor controllers, local displays) is permitted.
* **Data Diode:** Physical unidirectional diode (e.g., optical isolator, electrical diode, or severed reverse wire).
* **Inbound Updates:** Inbound firmware updates are permitted ONLY during dedicated, physical maintenance states (e.g., physical jumper activation, factory flash socket, or cryptographically signed ROM boot with actuator disabled).
* **Applicability:** Defense, high-security medical implants, maximum-privacy residential surveillance zones, industrial critical safety shut-off systems.

### 2.2 HYBRID Profile (`ZC-PROFILE-HYBRID`)
* **Core Philosophy:** Hardware-gated operational coexistence. The device may communicate with external networks via an untrusted Network Co-Processor, but the hardware topology physically and logically guarantees that raw sensor data CANNOT be leaked, extracted, or reverse-read.
* **Outbound Information Flow:** Permitted ONLY for **Allowlisted Semantic Telemetry** (system health, uptime, sanitized fault codes, high-level aggregated semantic state).
* **Hardware Interlocks:** All bidirectional communication between the untrusted Network Co-Processor and the Trusted Processing Domain MUST pass through hardware-enforced isolation firewalls:
  - Open Bus Interface (OBI) Subordinate Bridge (`zc_obi_subordinate_bridge.sv`) with orphan draining and synthetic error trap.
  - SPI Flash Firewall (`zc_spi_flash_firewall.sv`) with dual /CS gating and RDSR1 status reconciliation.
  - Always-On OTP Post-Authorization Controller (`zc_aon_post_auth_ctrl.sv`) with 4-phase DAI handshakes.
* **Applicability:** Commercial smart appliances, fleet-managed commercial Edge-AI devices, connected industrial sensors requiring remote health monitoring.

---

## 3. Normative Information Flow Policy (Outbound & Inbound)

### 3.1 Outbound Data Classification Matrix

| Data Classification | Description | STRICT Profile Rule | HYBRID Profile Rule | Hardware Containment Mechanism |
| :--- | :--- | :---: | :---: | :--- |
| **Class 0: Raw Sensory Data** | Uncompressed PCM audio, raw video frames, ADC sensor readings, biometric raw minutiae. | **FORBIDDEN (NEVER LEAVES)** | **FORBIDDEN (NEVER LEAVES)** | Physical Air-Gap / Memory Domain Isolation / Immediate Post-Inference M8 Zeroization. |
| **Class 1: Derived Representations** | Mel-spectrograms, FFT bins, intermediate neural tensor activations, dense latent embeddings. | **FORBIDDEN (NEVER LEAVES)** | **FORBIDDEN (NEVER LEAVES)** | Treated identically to Class 0 under M1/M8. Destroyed upon inference completion. |
| **Class 2: Semantic Commands** | Discrete actuator instructions (e.g., `HEATER_ON`, `DOOR_LOCK`, `VALVE_SET_40`). | **PERMITTED (Local Only)** | **PERMITTED (Local & Bus)** | One-way diode transfer (STRICT) or OBI subordinate transaction (HYBRID). |
| **Class 3: Allowlisted Telemetry** | Monotonic boot counters, sanitized error codes (e.g., `ERR_CODE_0x12`), thermal telemetry, SVN status. | **FORBIDDEN** | **PERMITTED (Hardware-Gated)** | Must conform to fixed-format schema; rate-limited; zero sensor data fields. |
| **Class 4: Raw Audio/Visual Streaming** | Direct pass-through, debug audio dumps, video RTSP streams. | **FORBIDDEN (NON-COMPLIANT)** | **FORBIDDEN (NON-COMPLIANT)** | Immediate disqualification from ZC-CORE compliance. |

### 3.2 Inbound Over-The-Air (OTA) Update Governance

Both profiles permit inbound firmware and AI weight updates, subject to strict cryptographic and hardware boundaries:

1. **Independent Cryptographic Signature Verification:**  
   Update payloads stored in external Flash (Bank B) SHALL be verified by an isolated ROM bootloader before execution.
2. **Hardware Anti-Rollback (SVN Invariant):**  
   Security Version Number (SVN) advancement SHALL be irreversible. The `zc_aon_post_auth_ctrl` module strictly enforces that downgrading to an SVN lower than the permanently fused OTP state causes an immediate `AUTH_LOCKED_FATAL`.
3. **Execution Gating:**  
   The `zc_spi_flash_firewall` module asserts `bank_b_commit_ready_o` if and only if:
   - Primary SPI transaction completes on rising /CS with `SCK == 0`.
   - Secondary electrical fault is clear (`fault_high_sec_i == 0`).
   - Flash internal status register confirms write completion (`SR1[1:0] == 2'b00`).
   - Independent ROM cryptographic verification completes successfully (`rom_img_verif_valid_i == 1`).

---

## 4. Trust Boundary & Interface Architecture

```mermaid
flowchart LR
    subgraph Untrusted_Network_Domain ["Untrusted External / Network Domain"]
        NET_SOC["Network Co-Processor (Wi-Fi / BLE / Ethernet)"]
        EXT_FLASH["Shared SPI Flash Memory (Bank A / Bank B)"]
    end

    subgraph Trust_Boundary ["Hardware Trust Boundary Firewall"]
        SPI_FW["zc_spi_flash_firewall<br/>(SPI Mode 0/3 Dual /CS Gating)"]
        OBI_BRG["zc_obi_subordinate_bridge<br/>(Orphan Drain & 1024-Cycle Watchdog)"]
        AON_CTRL["zc_aon_post_auth_ctrl<br/>(4-Phase DAI & Anti-Rollback OTP)"]
    end

    subgraph Trusted_Secure_Domain ["Trusted Processing Domain (ZC-CORE)"]
        HOST_CPU["Secure Host CPU (Ibex RISC-V)"]
        NPU_CORE["Edge AI NPU / Accelerator"]
        SEC_SRAM["Secure Volatile SRAM (M8 Zeroization)"]
        SENSORS["Privacy-Sensitive Sensors (MIC / CAM)"]
    end

    SENSORS ==>|Exclusive Route (M9)| SEC_SRAM
    SEC_SRAM <==>|Local Inference Only (M1, M7)| NPU_CORE
    NET_SOC <==>|Host Requests / Responses| OBI_BRG
    OBI_BRG <==>|Filtered Physical Bus| HOST_CPU
    NET_SOC <==>|SPI Flash Access| SPI_FW
    SPI_FW ==>|Commit Gating Signal| EXT_FLASH
    HOST_CPU ==>|Auth Post Command| AON_CTRL
    AON_CTRL ==>|Fused State| SEC_SRAM
```

---

## 5. Telemetry Guardrails & Covert Channel Mitigation (HYBRID Profile)

To prevent an adversary from constructing a steganographic covert channel via legitimate telemetry payloads:

1. **Deterministic Fixed Payload Formatting:** Telemetry packets SHALL utilize fixed-length binary schemas (e.g., CBOR or packed C structs). Variable-length arbitrary text or free-form debugging strings are prohibited.
2. **Entropy Clamping:** High-entropy fields in outbound telemetry (which could encode compressed audio/image samples) SHALL NOT exceed mathematically bounded limits unless cryptographically justified.
3. **Rate Limiting & Timing Sanitization:** Outbound telemetry packets SHALL be transmitted at fixed, quantised epoch intervals (e.g., exactly once every 60 seconds). Dynamic packet transmission timing responsive to raw sensor events is strictly prohibited.
4. **Physical Reverse-Channel Gating:** The OBI Subordinate Bridge guarantees that while handling orphan responses or watchdog timeouts, physical bus access is blocked and synthetic error states (`ST_TRAP`) prevent data leakage.

---

## 6. Implementation Status & Evidence Traceability

| Functional Mechanism | Implemented RTL Block | Gate C Status | Gate D / Silicon Status |
| :--- | :--- | :---: | :---: |
| **Inbound SPI Flash Firewall** | [`rtl/zc_spi_flash_firewall.sv`](../../rtl/zc_spi_flash_firewall.sv) | **`PROVEN` (Run #45)** | `UNVERIFIED` (Physical Flash Lab Test) |
| **OBI Subordinate Bus Bridge** | [`rtl/zc_obi_subordinate_bridge.sv`](../../rtl/zc_obi_subordinate_bridge.sv) | **`PROVEN` (Run #45)** | `UNVERIFIED` (SoC Crossbar Integration) |
| **AON OTP Anti-Rollback Ctrl** | [`rtl/zc_aon_post_auth_ctrl.sv`](../../rtl/zc_aon_post_auth_ctrl.sv) | **`PROVEN` (Run #45)** | `UNVERIFIED` (Analog Antifuse Macro) |
| **Full-SoC 2-Trace Miter** | [`fv/zc_m7_m8_ni_sva.sv`](../../fv/zc_m7_m8_ni_sva.sv) | **`BLOCKED`** | Mandatory Gate D Deliverable |
| **Telemetry Leakage Bound (MI)** | None (System / Software Policy) | N/A | Mandatory Gate D / CTS Annex B Test |
