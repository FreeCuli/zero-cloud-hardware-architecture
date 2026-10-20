# FREECULI ZC-CORE — Architecture RFC: Proposed Specification for ZC-CORE v4.0.0
## Formal Architectural Bifurcation: STRICT and HYBRID Operational Profiles, Remediated Information-Flow Contract (`M3-RFC-REVISED`), Hardware Firewall Contracts & Modular Conformance Test Framework

**RFC Document ID:** RFC-ZC-CORE-0004-DRAFT  
**Date:** 20 October 2026  
**Status:** `DRAFT / PROPOSED ARCHITECTURAL RFC / NOT RATIFIED / NOT RELEASED / NOT SOC-VERIFIED`  
**Target Milestone:** Post-Gate C Governance / Gate D Preparation (`ZC-CORE v4.0.0-rc1` Candidate)  
**Historical Normative Baseline:** Preserves [`ZC-CORE v3.3.0-rc2`](../../zero-cloud-core-methodology-invariants.md) as immutable STRICT reference  
**Technical Hardware Baseline:** Commit [`eb3ed5a`](https://github.com/FreeCuli/zero-cloud-hardware-architecture/commit/eb3ed5ad9fddb551506d43d2692bd040843af06f) (Run #45)  
**Governance Level:** Standards Committee Consensus Proposal  

---

> [!WARNING]
> **GOVERNANCE, SCOPE & UNRATIFIED STATUS NOTICE:**  
> This document is a **Draft Architectural Request for Comments (RFC)** proposing the next major-version evolution of the FreeCuli Zero-Cloud Hardware Core (ZC-CORE v4.0.0).  
> **IT IS NOT A RATIFIED NORMATIVE STANDARD, NOT A COMMERCIAL PRODUCT RELEASE, AND NOT SOC-VERIFIED.**  
> 1. Approval of this RFC draft authorizes architectural analysis only; it does **NOT** authorize modifying the 14 immutable v3.x normative documents in the repository root.
> 2. The technical proofs achieved in Gate C (`PARTIAL / QUALIFIED`) verify local digital RTL IP blocks (`zc_spi_flash_firewall`, `zc_obi_subordinate_bridge`, `zc_aon_post_auth_ctrl`) under open-source tools ($t=20$). They do **NOT** prove full-SoC information-flow noninterference, general-purpose DMA firewalling, or physical silicon side-channel immunity.
> 3. All physical silicon, SoC crossbar DMA isolation, and analog covert-channel bounds remain strictly **`Gate D (UNVERIFIED)`**.
> 4. Current release state remains: **`DO NOT MERGE / RELEASE BLOCKED`**.

---

## 1. Executive Summary & Architectural Motivation

The foundational premise of the FreeCuli Zero-Cloud Hardware Core (ZC-CORE) methodology is an uncompromising privacy guarantee: **sensitive raw sensory information (audio waveforms, camera video frames, biometric samples) must never cross the physical trust boundary into untrusted network domains.**

In ZC-CORE v3.0 through v3.3, this guarantee was enforced primarily via a strict, physically unidirectional air-gap or hardware data diode (such as optocouplers or severed reverse signal paths). While mathematically and physically impregnable against remote exfiltration, pure unidirectional air-gapping introduces severe real-world operational limitations in connected IoT deployments:
1. Devices cannot report basic operational health, crash logs, or telemetry (fleet management impossibility).
2. Devices cannot receive cryptographically authenticated in-field firmware updates over standard network buses without manual, physical jumper/socket maintenance.
3. Legacy invariant M3 contained historical drafting friction that conflated raw sensory data with derived semantic outputs.

To resolve these limitations without weakening the core privacy invariant (M1), this RFC introduces the **ZC-CORE v4.0.0 Architectural Evolution**:
- **Formal Profile Bifurcation:** Formally defines two distinct, non-overlapping operational profiles:
  - **`ZC-PROFILE-STRICT`:** The classic, immutable, physically unidirectional air-gap standard (maintaining 100% fidelity to v3.3.0-rc2).
  - **`ZC-PROFILE-HYBRID`:** A hardware-gated operational coexistence model permitting allowlisted, rate-limited semantic telemetry and verified inbound OTA updates over bidirectional physical buses (OBI, SPI).
- **Remediated Information-Flow Invariant (`M3-RFC-REVISED`):** Untangles historical drafting conflations by formally establishing a 5-class data classification hierarchy, explicitly distinguishing prohibited raw sensory data (Classes 0 & 1) from permitted semantic outputs (Classes 2 & 3).
- **Hardware Bus Firewall Contracts:** Formalizes the interface contracts of the Gate C formally verified RTL IP blocks (`zc_spi_flash_firewall`, `zc_obi_subordinate_bridge`, `zc_aon_post_auth_ctrl`).
- **Modular Conformance Test Suite (CTS-v4):** Restructures conformance testing into modular profiles (`CTS-Core`, `CTS-Strict`, `CTS-Hybrid`).

### 1.1 Technical Status Taxonomy
Throughout this RFC, all architectural components, properties, and verification claims are strictly classified using the following normative status taxonomy:

| Status Identifier | Meaning & Normative Boundary |
| :--- | :--- |
| **`DESIGN REQUIREMENT`** | A mandatory architectural constraint (`SHALL` / `MUST`) required for v4.0.0 profile conformance. |
| **`IMPLEMENTED RTL`** | Digital RTL logic implemented in synthesizable SystemVerilog in the `rtl/` directory. |
| **`FORMALLY PROVEN`** | Formally proven as a mathematical theorem across infinite/bounded cycles via SVA and open-source formal engines (SBY/Yosys/Boolector/Z3) in Gate C. |
| **`SIMULATED`** | Verified via deterministic digital RTL testbench simulation in `tb/`. |
| **`BLOCKED`** | A formal property or architectural test that cannot be executed due to the absence of a complete top-level dual-core SoC netlist. |
| **`UNVERIFIED`** | Physical silicon macro physics, analog side-channel bounds, or foundry manufacturing parameters deferred to Gate D accredited laboratory evaluation. |

---

## 2. Problem Statement & Legacy Normative Analysis

### 2.1 Verbatim Invariant Audit from ZC-CORE v3.x
An exhaustive audit of the root normative document [`zero-cloud-core-methodology-invariants.md`](../../zero-cloud-core-methodology-invariants.md) reveals the following verbatim clauses:

- **M1 (Trusted Sensor Acquisition):**
  > *"Raw sensor data (audio/video) SHALL NEVER leave the Trusted Domain."*
- **M3 (One-Way Information Flow):**
  > *"Protected raw-sensor information and derived representations SHALL flow strictly from the Trusted Domain to the Network Domain through a physically verifiable unidirectional channel. Authenticated control-plane and firmware-update traffic MAY enter the Trusted Domain, provided it cannot create a raw-sensor read-back path or a reverse raw-sensor information channel."*
- **M4 (Reverse-Read Impossibility):**
  > *"It MUST be physically or logically impossible for the Network/Control Domain to execute a functional reverse read (raw sensor read-back) from the Trusted Domain over a physical reverse channel. This is distinct from derived-data inference, reconstruction attacks, or side-channel leakage, which are mitigated by M1, M3, and M5."*
- **M8 (Post-Inference Destruction/Invalidation):**
  > *"Once inference completes, all persistent and temporary copies of raw data SHALL become irreversibly unrecoverable (e.g., physically destroyed or cryptographically zeroized across all caching layers)."*
- **Composition Rule:**
  > *"Sensor Acquisition → Trusted Local Inference → Controlled Semantic Release → Absolute Raw-Data Destruction → Network/Actuator Operation."*

### 2.2 Identification of the Legacy Drafting Friction (HAR-09)
Comparing these clauses reveals an acute textual friction in the legacy formulation:
1. **The Direct Contradiction:** M1 commands that raw sensor data *"SHALL NEVER leave"* the Trusted Domain, and M8 requires its complete post-inference zeroization. Yet the legacy text of M3 literally states that *"Protected raw-sensor information and derived representations SHALL flow strictly from the Trusted Domain to the Network Domain..."*. Taken literally, M3 asserts that raw-sensor information flows directly to the untrusted network.
2. **The True Architectural Intent:** The Composition Rule exposes the actual intended causal chain: what flows outward is **"Controlled Semantic Release"** (actuation states, classification tokens), while raw data is destroyed during **"Absolute Raw-Data Destruction"**.
3. **The Bidirectional Bus Ambiguity:** M3 mandates a *"physically verifiable unidirectional channel"*. In connected commercial appliances, utilizing separate physical one-way wires for every bus line is economically prohibitive and prevents standard bus topologies (OBI, AXI, SPI).
4. **Resolution via RFC:** This friction cannot be resolved by retroactively redefining v3.x text. It requires a formal major-version evolution (`v4.0.0 RFC`) establishing an unambiguous, mathematically sound information-flow contract.

---

## 3. Remediated Invariant Contract: `M3-RFC-REVISED`

To establish absolute normative clarity, this RFC proposes replacing the legacy M3 formulation with the following revised invariant contract for ZC-CORE v4.0.0:

```
==================================================================================================
 PROPOSED INVARIANT CONTRACT: M3-RFC-REVISED
==================================================================================================

1. ABSOLUTE PROHIBITION ON RAW SENSORY EGRESS (Class 0 & Class 1):
   Raw sensory data (Class 0: PCM audio, raw video frames, biometric ADC streams) and unquantized
   intermediate neural representations, spectrograms, or latent embeddings (Class 1) SHALL NEVER
   cross the physical Trust Boundary into the Network Domain under any operational state, power
   mode, reset condition, or fault status, strictly enforcing Invariants M1 and M8.

2. UNIDIRECTIONAL OUTBOUND SEMANTIC RELEASE (Class 2 & Class 3):
   Only cryptographically sanitized discrete physical actuation commands (Class 2) and allowlisted,
   entropy-bounded system health telemetry (Class 3) MAY flow outward from the Trusted Domain.
   Outbound release MUST be mediated by a hardware-enforced isolation boundary satisfying the
   configured operational profile.

3. HARDWARE-GATED INBOUND CONTROL & UPDATE PATH:
   Authenticated inbound control-plane commands and cryptographically signed firmware-update payloads
   MAY enter the Trusted Domain, provided that:
   a. Inbound traffic is gated by physical/fused hardware interlocks (e.g., dual /CS SPI firewalling,
      Boot ROM signature verification strobes, and monotonic SVN anti-rollback checks).
   b. Inbound paths cannot create a physical or logical reverse read-back channel (M4) to internal
      SRAM, registers, or sensor FIFOs.
   c. Execution from newly committed firmware banks is locked until verified by an independent
      hardware authorization gate.

4. PROFILE-STRATIFIED PHYSICAL ENFORCEMENT:
   a. STRICT Profile (M3-S): Semantic egress is enforced via a physical unidirectional channel
      (optical isolator, hardware data diode, or severed reverse conductor). Inbound traffic is
      prohibited during runtime and permitted only in dedicated physical maintenance modes.
   b. HYBRID Profile (M3-H): Shared bidirectional physical buses (OBI, SPI) are permitted ONLY when
      mediated by formally verified hardware bus firewalls with deterministic error trapping, bus
      orphan draining, and independent hardware rate limiting.
==================================================================================================
```

> [!IMPORTANT]
> **Implementation Gap & Scope Disclosure (HAR-11 Resolution):**  
> The requirements set forth in `M3-RFC-REVISED` represent **future mandatory architectural strictures (`SHALL` requirements)** for any device seeking ZC-CORE v4.0.0 HYBRID compliance.  
> In the current digital RTL baseline (`eb3ed5a` / Gate C):
> 1. The implemented RTL modules (`zc_obi_subordinate_bridge`, `zc_spi_flash_firewall`, `zc_aon_post_auth_ctrl`) provide local bus-level decoupling, orphan draining, and flash gating; they do **NOT** implement telemetry allowlisting, payload inspection, hardware rate limiting, or full-SoC DMA firewalling. These missing controls remain strictly **`PROPOSED / NOT IMPLEMENTED OR UNVERIFIED`** (tracked for Gate D SoC integration).
> 2. The local formal proofs in Gate C (`F-SPI-01..04`, `F-OBI-01..07`, `F-OTP-01..06`) prove block-level protocol invariants; they do **NOT** constitute end-to-end information-flow noninterference proofs across the entire hybrid architecture (which remains `BLOCKED` under `fv/zc_m7_m8_ni_sva.sv`).

---

## 4. Operational Security Profiles

```
+--------------------------------------------------------------------------------------------------+
|                                  ZC-CORE v4.0.0 SECURITY PROFILES                                |
+--------------------------------------------------------------------------------------------------+
|                                                                                                  |
|   +---------------------------------------+      +-------------------------------------------+   |
|   |         STRICT PROFILE (M3-S)         |      |          HYBRID PROFILE (M3-H)            |   |
|   +---------------------------------------+      +-------------------------------------------+   |
|   | Target: High-Assurance Air-Gap        |      | Target: Connected Commercial Edge-AI      |   |
|   | Egress: Zero Outbound Telemetry       |      | Egress: Hardware-Gated Semantic Telemetry |   |
|   | Diode: Physical Hardware Data Diode   |      | Diode: Formally Verified Bus Firewalls    |   |
|   | Updates: Physical Maintenance Port    |      | Updates: Hardware-Gated Dual-Bank OTA     |   |
|   | Status: 100% Backwards-Compatible     |      | Status: Architectural Target (Gate D)     |   |
|   +---------------------------------------+      +-------------------------------------------+   |
|                                                                                                  |
+--------------------------------------------------------------------------------------------------+
```

### 4.1 STRICT Profile (`ZC-PROFILE-STRICT`)
* **Objective:** Uncompromising outbound network isolation.
* **Outbound Information Flow:** Strictly prohibited. Zero bits of telemetry or state data cross the physical device perimeter. Only direct physical actuation (relays, motor drivers, local display panels) is permitted.
* **Physical Isolation Mechanism:** Physical data diode (e.g., optocoupler with reverse LED omitted, high-voltage electrical diode, or physical trace severance).
* **Inbound Maintenance:** Firmware updates permitted only when the device is placed into a dedicated, physical offline state (e.g., physical jumper shunting, mechanical key switch, factory programming header).
* **Target Markets:** Defense, critical national infrastructure, implanted medical devices, high-security residential surveillance zones.

### 4.2 HYBRID Profile (`ZC-PROFILE-HYBRID`)
* **Objective (Architectural Design Target):** Hardware-gated operational coexistence. The device may communicate with external networks via an untrusted Network Co-Processor under the strict design objective that raw sensor data cannot be leaked, extracted, or reverse-read.  
  *(Note: System-wide physical and logical verification of this design objective is unverified in current RTL and deferred to Gate D SoC integration).*
* **Outbound Information Flow:** Permitted exclusively for **Allowlisted Semantic Telemetry** (Class 3: boot counts, sanitized error codes, thermal indices, high-level aggregated inference state).
* **Hardware Interlocks in Gate C RTL:** Bidirectional communication utilizes dedicated hardware firewall modules:
  - `zc_obi_subordinate_bridge.sv`: Decouples bus transactions, drains orphan responses, and traps timeouts.
  - `zc_spi_flash_firewall.sv`: Reconciles Flash RDSR1 status and gates Bank B commit authorization.
  - `zc_aon_post_auth_ctrl.sv`: Enforces 4-phase DAI handshakes, monotonic SVN anti-rollback, and persistent fatal lock across warm resets.
* **Target Markets:** Commercial smart home appliances, fleet-managed commercial Edge-AI devices, connected industrial sensors requiring remote telemetry.

---

## 5. Comprehensive Information Flow Policy (Classes 0 to 4)

To resolve Auditor finding **HAR-01 / P0**, all information flows in a ZC-CORE v4.0.0 system are governed by the following multidimensional policy:

| Flow Direction | Source Domain | Destination Domain | Data Classification | STRICT Permission | HYBRID Permission | Physical & Hardware Enforcement Mechanism | Verification Status & Residual Risk |
| :--- | :--- | :--- | :--- | :---: | :---: | :--- | :--- |
| **Outbound** | Trusted Sensor / SRAM | Untrusted Network / Host | **Class 0: Raw Sensory Data** (PCM audio, raw video frames, ADC samples) | **FORBIDDEN** | **FORBIDDEN** | Hardware Domain Air-Gap / Memory Isolation / M8 Zeroization | **`DESIGN REQUIREMENT`** / Residual Risk: Physical PCB micro-probing (Mitigated by Gate D Tamper Shield). |
| **Outbound** | Trusted NPU / Cache | Untrusted Network / Host | **Class 1: Derived Representations** (Spectrograms, neural activations, embeddings) | **FORBIDDEN** | **FORBIDDEN** | Normatively treated as Class 0 under M1/M8. Destroyed upon inference completion. | **`DESIGN REQUIREMENT`** / Residual Risk: Un-zeroized DMA buffer retention (Mitigated by M8 zeroization). |
| **Outbound** | Trusted NPU / Host | Local Actuator (Physical) | **Class 2: Semantic Commands** (Discrete states: `RELAY_ON`, `TEMP_SET_200`) | **PERMITTED** | **PERMITTED** | Unidirectional Data Diode (STRICT) / OBI Subordinate Bridge (HYBRID) | **`IMPLEMENTED RTL`** (`zc_obi_subordinate_bridge.sv`) / Residual Risk: Command repetition side-channel. |
| **Outbound** | Trusted Host / Status | Untrusted Network / Host | **Class 3: Allowlisted Telemetry** (Boot count, thermal status, sanitized fault codes) | **FORBIDDEN** | **PERMITTED (Conditional Target)** | **PROPOSED / NOT IMPLEMENTED IN CURRENT RTL:** Requires dedicated Telemetry Hardware Rate Limiter & Allowlist Encoder (Gate D). Current Gate C RTL provides bus decoupling only. | **`UNVERIFIED RESEARCH TARGET`** / Residual Risk: Steganographic timing modulation or covert payload packing. |
| **Outbound** | Any Domain | External Network | **Class 4: Raw Audio/Visual Streaming** (RTSP, debug dumps, pass-through) | **FORBIDDEN (NON-COMPLIANT)** | **FORBIDDEN (NON-COMPLIANT)** | Immediate disqualification from ZC-CORE conformance under Invariant M1. | **`NON-COMPLIANT BY DEFINITION`** / Immediate exit from methodology. |
| **Inbound** | Untrusted Network / Master | Shared SPI Flash (Bank B) | **Inbound Firmware Update Payload** (Signed encrypted binary) | **Physical Socket Only** | **PERMITTED (Firewall-Gated)** | `zc_spi_flash_firewall.sv` (Rising /CS, SCK=0, RDSR1 status reconciliation, dual /CS gating). `bank_b_commit_ready_o = spi_idle_ready_o && rom_img_verif_valid_i`. | **`FORMALLY PROVEN`** (`F-SPI-01..04` Run #45) / Residual Risk: Flash wear-out attack (Mitigated by `AT-012`). |
| **Inbound** | Untrusted Network / Master | Trusted Core (Host OBI) | **Inbound Read/Write Request** (Bus access) | **FORBIDDEN** | **PERMITTED (Bridge-Gated)** | `zc_obi_subordinate_bridge.sv` (Warm reset gating `rst_sys_ni`, orphan drain, `ST_TRAP` error). Watchdog timeout verified via simulation (`SIMULATED`). | **`FORMALLY PROVEN`** (`F-OBI-01..07`) / **`SIMULATED`** (1,024-cyc wdog) / Residual Risk: Multi-master crossbar stall. |
| **Inbound** | Boot ROM / Verifier | AON OTP Controller | **Authorization Commit Command** (SVN increment, session seal) | **PERMITTED** | **PERMITTED** | `zc_aon_post_auth_ctrl.sv` (4-phase DAI handshake, single-cycle grant consumption). | **`FORMALLY PROVEN`** (`F-OTP-01..06` Run #45) / Residual Risk: Analog glitch during antifuse burning. |

---

## 6. Hardware Trust Boundaries & RTL Interface Contracts

The interconnect architecture enforces hardware trust boundaries across three discrete digital RTL IP blocks formally proven in Gate C (`eb3ed5a` / Run #45):

```
+---------------------------------------------------------------------------------------------------------+
|                                    ZC-CORE TRUST BOUNDARY TOPOLOGY                                      |
+---------------------------------------------------------------------------------------------------------+
|                                                                                                         |
|   [ UNTRUSTED EXTERNAL / NETWORK DOMAIN ]                                                               |
|     |  Network Co-Processor (Wi-Fi / BLE / Ethernet)                                                    |
|     +---------------+-------------------------------------+                                             |
|                     |                                     |                                             |
|          (SPI Bus)  v                         (OBI Bus)   v                                             |
|   +---------------------------------+   +------------------------------------+                          |
|   |   zc_spi_flash_firewall         |   |   zc_obi_subordinate_bridge        |                          |
|   |   - Pass-through / Gated /CS    |   |   - Synchronous Bus Decoupling     |                          |
|   |   - Rising /CS + SCK=0 Strobe   |   |   - 1024-Cycle Orphan Watchdog     |                          |
|   |   - 05h RDSR1 Status Reconciler |   |   - ST_TRAP Synthetic Error Trap   |                          |
|   |   - Bank-B Commit Gating        |   |   - Warm Reset (rst_sys_ni) Gating |                          |
|   +----------------+----------------+   +-----------------+------------------+                          |
|                    |                                      |                                             |
|                    v (Protected SPI)                      v (Safe Host OBI)                             |
|          [ Shared SPI Flash ]                   [ Secure Host CPU / Interconnect ]                      |
|                                                           |                                             |
|                                                (DAI Bus)  v                                             |
|                                         +------------------------------------+                          |
|                                         |   zc_aon_post_auth_ctrl            |                          |
|                                         |   - 4-Phase DAI Handshake          |                          |
|                                         |   - Immediate Grant Consumption    |                          |
|                                         |   - Permanent Fatal Lock (AON)     |                          |
|                                         |   - Hsiao (22,16) Parity Match     |                          |
|                                         +-----------------+------------------+                          |
|                                                           |                                             |
|                                                           v                                             |
|                                                 [ AON Physical OTP / eFuse ]                            |
|                                                                                                         |
|   [ TRUSTED PROCESSING DOMAIN ]                                                                         |
|     |  Edge NPU + Secure SRAM (M8 Zeroization) + Privacy Sensors (M1/M9 Air-Gap)                        |
|                                                                                                         |
+---------------------------------------------------------------------------------------------------------+
```

### 6.1 SPI Flash Firewall (`zc_spi_flash_firewall.sv`)
* **Verification Status:** `FORMALLY PROVEN` (`F-SPI-01`..`F-SPI-04`, `C-SPI-01`..`C-SPI-06` in Run #45).
* **Core Function:** Shields shared external SPI Flash memory from frame desynchronization, write-enable poisoning, and unauthorized Bank B boot execution.
* **Architectural Equation:**
  ```verilog
  assign spi_idle_ready_o      = (spi_update_fsm_q == UPD_IDLE) && !fault_high_sec_i;
  assign bank_b_commit_ready_o = spi_idle_ready_o && rom_img_verif_valid_i;
  ```
* **Cryptographic Trust Assumption Disclosure (HAR-04):** The SPI Firewall does **NOT** execute cryptographic hashing (SHA-256) or signature verification (Ed25519) within its RTL logic. It acts strictly as a **hardware authorization gate**. The cryptographic validity of the firmware image is a declared **external trust assumption** provided via `rom_img_verif_valid_i`.

### 6.2 OBI Subordinate Bridge (`zc_obi_subordinate_bridge.sv`)
* **Verification Status:** `FORMALLY PROVEN` (`F-OBI-01`..`F-OBI-07`) / `SIMULATED` (1,024-cycle watchdog timeout).
* **Core Function:** Synchronously decouples host bus transactions from subordinate peripherals, drains orphan responses, and traps bus deadlocks.
* **Watchdog Evidence Classification (HAR-06):** Continuous progression across 1,024 cycles is verified via digital RTL simulation (`tb_zc_obi.sv` Test 2 / `SIMULATED`). Properties `F-OBI-04` and `F-OBI-05` formally prove local inductive step logic and lock assertion (`PROVEN` at RTL step level).
* **Subsystem Boundary Disclosure (HAR-02 & HAR-07):** The OBI Bridge provides point-to-point transaction decoupling. It does **NOT** constitute a multi-master crossbar IOMMU, does **NOT** act as a system-wide DMA firewall, and does **NOT** filter or inspect telemetry payloads (`PROPOSED / NOT IMPLEMENTED IN CURRENT RTL`).

### 6.3 AON Post-Authorization Controller (`zc_aon_post_auth_ctrl.sv`)
* **Verification Status:** `FORMALLY PROVEN` (`F-OTP-01a/b`..`F-OTP-06`, `C-OTP-01`..`C-OTP-07` in Run #45).
* **Core Function:** Controls the Direct Access Interface (DAI) of the physical OTP memory for anti-rollback version fuses and permanent authorization seals.
* **Key Mechanisms:** 4-phase DAI handshake protocol, single-cycle grant consumption, permanent fatal lock surviving warm reset (`rst_sys_ni`), and Hsiao (22,16) codeword parity verification.

---

## 7. Proposed Telemetry Hardware Controls (Gate D Deliverables)

To achieve full compliance with `M3-RFC-REVISED` under the HYBRID profile, the following hardware mechanisms must be implemented and verified in future Gate D SoC integration:

| Security Control | Implementation Mechanism | Target Milestone | Status in Current Baseline (`eb3ed5a`) |
| :--- | :--- | :---: | :---: |
| **Telemetry Allowlist Filter** | Hardware comparator matching outbound OBI data against static schema IDs. | Gate D SoC Integration | **`PROPOSED / NOT IMPLEMENTED`** |
| **Deterministic Payload Encoder** | Static binary packetizer enforcing compile-time struct alignment and zero-padding. | Gate D SoC Integration | **`PROPOSED / NOT IMPLEMENTED`** |
| **Hardware Epoch Rate Limiter** | Hardware interval timer enforcing discrete transmission windows (e.g., $\le 1$ packet / 60 s). | Gate D SoC Integration | **`PROPOSED / NOT IMPLEMENTED`** |
| **Data-Origin Domain Isolation** | System crossbar PMP / IOMMU blocking DMA masters from bridging Secure SRAM to Network FIFO. | Gate D SoC Integration | **`UNVERIFIED AT SOC LEVEL`** |
| **Covert-Channel Mutual Information Target** | Statistical leakage bound $\max I(S_{\text{raw}}; T_{\text{out}}) \le \epsilon_{\text{target}}$ evaluated under CTS Annex B. | Gate D Lab Audit | **`UNVERIFIED RESEARCH TARGET`** |

### 7.1 Covert-Channel Mutual Information Objective (HAR-13)
The theoretical objective for statistical non-leakage under the HYBRID profile is formulated as:
$$\max_{\mathcal{A} \in \mathcal{M}_{\text{threat}}} I(S_{\text{raw}}; T_{\text{out}} \mid \mathcal{O}_{\text{side-channel}}) \le \epsilon_{\text{target}}$$
where $S_{\text{raw}}$ is the raw sensor data distribution, $T_{\text{out}}$ is the outbound telemetry stream, $\mathcal{O}_{\text{side-channel}}$ represents observable physical emissions, $\mathcal{M}_{\text{threat}}$ is a constrained non-invasive physical threat model, and $\epsilon_{\text{target}}$ is an unapproved, target statistical bound.

> [!WARNING]
> **Metric Limitations & Research Status (HAR-13 Resolution):**  
> 1. **Unapproved Metric:** The numerical value of $\epsilon_{\text{target}}$, the physical sampling methodology, sample size, measurement protocols, and statistical confidence intervals ($1 - \alpha$) are unapproved research objectives pending Gate D / CTS Annex B standardization. This equation is an **`UNVERIFIED RESEARCH / VALIDATION TARGET`**, not an approved or certified pass/fail acceptance criterion.  
> 2. **Scope Limitation:** A statistical mutual information metric bounded within a constrained model does NOT mathematically or physically prove the absolute absence of all conceivable side-channel avenues, hardware bugs, or covert leakage mechanisms across real-world physical operating conditions.

---

## 8. Invariant Compatibility & Methodology Impact (M1–M10 Matrix)

| Invariant ID | Normative Invariant Definition | STRICT Profile (v4.0.0-S) | HYBRID Profile (v4.0.0-H) | Implemented Digital RTL & Formal Proof (Gate C Baseline) | Missing System & Physical Scope (Gate D Deliverables) |
| :--- | :--- | :---: | :---: | :--- | :--- |
| **M1** | **Trusted Sensor Acquisition:** Raw sensor data SHALL NEVER leave Trusted Domain. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design Requirement)* | M1 is a domain boundary invariant; verified at PCB / package routing level. | Physical PCB pin air-gap, tamper shield. |
| **M2** | **Hardware-Enforced Domain Boundary:** Separation MUST be physical, not software. | **`COMPATIBLE`** | **`CONDITIONAL`** *(Design Requirement)* | Bus-level and SPI-level firewalls proven (`F-OBI-01..07`, `F-SPI-01..04`). | Multi-master crossbar DMA firewall, IOMMU. |
| **M3** | **One-Way Information Flow:** Protected data SHALL flow strictly unidirectional. | **`COMPATIBLE`** | **`CONDITIONAL`** *(Governed by M3-RFC-REVISED)* | Bus decoupling (`F-OBI-06`) and SPI commit gating (`F-SPI-02`) proven. Telemetry filtering NOT implemented. | Telemetry allowlist filter, hardware rate limiter, CTS Annex B mutual information testing. |
| **M4** | **Reverse-Read Impossibility:** Reverse read of raw sensor data MUST be impossible. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Implementation-Verified)* | `zc_obi_subordinate_bridge.sv` returns synthetic zero data (`ST_TRAP`) upon failure (`F-OBI-04/05`). | SoC crossbar reverse-read protection against malicious DMA bus masters (`BLOCKED`). |
| **M5** | **Control-Plane Isolation:** Boundary MUST encompass clock, reset, power, DMA, debug. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Implementation-Verified)* | Warm reset (`rst_sys_ni`) request gating (`F-OBI-07`); persistent fatal lock across reset (`F-OTP-05`). | Physical clock/voltage glitch fault injection tests; asynchronous reset recovery/removal STA. |
| **M6** | **Hardware-Rooted Execution Integrity:** Trust chain MUST cover model weights and SVN. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Implementation-Verified)* | 4-phase DAI handshake (`F-OTP-02/03`), single-cycle grant (`F-OTP-06`), SVN monotonicity (`F-OTP-01a/b`). | External Boot ROM crypto verification accuracy (`rom_img_verif_valid_i`); analog antifuse PDK macro. |
| **M7** | **Raw-Data Lifetime Enforcement:** Raw data bound strictly to inference cycle. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design Requirement)* | **`BLOCKED`**: Dual-trace miter formal equivalence (`fv/zc_m7_m8_ni_sva.sv`) awaits top-level SoC netlist. | Hardware inference lifecycle counter and interrupt enforcement in top-level SoC. |
| **M8** | **Post-Inference Destruction:** Irreversible zeroization post-inference. | **`COMPATIBLE`** | **`CONDITIONAL`** *(Physical Remanence Limit)* | **`BLOCKED`**: Digital RTL SRAM zeroization controller awaits top-level SoC netlist. | Physical silicon remanence rate verification ($R_{\text{rate}} \le 0.01\%$) via cryogenic testing in Gate D. |
| **M9** | **Complete Sensor Inventory:** ALL sensors MUST share identical trusted boundary. | **`COMPATIBLE`** | **`COMPATIBLE`** *(Design Requirement)* | M9 is an architectural policy; no secondary network-side microphones permitted. | Physical PCB X-ray inspection, BOM verification. |
| **M10** | **Independent Conformance Evidence:** Evidence MUST be objective, measurable lab proof. | **`COMPATIBLE`** | **`CONDITIONAL`** *(Formal Scope Scoped)* | Gate C digital formal proofs complete (`PARTIAL / QUALIFIED`). | Third-party accredited laboratory test reports (EM, fault injection, side-channel). |

---

## 9. Modular Conformance Test Framework (CTS-v4)

To prevent conflation between profiles, the ZC-CORE v4.0.0 Conformance Test Suite (CTS-v4) is structured into three modular, hierarchical test suites:

```
+--------------------------------------------------------------------------------------------------+
|                                    MODULAR CTS-v4 TEST ARCHITECTURE                              |
+--------------------------------------------------------------------------------------------------+
|                                                                                                  |
|   +------------------------------------------------------------------------------------------+   |
|   |   CTS-CORE (Mandatory Baseline for ALL Profiles)                                         |   |
|   |   - M1/M9 Physical Sensor Inventory & X-Ray Package Audit                                |   |
|   |   - M6 Secure Boot & Monotonic Anti-Rollback SVN Progression Verification                |   |
|   |   - M8 Post-Inference Cryptographic Memory Destruction Test                              |   |
|   +-----------------------------+------------------------------------------------------------+   |
|                                 |                                                                |
|                 +---------------+---------------+                                                |
|                 |                               |                                                |
|                 v                               v                                                |
|   +---------------------------+   +----------------------------------------------------------+   |
|   |   CTS-STRICT (Profile S)  |   |   CTS-HYBRID (Profile H)                                 |   |
|   +---------------------------+   +----------------------------------------------------------+   |
|   | - FC-ZC-017:              |   | - FC-ZC-018:                                             |   |
|   |   Zero Outbound Leakage   |   |   Hardware Bus Firewall Boundary & Error Trap Test       |   |
|   |   via Anechoic RF Audit   |   | - FC-ZC-019:                                             |   |
|   | - Physical Data Diode     |   |   Telemetry Allowlist Schema Clamping & Rate-Limit Audit |   |
|   |   Continuity Verification |   | - FC-ZC-020:                                             |   |
|   |                           |   |   Covert-Channel Mutual Information Leakage Bound Test   |   |
|   +---------------------------+   +----------------------------------------------------------+   |
|                                                                                                  |
+--------------------------------------------------------------------------------------------------+
```

---

## 10. Backward Compatibility & Versioning Governance Policy

1. **Preservation of ZC-CORE v3.3.0-rc2:**  
   The published `ZC-CORE v3.3.0-rc2` specification and its associated Zenodo records remain immutable historical benchmarks. All devices certified under v3.x automatically satisfy `ZC-PROFILE-STRICT` without hardware modification.
2. **The v4.0.0 Migration Path:**  
   ZC-CORE v4.0.0 represents a **Breaking Architectural Major Version** due to the formalization of bidirectional bus firewalls and the `M3-RFC-REVISED` invariant contract.
3. **Decoupled Milestone Strategy (HAR-10):**  
   - **Milestone 1 (Governance & RFC):** Formalization of this RFC document.
   - **Milestone 2 (Defensive Publication):** Public Zenodo disclosure of `ZC-CORE-008` patent claim family (establishing timestamped documentary prior art; does NOT require silicon tape-out).
   - **Milestone 3 (Digital RTL & SoC Verification):** FPGA synthesis and multi-master crossbar netlist verification.
   - **Milestone 4 (Physical Silicon Compliance - Gate D):** ASIC foundry fabrication, physical remanence testing, and commercial release authorization.

---

## 11. Open Security Questions, Limitations & Acceptance Criteria

Before ZC-CORE v4.0.0 can be submitted for final standards ratification and commercial release, the following open technical hurdles must be resolved in Gate D:

1. **Top-Level Multi-Master Noninterference (`SVA-M7-01`, `SVA-M8-01`):**  
   Formal verification of the dual-trace miter across the integrated dual-core Ibex, NPU, and shared crossbar netlist (`fv/zc_m7_m8_ni_sva.sv`). Currently **`BLOCKED`**.
2. **Physical Antifuse PDK Macro Characterization:**  
   Foundry silicon validation of high-voltage programming pulses ($V_{\text{PP}} > 1.8\,\text{V}$) and burn-in retention physics. Currently **`UNVERIFIED`**.
3. **Hardware Telemetry Controller Implementation:**  
   RTL synthesis and formal verification of the dedicated telemetry allowlist comparator and hardware rate limiter. Currently **`PROPOSED / NOT IMPLEMENTED`**.
4. **Anechoic Chamber Side-Channel Validation:**  
   Independent laboratory testing under CTS Annex B to measure physical EM/RF statistical leakage bounds against the target threshold $\epsilon_{\text{target}}$. Currently **`UNVERIFIED RESEARCH TARGET`**.
