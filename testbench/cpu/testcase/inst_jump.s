	.org 0x0
	.global _start
	.set noreorder
	.set nomacro
	.set noat
_start:
	ori $1, $0, 0x0001   # ans: $1=0x00000001
	j 0x20 			     # ans: skip
	ori $1, $0, 0x0002 	 # ans: $1=0x00000002
	ori $1, $0, 0x1111 
	ori $1, $0, 0x1100

.org 0x20 
	ori $1, $0, 0x0003	 # ans: $1=0x00000003
	jal 0x40             # ans: $31=0x8000002c
	ori $1, $0, 0x0005   # ans: $1=0x00000005
	ori $1, $0, 0x0006   
	j 0x60 				
	nop

.org 0x40
	jalr $2, $31 		 # ans: $2=0x80000048
	or $1, $2, $0 		 # ans: $1=0x80000048
	# ans: $1=0x00000006
	# ans: skip
	ori $1, $0, 0x0004   
	ori $1, $0, 0x000b   
	j 0x80 
	nop

.org 0x60
	ori $1, $0, 0x0009   # ans: $1=0x00000009
	jr $2 				 # skip
	ori $1, $0, 0x0008 	 # ans: $1=0x00000008
	# ans: $1=0x00000004
	# ans: $1=0x0000000b

.org 0x80
	nop
