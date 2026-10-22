# Hybrid Zero-Cloud & Edge Security Architecture
## STRICT & HYBRID Profile Compatibility & Invariant Mapping

**Document ID:** `ZC-HYBRID-COMPATIBILITY-01`  
**Classification:** Canonical Architecture Suite Specification  
**Status:** `CANDIDATE BASELINE / UNRATIFIED`  
**Parent Document:** [`README.md`](README.md)  

---

## 1. Architectural Relationship: STRICT vs. HYBRID Profiles

The FreeCuli Zero-Cloud Hardware Core (ZC-CORE) methodology standardizes a privacy-by-design framework across two distinct operational security profiles:

| Dimension | STRICT Profile (`ZC-PROFILE-STRICT`) | HYBRID Profile (`ZC-PROFILE-HYBRID`) |
| :--- | :--- | :--- |
| **Normative Reference** | [`zero-cloud-hardware-reference-architecture.md`](../../zero-cloud-hardware-reference-architecture.md) | [`docs/hybrid-zero-cloud-edge-security-architecture/`](README.md) & [`docs/architecture/`](../architecture/) |
| **Outbound Telemetry** | **Zero bits permitted.** Absolute outbound physical isolation. | **Conditional allowlisted semantic telemetry permitted** (health, status, sanitized fault codes). |
| **Interconnect Topology** | Pure physical unidirectional data diode (e.g., optocoupler, TX-only UART). | Hardware-gated bidirectional bus (OBI) and shared SPI Flash with dual /CS firewalling. |
| **Inbound Updates (OTA)**| Physical socket, factory programming jig, or physical maintenance jumper only. | Cryptographically validated inbound OTA via hardware SPI flash firewall (`zc_spi_flash_firewall.sv`). |
| **Deployment Scenarios** | Defense, medical implants, high-security facilities, zero-network air-gapped sensors. | Commercial smart home appliances, fleet-managed commercial Edge-AI, smart appliances. |
| **Standardization Status**| **Ratified Normative Standard** (v3.x root specifications). | **Candidate Architecture Baseline** (`v4.0.0-rc1` release candidate; unratified RFC draft). |

Both profiles share the fundamental axiom that **raw privacy-sensitive sensor data SHALL NEVER leave the local hardware-enforced Trusted Processing Domain.** The HYBRID profile does not weaken this rule; it introduces active digital silicon firewalls to permit network coexistence while maintaining noninterference.

---

## 2. Clause-by-Clause Methodology Invariants (M1–M10) Mapping

Every implementation of the ZC-CORE methodology must satisfy the causal sequence defined in [`zero-cloud-core-methodology-invariants.md`](../../zero-cloud-core-methodology-invariants.md). The table below evaluates each invariant against the HYBRID profile using the five standardized classification categories:

1. **Mevcut STRICT hükmü korunur** (Legacy STRICT requirement remains frozen and active)
2. **HYBRID içinde aynı hüküm uygulanır** (Identical requirement enforced in HYBRID)
3. **HYBRID için uyarlama veya açık tasarım kararı gerekir** (Requires architectural adaptation or RFC design decision)
4. **Mevcut kanıtlarla uyumluluk henüz doğrulanamıyor** (Compatibility cannot yet be verified with current evidence)
5. **İlgisiz; gerekçesi belirtilmiş** (Not applicable, with explicit rationale)

