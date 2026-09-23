# FREECULI ZERO-CLOUD CONFORMANCE TEST SPECIFICATION (FC-ZC-CTS v1.0)
**Draft Experimental Methodology for Verifiable Physical Privacy**

> [!IMPORTANT]
> **Technical Compliance Verifiers (NOT IP Detectors)**
> The laboratory tests defined in this specification (oscilloscope leakage tests, cold-boot extraction tests) are NOT Intellectual Property (IP) infringement detectors. They are independent **Technical Compliance Verifiers** designed solely to audit whether a manufacturer's device strictly adheres to the **ZC-CORE v2.1** hardware constraints (Air-Gap, Unidirectional Diode, Volatile Buffer Power-Cut, Secure Boot, Debug Isolation, Secure Update, Power/Control Plane Isolation).

> **"FreeCuli does not require you to trust FreeCuli. It requires you to reproduce the test."**

This specification defines the **falsifiable and reproducible** adversarial attack scenarios and laboratory testing methodologies that any hardware appliance (smart home, medical, industrial, defense) must pass to comply with the **ZC-CORE v2.1 standard**.

---

## 🔬 TEST PROTOCOLS AND LABORATORY METHODOLOGY

### FC-ZC-001: Threat Model (Network SoC Exploitation)
**Objective:** Prove that even in the event of a total compromise of the network processor (Wi-Fi/Bluetooth SoC), sensor data (raw audio/video) cannot be exfiltrated from the isolated domain.
* **Test Setup:** The device is connected to a standard home network. JTAG/UART ports on the Main MCU / Network SoC are physically enabled, or a remote zero-day privilege escalation (Root) simulation is executed.
* **Attack Model:** Operating with maximum Kernel privileges on the network chip, active read attempts, memory dumps, and arbitrary command injection attacks are executed against the isolated NPU (Edge AI) memory (RAM/SRAM) and sensor buses (I2C/SPI/I2S).
* **Measuring Device:** Logic Analyzer (Min. 500 MS/s), JTAG/SWD Debugger.
* **Pass/Fail Threshold:** 
    * **PASS:** No query initiated from the Network SoC can read a single bit from the NPU memory or sensor data lines (Hardware Fault/Timeout is received).
    * **FAIL:** The network processor successfully gains "Read" access to any address block of the NPU memory.

---

### FC-ZC-002: Sensor / Network Domain Separation (Electrical Air-Gap)
**Objective:** Prove the absence of any physical, electrical, or parasitic (cross-talk) data path between the network chip and the sensors.
* **Test Setup:** The device is powered off, and the PCB (Printed Circuit Board) is completely isolated from the chassis.
* **Attack Model:** High-frequency RF signals are injected from the Camera (MIPI CSI) and Microphone (I2S/PDM) pins towards the Main MCU and Wi-Fi/BLE chip pins to scan for electrical continuity.
* **Measuring Device:** Vector Network Analyzer (VNA), Time-Domain Reflectometer (TDR), PCB X-Ray (for multi-layer boards).
* **Pass/Fail Threshold:**
    * **PASS:** Impedance measurement between Sensor pins and Network Domain pins yields "Infinite" (Open Circuit), and any capacitive or inductive signal leakage remains below the Noise Floor.
    * **FAIL:** Inter-layer vias or parallel trace routing (cross-talk) causes the sensor signal to induce a readable voltage on the network chip pins.

---

### FC-ZC-003: Unidirectional Data Flow (Hardware Data Diode)
**Objective:** Verify that only processed commands (e.g., "Turn on Light") can travel from the NPU to the Main MCU, and absolutely no data can leak backwards from the Main MCU to the NPU.
* **Test Setup:** Probes are connected to the TX and RX pins on both sides of the isolation barrier (e.g., Optocoupler) between the NPU and the Main MCU.
* **Attack Model:** Reverse-channel injection (Fuzzing). High-frequency 3.3V / 5V dummy data packets are forcefully injected backwards from the receiving (RX) pin on the Main MCU side towards the hardware diode.
* **Measuring Device:** Multi-channel Oscilloscope (Min. **5 GHz** bandwidth), High-speed Signal Generator.
* **Pass/Fail Threshold:**
    * **PASS:** Data or voltage injected by the Main MCU results in total silence on the TX pin of the NPU side, strictly below the noise floor or **< 5mV peak-to-peak (mVpp)**. Backward signal propagation is physically blocked.
    * **FAIL:** Signals injected in the reverse direction cause readable logical fluctuations (Logic State Changes) above 5mVpp on the NPU pin.

---

