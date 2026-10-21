# Cryptographic Release Manifest

This manifest records the cryptographic identity, publication metadata, and file integrity of the specified ZC-CORE release. The associated defensive publication is intended to establish publicly accessible technical prior art for the disclosed subject matter. This document does not constitute a patentability opinion. Legacy pointer documents (and LICENSE) are intentionally excluded from the canonical release hash set because they contain no normative content.

## Publication Metadata
* **Release Version:** ZC-CORE v3.3.0-rc2 (Gate 4 Blueprint)
* **Status:** Pending Experimental Validation (Gate 4 Laboratory Execution)
* **Date (UTC):** 2026-09-24
* **Reference Concept DOI (Zenodo):** 10.5281/zenodo.22838473
* **Standardization Level:** RFC 2119 Normative Stricture
* **Repository:** FreeCuli/zero-cloud-hardware-architecture
* **Git Tag: v3.3.0-rc2**
* **Git Commit Resolution:** Resolves dynamically to the canonical tagged tree commit of `refs/tags/v3.3.0-rc2`
* **Release Artifact SHA-256:** *(to be computed and recorded upon generation of the immutable Zenodo archival tarball/zip using `sha256sum <zenodo_archive>`. This placeholder preserves cryptographic distinction between the Git tree state and the post-publication distribution artifact)*

## Cryptographic Evidence (SHA-256 Hashes)
The following hashes cover all canonical v3.3.0-rc2 normative and supporting documents listed in this manifest.

```text
0B93BA82ECAD0DFB7249DF4F45C060E73A4A42AD138397F10BCFC62433C07B37  README.md
D2B25667917F4EAB9271FAC7B6DC2B472F86CCF5A8ECBA307B55D2C1D1EF7D42  ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md
2ADDF84840616C3CEB2C904783DDEF7C60DCE140D263F85C0EC7FB8640B70E1F  zero-cloud-core-attack-taxonomy.md
382781216E054D23C4D210253C1A257A68392E573872343A7B27176E2AB463CC  zero-cloud-core-brand-and-trademark-policy.md
D802CE524D475862395093BF99C602839358F6D262E51FFF6DF102831F8280CE  zero-cloud-core-conformance-evidence-matrix.md
1C04DA4983E8FE7DC08CCFCCD011B6554E0801E79359921D2CF8735B1D67EEAE  zero-cloud-core-conformance-test-specification.md
E6AAFD08BCDB3EAC72E5D01DC09FE5CC6122ED73B3CF3879AB6FFC8BECBD467C  ZC-CORE-HARDWARE-FORENSIC-AUDIT-PROTOCOL.md
F49D810ED57835E74B9D6F01CF722C6C51ED8818BC19D8E13457230CF5C9B020  zero-cloud-core-defensive-publication.md
B067716C2CDFEC0FABFDFAF81D5292938CFB9E972EF39125DBE20574BC61B534  zero-cloud-core-implementation-coverage.md
401F642E608689475FDFF06E5B268C1A69F3231B6A2CB072EF88686F26282E38  zero-cloud-core-methodology-invariants.md
5C7D8CAA5871AB2DF1737AC99D5F39157E7219720AF54FA66C3DF1509CCED602  zero-cloud-core-scope-boundary.md
F3D337342493DC7849D6AB1904A80861E2FC08A0DA826ADD2A82CEFC523FC965  zero-cloud-core-versioning-and-governance.md
87A57A2768B206CC254BB8BD6483AE71911E52F9945F6CE1C0D8CC2AE92D3BB1  zero-cloud-dual-licensing.md
13AABDE3FECCE41CE4078F1F3BEE14CCAA371B1489AB5530D8DE5FDA099CB97C  zero-cloud-hardware-reference-architecture.md
```

## Release Hash-Chain Integrity
To maintain a cryptographically linked release history, this manifest explicitly anchors to the cryptographic state of the previous major release:

* **Previous Release Version:** v3.1.0
* **Previous Release Manifest SHA-256:** 1359c382dbfc0f0be201fb20d44e50d6f3e5362ffcd489bc8be10e53f162400e

Any future release MUST embed the SHA-256 hash of *this* specific ZERO-CLOUD-RELEASE-MANIFEST.md document to continue the chain.