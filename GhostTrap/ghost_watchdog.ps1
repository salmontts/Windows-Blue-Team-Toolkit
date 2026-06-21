# --- CONFIG ---
$dumpPath = "$env:USERPROFILE\Desktop\dumps"
$procDumpPath = ".\procdump.exe"
$intervalMs = 100
$maxDumps = 50

# --- LOGGING ---
function Log($msg) {
    $logFile = "$dumpPath\watchdog_log.txt"
    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss.fff')) - $msg" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

# --- INIT ---
if (!(Test-Path $dumpPath)) { New-Item -ItemType Directory -Path $dumpPath | Out-Null }
Write-Host "🎯 WATCHDOG dumps only processes frozen by FULLTRAP_NATIVE every ${intervalMs}ms..."
Log "WATCHDOG started. Dumping only processes frozen by FULLTRAP_NATIVE."

# --- LOAD PIDs to dump ---
$frozenPidsFile = "$PSScriptRoot\frozen_pids.txt"
$dumpedPIDs = @{}
$counter = 0

while ($true) {
    $frozenPIDs = @{}
    if (Test-Path $frozenPidsFile) {
        Get-Content $frozenPidsFile | ForEach-Object {
            if ($_ -match "PID=(\d+)") {
                $targetpid = $matches[1]
                $frozenPIDs[$targetpid] = $true
            }
        }
    }
    foreach ($targetpid in $frozenPIDs.Keys) {
        if ($dumpedPIDs.ContainsKey($targetpid)) { continue }
        # PID z regex jest stringiem -> rzutuj na int dla Get-Process
        $pidInt = [int]$targetpid
        try {
            $proc = Get-Process -Id $pidInt -ErrorAction Stop
        } catch {
            continue
        }
        $procName = $proc.ProcessName + ".exe"
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss_fff"
        $dumpFile = "$dumpPath\${procName}_PID${targetpid}_$timestamp.dmp"
        $metaFile = "$dumpPath\${procName}_PID${targetpid}_$timestamp-info.txt"

        # Memory dump — -Wait, żeby nie odpalić wielu procdumpów na ten sam PID
        Write-Host "💾 Dumping PID: $pidInt → $dumpFile"
        Log "Dumping $pidInt to $dumpFile"
        Start-Process -NoNewWindow -Wait -FilePath $procDumpPath -ArgumentList "-accepteula", "-ma", $pidInt, $dumpFile

        # Collecting information
        $cmdline = (Get-CimInstance Win32_Process -Filter "ProcessId=$pidInt").CommandLine
        try {
            $dlls = (Get-Process -Id $pidInt).Modules | ForEach-Object { $_.FileName }
        } catch {
            $dlls = @("Error retrieving DLLs: $_")
        }

        # Write metadata
        "=== PID: $targetpid ===" | Out-File -FilePath $metaFile -Encoding UTF8
        "ProcessName: $procName" | Out-File -Append -FilePath $metaFile -Encoding UTF8
        "CommandLine: $cmdline" | Out-File -Append -FilePath $metaFile -Encoding UTF8
        "DLLs:" | Out-File -Append -FilePath $metaFile -Encoding UTF8
        $dlls | Out-File -Append -FilePath $metaFile -Encoding UTF8

        Log "Collected info about PID $targetpid"
        $dumpedPIDs[$targetpid] = $true
        $counter++
        Log "Dump finished for PID $targetpid"

        if ($counter -ge $maxDumps) {
            Write-Host "✅ Dump limit ($maxDumps) reached. Exiting."
            Log "Exiting – dump limit reached."
            exit
        }
    }
    Start-Sleep -Milliseconds $intervalMs
}