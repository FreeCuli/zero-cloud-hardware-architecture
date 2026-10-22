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
| **Normative Reference** | [`zero-cloud-hardware-reference-architecture.md`](../zero-cloud-hardware-reference-architecture.md) | [`hybrid-zero-cloud-edge-security-architecture/`](README.md) & [`docs/architecture/`](../docs/architecture/) |
| **Outbound Telemetry** | **Zero bits permitted.** Absolute outbound physical isolation. | **Conditional allowlisted semantic telemetry permitted** (health, status, sanitized fault codes). |
| **Interconnect Topology** | Pure physical unidirectional data diode (e.g., optocoupler, TX-only UART). | Hardware-gated bidirectional bus (OBI) and shared SPI Flash with dual /CS firewalling. |
| **Inbound Updates (OTA)**| Physical socket, factory programming jig, or physical maintenance jumper only. | Cryptographically validated inbound OTA via hardware SPI flash firewall (`zc_spi_flash_firewall.sv`). |
| **Deployment Scenarios** | Defense, medical implants, high-security facilities, zero-network air-gapped sensors. | Commercial smart home appliances, fleet-managed commercial Edge-AI, smart appliances. |
| **Standardization Status**| **Ratified Normative Standard** (v3.x root specifications). | **Candidate Architecture Baseline** (`v4.0.0-rc2` release candidate; unratified RFC draft). |

Both profiles share the fundamental axiom that **raw privacy-sensitive sensor data SHALL NEVER leave the local hardware-enforced Trusted Processing Domain.** The HYBRID profile does not weaken this rule; it introduces active digital silicon firewalls to permit network coexistence while maintaining noninterference.

---

## 2. Clause-by-Clause Methodology Invariants (M1–M10) Mapping

Every implementation of the ZC-CORE methodology must satisfy the causal sequence defined in [`zero-cloud-core-methodology-invariants.md`](../zero-cloud-core-methodology-invariants.md). The table below evaluates each invariant against the HYBRID profile using the five standardized classification categories:

1. **Mevcut STRICT hükmü korunur** (Legacy STRICT requirement remains frozen and active)
2. **HYBRID içinde aynı hüküm uygulanır** (Identical requirement enforced in HYBRID)
3. **HYBRID için uyarlama veya açık tasarım kararı gerekir** (Requires architectural adaptation or RFC design decision)
4. **Mevcut kanıtlarla uyumluluk henüz doğrulanamıyor** (Compatibility cannot yet be verified with current evidence)
5. **İlgisiz; gerekçesi belirtilmiş** (Not applicable, with explicit rationale)

| Invariant | Root Normative Stricture (Summary) | Classification Category | HYBRID Profile Implementation & Technical Evidence |
| :--- | :--- | :---: | :--- |
| **M1: Trusted Sensor Acquisition** | Raw sensor data (audio/video) SHALL NEVER leave the Trusted Domain. | **HYBRID içinde aynı hüküm uygulanır** | Raw sensor lines connect exclusively to the isolated Edge NPU/host in Domain 1. The untrusted Network Co-Processor has zero physical routing or pin multiplexing to sensor interfaces. Proven at architecture level; verified via PCB netlist rules in Conformance Test Specification (CTS). |
| **M2: Hardware-Enforced Domain Boundary** | Separation between Trusted and Untrusted Domains MUST be enforced physically, not via software isolation. | **HYBRID içinde aynı hüküm uygulanır** | Boundary is enforced by physical silicon firewalls ([`rtl/zc_spi_flash_firewall.sv`](../rtl/zc_spi_flash_firewall.sv), [`rtl/zc_obi_subordinate_bridge.sv`](../rtl/zc_obi_subordinate_bridge.sv)) rather than operating system sandboxes or software VLANs. |
| **M3: One-Way Information Flow** | Protected raw-sensor information SHALL flow strictly from Trusted to Network domain. Authenticated control-plane/firmware-update traffic MAY enter Trusted Domain. | **HYBRID için uyarlama veya açık tasarım kararı gerekir** | *Root Clause Tension:* Legacy M3 stated that raw sensor data flows outward (contradicting M1/M8). In HYBRID, `M3-RFC-REVISED` formally adapts this: only discrete semantic actuation and allowlisted telemetry flow outward, while inbound OTA is gated via SPI firewall and Boot ROM authentication. Requires final RFC ratification. |
| **M4: Reverse-Read Impossibility** | MUST be physically or logically impossible for Network Domain to execute a functional reverse read of raw sensor data. | **HYBRID içinde aynı hüküm uygulanır** | Inbound OBI requests cannot address or read sensor ADC/FIFO buffers. `zc_obi_subordinate_bridge` maps unauthorized address spans to `ST_TRAP`, returning synthetic bus error responses and zero data (`host_rdata_o <= 32'h0`). Formally verified via `F-OBI-01` ($t=20$). |
| **M5: Control-Plane Isolation** | Trust Boundary MUST encompass control, memory, power, reset, clock, DMA, and debug paths. | **HYBRID için uyarlama veya açık tasarım kararı gerekir** | *Adaptation Required:* In STRICT, isolation is complete air-gap. In HYBRID, control signals cross domains under hardware gating (e.g., `rst_sys_ni` warm reset gating in OBI bridge). Full-SoC DMA and clock crossbar isolation requires Gate D SoC integration evidence. |
| **M6: Hardware-Rooted Execution Integrity** | Secure boot and update trust chain SHALL strictly cover entire Trusted Domain including AI weights. | **HYBRID içinde aynı hüküm uygulanır** | Authenticated boot flow mediated by Boot ROM signature check and [`rtl/zc_aon_post_auth_ctrl.sv`](../rtl/zc_aon_post_auth_ctrl.sv), which validates Security Version Numbers (SVN) and seals OTP authorization registers. |
| **M7: Raw-Data Lifetime Enforcement** | Availability of raw data MUST be strictly bound to local inference lifecycle. | **HYBRID içinde aynı hüküm uygulanır** | Raw audio/video frames are buffered only in volatile SRAM during active inference. Lifetime timers are implemented locally in the NPU execution domain. |
| **M8: Post-Inference Destruction / Invalidation** | Once inference completes, all persistent and temporary copies of raw data SHALL become irreversibly unrecoverable. | **HYBRID içinde aynı hüküm uygulanır** | Enforces hardware zeroization or physical power-cut of sensor SRAM. Formally specified in [`fv/zc_m7_m8_ni_sva.sv`](../fv/zc_m7_m8_ni_sva.sv); physical SRAM remanence characterization deferred to Gate D. |
| **M9: Physical Air-Gap / Interface Minimization** | Physical interfaces entering Trusted Domain MUST be strictly minimized and documented. | **HYBRID içinde aynı hüküm uygulanır** | All physical inter-domain pins are inventoried. The interface between Domain 0 and Domain 1 is restricted strictly to the documented SPI and OBI bus firewall connections. |
| **M10: Auditability & Conformance Verification** | Conformance MUST be empirically verifiable using standard lab equipment (oscilloscopes, VNAs) and formal proofs. | **HYBRID içinde aynı hüküm uygulanır** | Conformance verified through open-source formal proof suites ([`fv/`](../fv/)) and laboratory test benches in [`zero-cloud-core-conformance-test-specification.md`](../zero-cloud-core-conformance-test-specification.md). |

