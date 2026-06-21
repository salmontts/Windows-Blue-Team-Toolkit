# dllhost_watchdog.ps1

A PowerShell watchdog script for monitoring and memory-dumping suspicious `dllhost.exe` processes. Useful for malware analysis and incident response.

## Features

- Monitors for new `dllhost.exe` processes at a configurable interval.
- Suspends the process, collects metadata (command line, parent PID, loaded DLLs).
- Dumps process memory using [ProcDump](https://docs.microsoft.com/en-us/sysinternals/downloads/procdump).
- Logs all actions and errors.
- Stops after a configurable number of dumps.

## Requirements

- **Windows** (tested on Windows 10/11)
- **PowerShell 5.1+**
- [ProcDump](https://docs.microsoft.com/en-us/sysinternals/downloads/procdump) (`procdump.exe`) and [PsSuspend](https://docs.microsoft.com/en-us/sysinternals/downloads/pssuspend) (`pssuspend.exe`) in the script directory or in PATH.
- Run as **Administrator** for full access.

## Usage

1. Download or clone this repository.
2. Place `procdump.exe` and `pssuspend.exe` in the same directory as the script, or ensure they are in your PATH.
3. Open PowerShell as Administrator.
4. Navigate to the script directory.
5. Run:

   ```powershell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\dllhost_watchdog.ps1
   ```

6. Dumps and logs will be saved to a `dumps` folder on your Desktop.

## Configuration

You can adjust these variables at the top of the script:

- `$targetName` – process name to watch (default: `dllhost.exe`)
- `$dumpPath` – where to save dumps/logs (default: Desktop\dumps)
- `$procDumpPath` – path to `procdump.exe`
- `$pssuspend` – path to `pssuspend.exe`
- `$intervalMs` – scan interval in milliseconds (default: 100)
- `$maxDumps` – maximum number of dumps before exit (default: 50)

## Notes

- All logs are saved to `watchdog_log.txt` in the dump folder.
- Script messages and logs are currently in Polish. For broader use, translate to English.
- Script is designed for analysis and should not be used on production systems.

## License

MIT