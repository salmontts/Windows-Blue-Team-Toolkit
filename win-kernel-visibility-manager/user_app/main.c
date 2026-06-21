#include <stdio.h>
#include <windows.h>
#include "VisibilityManagerUser.h"

int main() {
    HANDLE hDevice = CreateFileA(DEVICE_NAME, 
                                 GENERIC_READ | GENERIC_WRITE, 
                                 0, 
                                 NULL, 
                                 OPEN_EXISTING, 
                                 0, 
                                 NULL);

    if (hDevice == INVALID_HANDLE_VALUE) {
        printf("Failed to open device: %lu\n", GetLastError());
        return 1;
    }

    // Przykładowe PID-y do filtrowania
    FILTER_PIDS filter;
    filter.PidCount = 2;
    filter.Pids[0] = 1234; // Podmień na rzeczywiste PID-y
    filter.Pids[1] = 5678;

    DWORD bytesReturned;

    // Wyślij PID-y do sterownika
    if (!DeviceIoControl(hDevice, 
                         IOCTL_FILTER_PIDS, 
                         &filter, 
                         sizeof(FILTER_PIDS), 
                         NULL, 
                         0, 
                         &bytesReturned, 
                         NULL)) {
        printf("Failed to set filter PIDs: %lu\n", GetLastError());
        CloseHandle(hDevice);
        return 1;
    }

    // Odczytaj przefiltrowaną listę procesów
    PROCESS_LIST procList = {0};
    if (!DeviceIoControl(hDevice, 
                         IOCTL_GET_PROCESSES, 
                         NULL, 
                         0, 
                         &procList, 
                         sizeof(procList), 
                         &bytesReturned, 
                         NULL)) {
        printf("Failed to get filtered processes: %lu\n", GetLastError());
        CloseHandle(hDevice);
        return 1;
    }

    // Wyświetl przefiltrowane procesy
    for (ULONG i = 0; i < procList.ProcessCount; i++) {
        printf("Process ID: %lu, Name: %ls\n", 
            procList.Processes[i].ProcessId, 
            procList.Processes[i].ProcessName);
    }

    CloseHandle(hDevice);
    return 0;
}