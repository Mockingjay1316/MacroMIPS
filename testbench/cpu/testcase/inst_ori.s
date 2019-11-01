.org 0x0
.global _start
.set noat

_start:
	ori $1, $0, 0x1100		# ans: $1=0x00001100
	ori $1, $1, 0x0030		# ans: $2=0x00001130
	ori $1, $1, 0x4400		# and: $3=0x00005530
	ori $1, $1, 0x0044		# and: $4=0x00005574


