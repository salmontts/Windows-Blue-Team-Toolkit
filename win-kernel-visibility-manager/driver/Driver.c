// Driver.c - Main entry point for the kernel-mode driver

#include <ntddk.h>
#include "Driver.h"
#include "VisibilityManager.h"

PDEVICE_OBJECT g_DeviceObject = NULL;
UNICODE_STRING g_DeviceName;
UNICODE_STRING g_SymbolicLinkName;

NTSTATUS DriverEntry(PDRIVER_OBJECT DriverObject, PUNICODE_STRING RegistryPath) {
    NTSTATUS status;
    UNICODE_STRING deviceName = RTL_CONSTANT_STRING(L"\\Device\\VisibilityManager");
    UNICODE_STRING symbolicLinkName = RTL_CONSTANT_STRING(L"\\DosDevices\\VisibilityManager");

    DriverObject->DriverUnload = UnloadDriver;

    status = IoCreateDevice(DriverObject, 0, &deviceName, FILE_DEVICE_UNKNOWN, 0, FALSE, &g_DeviceObject);
    if (!NT_SUCCESS(status)) {
        return status;
    }

    status = IoCreateSymbolicLink(&symbolicLinkName, &deviceName);
    if (!NT_SUCCESS(status)) {
        IoDeleteDevice(g_DeviceObject);
        return status;
    }

    g_DeviceName = deviceName;
    g_SymbolicLinkName = symbolicLinkName;

    DriverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL] = DeviceControl;

    return STATUS_SUCCESS;
}

VOID UnloadDriver(PDRIVER_OBJECT DriverObject) {
    IoDeleteSymbolicLink(&g_SymbolicLinkName);
    IoDeleteDevice(g_DeviceObject);
}

NTSTATUS DeviceControl(PDEVICE_OBJECT DeviceObject, PIRP Irp) {
    PIO_STACK_LOCATION stack = IoGetCurrentIrpStackLocation(Irp);
    NTSTATUS status = STATUS_SUCCESS;

    switch (stack->Parameters.DeviceIoControl.IoControlCode) {
        // Handle various IOCTLs here
        default:
            status = STATUS_INVALID_DEVICE_REQUEST;
            break;
    }

    Irp->IoStatus.Status = status;
    IoCompleteRequest(Irp, IO_NO_INCREMENT);
    return status;
}