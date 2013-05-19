/* A simple stop test */

.global _start

_start:
	nop
	nop
	addi a0, a0, 1
	mtpcr a0, cr30
	nop
