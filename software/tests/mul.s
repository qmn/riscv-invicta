.global _start

_start:
	li a0, 0xb6db6db7
	li a1, 0x7fc0
	li a2, 0x1240
	mul a3, a0, a1
	beq a3, a2, success

failure:
	li a4, 2
	mtpcr a4, cr30

success:
	li a4, 1
	mtpcr a4, cr30
