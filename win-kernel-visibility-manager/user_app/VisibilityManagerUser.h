// This header file declares functions and structures used in main.c,
// including the definitions for device communication and data structures 
// for sending and receiving information.

#ifndef VISIBILITY_MANAGER_USER_H
#define VISIBILITY_MANAGER_USER_H

#include <windows.h>

#define DEVICE_NAME "\\\\.\\VisibilityManager"
#define IOCTL_FILTER_PIDS CTL_CODE(FILE_DEVICE_UNKNOWN, 0x800, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define IOCTL_GET_PROCESSES CTL_CODE(FILE_DEVICE_UNKNOWN, 0x801, METHOD_BUFFERED, FILE_ANY_ACCESS)

typedef struct _FILTER_PIDS {
    ULONG PidCount;
    ULONG Pids[256]; // Array to hold PIDs to filter
} FILTER_PIDS, *PFILTER_PIDS;

typedef struct _PROCESS_INFO {
    ULONG ProcessId;
    WCHAR ProcessName[MAX_PATH];
} PROCESS_INFO, *PPROCESS_INFO;

typedef struct _PROCESS_LIST {
    ULONG ProcessCount;
    PROCESS_INFO Processes[256]; // Array to hold process information
} PROCESS_LIST, *PPROCESS_LIST;

// Function prototypes
HANDLE OpenVisibilityManagerDevice();
BOOL FilterPids(HANDLE hDevice, PFILTER_PIDS pFilterPids);
BOOL GetProcesses(HANDLE hDevice, PPROCESS_LIST pProcessList);
void CloseVisibilityManagerDevice(HANDLE hDevice);

#endif // VISIBILITY_MANAGER_USER_H