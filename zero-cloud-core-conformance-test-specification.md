# ZC-CORE: Conformance Test Specification (CTS)

**Version:** v3.3.0-rc1
**License:** CERN-OHL-S v2.0
**Status:** Laboratory Normative Upgrade & Measurement Methodology Rev. 1

## 1. Introduction and Vendor-Neutral Conformance Principle

ZC-CORE does not require a single reference semiconductor, SoC, FPGA, PCB topology, or vendor implementation. It defines a vendor-neutral set of security properties, observable physical behaviors, measurement procedures, acceptance criteria, and evidence requirements by which an implementation can be independently falsified or verified.

The absence of a mandatory reference schematic does not mean the absence of hardware evidence. It means that the implementation is evaluated against measurable security properties rather than architectural resemblance to a FreeCuli reference design.

## 2. Metrology and Measurement Foundation

Every normative security claim must be strictly falsifiable. The metrology foundation separates validity into three distinct layers:
1. **Measurement Validity:** Is the physical event measured correctly and reproducibly?
2. **Threshold Validity:** Is the acceptance threshold scientifically sufficient for security?
3. **Decision Validity:** How is the measurement uncertainty applied to the threshold (Decision Rule)?

### 2.1 Measurement Access Points (MAP)
ZC-CORE MUST NOT require a permanent externally accessible test point (TP) unless explicitly required by the applicable implementation profile. Measurement Access Points (e.g., MAP-TD-01 for Trusted Domain, MAP-ISO-01 for Isolation Boundary) MAY be permanent, temporary, or fixture-based.

### 2.2 Measurement Definition (Required Parameters)
A physical threshold (e.g., -80 dBm or <5 mVpp) is not a complete specification. The laboratory MUST define and report:
* Reference impedance (e.g., 50 Ω) and reference plane
* Measurement bandwidth and detection limit
* Sampling rate, detector mode, and probe/coupling method
* Instrument calibration state, noise floor, and expanded measurement uncertainty

### 2.3 Decision Rule (Guard-Banding)
**Decision Rule: Pending Validation.**
The application of measurement uncertainty to the PASS/FAIL decision (e.g., Strict Acceptance, Shared Risk) is pending independent validation. The laboratory MUST report the measured value, expanded uncertainty, and the decision rule applied.

### 2.4 INCONCLUSIVE Semantics and Measurement Adequacy
Test results MUST be classified as PASS, FAIL, INCONCLUSIVE, NOT APPLICABLE, or NOT TESTED.
Before applying INCONCLUSIVE, the laboratory must evaluate **Measurement Adequacy**. If fundamental calibration fails, the measurement is invalid. 
* **INCONCLUSIVE** SHALL be reported when the measurement is valid, but the metrology system's capabilities (e.g., insufficient dynamic range, unresolved uncertainty, insufficient bandwidth, or noise floor limitations) prevent a definitive PASS/FAIL decision.

---

## 3. Normative Conformance Tests

### FC-ZC-003: Physical Data Diode Isolation

The data diode isolation boundary (M1-M4) is evaluated across three distinct evidence layers.

#### FC-ZC-003A: Functional Reverse-Path Test
* **Security Claim:** The Network Domain cannot functionally read raw information from the Trusted Domain.
* **Observable:** Memory/bus transaction results on MAP-ND-01.
* **Validation Status:** Normative Requirement.

#### FC-ZC-003B: Electrical Coupling Test
* **Security Claim:** No measurable electrical coupling exists across the isolation boundary.
* **Acceptance Criterion:** The measured reverse-coupled signal SHALL remain below the applicable normative threshold (<5 mVpp or <-80 dBm).
* **Validation Status:** **Threshold Pending Experimental Validation**. (Measurement definition parameters are required).

#### FC-ZC-003C: Statistical Information Leakage Test
* **Security Claim:** There is no statistically significant relationship between the measured physical signal and the protected raw data.
* **Acceptance Criterion:** MI < MI_upper_bound (See Annex B).
* **Validation Status:** **Pending Independent Validation**.

---

### FC-ZC-004: Volatile Memory Zeroization & Data Remanence (M7/M8)

Data destruction evaluation is separated into three distinct phases to decouple command issuance from physical inference risk:
1. Zeroization command issued (Trigger)
2. Physical state transition completed (T_INV)
3. Residual information experimentally demonstrated to be unrecoverable (R_rate)

* **Acceptance Criterion:** 
  1. T_INV <= T_PROFILE (Currently specified as <10 ms).
  2. Residual recovery rate R_rate <= 0.01%.
* **Validation Status:** **Existing Threshold — Pending Independent Experimental Validation**. 

---

