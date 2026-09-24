$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$archPath = 'zero-cloud-hardware-reference-architecture.md'
$text = [System.IO.File]::ReadAllText($archPath, [System.Text.Encoding]::UTF8)

$text = $text -replace 'Hardware Interrupt', 'Hardware Power-Cut Trigger'
$text = $text -replace 'Indestructible Fortress', 'Hardware-Enforced Fortress'
$text = $text -replace 'Lethal Volatile Buffer', 'Strict Volatile Buffer'
$text = $text -replace 'Absolute Physical Air-Gap', 'Strict Physical Air-Gap'
$text = $text -replace 'Poisoned Sensor', 'Compromised Sensor'
$text = $text -replace 'Mathematically Verifiable', 'Empirically Verifiable'

[System.IO.File]::WriteAllText($archPath, $text, $utf8NoBom)

$icPath = 'zero-cloud-core-implementation-coverage.md'
$text = [System.IO.File]::ReadAllText($icPath, [System.Text.Encoding]::UTF8)
$text = $text -replace 'Hardware Firewalls', 'Hardware-Enforced Isolation'
[System.IO.File]::WriteAllText($icPath, $text, $utf8NoBom)

Write-Host 'Architecture terminology updated'
