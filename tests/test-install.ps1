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

try {
  # --- Case 1: existing tui.json keeps unrelated settings ---------------
  $case1 = Join-Path $Tmp 'case1'
  New-Item -ItemType Directory -Path $case1 | Out-Null
  $tui1 = Join-Path $case1 'tui.json'
  $initial = '{"$schema":"https://opencode.ai/tui.json","theme":"opencode","keybinds":{"leader":"ctrl+x"}}'
  [System.IO.File]::WriteAllText($tui1, $initial, $utf8NoBom)

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

  Write-Host 'PowerShell installer tests passed'
} finally {
  Remove-Item Env:\OPENCODE_CONFIG_DIR -ErrorAction SilentlyContinue
  if (Test-Path -LiteralPath $Tmp) {
    Remove-Item -Recurse -Force -LiteralPath $Tmp -ErrorAction SilentlyContinue
  }
}