### FC-ZC-008: Debug Interface Lifecycle and Attack Surface (M9)

* **Security Claim:** Production debug interfaces cannot be used to bypass the trust boundary or extract raw data.
* **Lifecycle Constraint:** JTAG/SWD is evaluated under a lifecycle model: Engineering DUT -> Instrumentation -> Security Test -> Production Lock -> Accessibility Verification.
* **Validation Status:** Normative Requirement.

---


## Annex B: Normative Laboratory Measurement Protocols & Statistical Calibration

To provide evidence relevant to selected cybersecurity considerations (it does not constitute formal EU Cyber Resilience Act (CRA) conformity assessment or legal compliance) and to ensure multi-lab reproducibility, all physical leakage thresholds specified in this document MUST be evaluated under the exact calibration, equipment, and statistical parameters defined below. 

### 1. Electromagnetic & Power Signal Leakage Calibration (Ref: FC-ZC-002 / FC-ZC-003)
Any manufacturer claim regarding RF/EM thresholds (e.g., < -80 dBm) or power plane ripple (e.g., < 5 mVpp) SHALL NOT be verified via generic ambient measurements. The testing laboratory MUST execute the following setup:

* **Equipment Standard:** Rohde & Schwarz FSW / Keysight N9040B Signal Analyzer or equivalent. Any "equivalent" instrument MUST possess a minimum real-time bandwidth (RTBW) of 1 GHz, sampling rate ≥ 5 GSa/s, and a characterized noise floor ≤ -150 dBm/Hz.
* **Probe Specification:** Near-field EM probes (Langer EMV-Technik LF-B 3 / RF-R 400 or equivalent) calibrated down to 20 dB gain via an external low-noise pre-amplifier.

### 2. Measurement Uncertainty & Decision Rule
To establish a rigorous laboratory standard, the test report MUST define the Measurement Uncertainty Budget. 
* **Decision Rule:** For any leakage threshold (e.g., `< -80 dBm`), if the measured value plus the calculated expanded measurement uncertainty (with a 95% confidence level, k=2) overlaps the threshold, it is considered a **FAIL**. Guard bands MUST be strictly applied to prevent false compliance due to instrumentation noise.
* **Measurement Configuration:** Unless explicitly overridden by a specific test, all continuous wave (CW) or broadband leakage limit tests (e.g., `< -80 dBm`) SHALL be evaluated using a Resolution Bandwidth (RBW) of 1 MHz, an RMS detector, and a 50-ohm reference impedance.
* **Probe Placement:** Fixed mechanically at a maximum distance of 2.0 mm ± 0.1 mm above the silicon die encapsulation or the designated physical trust boundary trace.
* **RF Environment:** All measurements MUST occur inside an ISO 17025 accredited fully anechoic chamber (FAC) with an ambient electromagnetic noise floor calibrated strictly below -110 dBm.
* **Sampling Parameters:** Minimum sampling rate of 10 GS/s with a hardware bandwidth limit set exactly matching the maximum clock frequency of the isolated NPU domain plus its 5th harmonic.
* **Measurement Device Roles:** To prevent instrument role ambiguity across laboratory reports, each piece of equipment SHALL be used exclusively for its designated function:
    * **VNA (Vector Network Analyzer):** Coupling/impedance characterization and S-parameter measurements.
    * **TDR (Time-Domain Reflectometer):** Transmission/reflection/path characterization.
    * **PCB X-Ray:** Physical topology verification of layer stackup and conductive path routing.
    * **Spectrum/Signal Analyzer:** RF/EM leakage power measurement against the `< -80 dBm` threshold.
    * **Oscilloscope:** Time-domain and mVpp reverse-injection measurements (FC-ZC-003).
    * **Logic Analyzer:** Digital control-plane and destruction-timing measurements (FC-ZC-004, FC-ZC-012).

### 2. Operational Statistical Criterion for Information Leakage
Real-world physical channels possess inherent thermal and environmental noise. Consequently, demonstrating an absolute mathematical zero for mutual information (I(X;Y) = 0) over a finite sample size is physically impossible and constitutes an untestable claim. 

To maintain strict scientific falsifiability, the criterion **"Mutual Information = 0"** is hereby structurally replaced with an operational statistical bound:

Criterion: I(X;Y) < MI_upper_bound