---

## 3. Data Taxonomy Reconciliation (Root Functional Taxonomy vs. V4 RFC Numbered Schema)

To eliminate conceptual contradictions between the root normative standard and the candidate V4 architecture, the data classification schemas are reconciled as follows:

### 3.1 The Root Normative Data Taxonomy ([`zero-cloud-core-scope-boundary.md`](../zero-cloud-core-scope-boundary.md))
The immutable root standard categorizes all system data into five foundational definitions:
- **Raw Sensor Data:** Uncompressed, unmodified analog or digital output directly from privacy-sensitive sensors (audio PCM waveforms, video pixel frames, biometric ADC streams). Egress is **CATEGORICALLY FORBIDDEN** (M1).
- **Derived Sensor Representation:** Intermediate features (embeddings, Mel-spectrograms, latent neural activations) that could indirectly facilitate reconstruction of raw data. Must be treated with the exact same containment rules as Raw Sensor Data; egress is **CATEGORICALLY FORBIDDEN** (M1/M8).
- **Metadata:** Contextual or environmental parameters (timestamps, ambient temperature) that do not leak raw sensor states.
- **Semantic Result:** Irreversible, abstracted low-bandwidth state (e.g., "Person recognized", "Turn on light") that cannot be reversed to raw data. May be released outside the Trusted Domain provided no practical reconstruction channel exists.
- **Actuator Command:** The final control signal sent outside the Trusted Domain to physical actuators.

### 3.2 The V4 RFC Numbered Classification Schema ([`docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md`](../docs/rfc/ZC-CORE-V4-ARCHITECTURE-RFC.md) §3)
In the candidate V4 Architecture RFC, the standards committee formulated an enumerated classification schema to support bus-level filtering and formal assertions:
- **Class 0 (Raw Sensory Data):** Corresponds directly to root *Raw Sensor Data*. Egress is **FORBIDDEN**.
- **Class 1 (Derived Representations):** Corresponds to root *Derived Sensor Representation*. Egress is **FORBIDDEN**; destroyed upon inference completion (M8).
- **Class 2 (Semantic Commands):** Corresponds to root *Semantic Result / Actuator Command*. Egress is **PERMITTED** across the isolation boundary.
- **Class 3 (Allowlisted Telemetry):** Proposed candidate class for sanitized health/status telemetry (boot count, temperature, sanitized fault flags). **`PROPOSED / CONDITIONAL TARGET`** in HYBRID (requires dedicated Gate D hardware rate-limiter and allowlist encoder; current RTL provides bus decoupling only).
- **Class 4 (Raw Audio/Visual Streaming):** Deliberate unencrypted/pass-through raw sensor streaming. **FORBIDDEN / NON-COMPLIANT** by definition.
- **Inbound Control Traffic:** Cryptographically signed firmware update containers and runtime management queries. Mediated exclusively through hardware firewalls (`zc_spi_flash_firewall.sv` for Bank B staging and `zc_obi_subordinate_bridge.sv` for configuration queries).

### 3.3 Reconciliation & Non-Contradiction
1. **Semantic Equivalence:** The RFC numbered classes do not contradict or alter the root functional taxonomy; RFC Class 0 and Class 1 directly encode the root Raw and Derived categories, while RFC Class 2 encodes the root Semantic Result / Actuator Command.
2. **Clear Proposal Status:** Class 3 allowlisted telemetry and inbound control flows are unratified candidate proposals in the V4 RFC (`DRAFT / NOT RATIFIED`). They do not amend or weaken the immutable root standard.
3. **Egress Independence:** Inbound control traffic applies exclusively to *inbound* operations. It does not create or permit any reverse egress path for Class 0 (Raw) or Class 1 (Derived) data, strictly maintaining compliance with Invariants M1, M4, and M8.
