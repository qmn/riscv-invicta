# 
# Copyright (c) 2013, Quan Nguyen
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
#     Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#     Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 

# Simulation Makefile

ICARUS_VERILOG = iverilog
XILINX_FUSE = fuse

# Module of the "top" module
XILINX_TOP = top_test

TEST_SRCS = tests/top_test.v
SRCS = \
	alu.v \
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


# Icarus Verilog backend
test-icarus : iverilog.out
	./iverilog.out

iverilog.out: $(TEST_SRCS) $(SRCS)
	$(ICARUS_VERILOG) -o $@ $(TEST_SRCS) $(SRCS)

# Xilinx toolchain
test-xilinx : fuse.out fuse.tcl
	./fuse.out -tclbatch fuse.tcl

fuse.out : invicta.prj
	$(XILINX_FUSE) -o $@ -prj $< $(XILINX_TOP)

invicta.prj :
	for i in $(SRCS) $(TEST_SRCS); do \
		echo "verilog work" $$i >> invicta.prj; \
	done

fuse.tcl :
	echo "run all" > $@

XILINX_JUNK = fuse* invicta.prj isim*

JUNK = iverilog.out $(XILINX_JUNK)

clean :
	rm -rf $(JUNK)