| Invariant | Root Normative Stricture (Summary) | Classification Category | HYBRID Profile Implementation & Technical Evidence |
| :--- | :--- | :---: | :--- |
| **M1: Trusted Sensor Acquisition** | Raw sensor data (audio/video) SHALL NEVER leave the Trusted Domain. | **HYBRID içinde aynı hüküm uygulanır** | Raw sensor lines connect exclusively to the isolated Edge NPU/host in Domain 1. The untrusted Network Co-Processor has zero physical routing or pin multiplexing to sensor interfaces. Proven at architecture level; verified via PCB netlist rules in Conformance Test Specification (CTS). |
| **M2: Hardware-Enforced Domain Boundary** | Separation between Trusted and Untrusted Domains MUST be enforced physically, not via software isolation. | **HYBRID içinde aynı hüküm uygulanır** | Boundary is enforced by physical silicon firewalls ([`rtl/zc_spi_flash_firewall.sv`](../../rtl/zc_spi_flash_firewall.sv), [`rtl/zc_obi_subordinate_bridge.sv`](../../rtl/zc_obi_subordinate_bridge.sv)) rather than operating system sandboxes or software VLANs. |
| **M3: One-Way Information Flow** | Protected raw-sensor information SHALL flow strictly from Trusted to Network domain. Authenticated control-plane/firmware-update traffic MAY enter Trusted Domain. | **HYBRID için uyarlama veya açık tasarım kararı gerekir** | *Root Clause Tension:* Legacy M3 stated that raw sensor data flows outward (contradicting M1/M8). In HYBRID, `M3-RFC-REVISED` formally adapts this: only discrete semantic actuation and allowlisted telemetry flow outward, while inbound OTA is gated via SPI firewall and Boot ROM authentication. Requires final RFC ratification. |
| **M4: Reverse-Read Impossibility** | MUST be physically or logically impossible for Network Domain to execute a functional reverse read of raw sensor data. | **HYBRID içinde aynı hüküm uygulanır** | Inbound OBI requests cannot address or read sensor ADC/FIFO buffers. `zc_obi_subordinate_bridge` maps unauthorized address spans to `ST_TRAP`, returning synthetic bus error responses and zero data (`host_rdata_o <= 32'h0`). Formally verified via `F-OBI-01` ($t=20$). |
| **M5: Control-Plane Isolation** | Trust Boundary MUST encompass control, memory, power, reset, clock, DMA, and debug paths. | **HYBRID için uyarlama veya açık tasarım kararı gerekir** | *Adaptation Required:* In STRICT, isolation is complete air-gap. In HYBRID, control signals cross domains under hardware gating (e.g., `rst_sys_ni` warm reset gating in OBI bridge). Full-SoC DMA and clock crossbar isolation requires Gate D SoC integration evidence. |
| **M6: Hardware-Rooted Execution Integrity** | Secure boot and update trust chain SHALL strictly cover entire Trusted Domain including AI weights. | **HYBRID içinde aynı hüküm uygulanır** | Authenticated boot flow mediated by Boot ROM signature check and [`rtl/zc_aon_post_auth_ctrl.sv`](../../rtl/zc_aon_post_auth_ctrl.sv), which validates Security Version Numbers (SVN) and seals OTP authorization registers. |
| **M7: Raw-Data Lifetime Enforcement** | Availability of raw data MUST be strictly bound to local inference lifecycle. | **HYBRID içinde aynı hüküm uygulanır** | Raw audio/video frames are buffered only in volatile SRAM during active inference. Lifetime timers are implemented locally in the NPU execution domain. |
| **M8: Post-Inference Destruction / Invalidation** | Once inference completes, all persistent and temporary copies of raw data SHALL become irreversibly unrecoverable. | **HYBRID içinde aynı hüküm uygulanır** | Enforces hardware zeroization or physical power-cut of sensor SRAM. Formally specified in [`fv/zc_m7_m8_ni_sva.sv`](../../fv/zc_m7_m8_ni_sva.sv); physical SRAM remanence characterization deferred to Gate D. |
| **M9: Physical Air-Gap / Interface Minimization** | Physical interfaces entering Trusted Domain MUST be strictly minimized and documented. | **HYBRID içinde aynı hüküm uygulanır** | All physical inter-domain pins are inventoried. The interface between Domain 0 and Domain 1 is restricted strictly to the documented SPI and OBI bus firewall connections. |
| **M10: Auditability & Conformance Verification** | Conformance MUST be empirically verifiable using standard lab equipment (oscilloscopes, VNAs) and formal proofs. | **HYBRID içinde aynı hüküm uygulanır** | Conformance verified through open-source formal proof suites ([`fv/`](../../fv/)) and laboratory test benches in [`zero-cloud-core-conformance-test-specification.md`](../../zero-cloud-core-conformance-test-specification.md). |

---

## 3. Data Taxonomy Reconciliation (Root 4-Class vs. V4 RFC 5-Class)

To eliminate conceptual contradictions between the root normative standard and the candidate V4 architecture, the data classification schemas are reconciled as follows:

### 3.1 The Root 4-Class Normative Taxonomy ([`zero-cloud-core-scope-boundary.md`](../../zero-cloud-core-scope-boundary.md))
The immutable root standard categorizes all system data into four strict classes:
- **Class 1 (Sensitive Raw Sensor Data):** Audio PCM samples, raw video frames, biometric scans. Egress is **CATEGORICALLY FORBIDDEN**.
- **Class 2 (Derived Representations):** Intermediate neural activations, spectrograms, feature embeddings. Normatively treated as Class 1 under M1/M8; egress is **CATEGORICALLY FORBIDDEN**.
- **Class 3 (Public System Metrics):** Device uptime, boot cycle count, temperature alerts, sanitized diagnostic error flags. Egress is permitted under strict conditions.
- **Class 4 (Security & Keying Material):** Cryptographic root keys, OTP eFuse contents, intermediate HMAC states. Egress is **CATEGORICALLY FORBIDDEN**.

### 3.2 The V4 RFC Candidate Proposal: Class 0 (Inbound Control-Plane Traffic)
In [`docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md`](../../docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md), the standards committee proposed introducing a fifth data class:
- **`Class 0: Inbound Control-Plane Traffic`:** Represents cryptographically signed firmware update containers, runtime management configuration packets, and time synchronization beacons arriving from external networks into the device.

### 3.3 Status Reconciliation
1. **No Silent Amendment:** The introduction of "Class 0" in RFC-0004 is an **architectural proposal draft (`DRAFT / NOT RATIFIED`)**. It does not silently overwrite or invalidate the 4-class taxonomy of the root specification.
2. **Operational Mapping:** In the HYBRID profile, Class 0 inbound traffic is permitted to cross the hardware boundary *only* through the firewall-mediated paths (`zc_spi_flash_firewall` for firmware staging and `zc_obi_subordinate_bridge` for configuration queries).
3. **Egress Independence:** Class 0 applies exclusively to *inbound* traffic. It does not create or permit any reverse egress path for Class 1 (Raw) or Class 2 (Derived) data, strictly maintaining compliance with Invariants M1, M4, and M8.