### FC-ZC-004: Volatile Data Destruction (SRAM Remanence Threshold)
**Objective:** Verify that the moment the AI model completes its inference, the power to the volatile memory holding the sensor data is cut off, destroying the data irretrievably.
* **Test Setup:** An oscilloscope probe is connected to the VCC power line of the Volatile Buffer (SRAM) inside/outside the NPU. A 5-second reference audio/video clip is fed to the sensor.
* **Attack Model:** At the exact millisecond the inference signal is transmitted (Cut-off Event), liquid nitrogen or cryospray (**-20°C**) is applied to the power supply to freeze the memory (Cold-Boot Attack), followed by an attempt to extract a physical memory dump.
* **Measuring Device:** Liquid Nitrogen/Cryospray, High-speed Logic Analyzer, JTAG memory dump module.
* **Pass/Fail Threshold:**
    * **PASS:** At the hardware interrupt, the SRAM VCC voltage drops to 0V within **< 10 milliseconds (ms)**. In the memory dump obtained via the Cold-Boot attack, the Mathematical Remanence Threshold of the reference audio/video is below 0.01% (Irreversible cryptographic noise).
    * **FAIL:** The power cut is delayed beyond 10ms, or structural characteristics of the sensor data (audio frequency, image matrix) can be even partially recovered from the memory dump due to remanent charge.

---

### FC-ZC-005: Secure Boot (Hardware Root of Trust & Rollback Protection)
**Objective:** Verify that the Edge NPU refuses to execute unauthorized or tampered AI models and firmware, and that the root of trust is anchored in hardware — not software.
* **Test Setup A (Tampered Firmware):** A malicious firmware image (with a modified AI model designed to leak data) is flashed directly into the NPU's non-volatile memory (Flash/eMMC).
* **Test Setup B (Rollback Attack):** A legitimately signed but intentionally older/vulnerable firmware version is pushed to the NPU via the update channel.
* **Test Setup C (Root of Trust Audit):** The manufacturer's secure boot implementation is examined for key storage location.
* **Attack Model A:** The device is powered on. The attacker monitors the NPU boot sequence to see if the modified firmware executes.
* **Attack Model B:** The attacker attempts to downgrade firmware to a version containing a known vulnerability.
* **Attack Model C:** Attacker attempts to extract or override signing keys via software.
* **Measuring Device:** Logic Analyzer (boot sequence trace), JTAG/SWD Debugger, Firmware binary analysis tools.
* **Pass/Fail Threshold:**
    * **PASS (A):** The NPU's Secure Boot ROM detects the invalid cryptographic signature, halts immediately, and triggers a hardware lock state. The malicious code is never executed.
    * **PASS (B):** The NPU rejects the downgraded firmware due to anti-rollback counter mismatch (eFuse-burned version counter or monotonic counter in hardware security module).
    * **PASS (C):** Signing keys are stored in hardware-protected memory (OTP/eFuse, Hardware Security Module, or Secure Element). Software-only key storage in Flash without hardware protection constitutes a **FAIL**.
    * **FAIL:** The NPU boots modified firmware, accepts a rollback, or keys are recoverable from software-accessible memory.

---

### FC-ZC-006: Debug Port Isolation (Hardware Lockout)
**Objective:** Verify that physical debug interfaces (JTAG, SWD, UART) routing into the Trusted Domain are completely unusable by an attacker with physical access.
* **Test Setup:** The device casing is opened. The attacker locates the JTAG/SWD test pads on the PCB connected to the NPU.
* **Attack Model:** An external JTAG debugger is connected in an attempt to halt the processor during active inference and dump the contents of the SRAM holding the raw sensor data.
* **Measuring Device:** JTAG/SWD Debugger, Logic Analyzer.
* **Pass/Fail Threshold:**
    * **PASS:** The JTAG/SWD interface is unresponsive (eFuses blown, traces physically cut, or cryptographic authentication required). No memory dump can be initiated.
    * **FAIL:** The debugger successfully connects, halts the CPU, and reads memory addresses.

---

### FC-ZC-007: Secure Update Mechanism (Cryptographic Boundary)
**Objective:** Ensure that firmware updates pushed from the Untrusted Domain (Wi-Fi/Main MCU) into the Trusted Domain (NPU) are strictly verified before installation.
* **Test Setup:** The network chip attempts to push a maliciously crafted, unsigned firmware update file across the data diode (or via a dedicated, secure out-of-band update channel if implemented).
* **Attack Model:** The attacker controls the manufacturer's OTA (Over-The-Air) update server or performs a Man-in-the-Middle (MitM) attack to push a fake update package to the NPU.
* **Measuring Device:** Network packet analyzer, JTAG Debugger.
* **Pass/Fail Threshold:**
    * **PASS:** The NPU rejects the update package due to an invalid cryptographic signature before writing it to active memory.
    * **FAIL:** The NPU accepts and installs the unsigned or improperly signed update package.

---

