// This header file declares functions and structures used in Driver.c,
// including device control functions and necessary includes for kernel-mode programming.

#ifndef DRIVER_H
#define DRIVER_H

#include <ntddk.h>

// Device name and symbolic link
#define DEVICE_NAME L"\\Device\\VisibilityManager"
#define SYMLINK_NAME L"\\DosDevices\\VisibilityManager"

// Function prototypes
NTSTATUS DriverEntry(PDRIVER_OBJECT DriverObject, PUNICODE_STRING RegistryPath);
VOID DriverUnload(PDRIVER_OBJECT DriverObject);
NTSTATUS CreateDevice(PDRIVER_OBJECT DriverObject);
NTSTATUS DeviceControl(PDEVICE_OBJECT DeviceObject, PIRP Irp);
NTSTATUS CleanupDevice(PDEVICE_OBJECT DeviceObject);

#endif // DRIVER_H