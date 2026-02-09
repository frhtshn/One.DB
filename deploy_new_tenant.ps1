<#
.SYNOPSIS
    Nucleo.DB - Tenant Provisioning Script
    Yeni bir tenant için tüm veritabanlarını oluşturur ve deploy eder.

.DESCRIPTION
    Bu script aşağıdaki işlemleri yapar:
    1. 5 veritabanı oluşturur: tenant_{code}, tenant_log_{code}, tenant_audit_{code},
       tenant_report_{code}, tenant_affiliate_{code}
    2. Her veritabanına ilgili deploy SQL dosyasını çalıştırır
    3. Hata durumunda oluşturulan veritabanlarını geri alır (Rollback)

.EXAMPLE
    .\deploy_new_tenant.ps1 -TenantCode "acme"
    .\deploy_new_tenant.ps1 -TenantCode "1"
    .\deploy_new_tenant.ps1 -TenantCode "acme" -Dry
    .\deploy_new_tenant.ps1 -TenantCode "acme" -SkipIfExists
    .\deploy_new_tenant.ps1 -TenantCode "acme" -Reset
    .\deploy_new_tenant.ps1 -TenantCode "acme" -Reset -Dry
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidatePattern('^[a-z0-9_]+$')]
    [string]$TenantCode,

    [switch]$Reset,
    [switch]$Dry,
    [switch]$SkipIfExists
)

# ============================================================
# CONFIG
# ============================================================

$config = Get-Content "$PSScriptRoot\deploy.config.json" | ConvertFrom-Json

$HOST_IP = $config.host
$PORT    = $config.port
$USER    = $config.user
$PASS    = $config.password

$env:PGPASSWORD = $PASS

# Tenant veritabanları ve deploy dosya eşleştirmesi
$tenantDatabases = @(
    @{ Name = "tenant_$TenantCode";           DeployFile = "deploy_tenant.sql" },
    @{ Name = "tenant_log_$TenantCode";       DeployFile = "deploy_tenant_log.sql" },
    @{ Name = "tenant_audit_$TenantCode";     DeployFile = "deploy_tenant_audit.sql" },
    @{ Name = "tenant_report_$TenantCode";    DeployFile = "deploy_tenant_report.sql" },
    @{ Name = "tenant_affiliate_$TenantCode"; DeployFile = "deploy_tenant_affiliate.sql" }
)

# ============================================================
# YARDIMCI FONKSİYONLAR
# ============================================================

function Test-DatabaseExists {
    param([string]$DbName)
    $result = psql -h $HOST_IP -p $PORT -U $USER -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname = '$DbName'" 2>&1
    return ($result -eq "1")
}

function New-Database {
    param([string]$DbName)
    $env:PGOPTIONS = "--client-min-messages=error"
    psql -h $HOST_IP -p $PORT -U $USER -d postgres -q -c "CREATE DATABASE $DbName" 2>&1
    $code = $LASTEXITCODE
    $env:PGOPTIONS = ""
    return $code
}

function Remove-Database {
    param([string]$DbName)
    $env:PGOPTIONS = "--client-min-messages=error"
    psql -h $HOST_IP -p $PORT -U $USER -d postgres -q -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DbName' AND pid <> pg_backend_pid()" 2>&1 | Out-Null
    psql -h $HOST_IP -p $PORT -U $USER -d postgres -q -c "DROP DATABASE IF EXISTS $DbName" 2>&1
    $env:PGOPTIONS = ""
}

function Invoke-DeployFile {
    param(
        [string]$DbName,
        [string]$SqlFile
    )

    $filePath = Join-Path $PSScriptRoot $SqlFile
    if (-not (Test-Path $filePath)) {
        Write-Host "  [XX] Deploy dosyasi bulunamadi: $SqlFile" -ForegroundColor Red
        return 1
    }

    $env:PGOPTIONS = "--client-min-messages=warning"
    Push-Location $PSScriptRoot
    $output = psql -h $HOST_IP -p $PORT -U $USER -d $DbName -q -v ON_ERROR_STOP=1 -f $SqlFile 2>&1
    $exitCode = $LASTEXITCODE
    Pop-Location
    $env:PGOPTIONS = ""

    if ($exitCode -ne 0) {
        Write-Host ""
        Write-Host "  =============== HATA DETAYI ===============" -ForegroundColor Red
        $errorLines = $output | Select-String -Pattern "ERROR|HATA|error|psql:"
        if ($errorLines) {
            $errorLines | ForEach-Object { Write-Host "  $($_.Line)" -ForegroundColor Yellow }
        }
        else {
            $output | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
        }
        Write-Host "  ============================================" -ForegroundColor Red
    }

    return $exitCode
}

