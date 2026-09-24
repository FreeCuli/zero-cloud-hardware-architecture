# Cryptographic Release Manifest

This manifest records the cryptographic identity, publication metadata, and file integrity of the specified ZC-CORE release. The associated defensive publication is intended to establish publicly accessible technical prior art for the disclosed subject matter. This document does not constitute a patentability opinion. Legacy pointer documents (and LICENSE) are intentionally excluded from the canonical release hash set because they contain no normative content.

## Publication Metadata
* **Release Version:** ZC-CORE v3.2.0 (Laboratory Normative Upgrade)
* **Date (UTC):** 2026-09-24
* **Reference Concept DOI (Zenodo):** 10.5281/zenodo.22838473
* **Standardization Level:** RFC 2119 Normative Stricture
* **Repository:** FreeCuli/zero-cloud-hardware-architecture
* **Git Tag:** v3.2.0
* **Git Commit Resolution:** Resolves dynamically to the canonical tagged tree commit of `refs/tags/v3.2.0`
* **Release Artifact SHA-256:** *(to be computed and recorded upon generation of the immutable Zenodo archival tarball/zip using `sha256sum <zenodo_archive>`. This placeholder preserves cryptographic distinction between the Git tree state and the post-publication distribution artifact)*

## Cryptographic Evidence (SHA-256 Hashes)
The following hashes cover all canonical v3.2.0 normative and supporting documents listed in this manifest.

```text
94C8BEDAC6C6937570393580C8515E3A6828881779C4A96678836DD5F7327D24  README.md
D2B25667917F4EAB9271FAC7B6DC2B472F86CCF5A8ECBA307B55D2C1D1EF7D42  ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md
25CB027856FD0264E15630F410C9EC52A4D2E5365F0A467EB6C8EAD41B5F67D5  zero-cloud-core-attack-taxonomy.md
35D168D75A30F8F6A39F11A218AFEC6E736A3F731F1C42D5E5B8080201109C6B  zero-cloud-core-brand-and-trademark-policy.md
2E6C0315D64C229D179C5DE23082E63BAF68DCFFC372BC2D60B3E986D022A79B  zero-cloud-core-conformance-evidence-matrix.md
84A9239D91F1DA5EA00190FFB7676B0936CFAB9E90DB72B451ED0FE690F3F0CA  zero-cloud-core-conformance-test-specification.md
23B001EAB5C02E40BA0A1B83CB1DB2F7F855CE780B0C752D5A654ABD20EB15B6  zero-cloud-core-defensive-publication.md
EB23C90731F5744D33AB50655568D7A934CC1FC9BF9C45C2D50CBB1FDE221804  zero-cloud-core-implementation-coverage.md
BA0B1A4D24F02CB85E66EFB8B3049913CC9334A9ADFA6E180B55E80CB714731F  zero-cloud-core-methodology-invariants.md
F599AEA3FD0BF02FEDE423750E92152E4D314683DF1F2C76BDE20F8B4CFD5760  zero-cloud-core-scope-boundary.md
CED7B36A4941C711761A974505510D79EB2A8EE4651402E9750FD0DEF4853813  zero-cloud-core-versioning-and-governance.md
A4E12452D2CED07BDDD8A2DD7BDEE460E53BB7F2F2F687D0678C2DE30261AD8E  zero-cloud-dual-licensing.md
C430BBEBF620AC5C1107CDEBE7AE926CB49D645D66FC42B18E997DCFE6E543C0  zero-cloud-hardware-reference-architecture.md
```

## Release Hash-Chain Integrity
To maintain a cryptographically linked release history, this manifest explicitly anchors to the cryptographic state of the previous major release:

* **Previous Release Version:** v3.1.0
* **Previous Release Manifest SHA-256:** 1359c382dbfc0f0be201fb20d44e50d6f3e5362ffcd489bc8be10e53f162400e

Any future release MUST embed the SHA-256 hash of *this* specific ZERO-CLOUD-RELEASE-MANIFEST.md document to continue the chain.