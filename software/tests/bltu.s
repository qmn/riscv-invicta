.global _start

_start:
	nop
	li a0, 1
	li a1, -1
	blt a0, a1, failure
	bltu a0, a1, success
	j failure

success:
	li a3, 1
	mtpcr a3, cr30
	nop

failure:
	li a3, 2
	mtpcr a3, cr30
	nop
