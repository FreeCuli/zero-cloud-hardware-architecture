# Cryptographic Release Manifest

This manifest records the cryptographic identity, publication metadata, and file integrity of the specified ZC-CORE release. The associated defensive publication is intended to establish publicly accessible technical prior art for the disclosed subject matter. This document does not constitute a patentability opinion. Legacy pointer documents (and LICENSE) are intentionally excluded from the canonical release hash set because they contain no normative content.

## Publication Metadata
* **Release Version:** ZC-CORE v3.3.0-rc1 (Gate 4 Blueprint)
* **Status:** Pending Experimental Validation (Gate 4 Laboratory Execution)
* **Date (UTC):** 2026-09-24
* **Reference Concept DOI (Zenodo):** 10.5281/zenodo.22838473
* **Standardization Level:** RFC 2119 Normative Stricture
* **Repository:** FreeCuli/zero-cloud-hardware-architecture
* **Git Tag: v3.3.0-rc1**
* **Git Commit Resolution:** Resolves dynamically to the canonical tagged tree commit of `refs/tags/v3.3.0-rc1`
* **Release Artifact SHA-256:** *(to be computed and recorded upon generation of the immutable Zenodo archival tarball/zip using `sha256sum <zenodo_archive>`. This placeholder preserves cryptographic distinction between the Git tree state and the post-publication distribution artifact)*

## Cryptographic Evidence (SHA-256 Hashes)
The following hashes cover all canonical v3.3.0-rc1 normative and supporting documents listed in this manifest.

```text
9AF4634F622C7EEEC96F865CF8913853E7A1E0AE17C78F5D37275A68BC97D750  README.md
D2B25667917F4EAB9271FAC7B6DC2B472F86CCF5A8ECBA307B55D2C1D1EF7D42  ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md
5B45D988519AF52452C5B323B1F72B1EC3BF5AEE57C85E7873EDFB66859A0910  zero-cloud-core-attack-taxonomy.md
E4A46E35EA25B8800E41591DF6C895D326739CBC97451C5890C00BE7C3FD6892  zero-cloud-core-brand-and-trademark-policy.md
3ABC22399BCE1A9E0F188DFD288D53528D2D1A4AE9F41812BE95B5793CA4511F  zero-cloud-core-conformance-evidence-matrix.md
CFB82BAC7F7D6DAA8BF09DC1528CEA65D03BB766506A6B1AC60BC17A4F494A92  zero-cloud-core-conformance-test-specification.md
8C8CB6B25589E2A290CF9B1B52D1664BCF5DA27DB4DBAC8A6129A8FFAC3D381F  ZC-CORE-HARDWARE-FORENSIC-AUDIT-PROTOCOL.md
E4CA3F7117D7EC24832ECA4AF0BEE28DED52D9BA9A95A55AC6B61C871672074B  zero-cloud-core-defensive-publication.md
0DDF2D7DC18953F0EA66E1BF92C5A206754DAD4FB4093D4C7A615E74A127029E  zero-cloud-core-implementation-coverage.md
E95775B0560AF8B9CBD4F7CEE830B8474047EF9931C02457301336B083BA040F  zero-cloud-core-methodology-invariants.md
A6861A61AFA3E693061FA0951082C8DE7A3C43132280B7D8A64AB1B4788B05D9  zero-cloud-core-scope-boundary.md
C7F2B4227B1BEAD5E9A08586483D0015985B35D7CCFF4CD96D887D0B39201A57  zero-cloud-core-versioning-and-governance.md
006F0E4E6FBBE7999C38EEC464FDD43369541BE9DA9A55061273E051741D79F8  zero-cloud-dual-licensing.md
22D1783223A04D04A6E8682F966C5C7EAF2F7DC4D06ACB1A7B8325E7E946B184  zero-cloud-hardware-reference-architecture.md
```

## Release Hash-Chain Integrity
To maintain a cryptographically linked release history, this manifest explicitly anchors to the cryptographic state of the previous major release:

* **Previous Release Version:** v3.1.0
* **Previous Release Manifest SHA-256:** 1359c382dbfc0f0be201fb20d44e50d6f3e5362ffcd489bc8be10e53f162400e

Any future release MUST embed the SHA-256 hash of *this* specific ZERO-CLOUD-RELEASE-MANIFEST.md document to continue the chain.