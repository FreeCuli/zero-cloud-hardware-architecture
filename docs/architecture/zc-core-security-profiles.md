# FREECULI ZC-CORE — Security Profiles Specification (STRICT & HYBRID)
## Normative Security Profile Definitions, Information Flow Policies & Boundary Strictures

**Status:** `PROPOSED / NOT RELEASED / NOT SOC-VERIFIED`  
**Document ID:** ZC-CORE-SPEC-SECURITY-PROFILES-DRAFT  
**Revision:** 0.9.1-draft (Post-Audit Remediation HAR-01 / HAR-02 / HAR-04 / HAR-05)  
**Target Milestone:** Post-Gate C Governance / Gate D Preparation  
**Reference Technical Baseline:** Commit [`eb3ed5a`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/eb3ed5ad9fddb551506d43d2692bd040843af06f) (Run #45)  
**Classification:** Architectural Security Specification (Draft)  

---

> [!WARNING]
> **GOVERNANCE & BOUNDARY NOTICE:**  
> This specification is an architectural draft (`PROPOSED / NOT RELEASED / NOT SOC-VERIFIED`). It defines the target requirements for the **STRICT** and **HYBRID** operational profiles. It does NOT assert that full-SoC, physical silicon, or analog telemetry channels are verified. All physical silicon, SoC crossbar, and analog side-channel guarantees remain strictly deferred to **Gate D (UNVERIFIED)**.

---

## 1. Scope & Architectural Objective

The FreeCuli Zero-Cloud Hardware Core (ZC-CORE) methodology guarantees that sensitive raw sensory information (audio, visual, biometrics) never leaves the local hardware-enforced Trusted Processing Domain.

To reconcile real-world IoT deployment requirements (such as fleet health monitoring, crash diagnostics, and cryptographically verified inbound firmware updates) with uncompromising zero-cloud privacy, ZC-CORE formally establishes two distinct operational profiles:

1. **STRICT Profile (`ZC-PROFILE-STRICT`):** The pure air-gap / zero-outbound operational model.
2. **HYBRID Profile (`ZC-PROFILE-HYBRID`):** The hardware-gated semantic telemetry and bidirectional bus coordination model.

### 1.1 Methodology Invariant Relationship: Design-Compatible vs. Implementation-Verified
To prevent scope inflation, an explicit distinction is maintained throughout this document:
- **`DESIGN-COMPATIBLE`:** The architectural property is specified as a design principle and targeted requirement.
- **`IMPLEMENTATION-VERIFIED (PARTIAL)`:** The digital RTL logic of specific IP blocks (`zc_spi_flash_firewall`, `zc_obi_subordinate_bridge`, `zc_aon_post_auth_ctrl`) has been formally proven under open-source tools ($t=20$) in **Gate C**.
- **`UNVERIFIED AT SYSTEM/SILICON`:** System-wide SoC crossbar DMA isolation, PMP enforcement, physical silicon macro behavior, and analog side-channel limits remain unverified and are tracked exclusively for **Gate D**.

---

## 2. Profile Definitions & Operational Constraints

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
* **Core Principle:** Absolute outbound network isolation. Zero bits of telemetry leave the physical boundary under any operational state.
* **Outbound Information Flow:** Strictly prohibited. Only local physical actuation (relays, motor controllers, local displays) is permitted.
* **Data Diode:** Physical unidirectional diode (e.g., optical isolator, electrical diode, or severed reverse wire).
* **Inbound Updates:** Inbound firmware updates are permitted ONLY during dedicated, physical maintenance states (e.g., physical jumper activation, factory flash socket, or cryptographically signed ROM boot with actuator disabled).
* **Applicability:** Defense, high-security medical implants, maximum-privacy residential surveillance zones, industrial critical safety shut-off systems.

### 2.2 HYBRID Profile (`ZC-PROFILE-HYBRID`)
* **Core Principle:** Hardware-gated operational coexistence. The device may communicate with external networks via an untrusted Network Co-Processor, but the hardware topology physically and logically guarantees that raw sensor data CANNOT be leaked, extracted, or reverse-read.
* **Outbound Information Flow:** Permitted ONLY for **Allowlisted Semantic Telemetry** (system health, uptime, sanitized fault codes, high-level aggregated semantic state).
* **Hardware Interlocks:** All bidirectional communication between the untrusted Network Co-Processor and the Trusted Processing Domain MUST pass through hardware-enforced isolation firewalls:
  - Open Bus Interface (OBI) Subordinate Bridge (`zc_obi_subordinate_bridge.sv`) with orphan draining and synthetic error trap.
  - SPI Flash Firewall (`zc_spi_flash_firewall.sv`) with dual /CS gating and RDSR1 status reconciliation.
  - Always-On OTP Post-Authorization Controller (`zc_aon_post_auth_ctrl.sv`) with 4-phase DAI handshakes.
* **Critical Boundary Caveat:** The implemented OBI and SPI firewalls protect specific bus protocols and Flash update paths; they do **not** replace a system-wide IOMMU or multi-master crossbar firewall across the entire SoC (which remains a Gate D requirement).
* **Applicability:** Commercial smart appliances, fleet-managed commercial Edge-AI devices, connected industrial sensors requiring remote health monitoring.

---

## 3. Comprehensive Information Flow Policy (Outbound & Inbound)

To resolve Auditor finding **HAR-01 / P0**, the table below specifies the exhaustive, multidimensional information flow policy governing both profiles:

| Flow Direction | Source Domain | Destination Domain | Data Classification | STRICT Permission | HYBRID Permission | Physical & Hardware Enforcement Mechanism | Residual Risk / Covert Channel Bound |
| :--- | :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| **Outbound** | Trusted Sensor / SRAM | Untrusted Network / Host | **Class 0: Raw Sensory Data** (PCM audio, raw video frames, ADC samples) | **FORBIDDEN** | **FORBIDDEN** | Hardware Domain Air-Gap / Memory Isolation / M8 Zeroization | Physical probing of unshielded PCB traces (Mitigated by Gate D Tamper Shield). |
| **Outbound** | Trusted NPU / Cache | Untrusted Network / Host | **Class 1: Derived Representations** (Spectrograms, neural activations, embeddings) | **FORBIDDEN** | **FORBIDDEN** | Class 1 is normatively treated as Class 0 under M1/M8. Destroyed upon inference end. | Tensor memory leakage via un-zeroized DMA buffer (Mitigated by M8 exact zeroization). |
| **Outbound** | Trusted NPU / Host | Local Actuator (Physical) | **Class 2: Semantic Commands** (Discrete states: `RELAY_ON`, `TEMP_SET_200`) | **PERMITTED** | **PERMITTED** | Unidirectional Data Diode (STRICT) / OBI Subordinate Bridge (HYBRID) | Command repetition side-channel (Mitigated by rate-limiting). |
| **Outbound** | Trusted Host / Status | Untrusted Network / Host | **Class 3: Allowlisted Telemetry** (Boot count, thermal status, sanitized fault codes) | **FORBIDDEN** | **PERMITTED (Hardware-Gated)** | OBI Subordinate Bridge (`zc_obi_subordinate_bridge.sv`) with deterministic schema | Steganographic timing modulation or payload packing (Mitigated by §5 guardrails). |
| **Outbound** | Any Domain | External Network | **Class 4: Raw Audio/Visual Streaming** (RTSP, debug dumps, pass-through) | **FORBIDDEN (NON-COMPLIANT)** | **FORBIDDEN (NON-COMPLIANT)** | Immediate disqualification from ZC-CORE conformance under M1. | Architectural non-compliance. |
| **Inbound** | Untrusted Network / Master | Shared SPI Flash (Bank B) | **Inbound Firmware Update Payload** (Signed encrypted binary) | **Physical Socket Only** | **PERMITTED (Firewall-Gated)** | `zc_spi_flash_firewall.sv` (Rising /CS, SCK=0, RDSR1 status reconciliation, dual /CS gating) | Flash write exhaustion / wear-out attack (Mitigated by `AT-012`). |
| **Inbound** | Untrusted Network / Master | Trusted Core (Host OBI) | **Inbound Read/Write Request** (Bus access) | **FORBIDDEN** | **PERMITTED (Bridge-Gated)** | `zc_obi_subordinate_bridge.sv` (Warm reset gating `rst_sys_ni`, orphan drain, `ST_TRAP` error) | Prolonged bus stall (Bounded to 1,024 cycles by hardware watchdog). |
| **Inbound** | Boot ROM / Verifier | AON OTP Controller | **Authorization Commit Command** (SVN increment, session seal) | **PERMITTED** | **PERMITTED** | `zc_aon_post_auth_ctrl.sv` (4-phase DAI handshake, single-cycle grant consumption) | Glitched write strobe (Mitigated by hardware parity and fatal lock `F-OTP-04`). |

---

## 4. Normative Evaluation of Invariant M3 & Major-Version Governance

### 4.1 The Normative Friction
Invariant M3 states:
> *"Protected raw-sensor information and derived representations SHALL flow strictly from the Trusted Domain to the Network Domain through a physically verifiable unidirectional channel. Authenticated control-plane and firmware-update traffic MAY enter the Trusted Domain, provided it cannot create a raw-sensor read-back path or a reverse raw-sensor information channel."*

- Under the **STRICT Profile**, M3 is satisfied unconditionally without normative friction.
- Under the **HYBRID Profile**, outbound Class 3 telemetry is released. While Class 3 telemetry contains no raw sensor data or derived representations (Classes 0 & 1), the physical transmission channel is bidirectional (e.g., OBI/Ethernet/Wi-Fi).

### 4.2 Major-Version Governance Decision (HAR-01 Resolution)
To maintain absolute normative integrity without premature assumptions:
1. **Option 1 (Normative Profile Annex for v3.x):**  
   M3 is interpreted as governing *protected raw-sensor information and derived representations* strictly. Because Class 3 telemetry is mathematically non-reconstructible to raw data, HYBRID is managed as a Normative Profile Annex to ZC-CORE v3.3.x, requiring no breaking change to M1–M10 core text.
2. **Option 2 (Major-Version v4.0.0 RFC):**  
   If independent audit or standards consensus determines that the word *"unidirectional"* in M3 strictly requires physical one-way transmission for *all* data categories (including telemetry), then HYBRID profile standardization SHALL NOT be merged as a v3.x update, but SHALL be formally submitted as an **RFC for ZC-CORE v4.0.0**.
3. **Governance Verdict:** The decision between Option 1 and Option 2 is explicitly deferred to independent standards committee consensus prior to any release authorization. In the interim, M3 status for HYBRID remains strictly **`CONDITIONAL`**.

---

## 5. Telemetry Guardrails & Covert Channel Mitigation (HYBRID Profile)

To ensure that Class 3 telemetry cannot be abused to construct a covert information channel:

1. **Fixed Binary Schema (No Arbitrary Payloads):**  
   Telemetry payloads SHALL use static, compile-time verified binary structures. Variable-length strings, raw hex dumps, or unconstrained error logs are strictly prohibited.
2. **Entropy Clamping & Mutual Information Bound:**  
   Outbound telemetry SHALL conform to the operational statistical leakage bound:
   $$I(X; Y) < \text{MI}_{\text{upper\_bound}}$$
   evaluated under the CTS Annex B protocol.
3. **Epoch-Quantised Rate Limiting:**  
   Telemetry packets SHALL be dispatched on deterministic, clock-quantised epoch boundaries (e.g., exactly once per 60 seconds). Event-driven telemetry timing that varies synchronously with sensor activity is prohibited to prevent timing-channel exfiltration.
4. **Physical Bus Gating:**  
   The OBI Subordinate Bridge guarantees that during orphan response draining or watchdog timeouts, all physical peripheral access is severed (`periph_phys_req_o == 0`) and deterministic synthetic errors (`ST_TRAP`) are returned.

---

## 6. Implementation Status & Evidence Traceability

| Functional Mechanism | Implemented RTL Block | Gate C Status | Gate D / Silicon Status | Trust Assumptions |
| :--- | :--- | :---: | :---: | :--- |
| **Inbound SPI Flash Firewall** | [`rtl/zc_spi_flash_firewall.sv`](../../rtl/zc_spi_flash_firewall.sv) | **`PROVEN` (Run #45)** | `UNVERIFIED` (Physical Flash Lab Test) | Requires external ROM cryptographic verifier (`rom_img_verif_valid_i == 1`). Does not execute crypto in RTL. |
| **OBI Subordinate Bus Bridge** | [`rtl/zc_obi_subordinate_bridge.sv`](../../rtl/zc_obi_subordinate_bridge.sv) | **`PROVEN` (Run #45)** | `UNVERIFIED` (SoC Crossbar Integration) | Provides bus-level orphan drain & watchdog; does not act as full SoC DMA IOMMU. |
| **AON OTP Anti-Rollback Ctrl** | [`rtl/zc_aon_post_auth_ctrl.sv`](../../rtl/zc_aon_post_auth_ctrl.sv) | **`PROVEN` (Run #45)** | `UNVERIFIED` (Analog Antifuse Macro) | Enforces DAI handshake and SVN anti-rollback; physical charge pump physics deferred to Gate D. |
| **Full-SoC 2-Trace Miter** | [`fv/zc_m7_m8_ni_sva.sv`](../../fv/zc_m7_m8_ni_sva.sv) | **`BLOCKED`** | Mandatory Gate D Deliverable | Requires top-level SoC integrating dual Ibex CPU, NPU, and secure crossbar. |
| **Telemetry Leakage Bound (MI)** | System / Software Policy | N/A | Mandatory Gate D / CTS Annex B Test | Physical radio/EM side-channel testing in ISO 17025 anechoic chamber. |
