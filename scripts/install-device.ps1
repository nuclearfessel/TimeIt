# Install or update Timed on a connected device (Android via adb; iOS via libimobiledevice when present).
# Usage:
#   .\scripts\install-device.ps1
#   .\scripts\install-device.ps1 -Apk path\to\app-release.apk
#   .\scripts\install-device.ps1 -Ipa path\to\Timed.ipa
# If Timed is already installed, the package is updated in place. Otherwise it installs fresh.

[CmdletBinding()]
param(
  [string]$Apk = "",
  [string]$Ipa = "",
  [string]$AndroidPackage = "com.nuclearfessel.timed",
  [string]$IosBundleId = "com.nuclearfessel.timed"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

function Find-Adb {
  $fromPath = Get-Command adb -ErrorAction SilentlyContinue
  if ($fromPath) { return $fromPath.Source }
  $local = Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe"
  if (Test-Path $local) { return $local }
  return $null
}

function Resolve-Apk([string]$explicit) {
  if ($explicit) {
    if (-not (Test-Path $explicit)) { throw "APK not found: $explicit" }
    return (Resolve-Path $explicit).Path
  }
  $candidates = @(
    (Join-Path $root "app\build\app\outputs\flutter-apk\app-release.apk"),
    (Join-Path $root "app\build\app\outputs\flutter-apk\app-debug.apk")
  )
  foreach ($c in $candidates) {
    if (Test-Path $c) { return (Resolve-Path $c).Path }
  }
  throw "No APK found. Build one (flutter build apk) or pass -Apk."
}

function Install-Android([string]$apkPath) {
  $adb = Find-Adb
  if (-not $adb) { throw "adb not found. Install Android platform-tools or add adb to PATH." }

  $devices = & $adb devices | Select-Object -Skip 1 | Where-Object { $_ -match "\tdevice$" }
  if (-not $devices) { throw "No Android device/emulator online (adb devices)." }

  $pathOut = & $adb shell pm path $AndroidPackage 2>$null
  $already = ($LASTEXITCODE -eq 0) -and ($pathOut -match "package:")
  $action = if ($already) { "update" } else { "install" }
  Write-Host "Android: Timed is $(if ($already) { 'already installed — updating' } else { 'not installed — installing' })."
  Write-Host "Using $apkPath"

  # -r replaces/updates an existing install; also works as a fresh install.
  & $adb install -r $apkPath
  if ($LASTEXITCODE -ne 0) { throw "adb install failed (exit $LASTEXITCODE)." }
  Write-Host "Android $action complete for $AndroidPackage."
}

function Install-Ios([string]$ipaPath) {
  if (-not $ipaPath) {
    Write-Host "iOS: pass -Ipa path\to\Timed.ipa on a Mac with a signed package (or use Xcode / Apple Configurator)."
    return
  }
  if (-not (Test-Path $ipaPath)) { throw "IPA not found: $ipaPath" }

  $ideviceinstaller = Get-Command ideviceinstaller -ErrorAction SilentlyContinue
  if (-not $ideviceinstaller) {
    throw "ideviceinstaller not found. On macOS: brew install libimobiledevice, or install the IPA with Xcode (Product > Run / Devices window). Same bundle id updates in place."
  }

  $list = & ideviceinstaller list 2>$null
  $already = ($list -match [regex]::Escape($IosBundleId))
  $action = if ($already) { "update" } else { "install" }
  Write-Host "iOS: Timed is $(if ($already) { 'already installed — updating' } else { 'not installed — installing' })."
  Write-Host "Using $ipaPath"
  & ideviceinstaller -i $ipaPath
  if ($LASTEXITCODE -ne 0) { throw "ideviceinstaller failed (exit $LASTEXITCODE)." }
  Write-Host "iOS $action complete for $IosBundleId."
}

$did = $false
$adb = Find-Adb
if ($adb) {
  $androidOnline = & $adb devices | Select-Object -Skip 1 | Where-Object { $_ -match "\tdevice$" }
  if ($androidOnline) {
    Install-Android (Resolve-Apk $Apk)
    $did = $true
  }
}

if ($Ipa -or -not $did) {
  if ($Ipa) {
    Install-Ios $Ipa
    $did = $true
  }
}

if (-not $did) {
  Write-Host @"
No device install ran.
- Android: connect a device/emulator, build an APK, then re-run this script (or pass -Apk).
- iOS: on a Mac, pass -Ipa path\to\Timed.ipa (same bundle id updates an existing install).
"@
  exit 1
}
