<#
.SYNOPSIS
    OneDB - Mevcut client DB'lerine tek bir SQL dosyasi deploy eder.
.DESCRIPTION
    Belirtilen SQL dosyasini, verilen client kodlarinin her birine calistirir.
    CREATE OR REPLACE function'lar icin guvenli (idempotent).
.EXAMPLE
    .\deploy_patch_clients.ps1 -SqlFile "client/functions/frontend/auth/player_find_by_email_hash.sql" -ClientCodes 1,2,3,4
    .\deploy_patch_clients.ps1 -SqlFile "client/functions/frontend/auth/player_find_by_email_hash.sql" -ClientCodes 1,2,3,4 -Dry
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$SqlFile,

    [Parameter(Mandatory = $true, Position = 1)]
    [string[]]$ClientCodes,

    [switch]$Dry
)

# Config
$config = Get-Content "$PSScriptRoot\deploy.config.json" | ConvertFrom-Json

$HOST_IP = $config.host
$PORT    = $config.port
$USER    = $config.user
$PASS    = $config.password

$env:PGPASSWORD = $PASS

# Dosya kontrolu
$filePath = Join-Path $PSScriptRoot $SqlFile
if (-not (Test-Path $filePath)) {
    Write-Host "[XX] Dosya bulunamadi: $SqlFile" -ForegroundColor Red
    exit 1
}

# psql kontrolu
if (-not (Get-Command psql -ErrorAction SilentlyContinue)) {
    Write-Host "[XX] psql bulunamadi! PostgreSQL client yukleyin." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "  ONEDB - CLIENT PATCH" -ForegroundColor Blue
Write-Host "  Server: ${HOST_IP}:${PORT}" -ForegroundColor Cyan
Write-Host "  File:   $SqlFile" -ForegroundColor Cyan
Write-Host "  Clients: $($ClientCodes -join ', ')" -ForegroundColor Cyan
Write-Host ""

if ($Dry) {
    Write-Host "  [OK] DRY RUN - Gercek deploy icin -Dry olmadan calistir." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

$success = 0
$failed  = 0

foreach ($code in $ClientCodes) {
    $dbName = "client_$code"
    Write-Host "  [..] $dbName" -ForegroundColor Cyan -NoNewline

    $env:PGOPTIONS = "--client-min-messages=warning"
    Push-Location $PSScriptRoot
    $output = psql -h $HOST_IP -p $PORT -U $USER -d $dbName -q -v ON_ERROR_STOP=1 -f $SqlFile 2>&1
    $exitCode = $LASTEXITCODE
    Pop-Location
    $env:PGOPTIONS = ""

    if ($exitCode -eq 0) {
        Write-Host " OK" -ForegroundColor Green
        $success++
    }
    else {
        Write-Host " BASARISIZ" -ForegroundColor Red
        $errorLines = $output | Select-String -Pattern "ERROR|HATA|error|psql:"
        if ($errorLines) {
            $errorLines | ForEach-Object { Write-Host "       $($_.Line)" -ForegroundColor Yellow }
        }
        $failed++
    }
}

Write-Host ""
if ($failed -eq 0) {
    Write-Host "  [OK] $success/$($ClientCodes.Count) client basarili" -ForegroundColor Green
}
else {
    Write-Host "  [!!] $success basarili, $failed basarisiz" -ForegroundColor Red
}
Write-Host ""
