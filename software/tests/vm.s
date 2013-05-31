.global _start

_start:
        li x1, 0x00001000 /* ptbr and pgd */
        li x2, 0x00002000 /* pmd */
        li x3, 0x00003000 /* pte */
        sw x2, 0(x1)
        sw x3, 0(x2)
        nop
        nop
        mtpcr x1, cr7
        mfpcr x5, cr0
        ori x5, x5, 0x100
        mtpcr x5, cr0
        nop
        nop
        addi x4, x0, 1
        mtpcr x4, cr30


