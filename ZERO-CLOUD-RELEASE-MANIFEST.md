# Cryptographic Release Manifest

This manifest records the cryptographic identity, publication metadata, and file integrity of the specified ZC-CORE release. The associated defensive publication is intended to establish publicly accessible technical prior art for the disclosed subject matter. This document does not constitute a patentability opinion.

## Publication Metadata
* **Release Version:** ZC-CORE v3.2.0 (Laboratory Normative Upgrade)
* **Date (UTC):** 2026-09-24
* **Reference Concept DOI (Zenodo):** 10.5281/zenodo.22838473
* **Standardization Level:** RFC 2119 Normative Stricture

## Cryptographic Evidence (SHA-256 Hashes)
The following hashes cover all canonical v3.2.0 normative and supporting documents listed in this manifest.

```text
CEFF6A4F119257645EE325F7D283E6391A0E398454B813B98E262D61081F3356  README.md
6D9320C683D9F13E54463829F2CB3298E2015AC24F2CDA6B44377EF756DFFB3F  zero-cloud-core-attack-taxonomy.md
236DA97C96669D97032D8955FC553A352F280D526FCCA588299B8B87A07348FC  zero-cloud-core-brand-and-trademark-policy.md
D3E380F0C5829AF51192D7044085265DE0FB794D41B321AFA547C833075AC586  zero-cloud-core-conformance-evidence-matrix.md
7F379B6BA2DEA74176DCC8FF6225EB52D338F88A2D06C70E2A8A4EFCAC129132  zero-cloud-core-conformance-test-specification.md
1F56F2FCF4D045AD1F0754F28D58AA0AB58CEA3EBF1E2E70F41CBDEC8B902053  zero-cloud-core-defensive-publication.md
1AAFEC1987041399D923F270492DBCF02BDD43CD3ED9AB8E8A650AC440FFCC19  zero-cloud-core-implementation-coverage.md
8FD67AD0CC3BA12BF4D860FE70C9E20DE56327B613A40C80B2B082BEBA1E82CB  zero-cloud-core-methodology-invariants.md
78C5BBD1F09452955E586254D60D9B6BBDB9C2EA37A352AC68FF396E6F38FDC8  zero-cloud-core-scope-boundary.md
9B46F39CF23C435A848CA37B34F45DCC48E587876222F909383088B7AFA1B799  zero-cloud-core-versioning-and-governance.md
7819016BF0AFBE29B6B9D600A7391171EC670D034ED7C4DDFFC1C9C172FC9C5F  zero-cloud-dual-licensing.md
4DC865E55712E64AE0C6AA69A1669FDAC0F4097B8F0B04B383A3C2A8A6DA3E52  zero-cloud-hardware-reference-architecture.md
```

## Release Hash-Chain Integrity
To maintain a cryptographically linked release history, this manifest explicitly anchors to the cryptographic state of the previous major release:

* **Previous Release Version:** v3.1.0
* **Previous Release Manifest SHA-256:** 1359c382dbfc0f0be201fb20d44e50d6f3e5362ffcd489bc8be10e53f162400e

Any future release MUST embed the SHA-256 hash of *this* specific ZERO-CLOUD-RELEASE-MANIFEST.md document to continue the chain.