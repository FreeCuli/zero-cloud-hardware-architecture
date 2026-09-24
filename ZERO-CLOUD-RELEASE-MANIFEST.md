# Cryptographic Release Manifest

This manifest records the cryptographic identity, publication metadata, and file integrity of the specified ZC-CORE release. The associated defensive publication is intended to establish publicly accessible technical prior art for the disclosed subject matter. This document does not constitute a patentability opinion. Legacy pointer documents (and LICENSE) are intentionally excluded from the canonical release hash set because they contain no normative content.

## Publication Metadata
* **Release Version:** ZC-CORE v3.2.1 (Hardening Release)
* **Date (UTC):** 2026-09-24
* **Reference Concept DOI (Zenodo):** 10.5281/zenodo.22838473
* **Standardization Level:** RFC 2119 Normative Stricture
* **Repository:** FreeCuli/zero-cloud-hardware-architecture
* **Git Tag:** v3.2.1
* **Git Commit Resolution:** Resolves dynamically to the canonical tagged tree commit of `refs/tags/v3.2.1`
* **Release Artifact SHA-256:** *(to be computed and recorded upon generation of the immutable Zenodo archival tarball/zip using `sha256sum <zenodo_archive>`. This placeholder preserves cryptographic distinction between the Git tree state and the post-publication distribution artifact)*

## Cryptographic Evidence (SHA-256 Hashes)
The following hashes cover all canonical v3.2.1 normative and supporting documents listed in this manifest.

```text
8CA6FBADE5B7F6ACA5C2D4C29F0A0C60BAC306D1696E46FF6CDB917748533A1F  README.md
D2B25667917F4EAB9271FAC7B6DC2B472F86CCF5A8ECBA307B55D2C1D1EF7D42  ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md
310F0F67C3BACD0F3BE6195361F3AFF97E84B0FC996AA7AC4F7214734E7F85DA  zero-cloud-core-attack-taxonomy.md
71A153BECE35BF0277FD2E736F401220F79912584795CDC1FCAF206CA1FFC7FE  zero-cloud-core-brand-and-trademark-policy.md
390380B9ABF6AA3D8DDB4CF31CCFB5275AD9840AAD0459691CE09A4AB106805F  zero-cloud-core-conformance-evidence-matrix.md
4090507D881D478ECC9675B1927EF74CB1CADAAD3C814A001FCC2FF900F66A5B  zero-cloud-core-conformance-test-specification.md
9D1E0F03A55383E215675B5EA934F9874C8C91D0A892F51A21CE0178C8DE6023  zero-cloud-core-defensive-publication.md
D540AFC4D4FF4279CFD8313E6FB2937EA8C54779193EFF55B0B119C94C2318E2  zero-cloud-core-implementation-coverage.md
976AAD5A86787A1D5033347D99A0E7EA6EB4E4A776326C42DC21806CC28BB8EF  zero-cloud-core-methodology-invariants.md
28CC5103265E38AA47E08DED132AD27D0D9015D36653AD4881CFC9DB3549EF3B  zero-cloud-core-scope-boundary.md
48A8BB8FFE4F44A6ACBE1F6E5A70F63EC2587407A900F13705E444A8578A21C2  zero-cloud-core-versioning-and-governance.md
361D9558CB51610C0CF8F15AE0B5486D530716433218D7DC7696D42B8D9806E4  zero-cloud-dual-licensing.md
63C5407A0C7583CF6502D86E3AE9A8ED712E776FFAE184C1EE82B3A46A64FB57  zero-cloud-hardware-reference-architecture.md
```

## Release Hash-Chain Integrity
To maintain a cryptographically linked release history, this manifest explicitly anchors to the cryptographic state of the previous major release:

* **Previous Release Version:** v3.1.0
* **Previous Release Manifest SHA-256:** 1359c382dbfc0f0be201fb20d44e50d6f3e5362ffcd489bc8be10e53f162400e

Any future release MUST embed the SHA-256 hash of *this* specific ZERO-CLOUD-RELEASE-MANIFEST.md document to continue the chain.