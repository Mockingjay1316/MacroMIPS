.org 0x0
.global _start
.set noat

_start:
    li $1, 0x1      # ans: $1=0x00000001
    li $2, 0x2      # ans: $2=0x00000002
    li $3, 0x3      # ans: $3=0x00000003

    mtc0 $1, $0     # ans: cp0=0x00000001
    mfc0 $4, $0     # ans: $4=0x00000001
    nop
    mtc0 $2, $0     # ans: cp0=0x00000002
    mtc0 $3, $0     # ans: cp0=0x00000003
    mfc0 $4, $0     # ans: $4=0x00000003
    addiu $4, $4, 1 # ans: $4=0x00000004
    mtc0 $4, $0     # ans: cp0=0x00000004
    mfc0 $5, $0     # ans: $5=0x00000004
    mtc0 $2, $1     # ans: cp1=0x00000002
