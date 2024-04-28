// Mips Multi-Cycle CPU
module top(input logic clk, reset,
 	   output logic [5:0]  op, funct,
           output logic [3:0]  state,
           output logic [15:0] controlword,
           output logic [31:0] pc,
	   output logic [31:0] aluresult, adr, writedata,
	   output logic        memwrite);

  logic [31:0] readdata;

  // microprocessor (control & datapath)
  mips mips(clk, reset, adr, writedata, memwrite, readdata, 
            op, funct, state, controlword, pc, aluresult);

  // memory
  mem mem(clk, memwrite, adr, writedata, readdata);

endmodule


module mips(input  logic        clk, reset,
            output logic [31:0] adr, writedata,
            output logic        memwrite,
            input logic [31:0]  readdata,
	    output logic [5:0]  op, funct,
            output logic [3:0]  state,
            output logic [15:0] controlword,
            output logic [31:0] pc,
	    output logic [31:0] alur);

  logic        zero, pcen;
  logic        irwrite, regwrite,
               alusrca, iord, memtoreg, regdst;
  logic [1:0]  alusrcb, pcsrc;
  logic [3:0]  alucontrol;

  controller c(clk, reset, op, funct, zero,
               pcen, memwrite, irwrite, regwrite,
               alusrca, iord, memtoreg, regdst, 
               alusrcb, pcsrc, alucontrol, alur[31], state, controlword);
  datapath dp(clk, reset, 
              pcen, irwrite, regwrite,
              alusrca, iord, memtoreg, regdst,
              alusrcb, pcsrc, alucontrol,
              op, funct, zero,
              adr, writedata, readdata, alur, pc);
endmodule

module controller(input  logic        clk, reset,
                  input  logic [5:0]  op, funct,
                  input  logic        zero,
                  output logic        pcen, memwrite, irwrite, regwrite,
                  output logic        alusrca, iord, memtoreg, regdst,
                  output logic [1:0]  alusrcb, pcsrc,
                  output logic [3:0]  alucontrol,
                  input logic         alur,
                  output logic [3:0]  state,
                  output logic [15:0] controlword);

  logic [1:0] aluop;
  logic       branch, pcwrite;
  logic       ble;

  // Main Decoder and ALU Decoder subunits.
  maindec md(clk, reset, op,
             pcwrite, memwrite, irwrite, regwrite,
             alusrca, branch, iord, memtoreg, regdst, 
             alusrcb, pcsrc, aluop, ble, state, controlword);
  aludec  ad(funct, aluop, alucontrol);

  assign pcen = (branch ? zero : (ble & (zero | alur))) | pcwrite;
 
endmodule

module maindec(input  logic        clk, reset, 
               input  logic [5:0]  op, 
               output logic        pcwrite, memwrite, irwrite, regwrite,
               output logic        alusrca, branch, iord, memtoreg, regdst,
               output logic [1:0]  alusrcb, pcsrc,
               output logic [1:0]  aluop,
	       output logic        ble,
               output logic [3:0]  state,
               output logic [15:0] controls);

  parameter   FETCH   = 4'b0000; 	// State 0
  parameter   DECODE  = 4'b0001; 	// State 1
  parameter   MEMADR  = 4'b0010;	// State 2
  parameter   MEMRD   = 4'b0011;	// State 3
  parameter   MEMWB   = 4'b0100;	// State 4
  parameter   MEMWR   = 4'b0101;	// State 5
  parameter   RTYPEEX = 4'b0110;	// State 6
  parameter   RTYPEWB = 4'b0111;	// State 7
  parameter   BEQEX   = 4'b1000;	// State 8
  parameter   ADDIEX  = 4'b1001;	// State 9
  parameter   ADDIWB  = 4'b1010;	// state 10
  parameter   JEX     = 4'b1011;	// State 11
  parameter   BLEEX   = 4'b1100;        // State 12

  parameter   LW      = 6'b100011;	// Opcode for lw
  parameter   SW      = 6'b101011;	// Opcode for sw
  parameter   RTYPE   = 6'b000000;	// Opcode for R-type
  parameter   BEQ     = 6'b000100;	// Opcode for beq
  parameter   ADDI    = 6'b001000;	// Opcode for addi
  parameter   J       = 6'b000010;	// Opcode for j
  parameter   BLE     = 6'b000111;      // Opcode for ble


  logic [3:0] nextstate;

  // state register
  always_ff @(posedge clk or posedge reset)			
    if(reset) state <= FETCH;
    else state <= nextstate;

  // next state logic
  always_comb
    case(state)
      FETCH:   nextstate <= DECODE;
      DECODE:  case(op)
                 LW:      nextstate <= MEMADR;
                 SW:      nextstate <= MEMADR;
                 RTYPE:   nextstate <= RTYPEEX;
                 BEQ:     nextstate <= BEQEX;
                 ADDI:    nextstate <= ADDIEX;
                 J:       nextstate <= JEX;
                 BLE:     nextstate <= BLEEX;
                 default: nextstate <= 4'bx; // should never happen
               endcase
 		// Add code here
      MEMADR:  case(op)
		 LW:	  nextstate <= MEMRD;
		 SW:      nextstate <= MEMWR;
		 default: nextstate <= 4'bx;
	       endcase
      MEMRD:   nextstate <= MEMWB;
      MEMWB:   nextstate <= FETCH;
      MEMWR:   nextstate <= FETCH;
      RTYPEEX: nextstate <= RTYPEWB;
      RTYPEWB: nextstate <= FETCH;
      BEQEX:   nextstate <= FETCH;
      ADDIEX:  nextstate <= ADDIWB;
      ADDIWB:  nextstate <= FETCH;
      JEX:     nextstate <= FETCH;
      BLEEX:   nextstate <= FETCH;
      default: nextstate <= 4'bx; // should never happen
    endcase

  // output logic
  assign {ble, pcwrite, memwrite, irwrite, regwrite, 
          alusrca, branch, iord, memtoreg, regdst,
          alusrcb, pcsrc, aluop} = controls;

  always_comb
    case(state)
      FETCH:   controls <= 16'h5010;
      DECODE:  controls <= 16'h0030;
      MEMADR:  controls <= 16'h0420;
      MEMRD:   controls <= 16'h0100;
      MEMWB:   controls <= 16'h0880;
      MEMWR:   controls <= 16'h2100;
      RTYPEEX: controls <= 16'h0402;
      RTYPEWB: controls <= 16'h0840;
      BEQEX:   controls <= 16'h0605;
      ADDIEX:  controls <= 16'h0420;
      ADDIWB:  controls <= 16'h0800;
      JEX:     controls <= 16'h4008;
      BLEEX:   controls <= 16'h8405;      
      default: controls <= 16'hxxxx; // should never happen
    endcase
