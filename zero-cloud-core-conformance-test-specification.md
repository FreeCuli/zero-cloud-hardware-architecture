# Conformance Test Specification (CTS): FreeCuli ZC-CORE
[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)

**Evidence-Based Methodology for Verifiable Physical Privacy in AIoT and Edge AI**

**Version History:**
* **v3.1.0:** Transitioned to Evidence-Based Conformance; Added FC-ZC-013 (Sensor Inventory) and FC-ZC-014 (Undocumented Interface Penalty); Explicit DMA and Cache zeroization mandates.
* **v2.1.0:** Original feature-based physical isolation constraints.

> [!IMPORTANT]
> **Technical Compliance Verifiers (NOT IP Detectors)**
> The laboratory tests defined in this specification (oscilloscope leakage tests, cold-boot extraction tests) are NOT Intellectual Property (IP) infringement detectors. They are independent **Technical Compliance Verifiers** designed solely to audit whether a manufacturer's AIoT device strictly adheres to the **ZC-CORE v3.1.0** hardware constraints.

> **"FreeCuli does not require you to trust FreeCuli. It requires you to reproduce the test and provide physical evidence."**

This specification defines the **falsifiable and reproducible** adversarial attack scenarios and laboratory testing methodologies that any hardware appliance (smart home, medical, industrial, defense, AIoT) must pass to comply with the **ZC-CORE v3.1.0 Edge AI standard**.

---

## 🔬 TEST PROTOCOLS AND LABORATORY METHODOLOGY

### FC-ZC-001: Threat Model (Network SoC Exploitation & DMA Isolation)
**Objective:** Prove that even in the event of a total compromise of the network processor (Wi-Fi/Bluetooth SoC), sensor data cannot be exfiltrated from the isolated domain via ANY path.
* **Attack Model:** Operating with Kernel privileges on the network chip, active read attempts are executed via CPU load/store, DMA (Direct Memory Access), bus master overrides, peripheral bridges (I2C/SPI), shared-memory apertures, cache coherency paths, and debug/trace interfaces.
* **Pass/Fail Threshold:** 
    * **PASS:** No query can read a single bit from the NPU memory. "Network Domain → Trusted Domain" must have strictly NO read-capable path across any subsystem.
    * **FAIL:** The network processor successfully gains "Read" access via CPU, DMA, or any side-band peripheral path.

---

### FC-ZC-002: Sensor / Network Domain Separation (Electrical Air-Gap)
**Objective:** Prove the absence of physical, electrical, or parasitic (cross-talk) data paths between the network chip and sensors.
* **Measuring Device:** Vector Network Analyzer (VNA), Time-Domain Reflectometer (TDR), PCB X-Ray.
* **Pass/Fail Threshold:**
    * **PASS:** Open-circuit criterion under specified measurement configuration. Capacitive/inductive signal leakage must remain strictly < -80 dBm across a 1MHz to 5GHz bandwidth measured with a 50-ohm probe.
    * **FAIL:** Signal coupling exceeds the -80 dBm threshold under standard confidence intervals.

---

### FC-ZC-003: Unidirectional Data Flow & Information Leakage
**Objective:** Verify that only processed commands can travel from the NPU to the Main MCU, and absolutely no data or *information* can leak backwards.
* **Measuring Device:** Multi-channel Oscilloscope (Min. **5 GHz** bandwidth), High-speed Signal Generator.
* **Pass/Fail Threshold:**
    * **PASS:** Data injected backwards results in strictly < 5mV peak-to-peak (mVpp) on the NPU side, AND formal Information Mutual Information assessment yields 0 (no statistical correlation or data-carrying capacity).
    * **FAIL:** Signals injected in reverse cause readable logical fluctuations, or timing/amplitude variations carry recoverable side-channel data.

---

### FC-ZC-004: Volatile Data Destruction (SRAM Remanence Threshold)
**Objective:** Verify that when AI inference completes, power to the volatile memory holding sensor data is physically severed.
* **Pass/Fail Threshold:**
    * **PASS:** At hardware interrupt, SRAM VCC drops to 0V within **< 10 ms**. Cold-Boot attack forensic extraction yields Mathematical Remanence < 0.01% (Irreversible cryptographic noise).
    * **FAIL:** Power cut is delayed beyond 10ms, or structural characteristics of the sensor data can be partially recovered.

---

### FC-ZC-005: Trusted Execution Artifact Chain (Secure Boot & AI Model Integrity)
**Objective:** Verify that the Edge NPU refuses to execute unauthorized firmware AND models, anchoring the *entire* boot chain in hardware.
* **Attack Model:** Attempts to bypass the chain: ROM → bootloader → firmware → OS/runtime → AI model → configuration parameters.
* **Pass/Fail Threshold:**
    * **PASS:** The Secure Boot ROM strictly verifies the signature of every single artifact in the chain, including the AI model weights. Signing keys are stored in OTP/eFuse or Hardware Security Modules with strict anti-rollback counters.
    * **FAIL:** The NPU boots modified firmware, accepts a rollback, executes unsigned AI models, or keys are recoverable from software-accessible flash.

---

