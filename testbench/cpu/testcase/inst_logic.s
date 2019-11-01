.org 0x0
.global _start
.set noat

_start:
	lui  $1, 0x0101			# ans: $1=0x01010000
	ori  $1, $1, 0x0110 	# ans: $1=0x01010110
	ori  $2, $1, 0x1100		# ans: $2=0x01011110
	or   $1, $1, $2			# ans: $1=0x01011110
	andi $3, $1, 0x00ef		# ans: $3=0x00000000
	and  $1, $3, $1			# ans: $1=0x00000000
	xori $4, $1, $0xff00	# ans: $4=0x0000ff00
	xor  $1, $4, $1			# ans: $1=0x0000ff00
	nor  $1, $4, $1			# ans: $1=0xffff00ff
	



