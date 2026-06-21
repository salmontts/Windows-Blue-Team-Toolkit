// VisibilityManager.h

#ifndef VISIBILITY_MANAGER_H
#define VISIBILITY_MANAGER_H

#include <ntddk.h>

typedef struct _FILTERED_PROCESS {
    HANDLE ProcessId;
    WCHAR ProcessName[MAX_PATH];
} FILTERED_PROCESS, *PFILTERED_PROCESS;

NTSTATUS FilterProcesses(PFILTERED_PROCESS FilteredProcesses, ULONG* ProcessCount);
NTSTATUS SetProcessFilter(HANDLE ProcessId);
NTSTATUS ClearProcessFilter(HANDLE ProcessId);

#endif // VISIBILITY_MANAGER_H