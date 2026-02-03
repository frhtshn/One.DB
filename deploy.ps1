<#
.SYNOPSIS
    Nucleo.DB Deploy Script (psql)
.EXAMPLE
    .\deploy.ps1 create_dbs.sql
    .\deploy.ps1 deploy_core.sql
    .\deploy.ps1 deploy_core_staging.sql
    .\deploy.ps1 deploy_core.sql -Reset
#>

param(
    [Parameter(Position = 0)]
    [string]$SqlFile = "deploy_core.sql",
    [switch]$Reset,
    [switch]$Dry
)

# Config
$config = Get-Content "$PSScriptRoot\deploy.config.json" | ConvertFrom-Json

$HOST_IP = $config.host
$PORT = $config.port
$USER = $config.user
$PASS = $config.password

# Şifreyi environment variable olarak ayarla
$env:PGPASSWORD = $PASS

# Database adını dosya adından çıkar
$DB = $SqlFile -replace '^deploy_', '' -replace '\.sql$', '' -replace '_(staging|production)$', ''
if ($SqlFile -eq "create_dbs.sql") { $DB = "postgres" }

Write-Host ""
Write-Host "  NUCLEO.DB DEPLOY" -ForegroundColor Blue
Write-Host "  Server: ${HOST_IP}:${PORT}" -ForegroundColor Cyan
Write-Host "  Database: $DB" -ForegroundColor Yellow
Write-Host "  File: $SqlFile" -ForegroundColor Cyan
Write-Host ""

# Dosya var mı?
$localFile = Join-Path $PSScriptRoot $SqlFile
if (-not (Test-Path $localFile)) {
    Write-Host "[XX] Dosya bulunamadi: $SqlFile" -ForegroundColor Red
    exit 1
}

# psql var mı?
if (-not (Get-Command psql -ErrorAction SilentlyContinue)) {
    Write-Host "[XX] psql bulunamadi! PostgreSQL client yukleyin." -ForegroundColor Red
    Write-Host "     https://www.postgresql.org/download/windows/" -ForegroundColor Gray
    exit 1
}

# Dry run?
if ($Dry) {
    Write-Host "[..] DRY RUN - Baglanti test ediliyor..." -ForegroundColor Yellow

    $testResult = psql -h $HOST_IP -p $PORT -U $USER -d $DB -c "SELECT 1" 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Baglanti basarili" -ForegroundColor Green
        Write-Host ""
        Write-Host "  Dosya:    $SqlFile" -ForegroundColor Cyan
        Write-Host "  Database: $DB" -ForegroundColor Cyan
        Write-Host "  Server:   ${HOST_IP}:${PORT}" -ForegroundColor Cyan
        if ($Reset) {
            Write-Host "  Reset:    EVET (schema'lar silinecek)" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "[!!] Gercek deploy icin -Dry olmadan calistir" -ForegroundColor Yellow
    }
    else {
        Write-Host "[XX] Baglanti basarisiz!" -ForegroundColor Red
        Write-Host $testResult -ForegroundColor Red
    }
    Write-Host ""
    exit 0
}

# Reset?
if ($Reset) {
    Write-Host "[!!] RESET - Tum schema'lar silinecek!" -ForegroundColor Red
    $confirm = Read-Host "Devam? (DELETE yaz)"
    if ($confirm -ne "DELETE") { Write-Host "Iptal"; exit 0 }

    Write-Host "[..] Schema'lar siliniyor..." -ForegroundColor Cyan
    $drop = "DROP SCHEMA IF EXISTS affiliate, affiliate_audit, affiliate_log, auth, backoffice, billing, bonus, bonus_log, campaign, catalog, commission, content, core, finance, finance_log, game, game_log, infra, kyc, kyc_audit, kyc_log, logs, metric_helpers, payout, performance, presentation, profile, promotion, public, routing, security, tracking, transaction, user_management, wallet CASCADE;"

    $env:PGOPTIONS = "--client-min-messages=error"
    psql -h $HOST_IP -p $PORT -U $USER -d $DB -q -c $drop 2>&1 | Out-Null
    $env:PGOPTIONS = ""
    Write-Host "[OK] Silindi" -ForegroundColor Green
    Write-Host ""
}

# Deploy
Write-Host "[..] $SqlFile calistiriliyor..." -ForegroundColor Cyan

# NOTICE mesajlarını gizle (skipping vs.)
$env:PGOPTIONS = "--client-min-messages=warning"

Push-Location $PSScriptRoot
$output = psql -h $HOST_IP -p $PORT -U $USER -d $DB -q -v ON_ERROR_STOP=1 -f $SqlFile 2>&1
$exitCode = $LASTEXITCODE
Pop-Location

if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "[OK] DEPLOY BASARILI" -ForegroundColor Green
}
else {
    Write-Host ""
    Write-Host "[XX] DEPLOY BASARISIZ" -ForegroundColor Red
    Write-Host ""
    Write-Host "═══════════════ HATA DETAYI ═══════════════" -ForegroundColor Red
    Write-Host ""

    # Hata satırlarını bul ve göster
    $errorLines = $output | Select-String -Pattern "ERROR|HATA|error|psql:"
    if ($errorLines) {
        $errorLines | ForEach-Object { Write-Host $_.Line -ForegroundColor Yellow }
    }
    else {
        $output | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
    }

    Write-Host ""
    Write-Host "════════════════════════════════════════════" -ForegroundColor Red
    exit 1
}
Write-Host ""
