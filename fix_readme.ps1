$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$text = [System.IO.File]::ReadAllText('README.md', [System.Text.Encoding]::UTF8)

# Replace the specific garbled strings with their correct emojis/chars
$text = $text -replace 'ğŸ —ï¸ ', '🏗️'
$text = $text -replace '🛡️ï¸ ', '🛡️'
$text = $text -replace 'ğŸ”¬', '🔬'
$text = $text -replace 'âš”ï¸ ', '⚔️'
$text = $text -replace 'ğŸ ›ï¸ ', '🏛️'
$text = $text -replace 'FreeCuli Certifiedâ„¢', 'FreeCuli Certified™'

[System.IO.File]::WriteAllText('README.md', $text, $utf8NoBom)
Write-Host "README fixed"
