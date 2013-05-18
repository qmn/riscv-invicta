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

module top (
	input clk,
	input reset
);

	wire stall;

	wire [31:0] fetch_addr;
	wire fetch_request;
	wire fetch_data_valid;
	
	wire [31:0] memory_addr;
	wire [31:0] write_data;
	wire [3:0] write_mask;
	wire memory_request;
	wire memory_request_type;
	wire memory_data_valid;

	wire[31:0] request_data;

	wire [31:0] m_addr;
	wire [3:0] m_mask;
	wire m_enable;
	wire m_cmd;
	wire [31:0] m_data;
	wire [31:0] m_wdata;
	wire m_valid;

	datapath dpath(.clk(clk), .reset(reset), .stall(stall),
		.fetch_addr(fetch_addr), .fetch_request(fetch_request), .fetch_data_valid(fetch_data_valid),
		.memory_addr(memory_addr), .write_data(write_data), .write_mask(write_mask),
		.memory_request(memory_request), .memory_request_type(memory_request_type), .memory_data_valid(memory_data_valid),
		.request_data(request_data));

	arbiter arbit(.clk(clk), .reset(reset),
		.request_data(request_data), .stall(stall), 
		.fetch_addr(fetch_addr), .fetch_request(fetch_request), .fetch_data_valid(fetch_data_valid),
		.memory_addr(memory_addr), .write_data(write_data), .write_mask(write_mask),
		.memory_request(memory_request), .memory_request_type(memory_request_type), .memory_data_valid(memory_data_valid),
		.addr(m_addr), .mask(m_mask), .enable(m_enable), .cmd(m_cmd), .data(m_data), .wdata(m_wdata), .valid(m_valid));

	mem simmem(.clk(clk), .reset(reset),
		.addr(m_addr), .mask(m_mask), .enable(m_enable), 
		.cmd(m_cmd), .load_data(m_data), .write_data(m_wdata), .valid(m_valid));

endmodule
