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

`include "consts.vh"

module arbiter (
	input clk,
	input reset,

	output [31:0] request_data,
	output stall,

	input [31:0] fetch_addr,
	input fetch_request,
	output fetch_data_valid,

	input [31:0] memory_addr,
	input [31:0] write_data,
	input [3:0] write_mask,
	input memory_request,
	input memory_request_type,
	output memory_data_valid,

	/* memory interface */
	output reg [31:0] addr,
	output [3:0] mask, /* write */
	output enable,
	output reg cmd,
	input [31:0] data,
	output [31:0] wdata,
	input valid
);

	wire requests_pending = fetch_request | memory_request;

	reg fetch_satisfied;
	reg memory_satisfied;

	localparam S_IDLE      = 2'b00;
	localparam S_SVC_FETCH = 2'b01;
	localparam S_SVC_MEM_R = 2'b10;
	localparam S_SVC_MEM_W = 2'b11;

	reg [1:0] state;
	reg [1:0] next_state;

	always @ (posedge clk) begin
		if (reset) begin
			state <= S_IDLE;
		end else begin
			state <= next_state;
		end
	end

	always @ (posedge clk) begin
		if (reset) begin
			fetch_satisfied  <= 1;
			memory_satisfied <= 1;
		end else if (state == S_IDLE && next_state != S_IDLE) begin
			fetch_satisfied  <= (fetch_request ? 0 : 1);
			memory_satisfied <= (memory_request ? 0 : 1);
		end else if (state == S_SVC_FETCH && valid) begin
			fetch_satisfied  <= 1;
		end else if (state == S_SVC_MEM_R && valid) begin
			memory_satisfied <= 1;
		end
	end

	always @ (*) begin
		case (state)
			S_IDLE:
				if (requests_pending)
					if (fetch_request)
						next_state = S_SVC_FETCH;
					else if (memory_request)
						if (memory_request_type == `MEM_REQ_WRITE)
							next_state = S_SVC_MEM_W;
						else
							next_state = S_SVC_MEM_R;
					else
						next_state = S_IDLE;
				else
					next_state = S_IDLE;

			S_SVC_FETCH:
				if (!fetch_satisfied)
					next_state = S_SVC_FETCH;
				else if (memory_request)
					if (memory_request_type == `MEM_REQ_WRITE)
						next_state = S_SVC_MEM_W;
					else
						next_state = S_SVC_MEM_R;
				else
					next_state = S_IDLE;

			S_SVC_MEM_R:
				if (!memory_satisfied)
					next_state = S_SVC_MEM_R;
				else
					next_state = S_IDLE;

			S_SVC_MEM_W:
				/* allow writes to go... write through */
				next_state = S_IDLE;

			default:
				next_state = S_IDLE;
		endcase
	end

	always @ (*) begin
		case (state)
			S_SVC_FETCH:
				addr = fetch_addr;
			S_SVC_MEM_R, S_SVC_MEM_W:
				addr = memory_addr;
			default:
				addr = 0;			
		endcase
	end

	assign stall = (next_state != S_IDLE);

	assign fetch_data_valid = (state == S_SVC_FETCH & valid);
	assign memory_data_valid = (state == S_SVC_MEM_R & valid);

	assign request_data = data;
	assign wdata = write_data;
	assign enable = (state == S_SVC_FETCH && !fetch_satisfied) || 
	                (state == S_SVC_MEM_R && !memory_satisfied) ||
	                (state == S_SVC_MEM_W);
	assign mask = write_mask;

	always @ (*) begin
		case (state)
			S_SVC_FETCH: cmd = `MEM_CMD_READ;
			S_SVC_MEM_R: cmd = `MEM_CMD_READ;
			S_SVC_MEM_W: cmd = `MEM_CMD_WRITE;
			default: cmd = 0;
		endcase
	end
	
endmodule
