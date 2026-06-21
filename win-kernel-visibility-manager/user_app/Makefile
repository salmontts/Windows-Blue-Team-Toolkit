# Makefile for the user-mode application

CC = gcc
CFLAGS = -Wall -Wextra -I. -I../driver
LDFLAGS = -lntdll
TARGET = visibility_manager_user
SOURCES = main.c
OBJECTS = $(SOURCES:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJECTS) $(TARGET)