where MI_upper_bound defines the upper bound of permissible leaked mutual information under the following mandatory evaluation strictures:
* **Statistical Confidence Level:** Minimum alpha = 0.05 (95% confidence interval). Confidence intervals SHALL be estimated using a bootstrap procedure with a minimum of 10,000 resamples, computing a two-sided 95% CI from the empirical distribution of the MI estimator.
* **Sample Size (N):** The measurement MUST pool a minimum of N = 1,000,000 independent, identically distributed (i.i.d.) Edge AI inference executions. The i.i.d. requirement SHALL be operationally met via randomized acquisition order, environmental temperature control, stable power-supply calibration, rigorous batch structure analysis, autocorrelation checks, and session separation to ensure trace independence.
* **Operational Bound Value:** For ZC-CORE-C1/C2 profiles, MI_upper_bound is fixed at 10^-4 bits. For ZC-CORE-C3 high-assurance profiles, MI_upper_bound = 10^-6 bits.
* **MI Estimator Specification:** The laboratory SHALL use a **k-nearest-neighbor (k-NN) mutual information estimator** (e.g., Kraskov-Stoegbauer-Grassberger estimator). The MI unit SHALL be **bits** (base-2 logarithm). `X` is defined as the raw sensor input value (e.g., audio sample amplitude) and `Y` is the corresponding electromagnetic side-channel measurement (e.g., power trace sample at the same inference cycle). To ensure reproducibility across laboratories, the exact trace window definition, time alignment procedure, feature extraction/dimensionality reduction policy, and raw sample representation MUST be explicitly documented. No preprocessing or normalization that could reduce measured MI is permitted unless explicitly justified in the lab report.
* **MI Estimator Reproducibility Parameters (Mandatory):** To ensure deterministic, inter-laboratory reproducibility, the following parameters MUST be reported in the Evidence Package:
    * **k value** (number of nearest neighbours).
    * **Distance metric** (e.g., Chebyshev, Euclidean).
    * **Tie-breaking and boundary correction method**.
    * **Dimensionality reduction algorithm and version** (if any).
    * **Random seed** (for any stochastic preprocessing step).
    * **Software library name and version** (e.g., Python `sklearn`, `pyinform`).
    * **Floating-point precision** (e.g., float64).
    * **Confidence interval implementation and bootstrap randomization method**.
* **Pass/Fail Calculation:** If the upper bound of the computed 95% confidence interval for the MI estimator exceeds `MI_upper_bound`, the device SHALL be issued an immediate **TOTAL FAILURE** verdict.

### 3. Normative TVLA (Test Vector Leakage Assessment) Execution Protocol (Ref: FC-ZC-009)
The phrase "strict threshold" regarding TVLA is operationally defined under the following cryptographic evaluation framework:

* **Methodology:** Fixed-vs-Random t-testing utilizing Welch's t-test algorithm to detect non-profiled leakage across the entire time-domain trace.
* **Trace Alignment:** Laboratories MUST implement a validated trace-alignment procedure (e.g., dynamic time warping - DTW) to eliminate clock jitter artifacts before computing statistical variance. The alignment procedure MUST be documented, the alignment parameters recorded, and reproducibility demonstrated by retaining the raw traces and script SHAs.
* **Sample Count:**
    * **C1 (Consumer):** Minimum **100,000** traces.
    * **C2 (Enhanced Industrial):** Minimum **1,000,000** traces.
    * **C3 (High-Assurance):** Minimum **5,000,000** traces.
* **Leakage Threshold (t-value):**
    * **PASS:** No evaluated temporal hypothesis has `p_i < alpha_adjusted`. The value `|t| > 4.5` is retained solely as a screening indicator.
    * **FAIL:** Any single temporal sample point in the processed trace matrix exhibiting `p_i < alpha_adjusted` constitutes a verifiable side-channel leakage event, resulting in an immediate conformance failure.
* **TVLA Reproducibility Metadata (Mandatory):** To ensure inter-laboratory determinism, the Evidence Package MUST document: raw trace length, post-alignment trace length, downsampling policy, window selection method, total number of hypotheses (m), feature extraction method, and any preprocessing applied.
* **Multiple-Comparison Correction (Bonferroni Method):** For `m` simultaneous temporal hypotheses (where `m` equals the total number of evaluated temporal sample points in the post-alignment trace window, including any pre-processed or dimensionality-reduced vectors), laboratories SHALL apply the following normative procedure:

    1. For each temporal point `i`, compute the Welch t-statistic `t_i` and its two-sided p-value `p_i`.
    2. Apply Bonferroni correction: `alpha_adjusted = 0.05 / m`.
    3. **FAIL** if any `p_i < alpha_adjusted`.

    > **Note:** The `|t| > 4.5` value referenced in this specification is an approximate screening heuristic corresponding to the uncorrected significance level for large sample sizes. The definitive normative decision rule is step 3 above. The `|t| > 4.5` value SHALL NOT be used as an independent FAIL criterion in place of the corrected p-value procedure.

