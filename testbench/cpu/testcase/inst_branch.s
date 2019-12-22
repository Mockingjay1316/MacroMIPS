.org 0x0
.set noat
.set noreorder

.globl _start 

_start:
    ori $1, $0, 0x0001    # ans: $1=0x00000001
    ori $2, $0, 0x0001    # ans: $2=0x00000001
    ori $3, $0, 0x0004    # ans: $3=0x00000004
    beq $1, $2, B1        # ans: skip
    ori $5, $0, 0x0001    # ans: $5=0x00000001
    ori $6, $0, 0x0001    

B1:
    bne $2, $3, B2        # ans: skip
    xori $5, $5, 0x0002   # ans: $5=0x00000003
    xori $6, $6, 0x0002   

B2:
    bgez $0, B3           # ans: skip
    ori $5, $5, 0x0004    # ans: $5=0x00000007
    ori $6, $6, 0x0004

B3:
    addiu $1, $1, 0xfffe  # ans: $1=0xffffffff
    bltz $1, B4           # ans: skip
    addiu $5, $5, 0x0008  # ans: $5=0x0000000f
    addiu $6, $6, 0x0008

B4:
    bgtz $2, B5           # ans: skip
    xori $5, $5, 0x0010   # ans: $5=0x0000001f
    xori $6, $6, 0x0010

B5:
    blez $0, B6           # ans: skip
    addiu $5, $5, 0x0020  # ans: $5=0x0000003f
    addiu $6, $6, 0x0020

B6:
    beq $1, $2, B1        # ans: skip
    ori $5, $5, 0x0040    # ans: $5=0x0000007f
    addiu $2, $2, 0xfffe  # ans: $2=0xffffffff
    bne $1, $2, B1        # ans: skip
    ori $5, $5, 0x0080    # ans: $5=0x000000ff
    bgez $1, B1           # ans: skip
    xori $5, $5, 0x0100   # ans: $5=0x000001ff
    bltz $0, B1           # ans: skip
    xori $5, $5, 0x0200   # ans: $5=0x000003ff
    bgtz $0, B1           # ans: skip
    addiu $5, $5, 0x0400  # ans: $5=0x000007ff
    blez $3, B1           # ans: skip
    addiu $5, $5, 0x0800  # ans: $5=0x00000fff
    nop