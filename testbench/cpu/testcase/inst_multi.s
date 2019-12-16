.org 0x0
	.global _start
	.set noreorder
	.set nomacro
	.set noat
_start:
	ori $1, $0, 0x0001  # ans: $1=0x00000001
	ori $2, $0, 0x2345  # ans: $2=0x00002345
	mthi $1             # ans: $hilo=0x0000000100000000
	mtlo $2             # ans: $hilo=0x0000000100002345
	ori $3, $0, 0xffff  # ans: $3=0x0000ffff
	lui $4, 0xffff      # ans: skip
	ori $4, $4, 0xfff1  # ans: $4=0xfffffff1
	ori $5, $0, 0x0011  # ans: $5=0x00000011

.org 0x380
	ori   $1, $0, 0xabcd  # ans: $1=0x0000abcd