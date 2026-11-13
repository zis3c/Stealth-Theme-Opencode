#Requires -Version 5.1
[CmdletBinding()]
param(
  [string]$ConfigDir = $env:OPENCODE_CONFIG_DIR
)

$ErrorActionPreference = 'Stop'

if (-not $ConfigDir) {
  $base = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME '.config' }
  $ConfigDir = Join-Path $base 'opencode'
}

$themeFile = Join-Path $ConfigDir 'themes\stealth.json'
$tui = Join-Path $ConfigDir 'tui.json'

if (Test-Path -LiteralPath $themeFile) {
  Remove-Item -Force -LiteralPath $themeFile
  Write-Host "Removed $themeFile"
} else {
  Write-Host "Theme not installed at $themeFile"
}

if (Test-Path -LiteralPath $tui) {
  try {
    $obj = Get-Content -Raw -LiteralPath $tui | ConvertFrom-Json
    if ($obj -is [pscustomobject] -and $obj.theme -eq 'stealth') {
      $obj | Add-Member -NotePropertyName 'theme' -NotePropertyValue 'opencode' -Force
      $json = $obj | ConvertTo-Json -Depth 32
      $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
      [System.IO.File]::WriteAllText($tui, $json + [Environment]::NewLine, $utf8NoBom)
      Write-Host "Restored default theme in $tui"
    }
  } catch {
    Write-Host "Could not update $tui; set `"theme`": `"opencode`" manually."
  }
}

Write-Host "Restart opencode to apply."
