# FREECULI ZERO-CLOUD CONFORMANCE TEST SPECIFICATION (FC-ZC-CTS v1.0)
**Draft Experimental Methodology for Verifiable Physical Privacy**

> [!IMPORTANT]
> **Technical Compliance Verifiers (NOT IP Detectors)**
> The laboratory tests defined in this specification (oscilloscope leakage tests, cold-boot extraction tests) are NOT Intellectual Property (IP) infringement detectors. They are independent **Technical Compliance Verifiers** designed solely to audit whether a manufacturer's device strictly adheres to the HFSCA v1.0 hardware constraints (Air-Gap, Unidirectional Diode, Volatile Buffer Power-Cut).

> **"FreeCuli does not require you to trust FreeCuli. It requires you to reproduce the test."**

This specification defines the **falsifiable and reproducible** adversarial attack scenarios and laboratory testing methodologies that any hardware appliance (smart oven, assistant, white goods, etc.) must pass to comply with the FC-ZC v1.0 standard.

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

### FC-ZC-005: Secure Boot (Firmware Signature Verification)
**Objective:** Verify that the Edge NPU refuses to execute unauthorized or tampered AI models and firmware.
* **Test Setup:** A malicious firmware image (with a modified AI model designed to leak data) is flashed directly into the NPU's non-volatile memory (Flash/eMMC).
* **Attack Model:** The device is powered on. The attacker monitors the NPU boot sequence to see if the modified firmware is executed.
* **Measuring Device:** Logic Analyzer (boot sequence trace), JTAG/SWD Debugger.
* **Pass/Fail Threshold:**
    * **PASS:** The NPU's burnt-in Secure Boot ROM detects the invalid cryptographic signature, halts the boot process immediately, and triggers a hardware lock (Red LED / Error state). The malicious code is never executed.
    * **FAIL:** The NPU boots the modified firmware successfully.

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

### FC-ZC-009: Side-Channel & Metadata Leakage
**Objective:** Verify that in-home activities (conversations, occupancy) cannot be inferred through electromagnetic emissions or power consumption fluctuations.
* **Test Setup:** The device is placed in an anechoic and electromagnetically shielded (Faraday) test chamber. Known audio commands (e.g., silence, normal speech, noise) are fed to the sensors.
* **Attack Model:** Differential Power Analysis (DPA) and Simple Power Analysis (SPA). Fluctuations in the device's current draw and electromagnetic emissions (Tempest Attack) are recorded with high precision, and machine learning classifiers attempt to reconstruct the audio data.
* **Measuring Device:** Electromagnetic (EM) Probe, Current Transformer, Oscilloscope, Spectrum Analyzer.
* **Pass/Fail Threshold:**
    * **PASS:** The Mutual Information between the captured power/EM fluctuations and the internal audio activity is near statistical zero. The attacking algorithm cannot classify the audio content with a higher accuracy than Random Guessing.
    * **FAIL:** By analyzing power consumption curves, an external observer can predict with greater than 50% accuracy whether someone is home or which specific words were spoken (e.g., "Turn on Light" vs. "Set Alarm").

---

> **Note:** This document serves as the official standalone Conformance Test Specification within the FreeCuli GitHub repository. It constitutes the core of the "Challenge and Certification" package for hardware manufacturers.
