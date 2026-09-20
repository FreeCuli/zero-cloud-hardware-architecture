# HFSCA v1.0 Technical Compliance & Laboratory Test Specification

> [!IMPORTANT]
> **Technical Compliance Verifiers (NOT IP Detectors)**
> The laboratory tests defined in this specification (oscilloscope leakage tests, cold-boot extraction tests) are NOT Intellectual Property (IP) infringement detectors. They are independent **Technical Compliance Verifiers** designed solely to audit whether a manufacturer's device strictly adheres to the HFSCA v1.0 hardware constraints (Air-Gap, Unidirectional Diode, Volatile Buffer Power-Cut).

This specification dictates the exact laboratory parameters required to certify an Edge AI appliance as "FreeCuli Zero-Cloud Compliant." Any deviation from these metrics constitutes a violation of the standard and the CERN-OHL-S methodology.

---

## 1. Unidirectional Data Diode Verification (Reverse-Channel Leakage Test)

To ensure the physical Data Diode (Optocoupler or Galvanic Isolator) completely blocks the Main Controller (and its Wi-Fi chip) from reading the isolated Edge NPU, the following RF and electrical limits apply:

### 1.1 Oscilloscope Parameters
- **Bandwidth Requirement:** Measurements must be conducted using a mixed-signal oscilloscope with a minimum bandwidth of **5 GHz** to detect high-frequency RF coupling or parasitic leakage.
- **Test Condition:** The Main Controller TX pin (facing the NPU RX) is flooded with a 1V-3.3V sweeping PRBS (Pseudo-Random Binary Sequence) signal at maximum rated frequency.
- **Pass/Fail Threshold:** The signal detected on the NPU's isolated side must remain strictly below the noise floor or **< 5mV peak-to-peak (mVpp)**. Any detectable signal correlation above 5mVpp indicates a reverse-channel vulnerability (hardware backdoor) and fails compliance.

## 2. Lethal Volatile Buffer (Cold-Boot SRAM Extraction Test)

To verify that the NPU's SRAM (Volatile Buffer) holding the raw audio/video is physically destroyed the millisecond inference completes, preventing forensic data recovery.

### 2.1 Laboratory Simulation Parameters
- **Thermal Stress Test:** The NPU chip is subjected to extreme cooling (Cryospray to **-20°C**) to artificially increase SRAM data remanence times (simulating a Cold-Boot Attack).
- **Power-Cut Timing:** The Hardware Interrupt responsible for cutting power to the SRAM must execute within **< 10 milliseconds (ms)** of the inference completion signal.
- **Pass/Fail Threshold:** After the power-cut trigger fires, an immediate logic analyzer sweep of the SRAM bus must return 100% scrambled or zeroed data. If any contiguous forensic audio/video frames are recoverable after 10ms, the power-cut topology is deemed non-compliant.

## 3. The "Poisoned Sensor" Trace Audit

A physical PCB teardown must confirm that **100% of audio and visual sensors** route exclusively to the Edge NPU.

### 3.1 Trace Verification
- **PCB X-Ray / Multimeter Check:** Continuity tests must prove infinite resistance (Open Circuit) between any sensor output pin and the Main Controller/Wi-Fi SoC.
- **Fail Condition:** If a secondary "wake-word" microphone is discovered wired directly to the network chip, the device instantly fails compliance, regardless of software-level "mute" guarantees.

---
*Version: 1.0.0 (Official Freeze)*
*FreeCuli Standards Organization*