# ============================================================
# BAŞLANGIÇ
# ============================================================

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Blue
Write-Host "  NUCLEO.DB - TENANT PROVISIONING" -ForegroundColor Blue
Write-Host "  ============================================" -ForegroundColor Blue
Write-Host ""
Write-Host "  Tenant Code : $TenantCode" -ForegroundColor Cyan
Write-Host "  Server      : ${HOST_IP}:${PORT}" -ForegroundColor Cyan
if ($Reset) {
    Write-Host "  Mode        : RESET (sil + yeniden olustur)" -ForegroundColor Red
}
Write-Host ""
Write-Host "  Veritabanlari:" -ForegroundColor White
foreach ($db in $tenantDatabases) {
    Write-Host "    - $($db.Name)  <--  $($db.DeployFile)" -ForegroundColor Gray
}
Write-Host ""

# ============================================================
# ÖN KONTROLLER
# ============================================================

# psql var mı?
if (-not (Get-Command psql -ErrorAction SilentlyContinue)) {
    Write-Host "  [XX] psql bulunamadi! PostgreSQL client yukleyin." -ForegroundColor Red
    Write-Host "       https://www.postgresql.org/download/windows/" -ForegroundColor Gray
    exit 1
}

# Deploy dosyaları var mı?
$missingFiles = @()
foreach ($db in $tenantDatabases) {
    $filePath = Join-Path $PSScriptRoot $db.DeployFile
    if (-not (Test-Path $filePath)) {
        $missingFiles += $db.DeployFile
    }
}
if ($missingFiles.Count -gt 0) {
    Write-Host "  [XX] Eksik deploy dosyalari:" -ForegroundColor Red
    foreach ($f in $missingFiles) {
        Write-Host "       - $f" -ForegroundColor Red
    }
    exit 1
}

# Bağlantı testi
Write-Host "  [..] Baglanti test ediliyor..." -ForegroundColor Cyan
$testResult = psql -h $HOST_IP -p $PORT -U $USER -d postgres -tAc "SELECT 1" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [XX] Baglanti basarisiz!" -ForegroundColor Red
    Write-Host "  $testResult" -ForegroundColor Red
    exit 1
}
Write-Host "  [OK] Baglanti basarili" -ForegroundColor Green
Write-Host ""

# Mevcut veritabanı kontrolü
$existingDbs = @()
foreach ($db in $tenantDatabases) {
    if (Test-DatabaseExists $db.Name) {
        $existingDbs += $db.Name
    }
}

# ============================================================
# RESET MODU
# ============================================================

if ($Reset -and $existingDbs.Count -gt 0) {
    Write-Host "  [!!] Silinecek veritabanlari:" -ForegroundColor Red
    foreach ($e in $existingDbs) {
        Write-Host "       - $e" -ForegroundColor Red
    }
    Write-Host ""

    if ($Dry) {
        Write-Host "  [OK] DRY RUN - Reset modunda silinecek DB'ler yukarida listelendi." -ForegroundColor Yellow
        Write-Host "       Gercek islem icin -Dry olmadan calistir." -ForegroundColor Gray
        Write-Host ""
        exit 0
    }

    $confirm = Read-Host "  Devam etmek icin DELETE yazin"
    if ($confirm -ne "DELETE") {
        Write-Host "  Iptal edildi." -ForegroundColor Yellow
        exit 0
    }
    Write-Host ""

    foreach ($dbName in $existingDbs) {
        Write-Host "  [..] $dbName siliniyor..." -ForegroundColor Yellow -NoNewline
        Remove-Database $dbName
        Write-Host " OK" -ForegroundColor Green
    }
    Write-Host ""

    # Mevcut listesini temizle, artık hepsi silinmiş durumda
    $existingDbs = @()
}