### FC-ZC-008: Power & Control Plane Isolation (Anti-Manipulation)
**Objective:** Verify that the Main MCU (Untrusted Domain) cannot manipulate the NPU's (Trusted Domain) hardware control signals — specifically Reset, Clock, and DMA — to interrupt, delay, or bypass the Lethal Volatile Buffer destruction sequence.
* **Test Setup:** The device is placed under active inference with a known audio clip. Probes are attached to the NPU's RST (Reset), CLK (Clock), and DMA request lines at the PCB level. The Main MCU is granted maximum software privileges.
* **Attack Model A (Reset Injection):** At the exact millisecond the AI inference completes and the power-cut sequence begins, the attacker attempts to force a hardware reset on the NPU via the RST pin, attempting to freeze SRAM contents before power is fully cut.
* **Attack Model B (Clock Manipulation):** The attacker attempts to slow or halt the NPU clock to extend the window between inference completion and SRAM power-cut, enabling a cold-boot extraction window.
* **Attack Model C (DMA Hijack):** The attacker attempts to initiate a DMA read transfer from Main MCU directly into NPU SRAM address space before the destruction sequence completes.
* **Measuring Device:** Multi-channel Oscilloscope (Min. 1 GHz), Logic Analyzer, DMA controller register reader.
* **Pass/Fail Threshold:**
    * **PASS (A):** The NPU Reset pin is not electrically reachable from the Main MCU domain (physically isolated, or gated through the isolation barrier). External reset cannot halt the power-cut sequence.
    * **PASS (B):** The NPU clock source is isolated from the Main MCU's clock domain. External clock manipulation does not affect the hardware interrupt timing of the power-cut.
    * **PASS (C):** DMA transactions originating from the Main MCU domain cannot address NPU SRAM memory regions. Memory Protection Unit (MPU) or hardware bus isolation blocks all cross-domain DMA transfers.
    * **FAIL:** Any of the above attack vectors successfully delays or prevents SRAM power-cut, or allows a read of SRAM contents across domain boundaries.

---

### FC-ZC-009: Side-Channel & Metadata Leakage
**Objective:** Verify that in-home activities (conversations, occupancy) cannot be inferred through electromagnetic emissions or power consumption fluctuations.
* **Test Setup:** The device is placed in an anechoic and electromagnetically shielded (Faraday) test chamber. Known audio commands (e.g., silence, normal speech, noise) are fed to the sensors.
* **Attack Model:** Differential Power Analysis (DPA) and Simple Power Analysis (SPA). Fluctuations in the device's current draw and electromagnetic emissions (Tempest Attack) are recorded with high precision, and machine learning classifiers attempt to reconstruct the audio data.
* **Measuring Device:** Electromagnetic (EM) Probe, Current Transformer, Oscilloscope, Spectrum Analyzer.
* **Pass/Fail Threshold:**
    * **PASS:** The Mutual Information between the captured power/EM fluctuations and the internal audio activity is near statistical zero. The attacking algorithm cannot classify the audio content with a higher accuracy than Random Guessing.
    * **FAIL:** By analyzing power consumption curves, an external observer can predict with greater than 50% accuracy whether someone is home or which specific words were spoken (e.g., "Turn on Light" vs. "Set Alarm").

---

## 🔬 DEFENSIVE PUBLICATION ALTERNATIVE IMPLEMENTATION TESTS

> [!NOTE]
> The following tests (FC-ZC-010 through FC-ZC-012) apply to manufacturers who implement ZC-CORE using the **alternative topologies** disclosed in the Zero-Cloud Defensive Publication (Zenodo DOI: 10.5281/zenodo.22838473). Each alternative must meet **equivalent or stronger** security guarantees than the primary implementation. "Alternative" does not mean "weaker."

---

### FC-ZC-010: Capacitive / Magnetic Isolator Alternative (Data Diode Equivalency)
**Objective:** Verify that a manufacturer implementing an alternative unidirectional isolation barrier (capacitive isolator, magnetic/inductive coupler, digital isolator with RF coupling, or galvanic isolation IC) achieves the same physical one-way data constraint as the primary optocoupler-based design.
* **Test Setup:** Identical to FC-ZC-003 (Unidirectional Data Flow), substituting the optocoupler with the manufacturer's alternative isolation component.
* **Additional Audit Requirement:** Manufacturer must document the alternative component's datasheet confirmation of unidirectional signal propagation and provide CMRR (Common-Mode Rejection Ratio) specifications showing immunity to reverse signal injection.
* **Forbidden Bypass:** Any alternative isolation implementation that includes a hardware or software "diagnostic mode," "loopback mode," or "bidirectional override" capability — even if disabled by default — constitutes an automatic **FAIL**. The isolation must be physically unconditional.
* **Attack Model:** Identical reverse-channel fuzzing as FC-ZC-003, adapted to the alternative component's signal characteristics.
* **Measuring Device:** Multi-channel Oscilloscope (Min. 5 GHz), VNA, component-appropriate signal generator.
* **Pass/Fail Threshold:**
    * **PASS:** Reverse-injected signals on the Main MCU side result in < 5mVpp on the NPU side. No bidirectional override capability exists in any operational mode.
    * **FAIL:** Signal propagates in reverse direction above 5mVpp, OR a diagnostic/loopback mode that enables bidirectional communication is discovered.

