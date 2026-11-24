param(
  [ValidateSet("release", "patch")]
  [string]$Mode = "patch",
  [string]$Flavor = "store",
  [string]$ReleaseVersion = "",
  [string]$FlutterVersion = ""
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command shorebird -ErrorAction SilentlyContinue)) {
  Write-Host "Shorebird CLI belum terpasang. Pasang sekali dengan:" -ForegroundColor Yellow
  Write-Host "  Set-ExecutionPolicy RemoteSigned -scope CurrentUser" -ForegroundColor Cyan
  Write-Host "  iwr -UseBasicParsing 'https://raw.githubusercontent.com/shorebirdtech/install/main/install.ps1' | iex" -ForegroundColor Cyan
  exit 1
}

Push-Location (Join-Path $PSScriptRoot "..")
try {
  if (-not (Test-Path "shorebird.yaml")) {
    Write-Host "shorebird.yaml belum ada. Menjalankan 'shorebird init'..." -ForegroundColor Yellow
    shorebird init
  }

  if ($Mode -eq "release") {
    Write-Host "Membangun rilis dasar Shorebird (flavor=$Flavor) yang mendukung Delta OTA..." -ForegroundColor Green
    if ($FlutterVersion -ne "") {
      shorebird release android --flavor $Flavor --artifact apk --flutter-version=$FlutterVersion
    } else {
      shorebird release android --flavor $Flavor --artifact apk
    }
  } else {
    Write-Host "Menerbitkan Delta OTA Patch (~1-5 MB, tanpa install ulang) untuk flavor=$Flavor..." -ForegroundColor Green
    if ($ReleaseVersion -ne "") {
      shorebird patch android --flavor $Flavor --release-version $ReleaseVersion
    } else {
      shorebird patch android --flavor $Flavor
    }
  }
} finally {
  Pop-Location
}
