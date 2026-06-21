# --- CONFIG ---
$targetName = "dllhost.exe"
$dumpPath = "$env:USERPROFILE\Desktop\dumps"
$procDumpPath = ".\procdump.exe"
$pssuspend = ".\pssuspend.exe"
$intervalMs = 100
$maxDumps = 50

# --- LOGGING ---
function Log($msg) {
    $logFile = "$dumpPath\watchdog_log.txt"
    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss.fff')) - $msg" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

# --- INIT ---
if (!(Test-Path $dumpPath)) { New-Item -ItemType Directory -Path $dumpPath | Out-Null }
Write-Host "🎯 FULLTRAP poluje na $targetName co ${intervalMs}ms..."
Log "FULLTRAP uruchomiony. Cel: $targetName co ${intervalMs}ms."

# --- LOOP ---
$counter = 0
$dumpedPIDs = @{}
# Legalny dllhost.exe (COM Surrogate) leży w System32/SysWOW64. Zamrażamy i
# dumpujemy TYLKO instancje spoza tych lokalizacji - inaczej ryzykujemy
# zawieszenie legalnej aplikacji korzystającej z COM.
$legitPaths = @(
    "$env:WINDIR\System32\dllhost.exe",
    "$env:WINDIR\SysWOW64\dllhost.exe"
)
while ($true) {
    $procs = Get-Process | Where-Object { $_.ProcessName -eq ($targetName -replace ".exe", "") }
    foreach ($proc in $procs) {
        $targetpid = $proc.Id
        if ($dumpedPIDs.ContainsKey($targetpid)) { continue }

        # Sprawdź ścieżkę - legalny COM Surrogate pomijamy
        $procPath = $null
        try { $procPath = $proc.Path } catch { $procPath = $null }
        if ($procPath -and ($legitPaths -contains $procPath)) {
            continue
        }
        Log "Non-standard $targetName PID $targetpid path=$procPath -> przetwarzam"

        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
        $dumpFile = "$dumpPath\${targetName}_PID${targetpid}_$timestamp.dmp"
        $metaFile = "$dumpPath\${targetName}_PID${targetpid}_$timestamp-info.txt"

        try {
            # Zamrożenie
            Write-Host "🧊 Zamrażam PID: $targetpid"
            Log "Zamrażanie PID: $targetpid"
            Start-Process -NoNewWindow -FilePath $pssuspend -ArgumentList "$targetpid"
            Start-Sleep -Milliseconds 300

            # Zbieranie informacji
            $cmdline = (Get-CimInstance Win32_Process -Filter "ProcessId=$targetpid").CommandLine
            $ppid = (Get-CimInstance Win32_Process -Filter "ProcessId=$targetpid").ParentProcessId
            try {
                $dlls = (Get-Process -Id $targetpid).Modules | ForEach-Object { $_.FileName }
            } catch {
                $dlls = @("Błąd pobierania DLLs: $_")
            }

            # Zapis metadanych
            "=== PID: $targetpid ===" | Out-File -FilePath $metaFile -Encoding UTF8
            "CommandLine: $cmdline" | Out-File -Append -FilePath $metaFile -Encoding UTF8
            "Parent PID: $ppid" | Out-File -Append -FilePath $metaFile -Encoding UTF8
            "DLLs:" | Out-File -Append -FilePath $metaFile -Encoding UTF8
            $dlls | Out-File -Append -FilePath $metaFile -Encoding UTF8

            Log "Zebrano info o PID $targetpid"

            # Dump pamięci — -Wait, żeby procdump skończył przed następną iteracją
            Write-Host "💾 Dumpuję PID: $targetpid → $dumpFile"
            Log "Dumping $targetpid to $dumpFile"
            Start-Process -NoNewWindow -Wait -FilePath $procDumpPath -ArgumentList "-accepteula", "-ma", $targetpid, $dumpFile
            $counter++
            $dumpedPIDs[$targetpid] = $true
            Log "Dump zakończony PID $targetpid"

            # Można dodać tu kopiowanie dumpa do bezpiecznego folderu
            # Copy-Item $dumpFile "E:\Backup\$($targetName)_$targetpid_$timestamp.dmp"

            # Tryb anty-dezintegracyjny
            Start-Sleep -Seconds 2

        } catch {
            Log ("❌ Błąd dumpowania PID ${targetpid}: " + $_)
        }

        if ($counter -ge $maxDumps) {
            Write-Host "✅ Limit dumpów ($maxDumps) osiągnięty. Zakończono."
            Log "Zakończenie – limit dumpów osiągnięty."
            exit
        }
    }
    Start-Sleep -Milliseconds $intervalMs
}