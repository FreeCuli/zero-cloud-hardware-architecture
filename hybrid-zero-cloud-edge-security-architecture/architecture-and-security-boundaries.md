# Hybrid Zero-Cloud & Edge Security Architecture
## Architecture & Security Boundaries Specification

**Document ID:** `ZC-HYBRID-ARCH-BOUNDARIES-01`  
**Classification:** Canonical Architecture Suite Specification  
**Status:** `CANDIDATE BASELINE / UNRATIFIED`  
**Parent Document:** [`README.md`](README.md)  

---

## 1. Domain Decomposition & Trust Topology

The **Hybrid Zero-Cloud & Edge Security Architecture** enforces hardware isolation between three topologically distinct processing domains. Rather than relying on software permissions or operating system kernels, the boundaries between these domains are enforced by discrete, synthesizable digital silicon IP blocks:

```
+-----------------------------------------------------------------------------------------------------------------------+
|                                              ZC-CORE HARDWARE DOMAIN TOPOLOGY                                         |
+-----------------------------------------------------------------------------------------------------------------------+
|                                                                                                                       |
|  [ UNTRUSTED EXTERNAL DOMAIN (DOMAIN 0) ]                                                                             |
|    - Network Co-Processor (Wi-Fi, Bluetooth Low Energy, Cellular, Ethernet)                                          |
|    - Third-party RTOS / Firmware Stacks (Espressif ESP-IDF, Zephyr, Linux)                                           |
|    - Internet / Cloud Connectivity & Cloud Management Daemons                                                         |
|                                                                                                                       |
|                                     | (Untrusted SPI Bus)                         | (Untrusted OBI Subordinate Bus)   |
|                                     v                                             v                                   |
|  ===================================|=============================================|=================================  |
|  [ HARDWARE-MEDIATED INTERCONNECT / FIREWALL PERIMETER ]                          |                                   |
|  ===================================|=============================================|=================================  |
|                                     |                                             |                                   |
|                     +---------------------------------+             +----------------------------------+              |
|                     |   zc_spi_flash_firewall         |             |   zc_obi_subordinate_bridge      |              |
|                     |   - Hardware Gated /CS Routing  |             |   - Synchronous Bus Decoupling   |              |
|                     |   - Rising /CS + SCK=0 Strobe   |             |   - 1024-Cycle Orphan Watchdog   |              |
|                     |   - 05h RDSR1 Status Reconciler |             |   - ST_TRAP Synthetic Bus Error  |              |
|                     |   - Bank-B Commit Gating        |             |   - Warm Reset (rst_sys_ni) Gate |              |
|                     +---------------+-----------------+             +-----------------+----------------+              |
|                                     |                                                 |                               |
|                                     v (Protected SPI)                                 v (Safe Internal OBI)           |
|                           [ Shared SPI Flash ]                           [ Secure Main SoC Interconnect ]             |
|                             - Bank A: Active FW                                       |                               |
|                             - Bank B: Staged OTA Payload                              v (Direct DAI Bus)              |
|                                                                             +----------------------------------+      |
|                                                                             |   zc_aon_post_auth_ctrl          |      |
|                                                                             |   - 4-Phase Atomic DAI Handshake |      |
|                                                                             |   - Single-Cycle Grant Egress    |      |
|                                                                             |   - Permanent AON Fatal Lock     |      |
|                                                                             |   - Hsiao (22,16) SECDED Verif   |      |
|                                                                             +-----------------+----------------+      |
|                                                                                               |                       |
|                                                                                               v                       |
|                                                                                   [ AON Physical OTP / Fuse ]         |
|                                                                                                                       |
|  ===================================================================================================================  |
|  [ TRUSTED PROCESSING DOMAIN (DOMAIN 1 - HARDWARE ENCLAVE) ]                                                          |
|  ===================================================================================================================  |
|    - Secure Host CPU (Executing Boot ROM & Verified Runtime)                                                          |
|    - Edge Neural Processing Unit (NPU) / Matrix Coprocessor                                                           |
|    - Privacy-Sensitive Sensors (Microphones, Cameras, Biometrics) via Dedicated Sensor Interfaces (M1 / M9)           |
|    - Secure Volatile SRAM with M8 Irreversible Post-Inference Zeroization                                             |
|                                                                                                                       |
+-----------------------------------------------------------------------------------------------------------------------+
```

