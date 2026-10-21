# Dual-Licensing & Commercial Integration

[![DOI](https://img.shields.io/badge/DOI-10.5281%2Fzenodo.22838473-blue)](https://doi.org/10.5281/zenodo.22838473)
[![License: CERN-OHL-S v2.0](https://img.shields.io/badge/License-CERN--OHL--S-blue.svg)](https://ohwr.org/cernohl)
[![OIN Member](https://img.shields.io/badge/OIN%202.0-Member-brightgreen.svg)](https://openinventionnetwork.com)
[![Release Candidate](https://img.shields.io/badge/ZC--CORE-v3.3.0--rc3-yellow.svg)](https://github.com/FreeCuli/zero-cloud-hardware-architecture/releases/tag/v3.3.0-rc3)

The FreeCuli ZC-CORE Architecture and the underlying AIoT/Edge AI methodology are guarded by strict Open Source licenses (CERN-OHL-S v2.0 for hardware, AGPL-3.0 for software) designed to protect the integrity of on-device inference and absolute privacy. 

However, we recognize that established AIoT Hardware Manufacturers (B2B)-whether in Smart Home, Defense, Medical IoT, or Industrial Automation—invest heavily in their R&D and may not be legally or commercially capable of open-sourcing their proprietary PCB schematics or internal controller software.

To bridge this gap, FreeCuli operates under a **Dual-Licensing Model**.

## 1. Route A: The Reciprocal Open Hardware Path
Any organization or individual—including commercial enterprises, industrial manufacturers, academic institutions, and independent developers—is entitled to exercise licence rights under CERN-OHL-S-2.0, subject to all applicable terms of the licence, including the grant of rights (§2), distribution conditions (§3), and provisions governing making and Conveying Products and Complete Source (§1.8, §4).

## 2. Route B: The Elective Commercial License Path
Commercial manufacturers wishing to integrate FreeCuli's reference RTL modules (`rtl/*.sv`) into proprietary ASICs or closed-source FPGA products without releasing derivative RTL under CERN-OHL-S-2.0 may negotiate an elective separate commercial license from FreeCuli.
Scope & Limitations: Any Route B agreement is a contractually defined alternative licensing pathway strictly limited to source materials where FreeCuli holds licensing authority (which, in this repository, is grounded in the founder's factual representation ATTEST-01 over `rtl/*.sv`, not an independently verified chain of title) and to the express terms of that agreement. Route B does not provide an automatic blanket exemption for an entire multi-vendor product, does not license third-party IP or patents, does not retroactively alter, revoke, or extinguish any rights previously acquired or obligations previously incurred under CERN-OHL-S-2.0, and does not impose a compulsory levy on independent implementations.

## 3. Patent Termination & Open Innovation Framework
To foster open collaboration and protect the ecosystem, licensing of FreeCuli's covered hardware is subject to the patent non-aggression and termination provisions of applicable open licenses:

- CERN-OHL-S-2.0 Patent Termination (§7.2): Under Section 7.2 of CERN-OHL-S-2.0, licence rights terminate as of the date such process is initiated if a licensee institutes patent litigation against any entity (including a cross-claim or counterclaim in a lawsuit) alleging that Covered Source or a Product constitutes direct or contributory patent infringement, or seeking any declaration that a patent licensed to You under this Licence is invalid or unenforceable. This summary notice does not alter, replace, or narrow the official terms of Section 7.2 of CERN-OHL-S-2.0.
- Open Invention Network (OIN): FreeCuli is a participant in the Open Invention Network (OIN 2.0), supporting patent non-aggression across the Linux System environment. OIN membership provides cross-licensing protections within the scope of the defined Linux System; it does not constitute a patent grant, patent ownership deed, or universal patent immunity for all proprietary hardware components.

## 4. Intellectual Property Scope, Boundaries & Independent Conformance Notice
FreeCuli claims copyright ownership over its original Register-Transfer Level source files (`rtl/*.sv`) and accompanying verification source (`tb/*.sv`, `fv/*.sv`), grounded in the founder's factual representation ATTEST-01 (which has not been verified through an independent external chain-of-title audit). These covered source files are licensed to the public under CERN-OHL-S-2.0. Under general copyright law principles, copyright protects specific creative expression, not abstract systems, architectural methodologies, or operational concepts:

- Independent Implementations: Developing an independent hardware implementation from functional specifications without copying FreeCuli's protected RTL source files does not, in itself, constitute copyright infringement of FreeCuli's RTL source code. This statement applies strictly and exclusively to FreeCuli's own RTL copyright claims.
- Multi-Domain Rights Boundary: This notice does not grant a universal liability shield. Patent validity, third-party rights, contractual commitments, and trade secrets remain distinct legal inquiries to be evaluated under applicable law and specific factual circumstances.
- Trademarks: Conformance to the functional methodology does not grant rights to display the "FreeCuli Certified™" trademark without separate trademark authorization.

### How to Apply
To initiate the commercial licensing and compliance audit process, contact our engineering and legal team:
📧 **Email:** [info@freeculi.com](mailto:info@freeculi.com)
