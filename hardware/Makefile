VERILOG = iverilog

SRCS = alu.v alu_dec.v consts.vh datapath.v regfile.v decode.v multiplier.v branch_jump.v memory.v arbiter.v mem.v top.v inst_decoder.v control_processor.v

TEST_SRCS = tests/top_test.v

a.out : $(SRCS)
	$(VERILOG) -o $@ $(SRCS)

# [ ] has non-stalled instructions
test : test.out
	./test.out

test.out: $(TEST_SRCS) $(SRCS)
	$(VERILOG) -o $@ $(TEST_SRCS) $(SRCS)

JUNK = test.out a.out

clean :
	rm -f $(JUNK)
