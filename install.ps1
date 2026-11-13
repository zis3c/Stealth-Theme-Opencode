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

$themeDir = Join-Path $ConfigDir 'themes'
New-Item -ItemType Directory -Force -Path $themeDir | Out-Null

$source = Join-Path $PSScriptRoot 'themes\stealth.json'
$target = Join-Path $themeDir 'stealth.json'
Copy-Item -Force -LiteralPath $source -Destination $target

$tui = Join-Path $ConfigDir 'tui.json'
$obj = $null
if (Test-Path -LiteralPath $tui) {
  try {
    $obj = Get-Content -Raw -LiteralPath $tui | ConvertFrom-Json
  } catch {
    $obj = $null
  }
}

if ($null -eq $obj -or $obj -is [System.Array] -or $obj -isnot [pscustomobject]) {
  $obj = [pscustomobject]@{}
}

if (-not $obj.PSObject.Properties['$schema']) {
  $obj | Add-Member -NotePropertyName '$schema' -NotePropertyValue 'https://opencode.ai/tui.json'
}
$obj | Add-Member -NotePropertyName 'theme' -NotePropertyValue 'stealth' -Force

$json = $obj | ConvertTo-Json -Depth 32
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($tui, $json + [Environment]::NewLine, $utf8NoBom)

Write-Host "Installed stealth theme to $target"
Write-Host "Active theme set in $tui"
Write-Host "Restart opencode to apply."
