TARGET = VisibilityManager.sys
OBJ = Driver.obj VisibilityManager.obj

!include <win32.mak>

all: $(TARGET)

$(TARGET): $(OBJ)
    $(LINK) $(OBJ) /OUT:$(TARGET) /SUBSYSTEM:WINDOWS /DRIVER

Driver.obj: Driver.c Driver.h
    $(CC) $(CFLAGS) /c Driver.c

VisibilityManager.obj: VisibilityManager.c VisibilityManager.h
    $(CC) $(CFLAGS) /c VisibilityManager.c

clean:
    del $(OBJ) $(TARGET)