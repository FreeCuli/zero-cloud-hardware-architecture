# Cryptographic Release Manifest

This manifest records the cryptographic identity, publication metadata, and file integrity of the specified ZC-CORE release. The associated defensive publication is intended to establish publicly accessible technical prior art for the disclosed subject matter. This document does not constitute a patentability opinion. Technical pointer files (such as superseded legacy placeholders) and legal instruments (such as LICENSE) are intentionally excluded from the technical normative release hash set: LICENSE establishes the governing legal framework rather than technical normative engineering requirements, while legacy placeholders contain no normative content. The 18-artifact canonical manifest strictly seals the technical normative specifications and synthesizable silicon IP blocks.

## Publication Metadata
* **Release Version:** ZC-CORE v4.0.0-rc2 (Gate 4 Blueprint / Hybrid Architecture)
* **Status:** Pending Experimental Validation (Gate C HDL Formally Verified / Gate D Physical Silicon Pending)
* **Date (UTC):** 2026-10-22
* **Reference Concept DOI (Zenodo):** 10.5281/zenodo.22838473
* **Standardization Level:** RFC 2119 Normative Stricture
* **Repository:** FreeCuli/zero-cloud-hardware-architecture
* **Git Tag: v4.0.0-rc2**
* **Git Commit Resolution:** Resolves dynamically to the canonical tagged tree commit of `refs/tags/v4.0.0-rc2`
* **Git Tag Lineage & Provenance:** Initial candidate evaluation baseline tagged at `bd5ccb1` (evaluated under archive `DC266503...`); remediated candidate release candidate tagged at child commit incorporating auditor findings.
* **Audit Baseline Evaluation Archive SHA-256 (commit bd5ccb1):** `DC2665032F64656A08E020E894660D53915DF466A985250BFD4F84696F91A8D2` (`zero-cloud-hardware-architecture-v4.0.0-rc2-candidate-eval-DC266503.zip`)
* **Post-Remediation Release Distribution Archive:** To be published externally as an external checksum record (sha256sum asset) upon GitHub release finalization to avoid circular self-reference.
* **Zenodo Release Artifact SHA-256:** *(to be computed and recorded upon post-audit publication of the immutable Zenodo archival archive)*

## Cryptographic Evidence (SHA-256 Hashes)

### Canonical Normative and Supporting Documents
The following hashes cover all canonical v4.0.0-rc2 normative and supporting documents listed in this manifest.

```text
A818AA849DC7C6B24A11C14F87EB6FA68F72B475BED930F26178B40F834E51CE  README.md
D2B25667917F4EAB9271FAC7B6DC2B472F86CCF5A8ECBA307B55D2C1D1EF7D42  ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md
50C994DABB243B5C8DA2D930A22274E5841C67181DABAB08547008B1D5048C6D  ZC-CORE-HARDWARE-FORENSIC-AUDIT-PROTOCOL.md
F5926B0E1F678D4EDF2056747CB02516EB9E41CCC7161AD00726E0988C576F8F  zero-cloud-core-attack-taxonomy.md
2D74DA7A27B6F7A14CA55B2B42D5E6091521BCB6200501A51A778380FC53E9F8  zero-cloud-core-brand-and-trademark-policy.md
2A8DE21919D43A3D56FA601A13667CF7D3FEB05131D1FC78485BA6258A82435F  zero-cloud-core-conformance-evidence-matrix.md
CAC52B453F482DD38A1CEFEEF292C490F3B5BA0FDB5FF7C09F3E0FD2A58C5FB5  zero-cloud-core-conformance-test-specification.md
29B722E5551485D638435605C318C2EC87D9FA7CECCF7665038DD97B6709BB7B  zero-cloud-core-defensive-publication.md
948B54AB0924D2284EEA88BE05475346B53ED6551D1CC5790C03A158D2D5932C  zero-cloud-core-implementation-coverage.md
5BA823F30B8AE988CFC2363D6ACD8340FFBFBD03CF704E32A2982372AA12EBAC  zero-cloud-core-methodology-invariants.md
6987D4F00FC2913F431689EDA08986E874AE3C81860E5566589837D8AC3C5E3A  zero-cloud-core-scope-boundary.md
78A7834984733F13D72E276C02FE8A556678DFB0E1E9FF7CE13436EDD0EEC446  zero-cloud-core-versioning-and-governance.md
FDFC064D30FDD966C4589B5A1A21DF15059F9604E643883731DD747DADA23683  zero-cloud-dual-licensing.md
33F19A37C778B99C05C54D593EE6D93BA0F928408771C5E3C6DD4F86CA2C53AB  zero-cloud-hardware-reference-architecture.md
```

### Synthesizable RTL Reference Implementation (Route B)
The following hashes cover the Gate C synthesizable SystemVerilog silicon IP blocks:

```text
22327D4C0F0794B3C62EE9EBAD68909B97C4FEA4A84DD6321216A124D0F663BD  rtl/zc_aon_post_auth_ctrl.sv
9AAAFBFC0634107348F502D1F4AF707F0D9489ED5F77BFF29B6C822A6D323AC5  rtl/zc_obi_subordinate_bridge.sv
AEC617370357B31419EFC309ECE13A34223D816D7D231528B703304C218752C9  rtl/zc_otp_pkg.sv
CFF0715EAFECF0D6D1E644567501ABD83824946AC6025791A006DED8440EE7BB  rtl/zc_spi_flash_firewall.sv
```

## Release Hash-Chain Integrity
To maintain a cryptographically linked release history, this manifest explicitly anchors to the cryptographic state of the previous release candidate:

* **Previous Release Version:** v3.3.0-rc2
* **Previous Release Manifest SHA-256:** 797c846bfd7f4f20a990d8520c850ebd293b0d383b18abd078ae985c335f2f8

Any future release MUST embed the SHA-256 hash of *this* specific ZERO-CLOUD-RELEASE-MANIFEST.md document to continue the chain.