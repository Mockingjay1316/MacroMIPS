GCCPREFIX = /Users/kingjames/Downloads/mipsel-linux-musl-cross/bin/mipsel-linux-musl-

override CFLAGS	+= -fno-builtin -nostdlib  -nostdinc -g  -EL -G0 -Wformat
override LDFLAGS	+= -nostdlib -EL -n -G0

CC 		:=$(GCCPREFIX)gcc
LD      := $(GCCPREFIX)ld
AS      := $(GCCPREFIX)as
OBJCOPY := $(GCCPREFIX)objcopy
OBJDUMP := $(GCCPREFIX)objdump

SRC   := $(wildcard *.s)
COES  := $(patsubst %.s, %.coe, $(SRC))
MIFS  := $(patsubst %.s, %.mif, $(SRC))
BINS  := $(patsubst %.s, %.bin, $(SRC))
MEMS  := $(patsubst %.s, %.mem, $(SRC))

all: $(MEMS)

%.o: %.s
	$(AS) -o $@ $^

%.mem: %.o
	$(OBJCOPY) --dump-section .text=/dev/stdout $< | xxd -c 4 -g 32 | cut -f 2 -d " " > $@

clean:
	rm *.mem