---

## 2. Formal Domain Definitions

### 2.1 Untrusted External Domain (Domain 0)
- **Definition:** Any microcontroller, system-on-chip, or peripheral interface that communicates with external packet-switched networks, cloud infrastructure, or external serial buses.
- **Trust Assumption:** **Adversarial / Compromised.** The architecture assumes Domain 0 firmware can be remotely compromised, maliciously modified, or hijacked via zero-day network exploits.
- **Hardware Privileges:**
  - Cannot access the internal system crossbar directly.
  - Cannot read, write, or access raw sensor lines.
  - Cannot assert cold reset (`rst_aon_por_ni`) or tamper alerts.
  - All bus transactions initiated by Domain 0 are intercepted by `zc_obi_subordinate_bridge`.
  - All SPI flash transactions initiated by Domain 0 are intercepted by `zc_spi_flash_firewall`.

### 2.2 Hardware-Mediated Interconnect Perimeter
- **Definition:** The synchronous digital logic blocks that sit physically between Domain 0 and Domain 1.
- **Composition:**
  1. **`zc_spi_flash_firewall.sv`:** Arbitrates and restricts external access to external SPI NOR Flash. Blocks direct access to Bank A (Active boot code) and permits staged writes to Bank B only when authorization criteria are met.
  2. **`zc_obi_subordinate_bridge.sv`:** Decouples external open bus interface (OBI) requests, isolates Domain 1 from bus stalls or unbounded latency, and injects synthetic error responses (`ST_TRAP`) if Domain 0 misbehaves.
  3. **`zc_aon_post_auth_ctrl.sv`:** Always-on security controller mediating access to One-Time Programmable (OTP) eFuse memory. Enforces atomic multi-word commit protocols and locks out execution on verification failure.

### 2.3 Trusted Processing Domain (Domain 1)
- **Definition:** The isolated hardware enclave containing the host CPU, AI inference accelerator (NPU), local secure memories, and privacy-sensitive sensors.
- **Trust Assumption:** **Hardware Root of Trust.** Executes authenticated code anchored in immutable Boot ROM.
- **Invariant Guarantees:**
  - Raw sensor data (audio, image, bio) is acquired exclusively within Domain 1.
  - Raw sensor data resides exclusively in volatile memory subject to Invariant M8 hardware-enforced post-inference zeroization.
  - No physical reverse-read path exists to read raw sensory data out of Domain 1 (Invariant M4).

---

## 3. Data & Control Flow Specifications

### 3.1 Inbound Control Flow: Authenticated OTA Update
The inbound control path enables network-assisted firmware updates without compromising execution integrity:

1. **Payload Staging:** The untrusted Network Co-Processor downloads an encrypted, signed firmware container and writes it into Flash Bank B via `zc_spi_flash_firewall.sv`.
2. **Flash Command Gating:** The firewall intercepts all SPI cycles. Only permitted read/write commands targeting Bank B are propagated. Any attempt to modify Bank A or send dangerous manufacturer opcodes results in chip-select (`/CS`) masking and transition to firewall alarm.
3. **Cryptographic Validation:** Once staging is complete, Domain 1 Boot ROM executes cryptographic signature verification (e.g., Ed25519 or ECDSA P-256) over the Bank B payload.
4. **Commit Authorization:** If and only if verification succeeds, Domain 1 asserts `rom_img_verif_valid_i` and coordinates with `zc_aon_post_auth_ctrl.sv` to increment the non-volatile Security Version Number (SVN) in OTP memory.
5. **Bank Activation:** The firewall updates its internal pointer, making Bank B the active execution bank for the subsequent boot cycle.

