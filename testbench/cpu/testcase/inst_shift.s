.org 0x0
.global _start
.set noat

_start:
	ori   $1,  $0, 0xFFFF
	ori   $31, $0, 34
	sll   $2,  $1, 2
	sllv  $3,  $1, $31
	sll   $4,  $1, 32
	sra   $5,  $1, 2
	srl   $6,  $1, 2
	srav  $7,  $1, $31
	srlv  $8,  $1, $31

	

