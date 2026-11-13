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

$themeDir = Join-Path $ConfigDir 'themes'
New-Item -ItemType Directory -Force -Path $themeDir | Out-Null

$source = Join-Path $PSScriptRoot "themes\$theme.json"
if (-not (Test-Path -LiteralPath $source)) {
  throw "Theme file not found: $source"
}
$target = Join-Path $themeDir "$theme.json"
Copy-Item -Force -LiteralPath $source -Destination $target

$tui = Join-Path $ConfigDir 'tui.json'
$cli = Join-Path $ConfigDir 'cli.json'

# Use v2 when requested, or when a v2 cli.json exists and tui.json does not.
if (-not $V2 -and (Test-Path -LiteralPath $cli) -and -not (Test-Path -LiteralPath $tui)) {
  $V2 = $true
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-JsonObject {
  param([string]$Path)
  if (Test-Path -LiteralPath $Path) {
    try {
      $obj = Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json
      if ($obj -is [pscustomobject]) { return $obj }
    } catch {
      return [pscustomobject]@{}
    }
  }
  return [pscustomobject]@{}
}

function Write-JsonObject {
  param([string]$Path, $Object)
  $json = $Object | ConvertTo-Json -Depth 32
  [System.IO.File]::WriteAllText($Path, $json + [Environment]::NewLine, $utf8NoBom)
}

if ($V2) {
  $obj = Read-JsonObject -Path $cli
  if (-not $obj.PSObject.Properties['$schema']) {
    $obj | Add-Member -NotePropertyName '$schema' -NotePropertyValue 'https://opencode.ai/v2/cli.json'
  }
  $mode = 'system'
  if ($obj.theme -is [pscustomobject] -and $obj.theme.mode -in @('system', 'dark', 'light')) {
    $mode = $obj.theme.mode
  }
  $obj | Add-Member -NotePropertyName 'theme' -NotePropertyValue ([pscustomobject]@{ name = $theme; mode = $mode }) -Force
  Write-JsonObject -Path $cli -Object $obj
  $configFile = $cli
} else {
  $obj = Read-JsonObject -Path $tui
  if (-not $obj.PSObject.Properties['$schema']) {
    $obj | Add-Member -NotePropertyName '$schema' -NotePropertyValue 'https://opencode.ai/tui.json'
  }
  $obj | Add-Member -NotePropertyName 'theme' -NotePropertyValue $theme -Force
  Write-JsonObject -Path $tui -Object $obj
  $configFile = $tui
}

Write-Host "Installed $theme theme to $target"
Write-Host "Active theme set in $configFile"
Write-Host "Restart opencode to apply."
