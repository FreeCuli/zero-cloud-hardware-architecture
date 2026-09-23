# FreeCuli ZC-CORE v3.0: Universal Zero-Cloud Hardware Methodology

The indestructible, privacy-first hardware reference methodology for Server-Independent AIoT and Edge AI devices (Smart Home, Medical, Industrial, Defense).

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)

## Overview
This repository contains the official, strictly falsifiable **ZC-CORE v3.0 Methodology**. Originally pioneered as a smart-kitchen architecture, it has evolved into a universal, sector-agnostic framework for designing smart devices that operate without centralized server/cloud dependency. As a proud member of the Open Invention Network (OIN), FreeCuli protects the open-source hardware ecosystem.

By enforcing Physical Data Diodes, Trust Boundaries, and Cryptographic Volatile Zeroization, this methodology completely eradicates the possibility of unauthorized data exfiltration (microphone/camera streams) from any AIoT appliance. It protects against state-sponsored espionage and guarantees third-party GDPR/CCPA compliance by design.

## The Core Philosophy: Implementation Freedom & Methodological Consistency

**1. Implementation Freedom & Methodological Consistency**
ZC-CORE does not prescribe or restrict any particular end-user appliance, hardware component, semiconductor vendor, processor, memory technology, or implementation stack. Conformance is determined by the achievement of defined functional security outcomes and their verifiable evidence, rather than by the use of any specific component or implementation technology. 

This principle applies across the AIoT value chain, including semiconductor, module, device, appliance, platform, and system-level implementations. 

**2. Conformance ≠ Code Ownership**
Passing the ZC-CORE Conformance Test Specification (CTS) does not grant FreeCuli any ownership over a manufacturer's implementation. A manufacturer retains full Intellectual Property (IP) rights over their proprietary codebase, custom ASIC/SoC designs, and firmware. ZC-CORE standardizes the *security properties and verification methodology*, NOT the vendor's implementation.

## Core Documents

1. **[The ZC-CORE Hardware Fortress (Architecture Document)](Zero-Cloud-Smart-Home-Edge-AI-Architecture.md)**
   * Mandatory specifications for Physical Air-Gap, Hardware Data Diode (Optocoupler), Lethal Volatile Buffer (SRAM zeroization), and Trust Boundary security pillars for Edge AI.
2. **[ZC-CORE Methodology Invariants (M1-M10)](ZC-CORE-METHODOLOGY-INVARIANTS.md)**
   * The legal and functional "DNA" of the standard. Defines the mandatory causal sequence and explicitly prohibits third-party methodology cloning.
3. **[FC-ZC Conformance Test Specification (CTS)](FC-ZC-Conformance-Test-Specification.md)**
   * Falsifiable adversarial laboratory attack scenarios requiring mandatory physical evidence (e.g., 5GHz oscilloscope reverse-channel fuzzing, DMA isolation, Sensor Inventories).
4. **[ZC-CORE Defensive Publication (Prior Art Matrix)](Zero-Cloud-Defensive-Publication.md)**
   * A legally structured claim-style matrix designed as an ultimate Defensive Publication. It explicitly defines all negative-space escape routes (e.g., capacitive isolators, memory zeroization) to establish undeniable Prior Art against future patenting by third parties.
5. **[Dual-Licensing Framework](DUAL-LICENSING.md)**
   * Commercial manufacturers must obtain a Commercial Exemption License. Open-source implementers are free under CERN-OHL-S. Contains the strict Patent Retaliation Clause.

## Commercial Certification
Industrial AIoT manufacturers utilizing this architecture in proprietary hardware must acquire a B2B Certification and Trademark License to ensure compliance and legally display the #FreeCULI badge. See [FreeCuli.com](https://freeculi.com) for details.
