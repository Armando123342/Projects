module alu(
	input logic [31:0] a, b,
	input logic [3:0] f,
	output logic [31:0] y,
	output logic zero);
	
	logic [31:0] BB;
	logic [31:0] AND, OR;
	logic [31:0] S, PM;
	logic SLT, OF;
	
	assign BB = f[2] ? ~b[31:0] : b[31:0];
	
	AND_32bit and0(a, BB, AND);
	OR_32bit or0(a, BB, OR);

	Adder add(a, BB, f[2], S);

	Get_SLT slt(a[31], b[31], f[3], S[31], SLT);

	Mux5_32 mux0(AND, OR, S, {31'b0, SLT}, f[2:0], y);

	GetZero getzero(y, zero);

endmodule

module Mux5_32(
	input logic [31: 0] d0, d1, d2, d3,
	input logic [2:0] f,
	output logic [31:0] Y);

	always_comb
		case(f)
			3'b000: Y = d0;
			3'b001: Y = d1;
			3'b010: Y = d2;
			3'b011: Y = d3; // Not used
			3'b100: Y = d0;
			3'b101: Y = d1;
			3'b110: Y = d2;
			3'b111: Y = d3;
		endcase
endmodule

module Adder(
	input logic [31:0] A, B,
	input logic cin,
	output logic [31:0] Y);

	logic cout;

	Hierarchical_CLA HCLA0(A[15:0], B[15:0], cin, cout, Y[15:0]);
	Hierarchical_CLA HCLA1(A[31:16], B[31:16], cout, ,Y[31:16]);
endmodule 

module GetZero(
	input logic [31:0] Y,
	output logic zero);

        logic bit0, bit1, bit2, bit3;
        logic bit4, bit5, bit6, bit7;
        logic bit8, bit9, bit10, bit11;
        logic bit12, bit13, bit14, bit15;
        logic bit16, bit17, bit18, bit19;
        logic bit20, bit21, bit22, bit23;
        logic bit24, bit25, bit26, bit27;
        logic bit28, bit29, bit30, bit31;

        assign bit0 = ~(Y[0] ^ 1'b0);
        assign bit1 = ~(Y[1] ^ 1'b0);
        assign bit2 = ~(Y[2] ^ 1'b0);
        assign bit3 = ~(Y[3] ^ 1'b0);
        assign bit4 = ~(Y[4] ^ 1'b0);
        assign bit5 = ~(Y[5] ^ 1'b0);
        assign bit6 = ~(Y[6] ^ 1'b0);
        assign bit7 = ~(Y[7] ^ 1'b0);
        assign bit8 = ~(Y[8] ^ 1'b0);
        assign bit9 = ~(Y[9] ^ 1'b0);
        assign bit10 = ~(Y[10] ^ 1'b0);
        assign bit11 = ~(Y[11] ^ 1'b0);
        assign bit12 = ~(Y[12] ^ 1'b0);
        assign bit13 = ~(Y[13] ^ 1'b0);
        assign bit14 = ~(Y[14] ^ 1'b0);
        assign bit15 = ~(Y[15] ^ 1'b0);
        assign bit16 = ~(Y[16] ^ 1'b0);
        assign bit17 = ~(Y[17] ^ 1'b0);
        assign bit18 = ~(Y[18] ^ 1'b0);
        assign bit19 = ~(Y[19] ^ 1'b0);
        assign bit20 = ~(Y[20] ^ 1'b0);
        assign bit21 = ~(Y[21] ^ 1'b0);
        assign bit22 = ~(Y[22] ^ 1'b0);
        assign bit23 = ~(Y[23] ^ 1'b0);
        assign bit24 = ~(Y[24] ^ 1'b0);
        assign bit25 = ~(Y[25] ^ 1'b0);
        assign bit26 = ~(Y[26] ^ 1'b0);
        assign bit27 = ~(Y[27] ^ 1'b0);
        assign bit28 = ~(Y[28] ^ 1'b0);
        assign bit29 = ~(Y[29] ^ 1'b0);
        assign bit30 = ~(Y[30] ^ 1'b0);
        assign bit31 = ~(Y[31] ^ 1'b0);

	assign zero = bit0 & bit1 & bit2 & bit3
      		    &  bit4 & bit5 & bit6 & bit7
      		    &  bit8 & bit9 & bit10 & bit11
      		    &  bit12 & bit13 & bit14 & bit15
      		    &  bit16 & bit17 & bit18 & bit19
      		    &  bit20 & bit21 & bit22 & bit23
      		    &  bit24 & bit25 & bit26 & bit27
      		    &  bit28 & bit29 & bit30 & bit31;
endmodule

module OR_32bit(
	input logic [31:0] A, B,
	output logic [31:0] Y);

	assign Y = A | B;
endmodule

module AND_32bit(
	input logic [31:0] A, B,
	output logic [31:0] Y);

	assign Y = A & B;
endmodule

module Get_SLT(
	input logic a, b, u, s,
	output logic SLT);

  always_comb begin
    if(u) begin
      if (a & ~b)      SLT = 0;
      else if (~a & b) SLT = 1;
      else 	       SLT = s;
    end else begin
      if (a & ~b)      SLT = 1;
      else if (~a & b) SLT = 0;
      else 	       SLT = s;
    end
  end

endmodule










