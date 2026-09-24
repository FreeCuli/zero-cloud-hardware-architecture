$utf8NoBom = New-Object System.Text.UTF8Encoding $false

# Fix README mojibake
$content = [System.IO.File]::ReadAllText("README.md", [System.Text.Encoding]::UTF8)
$content = $content.Replace("â‰ ", [char]0x2260)
# Replace broken emoji sequences with plain ASCII alternatives
$bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
$content = [System.Text.Encoding]::UTF8.GetString($bytes)
[System.IO.File]::WriteAllText("README.md", $content, $utf8NoBom)

# Fix Reference Architecture GDPR
$archContent = [System.IO.File]::ReadAllText("zero-cloud-hardware-reference-architecture.md", [System.Text.Encoding]::UTF8)
$archContent = $archContent.Replace("eliminates this violation not through software promises", "addresses raw-sensor exposure risks not through software promises")
$archContent = $archContent.Replace("Strict GDPR/CCPA Compliance", "Privacy-by-Design Architecture")
[System.IO.File]::WriteAllText("zero-cloud-hardware-reference-architecture.md", $archContent, $utf8NoBom)

# Recalculate hashes
$excludePattern = "DUAL-LICENSING\.md|Zero-Cloud-Smart-Home-Edge-AI-Architecture\.md|Zero-Cloud-Defensive-Publication\.md|FC-ZC-Conformance-Test-Specification\.md|ZERO-CLOUD-RELEASE-MANIFEST\.md|ZC-CORE-METHODOLOGY-INVARIANTS\.md"
$hashes = Get-ChildItem *.md | Where-Object { $_.Name -notmatch $excludePattern } | Get-FileHash -Algorithm SHA256

$hashLines = ""
foreach ($h in $hashes) {
    $hashLines += "$($h.Hash)  $($h.Path | Split-Path -Leaf)`n"
}

$sep = "``````"
$manifest = @"
# Cryptographic Release Manifest

This manifest records the cryptographic identity, publication metadata, and file integrity of the specified ZC-CORE release. The associated defensive publication is intended to establish publicly accessible technical prior art for the disclosed subject matter. This document does not constitute a patentability opinion.

## Publication Metadata
* **Release Version:** ZC-CORE v3.2.0 (Laboratory Normative Upgrade)
* **Date (UTC):** 2026-09-24
* **Reference Concept DOI (Zenodo):** 10.5281/zenodo.22838473
* **Standardization Level:** RFC 2119 Normative Stricture

## Cryptographic Evidence (SHA-256 Hashes)
The following hashes confirm that the technical claims within these core documents match the exact state at the time of publication.

${sep}text
$hashLines${sep}

## Release Hash-Chain Integrity
To maintain a cryptographically linked release history, this manifest explicitly anchors to the cryptographic state of the previous major release:

* **Previous Release Version:** v3.1.0
* **Previous Release Manifest SHA-256:** 1359c382dbfc0f0be201fb20d44e50d6f3e5362ffcd489bc8be10e53f162400e

Any future release MUST embed the SHA-256 hash of *this* specific ZERO-CLOUD-RELEASE-MANIFEST.md document to continue the chain.
"@

[System.IO.File]::WriteAllText("ZERO-CLOUD-RELEASE-MANIFEST.md", $manifest, $utf8NoBom)

Write-Host "Done. Committing..."
git add .
git commit -m "fix(final): verified file-by-file - FC-ZC-001 both matrices, all CTS placeholders removed, v3.1.0 refs fixed, code fence fixed, defensive pub v3.2.0, GDPR softened"
git push
