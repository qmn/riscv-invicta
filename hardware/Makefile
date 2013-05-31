VERILOG = iverilog

SRCS = alu.v \
	alu_dec.v \
	arbiter.v \
	branch_jump.v \
	consts.vh \
	control_processor.v \
	data_memory.v \
	datapath.v \
	decode.v \
	inst_decoder.v \
	mem_mux.v \
	memory_system.v \
	multiplier.v \
	regfile.v \
	simulated_memory.v \
	tlb.v \
	top.v \
	translater.v


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
