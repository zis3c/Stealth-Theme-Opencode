#Requires -Version 5.1
# Tests for install.ps1 / uninstall.ps1 on Windows PowerShell.
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSScriptRoot
$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("stealth-test-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $Tmp | Out-Null

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Assert-True {
  param([bool]$Condition, [string]$Message)
  if (-not $Condition) { throw "FAIL: $Message" }
}

function Write-Text {
  param([string]$Path, [string]$Text)
  [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}

try {
  # --- Case 1: existing tui.json keeps unrelated settings ---------------
  $case1 = Join-Path $Tmp 'case1'
  New-Item -ItemType Directory -Path $case1 | Out-Null
  $tui1 = Join-Path $case1 'tui.json'
  Write-Text $tui1 '{"$schema":"https://opencode.ai/tui.json","theme":"opencode","keybinds":{"leader":"ctrl+x"}}'

  $env:OPENCODE_CONFIG_DIR = $case1
  & (Join-Path $Root 'install.ps1')

  $themePath = Join-Path $case1 'themes\stealth.json'
  Assert-True (Test-Path -LiteralPath $themePath) 'theme not installed'
  $obj = Get-Content -Raw -LiteralPath $tui1 | ConvertFrom-Json
  Assert-True ($obj.theme -eq 'stealth') "theme not set (got $($obj.theme))"
  Assert-True ($obj.keybinds.leader -eq 'ctrl+x') 'keybinds not preserved'

  & (Join-Path $Root 'uninstall.ps1')
  Assert-True (-not (Test-Path -LiteralPath $themePath)) 'theme not removed'
  $obj = Get-Content -Raw -LiteralPath $tui1 | ConvertFrom-Json
  Assert-True ($obj.theme -eq 'opencode') "default theme not restored (got $($obj.theme))"
  Assert-True ($obj.keybinds.leader -eq 'ctrl+x') 'keybinds not preserved after uninstall'

  # --- Case 2: fresh config directory -----------------------------------
  $case2 = Join-Path $Tmp 'case2'
  New-Item -ItemType Directory -Path $case2 | Out-Null
  $env:OPENCODE_CONFIG_DIR = $case2
  & (Join-Path $Root 'install.ps1')

  Assert-True (Test-Path -LiteralPath (Join-Path $case2 'themes\stealth.json')) 'theme not installed (fresh)'
  $tui2 = Join-Path $case2 'tui.json'
  Assert-True (Test-Path -LiteralPath $tui2) 'tui.json not created (fresh)'
  $obj = Get-Content -Raw -LiteralPath $tui2 | ConvertFrom-Json
  Assert-True ($obj.theme -eq 'stealth') "theme not set (fresh, got $($obj.theme))"
  Assert-True ($obj.'$schema' -eq 'https://opencode.ai/tui.json') 'schema not set (fresh)'

  # --- Case 3: variant theme --------------------------------------------
  $case3 = Join-Path $Tmp 'case3'
  New-Item -ItemType Directory -Path $case3 | Out-Null
  $env:OPENCODE_CONFIG_DIR = $case3
  & (Join-Path $Root 'install.ps1') -Variant amber
  Assert-True (Test-Path -LiteralPath (Join-Path $case3 'themes\stealth-amber.json')) 'amber variant not installed'
  $obj = Get-Content -Raw -LiteralPath (Join-Path $case3 'tui.json') | ConvertFrom-Json
  Assert-True ($obj.theme -eq 'stealth-amber') "variant theme not set (got $($obj.theme))"
  & (Join-Path $Root 'uninstall.ps1') -Variant amber
  Assert-True (-not (Test-Path -LiteralPath (Join-Path $case3 'themes\stealth-amber.json'))) 'amber variant not removed'

  # --- Case 4: v2 cli.json auto-detection -------------------------------
  $case4 = Join-Path $Tmp 'case4'
  New-Item -ItemType Directory -Path $case4 | Out-Null
  $cli4 = Join-Path $case4 'cli.json'
  Write-Text $cli4 '{"$schema":"https://opencode.ai/v2/cli.json","model":"x","theme":{"name":"opencode","mode":"dark"}}'
  $env:OPENCODE_CONFIG_DIR = $case4
  & (Join-Path $Root 'install.ps1')
  Assert-True (-not (Test-Path -LiteralPath (Join-Path $case4 'tui.json'))) 'tui.json should not be created in v2 mode'
  $obj = Get-Content -Raw -LiteralPath $cli4 | ConvertFrom-Json
  Assert-True ($obj.theme.name -eq 'stealth') "v2 theme not set (got $($obj.theme.name))"
  Assert-True ($obj.theme.mode -eq 'dark') "v2 mode not preserved (got $($obj.theme.mode))"
  Assert-True ($obj.model -eq 'x') 'v2 unrelated key not preserved'
  & (Join-Path $Root 'uninstall.ps1')
  $obj = Get-Content -Raw -LiteralPath $cli4 | ConvertFrom-Json
  Assert-True ($obj.theme.name -eq 'opencode') "v2 default not restored (got $($obj.theme.name))"
  Assert-True ($obj.theme.mode -eq 'dark') 'v2 mode not preserved after uninstall'

  # --- Case 5: explicit v2 on a fresh directory -------------------------
  $case5 = Join-Path $Tmp 'case5'
  New-Item -ItemType Directory -Path $case5 | Out-Null
  $env:OPENCODE_CONFIG_DIR = $case5
  & (Join-Path $Root 'install.ps1') -V2 -Variant green
  Assert-True (Test-Path -LiteralPath (Join-Path $case5 'themes\stealth-green.json')) 'green variant not installed (v2)'
  $obj = Get-Content -Raw -LiteralPath (Join-Path $case5 'cli.json') | ConvertFrom-Json
  Assert-True ($obj.theme.name -eq 'stealth-green') "v2 variant not set (got $($obj.theme.name))"
  Assert-True ($obj.theme.mode -eq 'system') "v2 default mode wrong (got $($obj.theme.mode))"
  & (Join-Path $Root 'uninstall.ps1') -V2 -Variant green
  Assert-True (-not (Test-Path -LiteralPath (Join-Path $case5 'themes\stealth-green.json'))) 'green variant not removed (v2)'

  Write-Host 'PowerShell installer tests passed'
} finally {
  Remove-Item Env:\OPENCODE_CONFIG_DIR -ErrorAction SilentlyContinue
  if (Test-Path -LiteralPath $Tmp) {
    Remove-Item -Recurse -Force -LiteralPath $Tmp -ErrorAction SilentlyContinue
  }
}