### 3.2 Inbound Request Flow: Open Bus Interface (OBI) Subordinate
When the Network Co-Processor issues requests (e.g., querying public status registers or passing configuration parameters):

1. **Decoupled Synchronization:** `zc_obi_subordinate_bridge.sv` accepts the OBI request (`host_req_i`, `host_addr_i`, `host_wdata_i`).
2. **Orphan Draining Watchdog:** If the internal target peripheral does not respond within a 1,024-cycle timeout window, the watchdog triggers.
3. **Error Trap Isolation (`ST_TRAP`):** Rather than propagating a deadlocked bus state or hanging the host bus, the bridge transitions to `ST_TRAP`, asserts `host_err_o <= 1'b1`, returns dummy zero data (`host_rdata_o <= 32'h0`), and isolates the downstream peripheral.
4. **Warm Reset Decoupling:** While `rst_sys_ni` is asserted (warm reset active), external access is gated, preventing bus injection during system reboot transients.

### 3.3 Outbound Information Flow: Allowlisted Semantic Telemetry
In strict contrast to raw sensor data (which is forbidden from egress), the HYBRID profile defines an egress path for allowlisted semantic telemetry:
- **Permitted Data:** System uptime, sanitized error codes, thermal warnings, and high-level categorical inference states (e.g., "Boiling Detected", "Occupancy True").
- **Hardware Requirement (Target):** Outbound packets must be formatted via a hardware allowlist comparator and rate-limiter (Gate D target).
- **Prohibited Egress:** Raw audio samples, spectrograms, camera frames, neural embeddings, or intermediate layer tensors are strictly blocked by hardware air-gapping and M8 memory zeroization.

---

## 4. Hardware Boundary Strictures & Out-of-Scope Declarations

To maintain absolute technical integrity, the explicit boundaries of what this architecture guarantees—and what it does **not** guarantee—are formally stated:

### 4.1 In-Scope Guarantees (Verified at Digital RTL / Gate C)
- Hardware-enforced bus decoupling preventing subordinate deadlock on OBI buses.
- Hardware-enforced SPI command filtering and dual-bank access control.
- Hardware-enforced atomic 4-phase OTP write authorization with sticky fatal lockouts on fault detection.
- Mathematical absence of raw sensor reverse-read paths through the implemented RTL IP blocks under bounded formal models ($t=20$).

### 4.2 Out-of-Scope Declarations (Deferred to Gate D or External Policy)
- **SoC Crossbar DMA Isolation:** The standalone RTL blocks in `rtl/` do not replace a full-chip IOMMU or multi-master crossbar firewall. A rogue DMA master on a third-party SoC could theoretically bypass block-level boundaries if the SoC bus interconnect is misconfigured. System-wide isolation is a **Gate D (UNVERIFIED)** deliverable.
- **Clock Domain Crossing (CDC) Metastability:** Asynchronous control signals crossing between `clk_sys` and `clk_aon_i` in `zc_aon_post_auth_ctrl.sv` are evaluated synchronously under formal `async2sync`. Physical synchronizer reliability is **Gate D (UNVERIFIED)**.
- **Analog & Physical Attacks:** High-voltage fault injection ($V_{\text{PP}}$ glitching), optical laser fault injection on silicon dies, power side-channel analysis (DPA), and physical micro-probing of silicon traces are outside the scope of digital RTL verification and require physical laboratory evaluation under the Conformance Test Specification (CTS).
- **Operating System & Cloud Application Security:** Flaws in external cloud backends, network routers, or user mobile applications are strictly out of scope, as defined in [`zero-cloud-core-scope-boundary.md`](../zero-cloud-core-scope-boundary.md).
