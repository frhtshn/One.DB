<#
.SYNOPSIS
    Nucleo.DB - Tenant Provisioning Script
    Bir veya birden fazla tenant için tüm veritabanlarını oluşturur ve deploy eder.

.DESCRIPTION
    Bu script aşağıdaki işlemleri yapar:
    1. Her tenant için 5 veritabanı oluşturur: tenant_{code}, tenant_log_{code}, tenant_audit_{code},
       tenant_report_{code}, tenant_affiliate_{code}
    2. Tüm deploy'ları paralel çalıştırır (tenant'lar arası + DB'ler arası)
    3. Hata durumunda tenant bazında rollback yapar

.EXAMPLE
    .\deploy_new_tenant.ps1 -TenantCode "acme"
    .\deploy_new_tenant.ps1 -TenantCode "1","2","3"
    .\deploy_new_tenant.ps1 -TenantCode "1","2","3" -Reset
    .\deploy_new_tenant.ps1 -TenantCode "acme" -Dry
    .\deploy_new_tenant.ps1 -TenantCode "acme" -SkipIfExists
    .\deploy_new_tenant.ps1 -TenantCode "acme" -Reset -Dry
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]]$TenantCode,

    [switch]$Reset,
    [switch]$Dry,
    [switch]$SkipIfExists
)

# ============================================================
# VALIDATION
# ============================================================

foreach ($code in $TenantCode) {
    if ($code -notmatch '^[a-z0-9_]+$') {
        Write-Host "  [XX] Gecersiz tenant kodu: '$code' (sadece a-z, 0-9, _ kullanilabilir)" -ForegroundColor Red
        exit 1
    }
}

# ============================================================
# CONFIG
# ============================================================

$config = Get-Content "$PSScriptRoot\deploy.config.json" | ConvertFrom-Json

$HOST_IP = $config.host
$PORT    = $config.port
$USER    = $config.user
$PASS    = $config.password

$env:PGPASSWORD = $PASS

# ============================================================
# YARDIMCI FONKSİYONLAR
# ============================================================

function Get-TenantDatabases {
    param([string]$Code)
    return @(
        @{ Name = "tenant_$Code";           DeployFile = "deploy_tenant.sql" },
        @{ Name = "tenant_log_$Code";       DeployFile = "deploy_tenant_log.sql" },
        @{ Name = "tenant_audit_$Code";     DeployFile = "deploy_tenant_audit.sql" },
        @{ Name = "tenant_report_$Code";    DeployFile = "deploy_tenant_report.sql" },
        @{ Name = "tenant_affiliate_$Code"; DeployFile = "deploy_tenant_affiliate.sql" }
    )
}

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

