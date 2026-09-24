$utf8NoBom = New-Object System.Text.UTF8Encoding $false

# 1. Update CTS
$cts = 'zero-cloud-core-conformance-test-specification.md'
$text = [System.IO.File]::ReadAllText($cts, [System.Text.Encoding]::UTF8)

# ISO 17065/17025
$text = $text -replace 'certified to withstand invasive physical attacks following ISO/IEC 17065-accredited procedures', 'evaluated to pass the defined invasive physical assessment under the declared attack capability and evaluation scope following ISO/IEC 17025-accredited testing procedures (with certification/conformity assessment performed under an applicable ISO/IEC 17065 scheme where required)'
$text = $text -replace 'certified to mitigate fault injection attempts following ISO/IEC 17065-accredited procedures', 'evaluated to pass the defined fault injection assessment under the declared attack capability and evaluation scope following ISO/IEC 17025-accredited testing procedures (with certification/conformity assessment performed under an applicable ISO/IEC 17065 scheme where required)'

# CRA
$text = $text -replace 'evidence relevant to selected cybersecurity requirements under the EU Cyber Resilience Act \(CRA\)', 'evidence relevant to selected cybersecurity considerations; it does not constitute formal EU Cyber Resilience Act (CRA) conformity assessment or legal compliance'

# i.i.d.
$text = $text -replace 'N = 1,000,000 independent, identically distributed \(i.i.d.\) Edge AI inference executions\.', 'N = 1,000,000 independent, identically distributed (i.i.d.) Edge AI inference executions. The i.i.d. requirement SHALL be operationally met via randomized acquisition order, environmental temperature control, and stable power-supply calibration.'

# Key Storage
$text = $text -replace 'OTP/eFuse or Hardware Security Modules', 'hardware-protected key storage meeting the defined security property (e.g., OTP/eFuse, HSM, or Secure Enclave)'

# FC-ZC-010 MI link and mojibake
$text = $text -replace 'overrideâ€”even', 'override-even'
$text = $text -replace '\* \*\*Forbidden Bypass:\*\*', "* **Execution:** This test MUST explicitly invoke the Annex B Mutual Information (MI) protocol to empirically prove the MI bound.`n* **Forbidden Bypass:**"

[System.IO.File]::WriteAllText($cts, $text, $utf8NoBom)


# 2. Update Evidence Matrix
$ev = 'zero-cloud-core-conformance-evidence-matrix.md'
$text = [System.IO.File]::ReadAllText($ev, [System.Text.Encoding]::UTF8)
$text = $text -replace 'ISO/IEC 17065 Certification', 'ISO/IEC 17065 Scheme / 17025 Testing'
[System.IO.File]::WriteAllText($ev, $text, $utf8NoBom)


# 3. Update Brand Policy
$brand = 'zero-cloud-core-brand-and-trademark-policy.md'
$text = [System.IO.File]::ReadAllText($brand, [System.Text.Encoding]::UTF8)
$roleText = "
> **Note on Certification Role:** FreeCuli acts solely as the Standard Owner and Certification Scheme Owner. FreeCuli is NOT an ISO/IEC 17065 certification body itself. Final certification requires independent test reports from ISO/IEC 17025 accredited laboratories.
"
$text = $text -replace '### 4. FreeCuli Certified', "$roleText`n### 4. FreeCuli Certified"
[System.IO.File]::WriteAllText($brand, $text, $utf8NoBom)


# 4. Update Dual Licensing (Legal soften)
$dual = 'zero-cloud-dual-licensing.md'
$text = [System.IO.File]::ReadAllText($dual, [System.Text.Encoding]::UTF8)

$text = $text -replace 'License Contamination Shield', 'Commercial Intellectual Property Exemption'
$text = $text -replace 'acts as a waiver, removing the copyleft obligations', 'grants permissions expressly defined by FreeCuli for the FreeCuli-controlled materials, exempting them from the standard copyleft obligations'

$text = $text -replace 'is \*\*immediately subject to strict worldwide revocation under applicable license terms\*\*', 'is **subject to worldwide revocation under applicable license terms** (Subject to valid legal claims, applicable law, and specifically applying to FreeCuli-controlled IP)'

[System.IO.File]::WriteAllText($dual, $text, $utf8NoBom)


# 5. Manifest Hashing
$excludePattern = 'DUAL-LICENSING\.md|Zero-Cloud-Smart-Home-Edge-AI-Architecture\.md|Zero-Cloud-Defensive-Publication\.md|FC-ZC-Conformance-Test-Specification\.md|ZERO-CLOUD-RELEASE-MANIFEST\.md|ZC-CORE-METHODOLOGY-INVARIANTS\.md'
$hashes = Get-ChildItem *.md | Where-Object { $_.Name -notmatch $excludePattern } | Get-FileHash -Algorithm SHA256
$hashText = ''
foreach ($h in $hashes) { $hashText += $h.Hash + '  ' + ($h.Path | Split-Path -Leaf) + "`n" }

$manifestPath = 'ZERO-CLOUD-RELEASE-MANIFEST.md'
$manifestContent = [System.IO.File]::ReadAllText($manifestPath, [System.Text.Encoding]::UTF8)
$startIdx = $manifestContent.IndexOf('```text')
if ($startIdx -ge 0) {
    $endIdx = $manifestContent.IndexOf('```', $startIdx + 7)
    $newManifest = $manifestContent.Substring(0, $startIdx + 7) + "`n" + $hashText + $manifestContent.Substring($endIdx)
    [System.IO.File]::WriteAllText($manifestPath, $newManifest, $utf8NoBom)
}

Write-Host 'All updates done.'
