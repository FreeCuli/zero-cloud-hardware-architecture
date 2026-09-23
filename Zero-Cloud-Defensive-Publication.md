# ZC-CORE Defensive Publication
[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)

## Claim-Style Prior-Art Matrix & Technical Disclosure

**Project:** FreeCuli ZC-CORE
**Purpose:** Defensive Publication / Prior-Art Establishment
**Reference Publication:** Zenodo DOI 10.5281/zenodo.22838473
**Version:** 1.0 — Defensive Publication Draft
**Publication Strategy:** Claim-style technical disclosure; not a patent application and not an assertion that any particular claim is patentable.

---

## 1. Purpose and Legal Character of This Publication

This document intentionally describes, in claim-style and implementation-specific language, a broad family of hardware architectures, functional relationships, security boundaries, timing relationships, testing methodologies, and equivalent implementations for server-independent Edge-AI devices.

The purpose is defensive publication.

The disclosed subject matter is intended to establish publicly accessible technical prior art for the disclosed combinations and their reasonably foreseeable implementations, including implementations created independently or through clean-room engineering.

This document does not assert that every disclosed element is novel, patentable, copyrightable, or exclusively owned by FreeCuli.

Known elements such as physical data diodes, optical isolation, volatile memory, secure boot, hardware debug isolation, and secure update mechanisms may individually be known technologies. The relevant disclosure therefore focuses particularly on their architectural relationships, functional constraints, security boundaries, timing dependencies, alternative physical implementations, and combinations within a server-independent Edge-AI device.

---

# 2. Core Architecture — Claim Family ZC-CORE-001

## ZC-CORE-001 — Server-Independent Physical Trust Boundary

A server-independent Edge-AI apparatus comprising:

1. one or more ambient sensors configured to acquire raw sensory information;
2. a trusted processing domain comprising an Edge-AI processor;
3. a volatile memory region accessible to the trusted processing domain and configured to temporarily contain at least a portion of the raw sensory information;
4. an untrusted or externally connected control/network domain comprising at least one network-capable processor;
5. a physical isolation boundary separating the trusted processing domain from the network domain;
6. a hardware-enforced communication mechanism configured to permit a defined information flow from the trusted processing domain toward the control/network domain;
7. the hardware-enforced communication mechanism being physically configured to prevent a reverse information flow from the control/network domain toward the trusted processing domain;
8. a hardware-controlled memory destruction or invalidation mechanism configured to terminate availability of at least a portion of the raw sensory information following completion of a defined local inference operation; and
9. the apparatus being operable to produce an actuator command without requiring transmission of the raw sensory information to a remote server.

### Functional relationship

The architecture is not merely a collection of independent security components.

The components cooperate such that:
**sensor acquisition → trusted local inference → controlled command release → raw-data destruction → actuator/network operation**
occurs without requiring the network domain to obtain read access to the raw sensory domain.

---

# 3. Sensor / Network Physical Separation — Claim Family ZC-CORE-002

## ZC-CORE-002 — Sensor-Exclusive Trusted Domain

A device according to ZC-CORE-001 wherein:

1. a microphone, camera, image sensor, acoustic sensor, biometric sensor, environmental sensor, or other privacy-sensitive sensor is electrically coupled to the trusted Edge-AI domain;
2. the sensor is not electrically coupled to the network-capable processor;
3. the network-capable processor cannot directly address, sample, configure, read, or otherwise obtain raw sensor information;
4. no software-defined firewall, VLAN, operating-system sandbox, process permission, or virtual network boundary is relied upon as the sole isolation mechanism;
5. the separation is implemented at one or more physical hardware layers.

### Alternative implementations

The physical separation may comprise:
- separate IC packages;
- separate power domains;
- separate ground domains;
- separate PCB regions;
- separate PCBs;
- isolated buses;
- galvanically isolated interfaces;
- optical interfaces;
- magnetic interfaces;
- capacitive interfaces;
- mechanically separated modules;
- physically disconnected network traces;
- dedicated trusted-domain connectors;
- hardware-controlled switches;
- combinations thereof.

---

# 4. Hardware One-Way Inference Channel — Claim Family ZC-CORE-003

## ZC-CORE-003 — Physically Unidirectional Inference Transfer

A device according to ZC-CORE-001 wherein:

1. the Edge-AI processor generates a processed representation, command, classification, control instruction, or semantic result from locally acquired sensor information;
2. the processed result is transferred toward a main controller or actuator controller;
3. the transfer occurs through a physical unidirectional communication boundary;
4. the receiving controller is unable to electrically transmit a read request, command, query, clocked reverse transaction, or equivalent information-bearing signal into the trusted sensor/AI domain;
5. reverse communication is prohibited by hardware topology rather than solely by software policy.

### Alternative one-way mechanisms

