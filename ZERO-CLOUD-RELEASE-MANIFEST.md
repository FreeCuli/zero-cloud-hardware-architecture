# Cryptographic Release Manifest

This manifest records the cryptographic identity, publication metadata, and file integrity of the specified ZC-CORE release. The associated defensive publication is intended to establish publicly accessible technical prior art for the disclosed subject matter. This document does not constitute a patentability opinion. Legacy pointer documents (and LICENSE) are intentionally excluded from the canonical release hash set because they contain no normative content.

## Publication Metadata
* **Release Version:** ZC-CORE v3.3.0-rc3 (Gate 4 Blueprint)
* **Status:** Pending Experimental Validation (Gate 4 Laboratory Execution)
* **Date (UTC):** 2026-10-21
* **Reference Concept DOI (Zenodo):** 10.5281/zenodo.22838473
* **Standardization Level:** RFC 2119 Normative Stricture
* **Repository:** FreeCuli/zero-cloud-hardware-architecture
* **Git Tag: v3.3.0-rc3**
* **Git Commit Resolution:** Resolves dynamically to the canonical tagged tree commit of `refs/tags/v3.3.0-rc3`
* **Release Artifact SHA-256:** *(to be computed and recorded upon generation of the immutable Zenodo archival tarball/zip using `sha256sum <zenodo_archive>`. This placeholder preserves cryptographic distinction between the Git tree state and the post-publication distribution artifact)*

## Cryptographic Evidence (SHA-256 Hashes)

### Canonical Normative and Supporting Documents
The following hashes cover all canonical v3.3.0-rc3 normative and supporting documents listed in this manifest.

```text
7993A432FF4B8890F7485390C651719E7517E2628D0BACBEBECFE0F71D0BEEB8  README.md
D2B25667917F4EAB9271FAC7B6DC2B472F86CCF5A8ECBA307B55D2C1D1EF7D42  ZC-CORE-CONFORMANCE-EVIDENCE-PACKAGE.md
FF22F9B6189F0D19B60B6E811F700EA8BFA1413223ABF5584AAD4D01FCF48EC1  ZC-CORE-HARDWARE-FORENSIC-AUDIT-PROTOCOL.md
5F248F022F2A242D7D25EE66A6824687B215E7B029B49120A54820A665ABA599  zero-cloud-core-attack-taxonomy.md
51AE8738C4E5ECCC45F2E736151C59B8DDBBFC803F3DD344AEFAFD4537DAE3AA  zero-cloud-core-brand-and-trademark-policy.md
D100BD071B9ED8EEA1C7DC83B78DA4F3A57E65640BC37FF59B57FD53F855440E  zero-cloud-core-conformance-evidence-matrix.md
C4977A1E7B48F4FAC75F76FF60B13E4A71EF08E2D8C4D1AA6F3CC3864E4B6CCA  zero-cloud-core-conformance-test-specification.md
A00BB6F6BBE247038F0BC802C2E8D6E90B5D1FB08A4BC7C68F8511F5DC9467A5  zero-cloud-core-defensive-publication.md
D0B56132916A3020B15BEB337B0679F04426A779607B3EA6A9C5C30DAA69EC24  zero-cloud-core-implementation-coverage.md
D754C24885E0C35C9E8056DE588100952DD15E345E5A047BF70568CF92308F63  zero-cloud-core-methodology-invariants.md
ACA93657A8E79202DCB3E70F607E2065E20458826749DBD9D940626710E23A42  zero-cloud-core-scope-boundary.md
D944FF4D56359039DE3B2900D01F839223A86AB667BA5AF887D1672E53C85745  zero-cloud-core-versioning-and-governance.md
62F4ECEFCFBE4BB39ECC44F7E54E4EE43232F7B7EF2D1C3E0DB283FDA76A8F35  zero-cloud-dual-licensing.md
32E484339AE7F4096C3A079CD1C2A37D567A4D8C5538CE87656E04B32468C6DE  zero-cloud-hardware-reference-architecture.md
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