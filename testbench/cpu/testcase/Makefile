GCCPREFIX = /Users/kingjames/Downloads/mipsel-linux-musl-cross/bin/mipsel-linux-musl-

override CFLAGS	+= -fno-builtin -nostdlib  -nostdinc -g  -EL -G0 -Wformat
override LDFLAGS	+= -nostdlib -EL -n -G0

CC 		:=$(GCCPREFIX)gcc
LD      := $(GCCPREFIX)ld
AS      := $(GCCPREFIX)as
OBJCOPY := $(GCCPREFIX)objcopy
OBJDUMP := $(GCCPREFIX)objdump

SRC   := $(wildcard *.s)
ANS  := $(patsubst %.s, %.ans, $(SRC))
MEMS  := $(patsubst %.s, %.mem, $(SRC))

all: $(MEMS) $(ANS)

%.o: %.s
	$(AS) -o $@ $^

%.ans: %.s
	python extract_ans.py --input_file $< --output_file $@

%.mem: %.o
	$(OBJCOPY) --dump-section .text=/dev/stdout $< | xxd -c 4 -g 32 | cut -f 2 -d " " > $@

clean:
	rm *.mem *.ans


