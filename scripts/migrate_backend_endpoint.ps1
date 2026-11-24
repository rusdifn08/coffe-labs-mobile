param(
  [Parameter(Mandatory = $true)]
  [string]$NewPrimaryUrl,
  [string]$FallbackUrl = "https://coffe-labs-backend-production.up.railway.app",
  [switch]$ForceSwitch,
  [switch]$SkipHealthCheck
)

$ErrorActionPreference = "Stop"

$cleanPrimary = $NewPrimaryUrl.Trim().TrimEnd('/')
$cleanFallback = $FallbackUrl.Trim().TrimEnd('/')

if (-not $cleanPrimary.StartsWith("https://")) {
  throw "NewPrimaryUrl wajib memakai HTTPS (contoh: https://api.vps-anda.com)."
}

if (-not $SkipHealthCheck) {
  Write-Host "Menguji kesehatan server baru: $cleanPrimary/api/health ..." -ForegroundColor Cyan
  $health = Invoke-RestMethod -Uri "$cleanPrimary/api/health" -TimeoutSec 10
  if ($health.status -ne "ok" -or -not ($health.app -match "Coffee Labs")) {
    throw "Server $cleanPrimary belum merespons Coffee Labs /api/health OK. Migrasi dibatalkan agar user tetap aman!"
  }
  Write-Host "OK: Server baru sehat ($($health.app), db_ok=$($health.db_ok))" -ForegroundColor Green
}

$mobileManifestPath = Join-Path $PSScriptRoot "..\config\runtime-endpoints.json"
$landingManifestPath = Join-Path $PSScriptRoot "..\..\Coffe Labs Landing Pages\public\runtime-endpoints.json"

$currentRev = 1
if (Test-Path $mobileManifestPath) {
  $existing = Get-Content $mobileManifestPath -Raw | ConvertFrom-Json
  if ($existing.manifest_revision) {
    $currentRev = [int]$existing.manifest_revision
  }
}

$nextRev = $currentRev + 1
$fallbacks = @()
if ($cleanFallback -and $cleanFallback -ne $cleanPrimary -and $cleanFallback.StartsWith("https://")) {
  $fallbacks += $cleanFallback
}
if ($fallbacks.Count -eq 0) {
  $fallbacks += $cleanPrimary
}

$manifestObj = [ordered]@{
  schema_version      = 1
  manifest_revision   = $nextRev
  updated_at          = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  primary_api_url     = $cleanPrimary
  fallback_api_urls   = $fallbacks
  health_path         = "/api/health"
  force_switch        = [bool]$ForceSwitch
  maintenance_mode    = $false
  maintenance_message = $null
}

$json = $manifestObj | ConvertTo-Json -Depth 4
[System.IO.File]::WriteAllText($mobileManifestPath, "$json`n", (New-Object System.Text.UTF8Encoding($false)))
Write-Host "Updated: $mobileManifestPath (revision v$nextRev)" -ForegroundColor Green

if (Test-Path (Split-Path $landingManifestPath -Parent)) {
  [System.IO.File]::WriteAllText($landingManifestPath, "$json`n", (New-Object System.Text.UTF8Encoding($false)))
  Write-Host "Updated: $landingManifestPath (revision v$nextRev)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Langkah terakhir: commit & push kedua repo agar 3 CDN gratis (Vercel, jsDelivr, GitHub Raw) langsung mengarahkan seluruh HP user ke $cleanPrimary tanpa download APK baru!" -ForegroundColor Yellow
