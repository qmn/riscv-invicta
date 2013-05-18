/*
 * Copyright (c) 2013, Quan Nguyen
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * 
 *     Redistributions of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 *     Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation and/or
 * other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* Simulated Memory Device */
module mem (
	input clk,
	input reset,
	
	input [31:0] addr,
	input [3:0] mask,
	input enable,

	input cmd,
	input [31:0] write_data,
	output reg [31:0] load_data,
	output reg valid
);
	reg [31:0] memory [255:0];

	wire [7:0] word_addr = addr[9:2];

	initial begin
		$readmemh("mem.hex", memory);
	end

	always @ (*) begin
		if (enable && cmd == `MEM_CMD_READ) begin
			load_data = memory[word_addr];
			valid = 1;
		end else begin
			load_data = 32'b0;
			valid = 0;
		end
	end

	wire [31:0] expanded_mask = {mask[3] ? 8'hFF : 8'h00,
	                             mask[2] ? 8'hFF : 8'h00,
	                             mask[1] ? 8'hFF : 8'h00,
	                             mask[0] ? 8'hFF : 8'h00};

	always @ (*) begin
		if (enable && cmd == `MEM_CMD_WRITE) begin
			memory[word_addr] = (memory[word_addr] & ~expanded_mask) | write_data;
		end
	end

endmodule
