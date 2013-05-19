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

module control_processor (
	input clk,
	input reset,
	input stall,

	input  [31:0] inst,

	input enable,
	output reg [31:0] pcr_data,
	input  [31:0] pcr_write_data,
	input   [4:0] pcr,
	input   [1:0] cmd
);

	wire [2:0] command = {1'b0, cmd};

	wire [11:0] imm12 = inst[21:10];
	wire [31:0] sext_imm = imm12[11] ? {20'hFFFFF, imm12} : {20'b0, imm12};

	reg [31:0] status;
	reg [31:0] epc;
	reg [31:0] badvaddr;
	reg [31:0] evec;
	reg [31:0] count;
	reg [31:0] compare;
	reg [31:0] cause;
	reg [31:0] ptbr;
	reg [31:0] k0;
	reg [31:0] k1;
	reg [31:0] tohost;
	reg [31:0] fromhost;

	/* Upon reset, only the supervisor bit is set. S64 and U64 are hard-wired
	 * to zero, as are EC, EV, and EF. */
	localparam SR_WRITE_MASK = (`SR_IM | `SR_VM | `SR_S | `SR_PS | `SR_ET);

	always @ (posedge clk) begin
		if (reset) begin
			status   <= (`SR_S);
			epc      <= 32'h0;
			badvaddr <= 32'h0;
			evec     <= 32'h0;
			count    <= 32'h0;
			compare  <= 32'h0;
			cause    <= 32'h0;
			ptbr     <= 32'h0;
			k0       <= 32'h0;
			k1       <= 32'h0;
			tohost   <= 32'h0;
			fromhost <= 32'h0;
		end else if (!stall && enable && command == `F3_MTPCR) begin
			case (pcr)
				`PCR_STATUS:   status   <= pcr_write_data & SR_WRITE_MASK;
				`PCR_EVEC:     evec     <= pcr_write_data & 32'hFFFFFFFC;
				`PCR_COUNT:    count    <= pcr_write_data;
				`PCR_COMPARE:  compare  <= pcr_write_data;
				`PCR_PTBR:     ptbr     <= pcr_write_data;
				`PCR_K0:       k0       <= pcr_write_data;
				`PCR_K1:       k1       <= pcr_write_data;
				`PCR_TOHOST:   tohost   <= pcr_write_data;
				`PCR_FROMHOST: fromhost <= pcr_write_data;
			endcase
		end else if (!stall && enable && command == `F3_SETPCR) begin
			case (pcr)
				`PCR_STATUS:   status   <= status   | sext_imm & SR_WRITE_MASK;
				`PCR_EVEC:     evec     <= evec     | sext_imm & 32'hFFFFFFFC;
				`PCR_COUNT:    count    <= count    | sext_imm;
				`PCR_COMPARE:  compare  <= compare  | sext_imm;
				`PCR_PTBR:     ptbr     <= ptbr     | sext_imm;
				`PCR_K0:       k0       <= k0       | sext_imm;
				`PCR_K1:       k1       <= k1       | sext_imm;
				`PCR_TOHOST:   tohost   <= tohost   | sext_imm;
				`PCR_FROMHOST: fromhost <= fromhost | sext_imm;
			endcase
		end else if (!stall && enable && command == `F3_CLEARPCR) begin
			case (pcr)
				`PCR_STATUS:   status   <= status   & (~sext_imm) & SR_WRITE_MASK;
				`PCR_EVEC:     evec     <= evec     & (~sext_imm) & 32'hFFFFFFFC;
				`PCR_COUNT:    count    <= count    & ~sext_imm;
				`PCR_COMPARE:  compare  <= compare  & ~sext_imm;
				`PCR_PTBR:     ptbr     <= ptbr     & ~sext_imm;
				`PCR_K0:       k0       <= k0       & ~sext_imm;
				`PCR_K1:       k1       <= k1       & ~sext_imm;
				`PCR_TOHOST:   tohost   <= tohost   & ~sext_imm;
				`PCR_FROMHOST: fromhost <= fromhost & ~sext_imm;
			endcase
		end
	end

	/* The old value of a PCR is returned on a write */
	always @ (*) begin
		if (enable)
			case (pcr)
				`PCR_STATUS:   pcr_data = status;  
				`PCR_EPC:      pcr_data = epc;
				`PCR_BADVADDR: pcr_data = badvaddr;
				`PCR_EVEC:     pcr_data = evec;
				`PCR_COUNT:    pcr_data = count;
				`PCR_COMPARE:  pcr_data = compare;
				`PCR_PTBR:     pcr_data = ptbr;  
				`PCR_K0:       pcr_data = k0;
				`PCR_K1:       pcr_data = k1;
				`PCR_TOHOST:   pcr_data = tohost;
				`PCR_FROMHOST: pcr_data = fromhost;
				default: pcr_data = 32'h0;
			endcase
		else
			pcr_data = 32'h0;
	end

endmodule
