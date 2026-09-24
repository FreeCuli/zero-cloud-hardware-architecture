# Cryptographic Release Manifest

This manifest records the cryptographic identity, publication metadata, and file integrity of the specified ZC-CORE release. The associated defensive publication is intended to establish publicly accessible technical prior art for the disclosed subject matter. This document does not constitute a patentability opinion. Legacy pointer documents (and LICENSE) are intentionally excluded from the canonical release hash set because they contain no normative content.

## Publication Metadata
* **Release Version:** ZC-CORE v3.2.0 (Laboratory Normative Upgrade)
* **Date (UTC):** 2026-09-24
* **Reference Concept DOI (Zenodo):** 10.5281/zenodo.22838473
* **Standardization Level:** RFC 2119 Normative Stricture

## Cryptographic Evidence (SHA-256 Hashes)
The following hashes cover all canonical v3.2.0 normative and supporting documents listed in this manifest.

```text
367DA4E160B13920D6D7C5950563225E257D2D439AAD7025F0ECF7D56AE0C516  README.md
D2B25667917F4EAB9271FAC7B6DC2B472F86CCF5A8ECBA307B55D2C1D1EF7D42  ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md
2670626772F26A73756BE79ED6621892D72B81EF29A02AD7951FA10E4F1CDDEC  zero-cloud-core-attack-taxonomy.md
35D168D75A30F8F6A39F11A218AFEC6E736A3F731F1C42D5E5B8080201109C6B  zero-cloud-core-brand-and-trademark-policy.md
BF1368052BAAB32F36CF19B6853006D333462282CA2A0B47348BA505307C3AE9  zero-cloud-core-conformance-evidence-matrix.md
C521FA14BEE0F19A2CB5404A9FAD2FD8C970FBA51E710B51D495205F67D49F5E  zero-cloud-core-conformance-test-specification.md
23B001EAB5C02E40BA0A1B83CB1DB2F7F855CE780B0C752D5A654ABD20EB15B6  zero-cloud-core-defensive-publication.md
E8DBB82FF8CC53617D4BBE26E8139E140CA97CF8CE5119065F28E275A90BBC18  zero-cloud-core-implementation-coverage.md
8FD67AD0CC3BA12BF4D860FE70C9E20DE56327B613A40C80B2B082BEBA1E82CB  zero-cloud-core-methodology-invariants.md
A5638063A29CDCD24866BDB93832047387B2747954BF5D10742B20FDA6148103  zero-cloud-core-scope-boundary.md
B102221CC1FC42269357BA778FC7ADB2737C344066879BF33BE65527D4A60E64  zero-cloud-core-versioning-and-governance.md
A4E12452D2CED07BDDD8A2DD7BDEE460E53BB7F2F2F687D0678C2DE30261AD8E  zero-cloud-dual-licensing.md
956A1FBACDA4E2A6696F77AA0165E22CBE1C01235A14E9FC0684577AD3FEF549  zero-cloud-hardware-reference-architecture.md
```

## Release Hash-Chain Integrity
To maintain a cryptographically linked release history, this manifest explicitly anchors to the cryptographic state of the previous major release:

* **Previous Release Version:** v3.1.0
* **Previous Release Manifest SHA-256:** 1359c382dbfc0f0be201fb20d44e50d6f3e5362ffcd489bc8be10e53f162400e

Any future release MUST embed the SHA-256 hash of *this* specific ZERO-CLOUD-RELEASE-MANIFEST.md document to continue the chain.