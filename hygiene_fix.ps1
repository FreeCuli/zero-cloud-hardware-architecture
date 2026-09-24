$utf8NoBom = New-Object System.Text.UTF8Encoding $false

# Fix README mojibake characters
$readmePath = Join-Path (Get-Location) "README.md"
$content = [System.IO.File]::ReadAllText($readmePath, [System.Text.Encoding]::UTF8)

# Replace all known mojibake sequences with correct UTF-8
$content = $content -replace 'â‰ ', '≠'
$content = $content -replace 'ğŸ—ï¸', '🏗️'
$content = $content -replace 'ğŸ›¡ï¸', '🛡️'
$content = $content -replace 'ğŸ"¬', '🔬'
$content = $content -replace 'âš"ï¸', '⚔️'
$content = $content -replace 'ğŸ›ï¸', '🏛️'
$content = $content -replace 'ğŸ›¡ï¸', '🛡️'

[System.IO.File]::WriteAllText($readmePath, $content, $utf8NoBom)

# Fix Dual Licensing mojibake
$dualPath = Join-Path (Get-Location) "zero-cloud-dual-licensing.md"
$dualContent = [System.IO.File]::ReadAllText($dualPath, [System.Text.Encoding]::UTF8)
$dualContent = $dualContent -replace 'â€"', '—'
$dualContent = $dualContent -replace 'ğŸ"§', '📧'
[System.IO.File]::WriteAllText($dualPath, $dualContent, $utf8NoBom)

# Recalculate Manifest hashes
$excludePattern = "DUAL-LICENSING\.md|Zero-Cloud-Smart-Home-Edge-AI-Architecture\.md|Zero-Cloud-Defensive-Publication\.md|FC-ZC-Conformance-Test-Specification\.md|ZERO-CLOUD-RELEASE-MANIFEST\.md|ZC-CORE-METHODOLOGY-INVARIANTS\.md"
$hashes = Get-ChildItem *.md | Where-Object { $_.Name -notmatch $excludePattern } | Get-FileHash -Algorithm SHA256

$hashLines = ""
foreach ($h in $hashes) {
    $hashLines += "$($h.Hash)  $($h.Path | Split-Path -Leaf)`n"
}

$sep3 = '```'
$manifest = @"
# Cryptographic Release Manifest

This manifest records the cryptographic identity, publication metadata, and file integrity of the specified ZC-CORE release. The associated defensive publication is intended to establish publicly accessible technical prior art for the disclosed subject matter. This document does not constitute a patentability opinion.

## Publication Metadata
* **Release Version:** ZC-CORE v3.2.0 (Laboratory Normative Upgrade)
* **Date (UTC):** 2026-09-24
* **Reference Concept DOI (Zenodo):** 10.5281/zenodo.22838473
* **Standardization Level:** RFC 2119 Normative Stricture

## Cryptographic Evidence (SHA-256 Hashes)
The following hashes cover all canonical v3.2.0 normative and supporting documents listed in this manifest.

${sep3}text
$hashLines${sep3}

## Release Hash-Chain Integrity
To maintain a cryptographically linked release history, this manifest explicitly anchors to the cryptographic state of the previous major release:

* **Previous Release Version:** v3.1.0
* **Previous Release Manifest SHA-256:** 1359c382dbfc0f0be201fb20d44e50d6f3e5362ffcd489bc8be10e53f162400e

Any future release MUST embed the SHA-256 hash of *this* specific ZERO-CLOUD-RELEASE-MANIFEST.md document to continue the chain.
"@

$manifestPath = Join-Path (Get-Location) "ZERO-CLOUD-RELEASE-MANIFEST.md"
[System.IO.File]::WriteAllText($manifestPath, $manifest, $utf8NoBom)

Write-Host "Verifying README line 21:"
$readmeLines = Get-Content "README.md"
Write-Host $readmeLines[20]

Write-Host "Verifying Manifest code fence:"
$manifestLines = Get-Content "ZERO-CLOUD-RELEASE-MANIFEST.md"
Write-Host $manifestLines[13]

git add .
git commit -m "fix(release-hygiene): TVLA PASS/FAIL unambiguous, Bonferroni formula with m definition, MI k-NN estimator spec, Governance threshold-change rule, README mojibake and scope wording"
git push
