.org 0x0
.global _start
.set noat

_start:
    lui $s0, 0xa000      # ans: $16=0xa0000000
    ori $s0, $s0, 0x1000 # ans: $16=0xa0001000
	ori  $2, $0, 0x0001  # ans: $2=0x00000001
	lui  $4, 0xa000      # ans: $4=0xa0000000
	ori  $4, $4, 0x1004  # ans: $4=0xa0001004
	ori  $1, $0, 0xff00  # ans: $1=0x0000ff00
	sw   $4, 0xc($s0)    # ans: [0x100c]=0xa0001004
	sw   $1, 0x4($s0)    # ans: [0x1004]=0x0000ff00

	lw   $2, 0x0($4)    # ans: $2=0x0000ff00
	ori  $2, $2, 0x0001 # ans: $2=0x0000ff01

	lw   $1, 0x4($s0)    # ans: $1=0x0000ff00
	sw   $1, 0x8($s0)    # ans: [0x1008]=0x0000ff00
	lw   $3, 0x8($s0)    # ans: $3=0x0000ff00


	
