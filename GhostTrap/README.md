# GhostTrap

## Overview

**GhostTrap** is a Windows toolset for detecting, suspending, and dumping suspicious root processes.  
It consists of two main components:

- **FULLTRAP_NATIVE** (C++): Scans for root processes, suspends those not on a whitelist, and logs their PIDs and executable paths to a file.
- **ghost_watchdog.ps1** (PowerShell): Reads the list of suspended PIDs and creates memory dumps of those processes using Sysinternals' procdump.

## Project Structure

```
GhostTrap/
├── FULLTRAP_NATIVE.cpp      # C++ source code
├── ghost_watchdog.ps1       # PowerShell script for dumping processes
├── procdump.exe             # Sysinternals tool for process dumps (required)
├── start.bat                # Batch script to launch both tools
├── frozen_pids.txt          # (generated) List of suspended PIDs
└── .vscode/                 # VS Code settings (optional)
```

## Requirements

- Windows 10/11
- C++ compiler (MSVC or MinGW-w64)
- PowerShell
- [procdump.exe](https://docs.microsoft.com/en-us/sysinternals/downloads/procdump) (place in the project folder)

## Quick Start

1. **Compile FULLTRAP_NATIVE.cpp**  
   Open a terminal in the project folder and run:
   ```
   cl FULLTRAP_NATIVE.cpp /FeFULLTRAP_NATIVE.exe /link psapi.lib
   ```
   or (MinGW):
   ```
   g++ FULLTRAP_NATIVE.cpp -o FULLTRAP_NATIVE.exe -lpsapi
   ```

2. **Run the toolset**  
   The easiest way is to use:
   ```
   start.bat
   ```
   This will launch the process suspender and then the dumper.

3. **Results**  
   - Suspended processes are logged in `frozen_pids.txt`
   - Dumps and logs are saved in `C:\Users\<user>\Desktop\dumps`

## Whitelist

The following processes are never suspended:
- System Idle Process
- System
- csrss.exe
- smss.exe
- wininit.exe
- winlogon.exe
- services.exe
- lsass.exe

## Notes

- **Run as administrator!**
- Use at your own risk – suspending system processes can be dangerous.
- Do **not** commit `.exe`, `.obj`, `.dmp`, or other generated files to the repository.

## .gitignore Example

```
*.exe
*.obj
*.dmp
*.log
frozen_pids.txt
dumps/
```

## License

MIT

---

**Author:**
Sentio (`salmontts`) — Adrian Jędrocha