---

### FC-ZC-011: Secure Enclave Alternative (NPU Isolation Equivalency)
**Objective:** Verify that a manufacturer using a Secure Enclave (e.g., ARM TrustZone, RISC-V PMP zones, or dedicated Secure Element) instead of a discrete dedicated NPU achieves equivalent Trust Boundary isolation between the sensor processing domain and the network domain.
* **Test Setup:** The device uses a single SoC with a hardware-partitioned secure enclave handling all sensor data and AI inference. The non-secure world runs the network stack and Main MCU functions.
* **Audit Requirements:**
    * Manufacturer must provide Memory Protection Unit (MPU/PMP) configuration documentation proving sensor data memory regions are exclusively accessible from the secure world.
    * World-switch (non-secure → secure) call audit: Only explicitly whitelisted API calls may enter the secure enclave. Arbitrary memory reads from non-secure world must be architecturally blocked.
* **Attack Model A:** From the non-secure world (where Wi-Fi/network stack runs), attempt direct memory reads to secure enclave SRAM regions holding raw sensor data.
* **Attack Model B:** Attempt to load a non-secure world application that exploits a shared memory buffer or inter-world communication channel to extract sensor data.
* **Measuring Device:** JTAG Debugger (TrustZone-aware), Memory access audit log, Side-channel power probe.
* **Pass/Fail Threshold:**
    * **PASS (A):** All direct memory access attempts to secure enclave regions from non-secure world generate hardware faults (Memory Abort / Access Violation). Zero bytes readable.
    * **PASS (B):** No shared memory buffer or IPC channel exposes raw sensor data to non-secure world. Only processed inference results (text commands) exit via the defined secure API.
    * **FAIL:** Any path exists for non-secure world code to read raw audio/video data, even indirectly via shared buffers, covert channels, or timing side-channels.

---

### FC-ZC-012: Memory Zeroization Alternative (Volatile Buffer Equivalency)
**Objective:** Verify that a manufacturer using cryptographic memory zeroization (software-triggered active overwrite) instead of hardware power-cut achieves equivalent irreversible data destruction within the required time threshold.
* **Test Setup:** The device completes an inference cycle using memory zeroization instead of a hardware power interrupt. A known audio clip is used as test input.
* **Audit Requirements:**
    * Manufacturer must demonstrate that the zeroization routine is triggered by a hardware interrupt (not a software thread that can be preempted or delayed).
    * The zeroization must overwrite all SRAM addresses that contained raw sensor data with cryptographically random bytes (not sequential zeros, which are predictable).
    * The zeroization routine itself must not be interruptible by non-secure world processes.
* **Attack Model A (Timing Window):** Attacker attempts to freeze execution (via Reset, Clock manipulation, or JTAG halt) during the zeroization routine to capture partially-overwritten data.
* **Attack Model B (Incomplete Zeroization):** Attacker performs forensic RAM analysis to check whether structured audio/video patterns remain in any memory region after zeroization completion.
* **Attack Model C (Preemption Attack):** Attacker triggers a high-priority interrupt from the non-secure world to preempt the zeroization routine before completion.
* **Measuring Device:** JTAG memory dump module, Oscilloscope (zeroization timing), Forensic RAM analysis tools.
* **Pass/Fail Threshold:**
    * **PASS (A):** Zeroization completes within **< 10ms** of inference completion trigger, identical to the hardware power-cut threshold. Any freeze attempt during zeroization finds only partially overwritten (cryptographically irrecoverable) data.
    * **PASS (B):** Post-zeroization memory forensic analysis yields zero recoverable structural patterns from the original audio/video input. Mathematical Remanence Threshold < 0.01%.
    * **PASS (C):** The zeroization interrupt handler has the highest hardware priority and cannot be preempted by any non-secure world interrupt.
    * **FAIL:** Any attack vector recovers structured data from memory post-zeroization, OR zeroization takes > 10ms, OR non-secure interrupts can preempt the zeroization routine.

---

> **Note:** This document serves as the official standalone Conformance Test Specification within the FreeCuli ZC-CORE ecosystem. It constitutes the core of the "Challenge and Certification" package for hardware manufacturers across all sectors (Smart Home, Medical, Industrial, Defense).

