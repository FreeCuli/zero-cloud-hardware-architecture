$utf8NoBom = New-Object System.Text.UTF8Encoding $false
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