### FC-ZC-006: Debug Port Isolation (Hardware Lockout)
**Objective:** Verify that physical debug interfaces (JTAG, SWD, UART) routing into the Trusted Domain are completely unusable.
* **Pass/Fail Threshold:**
    * **PASS:** The JTAG/SWD interface is permanently physically disabled (eFuses blown, traces cut).
    * **FAIL:** The debugger successfully connects, halts the CPU, or reads memory addresses.

---

### FC-ZC-007: Secure Update Mechanism & Key Revocation
**Objective:** Ensure firmware updates are strictly verified and handle compromised keys correctly.
* **Pass/Fail Threshold:**
    * **PASS:** The NPU rejects unsigned updates AND rejects validly signed malicious updates if the signing key has been formally revoked or rollback counters detect a downgrade.
    * **FAIL:** The NPU accepts unsigned updates, or accepts a rollback attack using an older but validly signed artifact.

---

### FC-ZC-008: Trusted-Domain Control Surface Isolation
**Objective:** Verify that the Main MCU cannot manipulate the NPU via indirect hardware control signals.
* **Pass/Fail Threshold:**
    * **PASS:** The manufacturer must provide a complete "Trusted-Domain Control Surface Inventory" documenting Reset, Clock, DMA, Power, Watchdog, Interrupt, Debug, and Boot-mode. None of these surfaces can be leveraged by the Main MCU to freeze, delay, or bypass the volatile destruction sequence.
    * **FAIL:** Any undocumented control path exists, or an external reset/clock manipulation halts the power-cut sequence.

---

### FC-ZC-009: Formal Side-Channel Leakage Assessment
**Objective:** Verify that in-home activities cannot be inferred through electromagnetic emissions (Tempest) or power fluctuations.
* **Pass/Fail Threshold:**
    * **PASS:** Formal Test Vector Leakage Assessment (TVLA) demonstrates no statistically significant leakage (t-test confidence value below strict threshold).
    * **FAIL:** The device fails the formal TVLA protocol, showing correlation between power traces and the raw sensor data being processed.

---

## 🔬 DEFENSIVE PUBLICATION & EVIDENCE-BASED ALTERNATIVES

> [!NOTE]
> The following tests apply to manufacturers implementing alternative ZC-CORE topologies (Zenodo DOI: 10.5281/zenodo.22838473). **Vendor datasheet claims are strictly insufficient. Physical laboratory evidence must be provided.**

---

### FC-ZC-010: Alternative Isolation & Manufacturer Evidence
**Objective:** Verify capacitive/magnetic/galvanic isolators achieve optocoupler-equivalent one-way constraints.
* **Mandatory Evidence:** Manufacturer must provide Schematic Revisions, BOM (Bill of Materials), PCB Layout Evidence, and independent Lab Measurement Results.
* **Forbidden Bypass:** Any diagnostic/loopback mode or bidirectional override—even if disabled—is an automatic **FAIL**.

---

### FC-ZC-011: Secure Enclave Alternative (Covert Channel Blocking)
**Objective:** Verify TrustZone/PMP alternatives achieve physical-equivalent isolation.
* **Pass/Fail Threshold:**
    * **PASS:** Zero bytes readable from non-secure to secure memory. Strict timing side-channel leakage thresholds must be formally met to block covert channel data exfiltration from shared buffers.
    * **FAIL:** Any timing, cache, or shared-memory side-channel allows the non-secure world to infer raw sensor data.

---

### FC-ZC-012: Cryptographic Zeroization & Memory Surface Completeness
**Objective:** Verify software-triggered active overwrite achieves power-cut equivalency.
* **Pass/Fail Threshold:**
    * **PASS:** Zeroization overwrites ALL copies of sensor data (CPU registers, cache, DMA buffers, scratchpad, temporary tensors) with cryptographically random bytes in < 10ms. The overwrite must be strictly protected via memory barriers/volatile keywords to prevent compiler optimization removal.
    * **FAIL:** Forensics recover structured data from *any* caching layer, zeroization takes > 10ms, or the compiler optimized away the overwrite.

---

## 🔬 MANDATORY COMPLIANCE INVENTORIES (FC-ZC-013+)

### FC-ZC-013: Sensor Inventory Completeness Test
**Objective:** Prevent manufacturers from routing auxiliary sensors (e.g., wake-word microphones) to untrusted domains.
* **Pass/Fail Threshold:**
    * **PASS:** Manufacturer provides signed BOM and PCB schematics proving that ALL microphones, cameras, biometric, acoustic, and auxiliary sensors on the device route exclusively and definitively to the Trusted NPU Domain.
    * **FAIL:** Any undocumented sensor or auxiliary wake-word microphone routes directly to the Wi-Fi/Network SoC.

### FC-ZC-014: Undocumented Interface Penalty
**Objective:** Enforce absolute transparency of the Trusted Domain boundary.
* **Pass/Fail Threshold:**
    * **PASS:** All physical and logical connections entering/leaving the Trusted Domain exactly match the submitted ZC-CORE Interface Inventory.
    * **FAIL:** Discovery of any undocumented connection, debug pad, or shared memory aperture results in an immediate and total failure of ZC-CORE compliance.
