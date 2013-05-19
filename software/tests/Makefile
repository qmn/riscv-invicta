RISCV_GCC = riscv-linux-gcc
RISCV_OBJDUMP = riscv-linux-objdump

TESTS = stop beq blt bltu

SRCS  = $(addsuffix .s, $(TESTS))
OUTS  = $(addsuffix .out, $(TESTS))
HEXS = $(addsuffix .hex, $(TESTS))

test : $(HEXS)

%.out : %.s
	$(RISCV_GCC) -c -o $@ $<

%.hex : %.out
	$(RISCV_OBJDUMP) -D $< | awk "{ if (match(\$$2, \"[0-9a-f]{8}\")) print \$$2 }" > $@

clean:
	rm -rf $(OUTS) $(HEXS)
