#Requires -Version 5.1
[CmdletBinding()]
param(
  [ValidateSet('gray', 'amber', 'green')]
  [string]$Variant = 'gray',
  [switch]$V2,
  [string]$ConfigDir = $env:OPENCODE_CONFIG_DIR
)

$ErrorActionPreference = 'Stop'

if (-not $ConfigDir) {
  $base = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME '.config' }
  $ConfigDir = Join-Path $base 'opencode'
}

$theme = if ($Variant -eq 'gray') { 'stealth' } else { "stealth-$Variant" }
if ($env:OPENCODE_V2 -eq '1') { $V2 = $true }

$themeFile = Join-Path $ConfigDir "themes\$theme.json"
$tui = Join-Path $ConfigDir 'tui.json'
$cli = Join-Path $ConfigDir 'cli.json'

if (Test-Path -LiteralPath $themeFile) {
  Remove-Item -Force -LiteralPath $themeFile
  Write-Host "Removed $themeFile"
} else {
  Write-Host "Theme not installed at $themeFile"
}

if (-not $V2 -and (Test-Path -LiteralPath $cli) -and -not (Test-Path -LiteralPath $tui)) {
  $V2 = $true
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Restore-Theme {
  param([string]$Path, [bool]$IsV2)
  if (-not (Test-Path -LiteralPath $Path)) { return }
  try {
    $obj = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
    if ($obj -isnot [pscustomobject]) { return }
    if ($IsV2) {
      $name = if ($obj.theme -is [pscustomobject]) { $obj.theme.name } else { $obj.theme }
      if ($name -eq $theme) {
        $mode = if ($obj.theme -is [pscustomobject] -and $obj.theme.mode) { $obj.theme.mode } else { 'system' }
        $obj | Add-Member -NotePropertyName 'theme' -NotePropertyValue ([pscustomobject]@{ name = 'opencode'; mode = $mode }) -Force
        $json = $obj | ConvertTo-Json -Depth 32
        [System.IO.File]::WriteAllText($Path, $json + [Environment]::NewLine, $utf8NoBom)
        Write-Host "Restored default theme in $Path"
      }
    } else {
      if ($obj.theme -eq $theme) {
        $obj | Add-Member -NotePropertyName 'theme' -NotePropertyValue 'opencode' -Force
        $json = $obj | ConvertTo-Json -Depth 32
        [System.IO.File]::WriteAllText($Path, $json + [Environment]::NewLine, $utf8NoBom)
        Write-Host "Restored default theme in $Path"
      }
    }
  } catch {
    Write-Host "Could not update $Path; set the theme to opencode manually."
  }
}

if ($V2) {
  Restore-Theme -Path $cli -IsV2 $true
} else {
  Restore-Theme -Path $tui -IsV2 $false
}

Write-Host "Restart opencode to apply."