# ============================================================
# MEVCUT DB KONTROLÜ (Reset değilse)
# ============================================================

if (-not $Reset -and $existingDbs.Count -gt 0) {
    if ($SkipIfExists) {
        Write-Host "  [!!] Mevcut veritabanlari atlanacak (-SkipIfExists):" -ForegroundColor Yellow
        foreach ($e in $existingDbs) {
            Write-Host "       - $e" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    else {
        Write-Host "  [XX] Asagidaki veritabanlari zaten mevcut:" -ForegroundColor Red
        foreach ($e in $existingDbs) {
            Write-Host "       - $e" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "  Sifirdan olusturmak icin : -Reset" -ForegroundColor Gray
        Write-Host "  Mevcut olanlari atlamak  : -SkipIfExists" -ForegroundColor Gray
        exit 1
    }
}

# Dry run? (Reset olmayan durumlar)
if ($Dry) {
    Write-Host "  [OK] DRY RUN - Her sey hazir. Gercek deploy icin -Dry olmadan calistir." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# ============================================================
# PROVISIONING
# ============================================================

$createdDbs = @()
$failedDb   = $null

foreach ($db in $tenantDatabases) {
    $dbName     = $db.Name
    $deployFile = $db.DeployFile

    # Zaten varsa atla (SkipIfExists modunda)
    if ($SkipIfExists -and ($existingDbs -contains $dbName)) {
        Write-Host "  [--] $dbName zaten mevcut, atlaniyor" -ForegroundColor Yellow
        continue
    }

    # 1. Veritabanı oluştur
    Write-Host "  [..] $dbName olusturuluyor..." -ForegroundColor Cyan -NoNewline
    $createResult = New-Database $dbName

    if ($createResult -ne 0) {
        Write-Host " BASARISIZ" -ForegroundColor Red
        $failedDb = $dbName
        break
    }

    Write-Host " OK" -ForegroundColor Green
    $createdDbs += $dbName

    # 2. Deploy dosyasını çalıştır
    Write-Host "  [..] $deployFile -> $dbName deploy ediliyor..." -ForegroundColor Cyan -NoNewline
    $deployResult = Invoke-DeployFile -DbName $dbName -SqlFile $deployFile

    if ($deployResult -ne 0) {
        Write-Host " BASARISIZ" -ForegroundColor Red
        $failedDb = $dbName
        break
    }

    Write-Host " OK" -ForegroundColor Green
}

# ============================================================
# SONUÇ
# ============================================================

if ($failedDb) {
    Write-Host ""
    Write-Host "  [XX] PROVISIONING BASARISIZ: $failedDb" -ForegroundColor Red
    Write-Host ""

    if ($createdDbs.Count -gt 0) {
        Write-Host "  [..] ROLLBACK - Olusturulan veritabanlari siliniyor..." -ForegroundColor Yellow
        foreach ($cdb in $createdDbs) {
            Write-Host "       Siliniyor: $cdb..." -ForegroundColor Yellow -NoNewline
            Remove-Database $cdb
            Write-Host " OK" -ForegroundColor Green
        }
        Write-Host ""
        Write-Host "  [OK] Rollback tamamlandi" -ForegroundColor Yellow
    }

    Write-Host ""
    exit 1
}

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Green
Write-Host "  [OK] TENANT PROVISIONING BASARILI" -ForegroundColor Green
Write-Host "  ============================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Veritabanlari:" -ForegroundColor White
foreach ($db in $tenantDatabases) {
    if (-not ($SkipIfExists -and ($existingDbs -contains $db.Name))) {
        Write-Host "    [OK] $($db.Name)" -ForegroundColor Green
    }
    else {
        Write-Host "    [--] $($db.Name) (zaten mevcuttu)" -ForegroundColor Yellow
    }
}
Write-Host ""
Write-Host "  Sonraki adimlar:" -ForegroundColor White
Write-Host "    1. Backend'de tenant kaydini olustur (core DB)" -ForegroundColor Gray
Write-Host "    2. Tenant seed verilerini backend uzerinden yukle" -ForegroundColor Gray
Write-Host "    3. Connection string'i yapilandir" -ForegroundColor Gray
Write-Host ""
