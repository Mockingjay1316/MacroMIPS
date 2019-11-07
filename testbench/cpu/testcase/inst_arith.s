.org 0x0
.global _start
.set noat

_start:
	ori   $2,  $0,  0xFFFF     # ans: $2=0x0000ffff
	ori   $4,  $0,  0x1		   # ans: $4=0x00000001
	ori   $7,  $0,  0x1        # ans: $7=0x00000001
	ori   $9,  $0,  0x1        # ans: $9=0x00000001
	ori   $10, $0,  0x1        # ans: $10=0x00000001
	lui   $31, 0x8000          # ans: $31=0x80000000
	addu  $1,  $31, $0         # ans: $1=0x80000000
	ori   $3,  $0,  0xFFFF     # ans: $3=0x0000ffff
	sltiu $4,  $3,  -1         # ans: $4=0x00000001
	sltiu $5,  $1,  -1         # ans: $5=0x00000001
	slti  $6,  $1,  -1	       # ans: $6=0x00000001
	slt   $8,  $1,  $3         # ans: $8=0x00000001
	slt   $10, $0,  $10        # ans: $10=0x00000001
	addiu $2,  $1,  1          # ans: $2=0x80000001
	addu  $3,  $3,  $3         # ans: $3=0x0001fffe
	subu  $2,  $2,  $1		   # ans: $2=0x00000001
	
