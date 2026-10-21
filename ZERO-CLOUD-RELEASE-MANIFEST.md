# Cryptographic Release Manifest

This manifest records the cryptographic identity, publication metadata, and file integrity of the specified ZC-CORE release. The associated defensive publication is intended to establish publicly accessible technical prior art for the disclosed subject matter. This document does not constitute a patentability opinion. Legacy pointer documents (and LICENSE) are intentionally excluded from the canonical release hash set because they contain no normative content.

## Publication Metadata
* **Release Version:** ZC-CORE v4.0.0-rc1 (Gate 4 Blueprint / Hybrid Architecture)
* **Status:** Pending Experimental Validation (Gate C HDL Formally Verified / Gate D Physical Silicon Pending)
* **Date (UTC):** 2026-10-21
* **Reference Concept DOI (Zenodo):** 10.5281/zenodo.22838473
* **Standardization Level:** RFC 2119 Normative Stricture
* **Repository:** FreeCuli/zero-cloud-hardware-architecture
* **Git Tag: v4.0.0-rc1**
* **Git Commit Resolution:** Resolves dynamically to the canonical tagged tree commit of `refs/tags/v4.0.0-rc1`
* **Release Artifact SHA-256:** *(to be computed and recorded upon generation of the immutable Zenodo archival tarball/zip using `sha256sum <zenodo_archive>`. This placeholder preserves cryptographic distinction between the Git tree state and the post-publication distribution artifact)*

## Cryptographic Evidence (SHA-256 Hashes)

### Canonical Normative and Supporting Documents
The following hashes cover all canonical v4.0.0-rc1 normative and supporting documents listed in this manifest.

```text
59756E3FCF7D80DD2FCB107FAF9BCC89090D3523C619C234A3CEFBA63F70B864  README.md
D2B25667917F4EAB9271FAC7B6DC2B472F86CCF5A8ECBA307B55D2C1D1EF7D42  ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md
575ED5E3772E5A66923A81D5A997ED5271370E20D0AF9659AB68F1A8F86594EF  ZC-CORE-HARDWARE-FORENSIC-AUDIT-PROTOCOL.md
E89A46325559F8E0CE6DFC056FBC73CED84656EC3D65DBB7C31BC8456C7125BB  zero-cloud-core-attack-taxonomy.md
43632A26013E038DCC9FB63D8E97D3DA4889242D54E954A1B2C5E8571570AA63  zero-cloud-core-brand-and-trademark-policy.md
B61D7C387FB89D5CDF6D52D8B789F15486FBC69977EA1D09D8205DD2B8AA2804  zero-cloud-core-conformance-evidence-matrix.md
D2E437D36CF3C1C75C83C26F56DA7E7629D35342DA6384D51DDAB7D756A0041F  zero-cloud-core-conformance-test-specification.md
59652359871D466DD341A3E38710FB486DCC92597A104F57E0F64F8C7F92CA02  zero-cloud-core-defensive-publication.md
42D322868B7EE886EEA6F9623D4183BDBE6C8FF2BBB5E5212FFCDE3A7E70DA2A  zero-cloud-core-implementation-coverage.md
1231F6F740B7F2C7E807E4328CDD7A2C2B214B843042E1BD9D3B03DC1D8F04B7  zero-cloud-core-methodology-invariants.md
69F18D4C9DF8E03A60CC492FE009A81355F792A21B4E91BB95FE41F17914FE18  zero-cloud-core-scope-boundary.md
FEF4B9A6752F8CDA8178005A8C2DA708AEA4FB64E4B55C21783A129A5CF908F6  zero-cloud-core-versioning-and-governance.md
A48133C9434ABB4622A37B35D3E85FDD4EE44B387EABBC2C9EB1B2F0329E0215  zero-cloud-dual-licensing.md
AAEA5E7B26DB5538C8A17CB95760E423E69218D871E45442DCB04C427A091A05  zero-cloud-hardware-reference-architecture.md
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