RM	:= rm -f
ifeq ($(OS),Windows_NT)
# Windows Host
GCCPREFIX	?= mips-mti-elf-
else
#GCCPREFIX	:= mipsel-linux-gnu-
GCCPREFIX	?= mips-mti-elf-
endif
QEMU := qemu-system-mipsel
LD	:= $(GCCPREFIX)ld
CC	:= $(GCCPREFIX)gcc
MODULE	:= init
OBJDIR	:= obj
INCLUDE	:= include
SRCDIR	:= kern
LDSCRIPT	:= kern/kernel.ld
SRC	:= $(foreach sdir, $(SRCDIR), $(wildcard $(sdir)/*.S))
OBJ	:= $(patsubst $(SRCDIR)/%.S, $(OBJDIR)/%.o, $(SRC))
TARGET	:= kernel.elf
ASFLAG	:= -D__ASSEMBLY__ -EL -g -mips32r2 -mno-abicalls -mno-shared

CONFIG_FILE := .config_$(ON_FPGA)_$(EN_INT)_$(EN_TLB)

.PHONY: all clean show-utest

all: $(TARGET) kernel.bin

$(CONFIG_FILE):
	@rm -f .config_*
	touch $@

$(TARGET): checkdirs $(OBJ) $(LDSCRIPT)
	$(LD) $(OBJ) -T$(LDSCRIPT)

$(OBJ): $(OBJDIR)/%.o : $(SRCDIR)/%.S $(CONFIG_FILE)
	$(CC) -o $@ $< -c -I$(INCLUDE) $(ASFLAG)


checkdirs: $(OBJDIR)

$(OBJDIR):
	test -d $@ || mkdir $@

kernel.bin: $(TARGET)
	@$(GCCPREFIX)objcopy -j .text -j .text.* -O binary -v $< kernel.bin


.PHONY: commits-num show-utest sim clean

commits-num:
	@git log --pretty=format:"commit %H" | grep -c 'commit'

clean:
	-$(RM) -r $(OBJDIR)
