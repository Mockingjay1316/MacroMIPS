
GCCPREFIX	?=mipsel-linux-musl-

override CFLAGS	+= -fno-builtin -nostdlib  -nostdinc -g  -EL -G0 -Wformat
override LDFLAGS	+= -nostdlib -EL -n -G0

CC :=$(GCCPREFIX)gcc
LD      := $(GCCPREFIX)ld
AS      := $(GCCPREFIX)as -EL -g -mips32
AR      := $(GCCPREFIX)ar
OBJCOPY := $(GCCPREFIX)objcopy
OBJDUMP := $(GCCPREFIX)objdump

SRC   := $(wildcard *.s)
COES  := $(patsubst %.s, %.coe, $(SRC))
MIFS  := $(patsubst %.s, %.mif, $(SRC))
BINS  := $(patsubst %.s, %.bin, $(SRC))
MEMS  := $(patsubst %.s, %.mem, $(SRC))

all: $(BINS)

%.rom.bin: %.rom.elf
	$(OBJCOPY) -j .text -O binary  -S $^ $@

%.rom.elf: %.o
	$(LD) $(LDFLAGS) -Ttext 0xbfc00000 -o $@ $^

%.bin: %.elf
	$(OBJCOPY) -j .text -O binary $^ $@

%.elf: %.o
	$(LD) $(LDFLAGS) -Ttext 0x80000000 -o $@ $^

%.o: %.s
	$(CC) $(CFLAGS) -x assembler-with-cpp -g -c -o $@ $^
