.org 0x0
.global _start
.set noat

_start:
	ori   $1,  $0,  0xFFFF
	ori   $4,  $0,  0x1
	ori   $7,  $0,  0x1
	ori   $9,  $0,  0x1
	ori   $10, $0,  0x1
	lui   $31, 0x8000
	addu  $1,  $31, $0
	ori   $3,  $0,  0xFFFF
	sltiu $4,  $3,  -1
	sltiu $5,  $1,  -1
	slti  $6,  $1,  -1
	sltu  $7,  $1,  $3
	slt   $8,  $1,  $3
	slt   $10, $0,  $10
	addiu $2,  $1,  1
	addu  $3,  $3,  $3
	subu  $2,  $2,  $1
	
