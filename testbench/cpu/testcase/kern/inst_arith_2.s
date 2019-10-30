.org 0x0
.global _start
.set noat

_start:
	ori   $1,  $0,  0x8000
	sll   $1,  $1,  16
	ori   $1,  $1,  0x0010

	ori   $2,  $0,  0x8000
	sll   $2,  $0,  16
	ori   $2,  $2,  0x0001
	ori   $3,  $0,  0x0000
	addu  $3,  $2,  $1
	ori   $3,  $0,  0x0000
	addu  $3,  $2,  $1

	subu $3, $1, $3 
	subu $3, $3, $2
	addiu $3, $3, 2
	ori $3, $0, 0x0000 
	addiu $3, $3, 0x8000

	or $1, $0, 0xffff 
	sll $1, $1, 16
	slt $2, $1, $0
	sltu $2, $1, $0
	slti $2, $1, 0x8000 
	sltiu $2, $1, 0x8000
	ori $1, $0, 0xffff 
	sll $1, $1, 16
	ori $1, $1, 0xfffb
	ori $2, $0, 6
	mult $1, $2





	