### 4. Mathematical Definition of "0.01% Remanence" (Ref: FC-ZC-004)
To prevent manufacturer obfuscation regarding the volatile memory zeroization threshold (< 0.01%), the **Remanence Recovery Rate (R_rate)** is mathematically defined and evaluated via the following formula:

R_rate = (Successfully Reconstructed Raw Data Bits / Original Raw Data Bits) * 100

> **Normative Note on "Successfully Reconstructed":** A bit is considered "successfully reconstructed" if any extraction methodology (including exact recovery, statistical inference, correlation, or partial classification) can determine the bit's original state with a statistically significant improvement over a random guessing baseline (`p < 0.01` after multiple-hypothesis correction for the number of bits evaluated). The assumed attacker capability includes full knowledge of the classifier structure and unlimited access to training baselines on identical counterpart devices.
>
> **Normative Metric Disambiguation:** To prevent conflation of classification-level leakage with bit-level reconstruction, laboratories SHALL additionally report two sub-metrics alongside R_rate:
> * **R_exact** = (exactly reconstructed raw bits / total raw bits). This measures only hard, bit-accurate reconstruction.
> * **A_advantage** = (observed reconstruction performance − random guessing baseline). This measures the statistical advantage of any inference method above random.
>
> A device MUST satisfy R_rate ≤ 0.01% on the primary R_rate metric. The R_exact and A_advantage sub-metrics are mandatory for audit traceability. Classification-level accuracy alone SHALL NOT be substituted for the R_rate pass/fail determination.

* **Timing Parameters (mechanism-specific requirements):**
    * For **power-cut implementations**: Following the inference-completion event, the hardware power-cut mechanism SHALL initiate and SRAM/volatile-memory VCC SHALL drop to 0V within `t_latency < 10 ms`. Power SHALL remain removed for a minimum of `t_off = 10 ms` at ambient temperature calibrated to 25°C before the forensic extraction attempt. *The VCC = 0V requirement applies only to power-cut implementations.*
    * For **cryptographic or equivalent implementations**: The declared destruction/invalidation mechanism SHALL complete its normative destruction/invalidation transition within `t_latency < 10 ms` from the inference-complete interrupt and SHALL satisfy the FC-ZC-012 memory-surface completeness criteria. The mechanism itself constitutes the forensic-irrecoverability event; `t_off` does not apply.
* **Pass/Fail Condition:** Following the destruction/invalidation event, the residual charge state or state-reconstruction success rate across all storage locations capable of retaining raw-sensor information (including registers, cache, DMA buffers, and scratchpads) MUST satisfy R_rate <= 0.01% with a statistical confidence interval of 99% (p < 0.01). Any classification accuracy or ad-hoc forensic reconstruction tool achieving a bit recovery rate higher than 0.01% over 10,000 test iterations SHALL trigger an automatic conformance failure.

---

### 4. Reproducibility & Traceability Metadata
To guarantee measurement reproducibility, the Evidence Package MUST include the following metadata for all statistical analyses:
* **Dataset Identifiers:** Unique ID, randomized acquisition seed, and timestamps.
* **Environmental Log:** Exact temperature and voltage baseline during acquisition.
* **Analysis Software Identity:** Tool name, version, source revision, and the SHA-256 hash of the specific analysis script executed (e.g., Python TVLA script).

---

## Annex C: ZC-CORE Assurance Profile Matrix (C1/C2/C3)

To ensure absolute traceability for certification, manufacturers MUST declare their target assurance profile, which dictates the mandatory subset of tests and stringency levels:

> **Note on Profile Semantics:** C2-specific assurance requirements are expressed through profile-specific parameters, evidence requirements, and acceptance criteria; they do not necessarily require additional FC-ZC test identifiers compared to C1. C3 requires both tightened parameters and additional invasive test identifiers.

| Assurance Profile | Required CTS Test IDs | Profile-Specific Normative Parameters |
| :--- | :--- | :--- |
| **ZC-CORE-C1 (Consumer)** | FC-ZC-001 through FC-ZC-014 | `MI_upper_bound` = 10^-4 bits<br>TVLA Minimum Traces = 100,000 |
| **ZC-CORE-C2 (Industrial)** | FC-ZC-001 through FC-ZC-014 | `MI_upper_bound` = 10^-4 bits<br>TVLA Minimum Traces = 1,000,000<br>Supply-chain cryptographic evidence: REQUIRED<br>Extended memory zeroization validation: REQUIRED |
| **ZC-CORE-C3 (High-Assurance)** | FC-ZC-001 through FC-ZC-016 | `MI_upper_bound` = 10^-6 bits<br>TVLA Minimum Traces = 5,000,000<br>Invasive/Fault tests (FC-ZC-015, FC-ZC-016) |