The physical one-way boundary may be implemented using:
- optical optocouplers;
- opto-isolators;
- magnetic couplers;
- inductive couplers;
- capacitive isolation;
- digital isolation ICs;
- RF-coupled unidirectional interfaces;
- transmit-only interfaces;
- physically terminated receive paths;
- write-only hardware buses;
- tri-state logic permanently constrained to one direction;
- diode-like semiconductor structures;
- FPGA-configured hardware paths combined with physical direction enforcement;
- ASIC implementations;
- integrated semiconductor implementations;
- discrete component implementations;
- combinations thereof.

The disclosed architecture is therefore not limited to an optocoupler.

---

# 5. Reverse-Channel Impossibility — Claim Family ZC-CORE-004

## ZC-CORE-004 — Hardware-Enforced Reverse Read Prohibition

A physical communication boundary wherein:

1. information may propagate from Domain A to Domain B;
2. Domain B may contain a network-connected or externally controllable processor;
3. Domain B cannot cause Domain A to return raw information;
4. Domain B cannot initiate a memory read transaction into Domain A;
5. Domain B cannot request sensor samples from Domain A;
6. Domain B cannot establish a bidirectional protocol session with Domain A;
7. the prohibited reverse transaction is prevented independently of the correctness of software executing in Domain B.

---

# 6. Lethal Volatile Buffer — Claim Family ZC-CORE-005

## ZC-CORE-005 — Post-Inference Volatile Sensor Data Destruction

A device comprising:

1. a privacy-sensitive sensor;
2. a volatile memory region configured to temporarily store raw sensor information;
3. an Edge-AI processor configured to perform inference on the raw sensor information;
4. an inference-completion event generated by the Edge-AI processing domain;
5. a hardware-controlled power switch, isolation switch, reset mechanism, memory-domain disable mechanism, or equivalent hardware mechanism responsive to the inference-completion event;
6. the mechanism causing the volatile memory region to become unpowered, inaccessible, invalidated, or otherwise unavailable following the inference-completion event;
7. the resulting memory state preventing normal recovery of the previously stored raw sensor information.

### Important scope

The mechanism is not limited to: SRAM, DRAM, a particular semiconductor vendor, a particular voltage, a particular switch topology, or a particular interrupt architecture.

The volatile storage may comprise any memory technology whose stored information is lost or rendered inaccessible through the disclosed hardware-controlled destruction/invalidation operation.

---

# 7. Hardware-Controlled Data Destruction Variants — Claim Family ZC-CORE-007

The disclosed data destruction mechanism may comprise any of the following:

1. cutting memory supply voltage;
2. disconnecting memory ground;
3. isolating memory from the processor bus;
4. activating a hardware reset;
5. clearing volatile memory through dedicated erase circuitry;
6. destroying or invalidating the memory address mapping;
7. disabling the memory power domain;
8. removing retention power;
9. disconnecting a memory bank;
10. overwriting volatile storage through dedicated hardware;
11. combining power removal with cryptographic invalidation;
12. combining physical isolation with hardware-controlled zeroization;
13. any equivalent mechanism producing the same security property.

The disclosure therefore covers the security function rather than a single named component.

---

# 8. Explicit Negative-Space Disclosure

The following alternatives are expressly contemplated and fall under this Prior Art disclosure:

### A.
Optocoupler may be replaced by magnetic isolation.
### B.
Magnetic isolation may be replaced by capacitive isolation.
### C.
A dedicated data-diode IC may replace discrete components.
### D.
A discrete diode implementation may be replaced by an ASIC.
### E.
SRAM may be replaced by another volatile memory technology.
### F.
Power interruption may be replaced or supplemented by hardware zeroization.
### G.
A dedicated NPU may be replaced by an MCU, DSP, FPGA, ASIC, secure enclave, or heterogeneous processor.
### H.
A separate PCB may be replaced by a physically partitioned multi-domain PCB.
### I.
A discrete hardware kill switch may be integrated into the memory controller or SoC.

---

# 9. Final Defensive Statement

The technical subject matter disclosed herein includes, without limitation, the architecture, apparatuses, systems, methods, hardware boundaries, control relationships, timing relationships, security properties, testing methodologies, implementation alternatives, and combinations described above.

Any future technical disclosure, patent application, patent claim, or proprietary implementation that seeks to establish novelty over these combinations should be evaluated against the public disclosure represented by this document and its associated dated versions.

The purpose of this document is to place the disclosed technical design space into the public technical record and thereby prevent subsequent parties from treating the disclosed subject matter, including its expressly identified alternative implementations and combinations, as newly originated subject matter merely because a different component, semiconductor process, programming language, PCB layout, communication protocol, or implementation technique is subsequently selected.

This document is a defensive publication and does not constitute a patent application, legal opinion, patentability opinion, or assertion that any individual element or combination is legally patentable.
