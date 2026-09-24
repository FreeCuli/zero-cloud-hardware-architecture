# Conformance Test Specification (CTS)

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S v2.0](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)
[![Standard](https://img.shields.io/badge/ZC--CORE-v3.2.0-black.svg)]()

**Evidence-Based Methodology for Verifiable Physical Privacy in AIoT and Edge AI**

**Version History:**
* **v3.2.0:** Normative Laboratory Upgrade; Introduced Annex B defining strict calibration thresholds, Welch t-test (TVLA), and operational Mutual Information limits (I(X;Y) < MI_upper_bound).
* **v3.1.0:** Transitioned to Evidence-Based Conformance; Added FC-ZC-013 (Sensor Inventory) and FC-ZC-014 (Undocumented Interface Penalty); Explicit DMA and Cache zeroization mandates.
* **v2.1.0:** Original feature-based physical isolation constraints.

> [!IMPORTANT]
> **Technical Compliance Verifiers (NOT IP Detectors)**
> The laboratory tests defined in this specification (oscilloscope leakage tests, cold-boot extraction tests) are NOT Intellectual Property (IP) infringement detectors. They are independent **Technical Compliance Verifiers** designed solely to audit whether a manufacturer's AIoT device strictly adheres to the **ZC-CORE v3.2.0** hardware constraints.

> **"FreeCuli does not require you to trust FreeCuli. It requires you to reproduce the test and provide physical evidence."**

This specification defines the **falsifiable and reproducible** adversarial attack scenarios and laboratory testing methodologies that any hardware appliance (smart home, medical, industrial, defense, AIoT) must pass to comply with the **ZC-CORE v3.2.0 Edge AI standard**.

---

## ğŸ”¬ TEST PROTOCOLS AND LABORATORY METHODOLOGY

### FC-ZC-001: Threat Model (Network SoC Exploitation & DMA Isolation)
**Objective:** Prove that even in the event of a total compromise of the network processor (Wi-Fi/Bluetooth SoC), sensor data cannot be exfiltrated from the isolated domain via ANY path.
* **Attack Model:** Operating with Kernel privileges on the network chip, active read attempts are executed via CPU load/store, DMA (Direct Memory Access), bus master overrides, peripheral bridges (I2C/SPI), shared-memory apertures, cache coherency paths, and debug/trace interfaces.
* **Pass/Fail Threshold:** 
    * **PASS:** No query can read a single bit from the NPU memory. "Network Domain â†’ Trusted Domain" must have strictly NO read-capable path across any subsystem.
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
    * **PASS:** Data injected backwards results in strictly < 5mV peak-to-peak (mVpp) on the NPU side, AND formal Mutual Information assessment yields strictly I\(X;Y\) < MI_upper_bound (See Annex B) (no statistical correlation or data-carrying capacity).
    * **FAIL:** Signals injected in reverse cause readable logical fluctuations, or timing/amplitude variations carry recoverable side-channel data.

---

### FC-ZC-004: Volatile Data Destruction (SRAM Remanence Threshold)
**Objective:** Verify that when AI inference completes, power to the volatile memory holding sensor data is physically severed.
* **Pass/Fail Threshold:**
    * **PASS:** At hardware interrupt, SRAM VCC drops to 0V within **< 10 ms**. Cold-Boot attack forensic extraction yields Remanence Recovery Rate \(R_rate\) <= 0.01% (See Annex B) (Irreversible cryptographic noise).
    * **FAIL:** Power cut is delayed beyond 10ms, or structural characteristics of the sensor data can be partially recovered.

---

### FC-ZC-005: Trusted Execution Artifact Chain (Secure Boot & AI Model Integrity)
**Objective:** Verify that the Edge NPU refuses to execute unauthorized firmware AND models, anchoring the *entire* boot chain in hardware.
* **Attack Model:** Attempts to bypass the chain: ROM â†’ bootloader â†’ firmware â†’ OS/runtime â†’ AI model â†’ configuration parameters.
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
    * **PASS:** For every evaluated temporal sample point, the Welch t-statistic satisfies |t| ≤ 4.5 after the required multiple-comparison correction (See Annex B).
    * **FAIL:** Any single temporal sample point exhibiting a corrected |t| > 4.5 constitutes a verifiable side-channel leakage event and results in immediate conformance failure.

---

## ğŸ”¬ DEFENSIVE PUBLICATION & EVIDENCE-BASED ALTERNATIVES

> [!NOTE]
> The following tests apply to manufacturers implementing alternative ZC-CORE topologies (Zenodo DOI: 10.5281/zenodo.22838473). **Vendor datasheet claims are strictly insufficient. Physical laboratory evidence must be provided.**

---

### FC-ZC-010: Alternative Isolation & Manufacturer Evidence
**Objective:** Verify capacitive/magnetic/galvanic isolators achieve optocoupler-equivalent one-way constraints.
* **Mandatory Evidence:** Manufacturer must provide Schematic Revisions, BOM (Bill of Materials), PCB Layout Evidence, and independent Lab Measurement Results.
* **Forbidden Bypass:** Any diagnostic/loopback mode or bidirectional overrideâ€”even if disabledâ€”is an automatic **FAIL**.

---

### FC-ZC-011: Secure Enclave Alternative (Covert Channel Blocking)
**Objective:** Verify TrustZone/PMP alternatives achieve physical-equivalent isolation.
* **Pass/Fail Threshold:**
    * **PASS:** Zero bytes readable from non-secure to secure memory. Evaluation SHALL strictly use the FC-ZC-009 TVLA protocol for timing leakage assessment to block covert channel data exfiltration from shared buffers.
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

---

## 🔬 HIGH-ASSURANCE (C3) EXTERNAL EVALUATIONS (FC-ZC-015+)

### FC-ZC-015: Invasive Physical Assessment (Decapping)
**Objective:** Verify resilience against invasive physical tampering (Ref: T4).
* **Pass/Fail Threshold:**
    * **PASS:** Device is certified to withstand invasive physical attacks following ISO/IEC 17065-accredited procedures (e.g., Common Criteria AVA_VAN.5) by at least two independent accredited laboratories.
    * **FAIL:** Device fails the invasive decapping and probing assessment or lacks multi-lab certification.

### FC-ZC-016: Fault Injection Assessment (Glitching)
**Objective:** Verify resilience against voltage/clock fault injection (Ref: T5).
* **Pass/Fail Threshold:**
    * **PASS:** Device is certified to mitigate fault injection attempts following ISO/IEC 17065-accredited procedures (e.g., Common Criteria ATE_DPT) by at least two independent accredited laboratories.
    * **FAIL:** Device fails the fault injection assessment or lacks multi-lab certification.

## Annex B: Normative Laboratory Measurement Protocols & Statistical Calibration

To provide evidence relevant to selected cybersecurity requirements under the EU Cyber Resilience Act (CRA) and to ensure multi-lab reproducibility, all physical leakage thresholds specified in this document MUST be evaluated under the exact calibration, equipment, and statistical parameters defined below. 

### 1. Electromagnetic & Power Signal Leakage Calibration (Ref: FC-ZC-002 / FC-ZC-003)
Any manufacturer claim regarding RF/EM thresholds (e.g., < -80 dBm) or power plane ripple (e.g., < 5 mVpp) SHALL NOT be verified via generic ambient measurements. The testing laboratory MUST execute the following setup:

* **Equipment Standard:** Rohde & Schwarz FSW / Keysight N9040B Signal Analyzer or equivalent, with a minimum real-time bandwidth (RTBW) of 1 GHz.
* **Probe Specification:** Near-field EM probes (Langer EMV-Technik LF-B 3 / RF-R 400 or equivalent) calibrated down to 20 dB gain via an external low-noise pre-amplifier.
* **Probe Placement:** Fixed mechanically at a maximum distance of 2.0 mm ± 0.1 mm above the silicon die encapsulation or the designated physical trust boundary trace.
* **RF Environment:** All measurements MUST occur inside an ISO 17025 accredited fully anechoic chamber (FAC) with an ambient electromagnetic noise floor calibrated strictly below -110 dBm.
* **Sampling Parameters:** Minimum sampling rate of 10 GS/s with a hardware bandwidth limit set exactly matching the maximum clock frequency of the isolated NPU domain plus its 5th harmonic.

### 2. Operational Statistical Criterion for Information Leakage
Real-world physical channels possess inherent thermal and environmental noise. Consequently, demonstrating an absolute mathematical zero for mutual information (I(X;Y) = 0) over a finite sample size is physically impossible and constitutes an untestable claim. 

To maintain strict scientific falsifiability, the criterion **"Mutual Information = 0"** is hereby structurally replaced with an operational statistical bound:

Criterion: I(X;Y) < MI_upper_bound

where MI_upper_bound defines the upper bound of permissible leaked mutual information under the following mandatory evaluation strictures:
* **Statistical Confidence Level:** Minimum α = 0.05 (95% confidence interval). Confidence intervals SHALL be estimated using a bootstrap procedure with a minimum of 10,000 resamples, computing a two-sided 95% CI from the empirical distribution of the MI estimator.
* **Sample Size (N):** The measurement MUST pool a minimum of N = 1,000,000 independent, identically distributed (i.i.d.) Edge AI inference executions.
* **Operational Bound Value:** For ZC-CORE-C1/C2 profiles, MI_upper_bound is fixed at 10^-4 bits. For ZC-CORE-C3 high-assurance profiles, MI_upper_bound = 10^-6 bits.
* **MI Estimator Specification:** The laboratory SHALL use a **k-nearest-neighbor (k-NN) mutual information estimator** (e.g., Kraskov-Stögbauer-Grassberger estimator). The MI unit SHALL be **bits** (base-2 logarithm). `X` is defined as the raw sensor input value (e.g., audio sample amplitude) and `Y` is the corresponding electromagnetic side-channel measurement (e.g., power trace sample at the same inference cycle). No preprocessing or normalization that could reduce measured MI is permitted unless explicitly justified in the lab report.
* **Pass/Fail Calculation:** If the computed empirical mutual information estimator exceeds MI_upper_bound under the defined confidence interval, the device SHALL be issued an immediate **TOTAL FAILURE** verdict.

### 3. Normative TVLA (Test Vector Leakage Assessment) Execution Protocol (Ref: FC-ZC-009)
The phrase "strict threshold" regarding TVLA is operationally defined under the following cryptographic evaluation framework:

* **Methodology:** Fixed-vs-Random t-testing utilizing Welch's t-test algorithm to detect non-profiled leakage across the entire time-domain trace.
* **Trace Alignment:** Laboratories MUST implement dynamic time warping (DTW) or elastic alignment algorithms to eliminate clock jitter artifacts before computing statistical variance.
* **Sample Count:**
    * **C1 (Consumer):** Minimum **100,000** traces.
    * **C2 (Enhanced Industrial):** Minimum **1,000,000** traces.
    * **C3 (High-Assurance):** Minimum **5,000,000** traces.
* **Leakage Threshold (t-value):**
    * **PASS:** For every evaluated temporal sample point, the Welch t-statistic satisfies |t| ≤ 4.5 after the required multiple-comparison correction.
    * **FAIL:** Any single temporal sample point in the processed trace matrix exhibiting a corrected |t| > 4.5 constitutes a verifiable side-channel leakage event, resulting in an immediate conformance failure.
* **Multiple-Comparison Correction (Bonferroni Method):** For `m` simultaneous temporal hypotheses (where `m` equals the total number of evaluated temporal sample points in the trace), laboratories SHALL apply the following normative procedure:

    1. For each temporal point `i`, compute the Welch t-statistic `t_i` and its two-sided p-value `p_i`.
    2. Apply Bonferroni correction: `alpha_adjusted = 0.05 / m`.
    3. **FAIL** if any `p_i < alpha_adjusted`.

    > **Note:** The `|t| > 4.5` value referenced in this specification is an approximate screening heuristic corresponding to the uncorrected significance level for large sample sizes. The definitive normative decision rule is step 3 above. The `|t| > 4.5` value SHALL NOT be used as an independent FAIL criterion in place of the corrected p-value procedure.

### 4. Mathematical Definition of "0.01% Remanence" (Ref: FC-ZC-004)
To prevent manufacturer obfuscation regarding the volatile memory zeroization threshold (< 0.01%), the **Remanence Recovery Rate (R_rate)** is mathematically defined and evaluated via the following formula:

R_rate = (Successfully Reconstructed Raw Data Bits / Original Raw Data Bits) * 100

> **Normative Note on "Successfully Reconstructed":** A bit is considered "successfully reconstructed" if any extraction methodology (including exact recovery, statistical inference, correlation, or partial classification) can determine the bit's original state with a statistical accuracy greater than random guessing (p < 0.05 vs. 50% baseline).

* **Timing Parameters (two distinct requirements):**
    * **Destruction-Trigger Latency (`t_latency`):** Following the inference-completion event, the hardware power-cut mechanism SHALL initiate and SRAM VCC SHALL drop to 0V within `t_latency < 10 ms`.
    * **Minimum Power-Off Duration (`t_off`):** Power SHALL remain removed for a minimum of `t_off = 10 ms` at ambient temperature calibrated to 25°C before the forensic extraction attempt.
* **Pass/Fail Condition:** Following power restoration, the residual charge state or state-reconstruction success rate across all allocated sensor data registers MUST satisfy R_rate <= 0.01% with a statistical confidence interval of 99% (p < 0.01). Any classification accuracy or ad-hoc forensic reconstruction tool achieving a bit recovery rate higher than 0.01% over 10,000 test iterations SHALL trigger an automatic conformance failure.

---

## Annex C: ZC-CORE Assurance Profile Matrix (C1/C2/C3)

To ensure absolute traceability for certification, manufacturers MUST declare their target assurance profile, which dictates the mandatory subset of tests and stringency levels:

| Assurance Profile | Required CTS Test IDs | Profile-Specific Normative Parameters |
| :--- | :--- | :--- |
| **ZC-CORE-C1 (Consumer)** | FC-ZC-001 through FC-ZC-014 | `MI_upper_bound` = 10^-4 bits<br>TVLA Minimum Traces = 100,000 |
| **ZC-CORE-C2 (Industrial)** | FC-ZC-001 through FC-ZC-014 | `MI_upper_bound` = 10^-4 bits<br>TVLA Minimum Traces = 1,000,000 |
| **ZC-CORE-C3 (High-Assurance)** | FC-ZC-001 through FC-ZC-016 | `MI_upper_bound` = 10^-6 bits<br>TVLA Minimum Traces = 5,000,000<br>Invasive/Fault tests (FC-ZC-015, FC-ZC-016) |
