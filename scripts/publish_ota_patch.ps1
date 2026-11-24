param(
  [ValidateSet("release", "patch")]
  [string]$Mode = "patch",
  [string]$Flavor = "store",
  [string]$ReleaseVersion = "2.5.2+2010",
  [string]$FlutterVersion = "3.44.4"
)

$ErrorActionPreference = "Stop"

$shorebirdCmd = Get-Command shorebird -ErrorAction SilentlyContinue
$shorebirdBin = if ($shorebirdCmd) { $shorebirdCmd.Source } elseif (Test-Path "$env:USERPROFILE\.shorebird\bin\shorebird.bat") { "$env:USERPROFILE\.shorebird\bin\shorebird.bat" } else { $null }

if (-not $shorebirdBin) {
  Write-Host "Shorebird CLI belum terpasang. Pasang sekali dengan:" -ForegroundColor Yellow
  Write-Host "  Set-ExecutionPolicy RemoteSigned -scope CurrentUser" -ForegroundColor Cyan
  Write-Host "  iwr -UseBasicParsing 'https://raw.githubusercontent.com/shorebirdtech/install/main/install.ps1' | iex" -ForegroundColor Cyan
  exit 1
}

Push-Location (Join-Path $PSScriptRoot "..")
try {
  if (-not (Test-Path "shorebird.yaml")) {
    Write-Host "shorebird.yaml belum ada. Menjalankan 'shorebird init'..." -ForegroundColor Yellow
    & $shorebirdBin init
  }

  if ($Mode -eq "release") {
    Write-Host "Membangun rilis dasar Shorebird (flavor=$Flavor, flutter=$FlutterVersion) yang mendukung Delta OTA..." -ForegroundColor Green
    & $shorebirdBin release android --flavor $Flavor --artifact apk --target-platform android-arm64 --flutter-version=$FlutterVersion
  } else {
    Write-Host "Menerbitkan Delta OTA Patch (~1-5 MB, tanpa install ulang) untuk flavor=$Flavor release=$ReleaseVersion..." -ForegroundColor Green
    if ($ReleaseVersion -ne "") {
      & $shorebirdBin patch --platforms=android --flavor $Flavor --release-version $ReleaseVersion
    } else {
      & $shorebirdBin patch --platforms=android --flavor $Flavor --release-version=latest
    }
  }
} finally {
  Pop-Location
}