# ============================================================
# BAŞLANGIÇ
# ============================================================

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Blue
Write-Host "  NUCLEO.DB - TENANT PROVISIONING (PARALLEL)" -ForegroundColor Blue
Write-Host "  ============================================" -ForegroundColor Blue
Write-Host ""
Write-Host "  Tenant Codes : $($TenantCode -join ', ')" -ForegroundColor Cyan
Write-Host "  Toplam       : $($TenantCode.Count) tenant" -ForegroundColor Cyan
Write-Host "  Server       : ${HOST_IP}:${PORT}" -ForegroundColor Cyan
if ($Reset) {
    Write-Host "  Mode         : RESET (sil + yeniden olustur)" -ForegroundColor Red
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
$deployFiles = @("deploy_tenant.sql", "deploy_tenant_log.sql", "deploy_tenant_audit.sql", "deploy_tenant_report.sql", "deploy_tenant_affiliate.sql")
$missingFiles = @()
foreach ($f in $deployFiles) {
    $filePath = Join-Path $PSScriptRoot $f
    if (-not (Test-Path $filePath)) {
        $missingFiles += $f
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

# ============================================================
# RESET ONAY (tum tenant'lar icin tek seferde)
# ============================================================

if ($Reset) {
    $allExistingDbs = @()
    foreach ($code in $TenantCode) {
        $dbs = Get-TenantDatabases $code
        foreach ($db in $dbs) {
            if (Test-DatabaseExists $db.Name) {
                $allExistingDbs += $db.Name
            }
        }
    }

    if ($allExistingDbs.Count -gt 0) {
        Write-Host "  [!!] Silinecek veritabanlari:" -ForegroundColor Red
        foreach ($e in $allExistingDbs) {
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

        foreach ($dbName in $allExistingDbs) {
            Write-Host "  [..] $dbName siliniyor..." -ForegroundColor Yellow -NoNewline
            Remove-Database $dbName
            Write-Host " OK" -ForegroundColor Green
        }
        Write-Host ""
    }
}

# ============================================================
# DRY RUN (Reset olmayan)
# ============================================================

if ($Dry -and -not $Reset) {
    Write-Host "  Olusturulacak veritabanlari:" -ForegroundColor White
    foreach ($code in $TenantCode) {
        Write-Host ""
        Write-Host "  [$code]" -ForegroundColor Cyan
        $dbs = Get-TenantDatabases $code
        foreach ($db in $dbs) {
            $exists = Test-DatabaseExists $db.Name
            if ($exists -and $SkipIfExists) {
                Write-Host "    [--] $($db.Name) (mevcut, atlanacak)" -ForegroundColor Yellow
            }
            elseif ($exists) {
                Write-Host "    [XX] $($db.Name) (zaten mevcut!)" -ForegroundColor Red
            }
            else {
                Write-Host "    [OK] $($db.Name)  <--  $($db.DeployFile)" -ForegroundColor Gray
            }
        }
    }
    Write-Host ""
    Write-Host "  [OK] DRY RUN - Her sey hazir. Gercek deploy icin -Dry olmadan calistir." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# ============================================================
# GOREV LISTESI OLUSTUR
# ============================================================

# Her (tenant, db) cifti icin gorev listesi
$tasks          = @()  # deploy edilecekler
$skippedTasks   = @()  # atlananlar
$blockedTenants = @()  # mevcut DB yuzunden bloklanan tenant'lar

foreach ($code in $TenantCode) {
    $dbs = Get-TenantDatabases $code

    # Mevcut DB kontrolu
    $existingDbs = @()
    foreach ($db in $dbs) {
        if (Test-DatabaseExists $db.Name) {
            $existingDbs += $db.Name
        }
    }

    # Reset olmayan modda mevcut DB kontrolu
    if (-not $Reset -and $existingDbs.Count -gt 0) {
        if ($SkipIfExists) {
            foreach ($db in $dbs) {
                if ($existingDbs -contains $db.Name) {
                    $skippedTasks += @{ TenantCode = $code; DbName = $db.Name; DeployFile = $db.DeployFile }
                }
                else {
                    $tasks += @{ TenantCode = $code; DbName = $db.Name; DeployFile = $db.DeployFile }
                }
            }
        }
        else {
            Write-Host "  [XX] Tenant '$code' - asagidaki DB'ler zaten mevcut:" -ForegroundColor Red
            foreach ($e in $existingDbs) {
                Write-Host "       - $e" -ForegroundColor Red
            }
            Write-Host "       -Reset veya -SkipIfExists ile tekrar deneyin." -ForegroundColor Gray
            Write-Host ""
            $blockedTenants += $code
            continue
        }
    }
    else {
        foreach ($db in $dbs) {
            $tasks += @{ TenantCode = $code; DbName = $db.Name; DeployFile = $db.DeployFile }
        }
    }
}

if ($tasks.Count -eq 0) {
    Write-Host "  [--] Deploy edilecek veritabani yok." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# ============================================================
# PHASE 1: TUM DB'LERI OLUSTUR (sirayla - hizli)
# ============================================================

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "  PHASE 1: Veritabanlari olusturuluyor ($($tasks.Count) adet)..." -ForegroundColor Blue
Write-Host ""

$createdDbs   = @()  # rollback icin
$createFailed = $false

foreach ($task in $tasks) {
    Write-Host "  [..] $($task.DbName) olusturuluyor..." -ForegroundColor Cyan -NoNewline
    $createResult = New-Database $task.DbName

    if ($createResult -ne 0) {
        Write-Host " BASARISIZ" -ForegroundColor Red
        $createFailed = $true
        break
    }

    Write-Host " OK" -ForegroundColor Green
    $createdDbs += $task
}

# CREATE basarisiz olduysa rollback
if ($createFailed) {
    Write-Host ""
    Write-Host "  [XX] DB olusturma basarisiz! Rollback yapiliyor..." -ForegroundColor Red

    foreach ($t in $createdDbs) {
        Write-Host "       Siliniyor: $($t.DbName)..." -ForegroundColor Yellow -NoNewline
        Remove-Database $t.DbName
        Write-Host " OK" -ForegroundColor Green
    }

    Write-Host ""
    exit 1
}

Write-Host ""

# ============================================================
# PHASE 2: TUM DEPLOY'LAR PARALEL
# ============================================================

Write-Host "  PHASE 2: Deploy basliyor ($($tasks.Count) paralel job)..." -ForegroundColor Blue
Write-Host ""

$jobs = @()

foreach ($task in $tasks) {
    $jobName = "$($task.TenantCode)::$($task.DbName)"

    $job = Start-Job -Name $jobName -ScriptBlock {
        param($HostIP, $Port, $User, $Pass, $DbName, $SqlFile, $ScriptRoot)

        $env:PGPASSWORD = $Pass
        $env:PGOPTIONS = "--client-min-messages=warning"

        Push-Location $ScriptRoot
        $output = & psql -h $HostIP -p $Port -U $User -d $DbName -q -v ON_ERROR_STOP=1 -f $SqlFile 2>&1
        $exitCode = $LASTEXITCODE
        Pop-Location

        # Sadece hata satirlarini filtrele
        $errorLines = @()
        if ($exitCode -ne 0) {
            $errorLines = $output | Select-String -Pattern "ERROR|HATA|error|psql:" | ForEach-Object { $_.Line }
            if ($errorLines.Count -eq 0) {
                $errorLines = @($output | ForEach-Object { "$_" })
            }
        }

        return @{
            DbName    = $DbName
            ExitCode  = $exitCode
            Errors    = $errorLines
        }
    } -ArgumentList $HOST_IP, $PORT, $USER, $PASS, $task.DbName, $task.DeployFile, $PSScriptRoot

    $jobs += @{ Job = $job; Task = $task }
}

# Ilerleme takibi + sonuc toplama
$totalJobs  = $jobs.Count
$jobResults = @{}

Write-Host "  Bekleniyor..." -ForegroundColor Gray

do {
    Start-Sleep -Milliseconds 500

    foreach ($entry in $jobs) {
        $j = $entry.Job
        $t = $entry.Task
        $key = $t.DbName

        if (-not $jobResults.ContainsKey($key) -and $j.State -ne 'Running') {
            $done = $jobResults.Count + 1

            if ($j.State -eq 'Completed') {
                $result = Receive-Job $j
                $exitCode = if ($result -and $null -ne $result.ExitCode) { $result.ExitCode } else { 1 }

                $jobResults[$key] = @{ TenantCode = $t.TenantCode; ExitCode = $exitCode }

                if ($exitCode -eq 0) {
                    Write-Host "  [OK] [$done/$totalJobs] $($t.TenantCode)::$($t.DbName)" -ForegroundColor Green
                }
                else {
                    Write-Host "  [XX] [$done/$totalJobs] $($t.TenantCode)::$($t.DbName)" -ForegroundColor Red
                    if ($result.Errors) {
                        foreach ($line in $result.Errors) {
                            Write-Host "       $line" -ForegroundColor Yellow
                        }
                    }
                }
            }
            else {
                $jobResults[$key] = @{ TenantCode = $t.TenantCode; ExitCode = 1 }
                Write-Host "  [XX] [$done/$totalJobs] $($t.TenantCode)::$($t.DbName) (job state: $($j.State))" -ForegroundColor Red
            }

            Remove-Job $j -Force -ErrorAction SilentlyContinue
        }
    }
} while ($jobResults.Count -lt $totalJobs)

Write-Host ""

# ============================================================
# PHASE 3: SONUC ANALIZI + ROLLBACK
# ============================================================

# Tenant bazinda basari/basarisizlik
$tenantResults = @{}
foreach ($code in $TenantCode) {
    if ($blockedTenants -contains $code) { continue }
    $tenantResults[$code] = @{ Success = $true; FailedDbs = @(); CreatedDbs = @() }
}

foreach ($task in $tasks) {
    $code = $task.TenantCode
    if (-not $tenantResults.ContainsKey($code)) { continue }

    $tenantResults[$code].CreatedDbs += $task.DbName

    $jr = $jobResults[$task.DbName]
    if ($jr -and $jr.ExitCode -ne 0) {
        $tenantResults[$code].Success = $false
        $tenantResults[$code].FailedDbs += $task.DbName
    }
}

# Basarisiz tenant'lari rollback
$successTenants = @()
$failedTenants  = @() + $blockedTenants

foreach ($code in $tenantResults.Keys) {
    $tr = $tenantResults[$code]

    if ($tr.Success) {
        $successTenants += $code
    }
    else {
        $failedTenants += $code
        Write-Host "  [..] ROLLBACK '$code' - basarisiz DB'ler nedeniyle tum DB'leri siliniyor..." -ForegroundColor Yellow

        foreach ($dbName in $tr.CreatedDbs) {
            Write-Host "       Siliniyor: $dbName..." -ForegroundColor Yellow -NoNewline
            Remove-Database $dbName
            Write-Host " OK" -ForegroundColor Green
        }

        Write-Host ""
    }
}

$stopwatch.Stop()

# ============================================================
# SONUÇ ÖZETİ
# ============================================================

Write-Host "  ============================================" -ForegroundColor Blue
Write-Host "  SONUC OZETI" -ForegroundColor Blue
Write-Host "  ============================================" -ForegroundColor Blue
Write-Host ""
Write-Host "  Sure: $([math]::Round($stopwatch.Elapsed.TotalSeconds, 1)) saniye" -ForegroundColor Cyan
Write-Host ""

if ($successTenants.Count -gt 0) {
    Write-Host "  Basarili ($($successTenants.Count)):" -ForegroundColor Green
    foreach ($t in $successTenants) {
        Write-Host "    [OK] $t" -ForegroundColor Green
    }
}

if ($skippedTasks.Count -gt 0) {
    $skippedTenants = $skippedTasks | ForEach-Object { $_.TenantCode } | Sort-Object -Unique
    Write-Host "  Atlanan DB'ler:" -ForegroundColor Yellow
    foreach ($st in $skippedTasks) {
        Write-Host "    [--] $($st.DbName) (zaten mevcuttu)" -ForegroundColor Yellow
    }
}

if ($failedTenants.Count -gt 0) {
    Write-Host "  Basarisiz ($($failedTenants.Count)):" -ForegroundColor Red
    foreach ($t in $failedTenants) {
        Write-Host "    [XX] $t" -ForegroundColor Red
    }
}

Write-Host ""

if ($failedTenants.Count -gt 0) {
    Write-Host "  Basarisiz tenant'lar icin: -Reset veya -SkipIfExists ile tekrar deneyin." -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "  Sonraki adimlar:" -ForegroundColor White
Write-Host "    1. Backend'de tenant kaydini olustur (core DB)" -ForegroundColor Gray
Write-Host "    2. Tenant seed verilerini backend uzerinden yukle" -ForegroundColor Gray
Write-Host "    3. Connection string'i yapilandir" -ForegroundColor Gray
Write-Host ""
