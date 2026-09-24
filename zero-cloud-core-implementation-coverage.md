# Implementation Coverage Guidelines

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S v2.0](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)
[![Standard](https://img.shields.io/badge/ZC--CORE-v3.2.0-black.svg)]()

This document provides a normative mapping between ZC-CORE security invariant properties (M1-M10) and their representative implementation families. 

## Terminology (RFC 2119)
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

## Scope and Intent
**IMPORTANT:** The implementations listed in this matrix are strictly **Representative and Non-Limiting**. The purpose of ZC-CORE is to standardize the *security property (invariant)*, not the *specific technology*. Any future or equivalent technology that achieves the required security property SHALL be considered compliant and subject to this framework.

## Matrix

| Invariant | Attack Class Mitigated | Representative / Non-Limiting Implementations | Required Security Property (Normative) |
| :--- | :--- | :--- | :--- |
| **M1** (Trusted Acquisition) | AT-009 | Isolated PCB traces, Dedicated Sensor MCU | Raw data SHALL NOT bypass the trusted domain. |
| **M2** (Physical Boundary) | AT-004 | Discrete NPU, Physical Air-Gap, Hardware-Enforced Isolation | Separation MUST be enforced physically, not merely logically. |
| **M3** (One-Way Flow) | AT-001, AT-008 | Optocoupler, Magnetic/Capacitive Isolator, FPGA, ASIC | Information SHALL flow strictly from Trusted to Untrusted domain. |
| **M4** (Reverse-Read Block) | AT-001, AT-008 | TX-only transceivers, severed RX lines, un-addressable memory | Reverse read queries MUST be physically impossible. |
| **M5** (Control-Plane Isolate) | AT-007 | Isolated Clock/Reset trees, Uncontrollable Power rails | Control plane MUST NOT allow manipulation of the trusted execution. |
| **M6** (Hardware Integrity) | AT-005, AT-010 | Secure Boot ROM, Anti-Rollback eFuses, HSM | Execution environment SHALL verify cryptographic integrity. |
| **M7** (Lifetime Enforcement) | AT-003 | Bounded SRAM buffers, ephemeral memory | Raw data SHALL exist only during the local inference lifecycle. |
| **M8** (Data Destruction) | AT-003, AT-004 | Hardware power-cut, Cryptographic zeroization (SRAM/Cache/DMA/Scratchpad) | All persistent and temporary copies MUST become irreversibly unrecoverable. |
| **M9** (Complete Inventory) | AT-009, AT-006 | Strict PCB BOM, Complete peripheral accounting | Every sensor and acquisition path MUST be accounted for inside the boundary. |
| **M10** (Independent Evidence) | All | Third-party Lab Reports (Oscilloscope, X-Ray, Firmware Hashes) | Conformance MUST rely on objective physical evidence, not vendor claims. |
