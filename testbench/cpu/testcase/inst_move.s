	.org 0x0
	.global _start
	.set noat
_start:
	lui $1, 0xf00f      # ans: $1=0xf00f0000
	lui $2, 0x5555      # ans: $2=0x55550000
	ori $3, $2, 0xaaaa  # ans: $3=0x5555aaaa

	movz $3, $1, $3     # not moved
	ori  $3, $3, 0x0000 # ans: $3=0x5555aaaa

	movz $3, $1, $0     # ans: $3=0xf00f0000

	movn $3, $2, $2     # ans: $3=0x55550000
	movn $3, $1, $0     # not moved
	ori  $3, $3, 0x0000 # ans: $3=0x55550000
	lui $3, 0xffac      # ans: $3=0xffac0000