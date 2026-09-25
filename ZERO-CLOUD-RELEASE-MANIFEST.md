# Cryptographic Release Manifest

This manifest records the cryptographic identity, publication metadata, and file integrity of the specified ZC-CORE release. The associated defensive publication is intended to establish publicly accessible technical prior art for the disclosed subject matter. This document does not constitute a patentability opinion. Legacy pointer documents (and LICENSE) are intentionally excluded from the canonical release hash set because they contain no normative content.

## Publication Metadata
* **Release Version:** ZC-CORE v3.2.1 (Hardening Release)
* **Date (UTC):** 2026-09-24
* **Reference Concept DOI (Zenodo):** 10.5281/zenodo.22838473
* **Standardization Level:** RFC 2119 Normative Stricture
* **Repository:** FreeCuli/zero-cloud-hardware-architecture
* **Git Tag: v3.2.1**
* **Git Commit Resolution:** Resolves dynamically to the canonical tagged tree commit of `refs/tags/v3.2.1`
* **Release Artifact SHA-256:** *(to be computed and recorded upon generation of the immutable Zenodo archival tarball/zip using `sha256sum <zenodo_archive>`. This placeholder preserves cryptographic distinction between the Git tree state and the post-publication distribution artifact)*

## Cryptographic Evidence (SHA-256 Hashes)
The following hashes cover all canonical v3.2.1 normative and supporting documents listed in this manifest.

```text
A84067C69EDD08643DE9D37CA40DF642E8C7756E0182C02F1D4FFEFEF4C4131B  README.md
D2B25667917F4EAB9271FAC7B6DC2B472F86CCF5A8ECBA307B55D2C1D1EF7D42  ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md
D7843421814FF1C0AE4FB0EB251FE7E35A8A23B6D9FC4EAF0E8C95B2A464FDE0  zero-cloud-core-attack-taxonomy.md
7E6935D7444DAE47BF5F3D5BC82A5BBA3971A4765731E978BFF2F523F9009110  zero-cloud-core-brand-and-trademark-policy.md
38EA3D6542211A57FE89F9CFAF6A04A25ECE3468C57300C784DF4E6B2C9A7720  zero-cloud-core-conformance-evidence-matrix.md
FCBE0C7F434C69F5C40E48B356EA09637A793FFACFD0E2F3776BE6890E826144  zero-cloud-core-conformance-test-specification.md
0DDAF0FEDE4AB395C2A9DBC14B93B27ADA2D8BFB76B2B16008B65662D55D056D  ZC-CORE-HARDWARE-FORENSIC-AUDIT-PROTOCOL.md
09264F3719DAE0918F516BDEB128845AAC45E6B863B9BC5024E11A8F20DDD202  zero-cloud-core-defensive-publication.md
65BD3FF39A3A72058D6153EB9BF23E8DE04E7A9F681E07D79549C3E98AD7B9CD  zero-cloud-core-implementation-coverage.md
A8D70D625461C481B718BB7C731B382B28742AA06A677465A97C3E2554DDB8A2  zero-cloud-core-methodology-invariants.md
BDC02D1DCAEF3A99A9FC6C7F7482E98737C1402829EA0E4264CE1871CEC3C49E  zero-cloud-core-scope-boundary.md
D17191A6A3A6FCB2E411196D3000B818DECEB52DA0D39CD4FFA7D1BEF97CFF87  zero-cloud-core-versioning-and-governance.md
D8634F13B56892836D1AD3B6D04CF2A299182DF92C1862899E3AC17C8C925CC0  zero-cloud-dual-licensing.md
97780AE1577747523C238B151045EE3A5E5C7D085304E4CA45BC11F2940B1D4A  zero-cloud-hardware-reference-architecture.md
```

## Release Hash-Chain Integrity
To maintain a cryptographically linked release history, this manifest explicitly anchors to the cryptographic state of the previous major release:

* **Previous Release Version:** v3.1.0
* **Previous Release Manifest SHA-256:** 1359c382dbfc0f0be201fb20d44e50d6f3e5362ffcd489bc8be10e53f162400e

Any future release MUST embed the SHA-256 hash of *this* specific ZERO-CLOUD-RELEASE-MANIFEST.md document to continue the chain.