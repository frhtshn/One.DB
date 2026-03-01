<#
.SYNOPSIS
    OneDB - Client Provisioning Script
    Bir veya birden fazla client için tüm veritabanlarını oluşturur ve deploy eder.

.DESCRIPTION
    Bu script aşağıdaki işlemleri yapar:
    1. Her client için tek birleşik veritabanı oluşturur: client_{code}
       (30 schema: core business + log + audit + report + affiliate)
    2. Tüm deploy'ları paralel çalıştırır (client'lar arası)
    3. Hata durumunda client bazında rollback yapar

.EXAMPLE
    .\deploy_new_client.ps1 -ClientCode "acme"
    .\deploy_new_client.ps1 -ClientCode "1","2","3"
    .\deploy_new_client.ps1 -ClientCode "1","2","3" -Reset
    .\deploy_new_client.ps1 -ClientCode "acme" -Dry
    .\deploy_new_client.ps1 -ClientCode "acme" -SkipIfExists
    .\deploy_new_client.ps1 -ClientCode "acme" -Reset -Dry
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]]$ClientCode,

    [switch]$Reset,
    [switch]$Dry,
    [switch]$SkipIfExists
)

# ============================================================
# VALIDATION
# ============================================================

foreach ($code in $ClientCode) {
    if ($code -notmatch '^[a-z0-9_]+$') {
        Write-Host "  [XX] Gecersiz client kodu: '$code' (sadece a-z, 0-9, _ kullanilabilir)" -ForegroundColor Red
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

function Get-ClientDatabases {
    param([string]$Code)
    return @(
        @{ Name = "client_$Code"; DeployFile = "deploy_client.sql" }
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
Write-Host "  ONEDB - CLIENT PROVISIONING (PARALLEL)" -ForegroundColor Blue
Write-Host "  ============================================" -ForegroundColor Blue
Write-Host ""
Write-Host "  Client Codes : $($ClientCode -join ', ')" -ForegroundColor Cyan
Write-Host "  Toplam       : $($ClientCode.Count) client" -ForegroundColor Cyan
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
$deployFiles = @("deploy_client.sql")
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
# RESET ONAY (tum client'lar icin tek seferde)
# ============================================================

if ($Reset) {
    $allExistingDbs = @()
    foreach ($code in $ClientCode) {
        $dbs = Get-ClientDatabases $code
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
    foreach ($code in $ClientCode) {
        Write-Host ""
        Write-Host "  [$code]" -ForegroundColor Cyan
        $dbs = Get-ClientDatabases $code
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

# Her (client, db) cifti icin gorev listesi
$tasks          = @()  # deploy edilecekler
$skippedTasks   = @()  # atlananlar
$blockedClients = @()  # mevcut DB yuzunden bloklanan client'lar

foreach ($code in $ClientCode) {
    $dbs = Get-ClientDatabases $code

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
                    $skippedTasks += @{ ClientCode = $code; DbName = $db.Name; DeployFile = $db.DeployFile }
                }
                else {
                    $tasks += @{ ClientCode = $code; DbName = $db.Name; DeployFile = $db.DeployFile }
                }
            }
        }
        else {
            Write-Host "  [XX] Client '$code' - asagidaki DB'ler zaten mevcut:" -ForegroundColor Red
            foreach ($e in $existingDbs) {
                Write-Host "       - $e" -ForegroundColor Red
            }
            Write-Host "       -Reset veya -SkipIfExists ile tekrar deneyin." -ForegroundColor Gray
            Write-Host ""
            $blockedClients += $code
            continue
        }
    }
    else {
        foreach ($db in $dbs) {
            $tasks += @{ ClientCode = $code; DbName = $db.Name; DeployFile = $db.DeployFile }
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
    $jobName = "$($task.ClientCode)::$($task.DbName)"

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

                $jobResults[$key] = @{ ClientCode = $t.ClientCode; ExitCode = $exitCode }

                if ($exitCode -eq 0) {
                    Write-Host "  [OK] [$done/$totalJobs] $($t.ClientCode)::$($t.DbName)" -ForegroundColor Green
                }
                else {
                    Write-Host "  [XX] [$done/$totalJobs] $($t.ClientCode)::$($t.DbName)" -ForegroundColor Red
                    if ($result.Errors) {
                        foreach ($line in $result.Errors) {
                            Write-Host "       $line" -ForegroundColor Yellow
                        }
                    }
                }
            }
            else {
                $jobResults[$key] = @{ ClientCode = $t.ClientCode; ExitCode = 1 }
                Write-Host "  [XX] [$done/$totalJobs] $($t.ClientCode)::$($t.DbName) (job state: $($j.State))" -ForegroundColor Red
            }

            Remove-Job $j -Force -ErrorAction SilentlyContinue
        }
    }
} while ($jobResults.Count -lt $totalJobs)

Write-Host ""

# ============================================================
# PHASE 3: SONUC ANALIZI + ROLLBACK
# ============================================================

# Client bazinda basari/basarisizlik
$clientResults = @{}
foreach ($code in $ClientCode) {
    if ($blockedClients -contains $code) { continue }
    $clientResults[$code] = @{ Success = $true; FailedDbs = @(); CreatedDbs = @() }
}

foreach ($task in $tasks) {
    $code = $task.ClientCode
    if (-not $clientResults.ContainsKey($code)) { continue }

    $clientResults[$code].CreatedDbs += $task.DbName

    $jr = $jobResults[$task.DbName]
    if ($jr -and $jr.ExitCode -ne 0) {
        $clientResults[$code].Success = $false
        $clientResults[$code].FailedDbs += $task.DbName
    }
}

# Basarisiz client'lari rollback
$successClients = @()
$failedClients  = @() + $blockedClients

foreach ($code in $clientResults.Keys) {
    $tr = $clientResults[$code]

    if ($tr.Success) {
        $successClients += $code
    }
    else {
        $failedClients += $code
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

if ($successClients.Count -gt 0) {
    Write-Host "  Basarili ($($successClients.Count)):" -ForegroundColor Green
    foreach ($t in $successClients) {
        Write-Host "    [OK] $t" -ForegroundColor Green
    }
}

if ($skippedTasks.Count -gt 0) {
    $skippedClients = $skippedTasks | ForEach-Object { $_.ClientCode } | Sort-Object -Unique
    Write-Host "  Atlanan DB'ler:" -ForegroundColor Yellow
    foreach ($st in $skippedTasks) {
        Write-Host "    [--] $($st.DbName) (zaten mevcuttu)" -ForegroundColor Yellow
    }
}

if ($failedClients.Count -gt 0) {
    Write-Host "  Basarisiz ($($failedClients.Count)):" -ForegroundColor Red
    foreach ($t in $failedClients) {
        Write-Host "    [XX] $t" -ForegroundColor Red
    }
}

Write-Host ""

if ($failedClients.Count -gt 0) {
    Write-Host "  Basarisiz client'lar icin: -Reset veya -SkipIfExists ile tekrar deneyin." -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "  Sonraki adimlar:" -ForegroundColor White
Write-Host "    1. Backend'de client kaydini olustur (core DB)" -ForegroundColor Gray
Write-Host "    2. Client seed verilerini backend uzerinden yukle" -ForegroundColor Gray
Write-Host "    3. Connection string'i yapilandir" -ForegroundColor Gray
Write-Host ""