endmodule

module aludec(input  logic [5:0] funct,
              input  logic [1:0] aluop,
              output logic [3:0] alucontrol);

  // ADD CODE HERE
  always_comb begin
    case(aluop)
      2'b00: alucontrol = 4'b0010;  // add
      2'b01: alucontrol = 4'b0110;  // sub
      2'b11: alucontrol = 4'b0111;  // stl
      default: case(funct)          // RTYPE
          6'b100000: alucontrol = 4'b0010; // ADD
          6'b100010: alucontrol = 4'b0110; // SUB
          6'b100100: alucontrol = 4'b0000; // AND
          6'b100101: alucontrol = 4'b0001; // OR
          6'b101010: alucontrol = 4'b0111; // SLT
	  6'b101011: alucontrol = 4'b1111; // SLTU
          default:   alucontrol = 4'bxxxx; // ???
        endcase
    endcase
  end
  
endmodule

// The datapath unit is a structural verilog module.
module datapath(input  logic        clk, reset,
                input  logic        pcen, irwrite, regwrite,
                input  logic        alusrca, iord, memtoreg, regdst,
                input  logic [1:0]  alusrcb, pcsrc, 
                input  logic [3:0]  alucontrol,
                output logic [5:0]  op, funct,
                output logic        zero,
                output logic [31:0] adr, writedata, 
                input  logic [31:0] readdata,
		output logic [31:0] aluresult,
                output logic [31:0] pc);

  logic [4:0]  writereg;
  logic [31:0] pcnext;
  logic [31:0] instr, data, srca, srcb;
  logic [31:0] a;
  logic [31:0] aluout;
  logic [31:0] signimm;   // the sign-extended immediate
  logic [31:0] signimmsh;	// the sign-extended immediate shifted left by 2
  logic [31:0] wd3, rd1, rd2;
  logic [31:0] pcjump;

  // op and funct fields to controller
  assign op = instr[31:26];
  assign funct = instr[5:0];

  // datapath

  // next PC logic 
  flopenr #(32)  pcreg(clk, reset, pcen, pcnext, pc);
  mux2 #(32)     pcord(pc, aluout, iord, adr);

  // register file logic 
  flopenr #(32) instreg(clk, reset, irwrite, readdata, instr);
  flopr #(32)   datareg(clk, reset, readdata, data);
  mux2 #(5)     writeregmux(instr[20:16], instr[15:11], regdst, writereg);
  mux2 #(32)    wd3mux(aluout, data, memtoreg, wd3);
  regfile       rf(clk, regwrite, instr[25:21], instr[20:16], writereg, wd3, rd1, rd2);
  readreg       readreg(clk, reset, rd1, rd2, a, writedata);
  signext       se(instr[15:0], signimm);
  sl2		immsh(signimm, signimmsh);
  mux2 #(32)    srcamux(pc, a, alusrca, srca);
  mux4 #(32)    srcbmux(writedata, 32'h0004, signimm, signimmsh, alusrcb, srcb);

  // alu logic 
  alu		alu(srca, srcb, alucontrol, aluresult, zero);
  jumpsl2	jsh(instr[25:0], pcjump[27:0]);
  assign pcjump[31:28] = pc[31:28];
  flopr #(32)   alureg(clk, reset, aluresult, aluout);
  mux4 #(32)    pcmux(aluresult, aluout, pcjump, 32'hxxxx, pcsrc, pcnext);
  
endmodule


module jumpsl2(input logic [25:0] a,
	       output logic [27:0] y);

assign y = {a[25:0], 2'b00};

endmodule


module mem(input logic clk, we,
 	   input logic [31:0] a, wd,
 	   output logic [31:0] rd);

  logic [31:0] RAM[63:0];

  // initialize memory with instructions
  initial
    begin
      $readmemh("memfile.dat",RAM);
      // "memfile.dat" contains your instructions in hex
      // you must create this file
    end

  assign rd = RAM[a[31:2]]; // word aligned

  always_ff @(posedge clk)
    if (we) RAM[a[31:2]] <= wd;

endmodule










