set PATH=util\python37-32;util\msys\1.0\bin;util\toolchain\bin;util\qemu;%PATH%
make CROSS_COMPILE=mips-mti-elf- ON_FPGA=n qemu
pause