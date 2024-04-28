// Single-Cycle MIPS Processor

module mips(input  logic        clk, reset,
            output logic [31:0] pc,
            input  logic [31:0] instr,
            output logic        memwrite,
            output logic [31:0] aluout, writedata,
            input  logic [31:0] readdata);

  logic        memtoreg, branch,
               pcsrc, zero,
               alusrc, regdst, regwrite, jump;
  logic [3:0]  alucontrol; // increased the size of alucontrol

  controller c(instr[31:26], instr[5:0], zero,
               memtoreg, memwrite, pcsrc,
               alusrc, regdst, regwrite, jump,
               alucontrol, aluout[31]);
  datapath dp(clk, reset, memtoreg, pcsrc,
              alusrc, regdst, regwrite, jump,
              alucontrol,
              zero, pc, instr,
              aluout, writedata, readdata);
endmodule

// This module produceses the control bits the datapath
module controller(input  logic [5:0] op, funct,
                  input  logic       zero,
                  output logic       memtoreg, memwrite,
                  output logic       pcsrc, alusrc,
                  output logic       regdst, regwrite,
                  output logic       jump,
                  output logic [3:0] alucontrol,
		  input logic 	     alur);

  logic [1:0] aluop;
  logic       branch;
  logic	      bne; // contrl bit for bne
  logic	      ble; // contrl bit for ble

  maindec md(op, memtoreg, memwrite, branch,
             alusrc, regdst, regwrite, jump,
             aluop, bne, ble);
  aludec  ad(funct, aluop, alucontrol);

  // new implementation of pcsrc
  always_comb
    case({branch, bne}) 
      2'b00: pcsrc = ble & (zero | alur);
      2'b01: pcsrc = bne & ~zero;
      2'b10: pcsrc = branch & zero;
      2'b11: pcsrc = 1'b0;
    endcase
endmodule

module maindec(input  logic [5:0] op,
               output logic       memtoreg, memwrite,
               output logic       branch, alusrc,
               output logic       regdst, regwrite,
               output logic       jump,
               output logic [1:0] aluop,
	       output logic 	  bne,
	       output logic	  ble);

  logic [10:0] controls;

  assign {regwrite, regdst, alusrc,
          branch, memwrite,
          memtoreg, jump, aluop, bne, ble} = controls;

  // added BNE, STLI, and BLE
  always_comb
    case(op)
      6'b000000: controls = 11'b11000001000; //Rtype
      6'b100011: controls = 11'b10100100000; //LW
      6'b101011: controls = 11'b00101000000; //SW
      6'b000100: controls = 11'b00010000100; //BEQ
      6'b001000: controls = 11'b10100000000; //ADDI
      6'b000010: controls = 11'b00000010000; //J
      6'b000101: controls = 11'b00000000110; //BNE
      6'b001010: controls = 11'b10100001100; //STLI
      6'b000111: controls = 11'b00000000101; //BLE
      default:   controls = 11'bxxxxxxxxxxx; //???
    endcase
endmodule

module aludec(input  logic [5:0] funct,
              input  logic [1:0] aluop,
              output logic [3:0] alucontrol);

  // added stl, and SLTU
  // also increased the bit width of alucontrol for unsign operations
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

module datapath(input  logic        clk, reset,
                input  logic        memtoreg, pcsrc,
                input  logic        alusrc, regdst,
                input  logic        regwrite, jump,
                input  logic [3:0]  alucontrol,
                output logic        zero,
                output logic [31:0] pc,
                input  logic [31:0] instr,
                output logic [31:0] aluout, writedata,
                input  logic [31:0] readdata);

  logic [4:0]  writereg;
  logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch;
  logic [31:0] signimm, signimmsh;
  logic [31:0] srca, srcb;
  logic [31:0] result;

  // Next PC logic
  flopr #(32) pcreg(clk, reset, pcnext, pc);
  adder       pcadd1(pc, 32'b100, pcplus4);
  sl2         immsh(signimm, signimmsh);
  adder       pcadd2(pcplus4, signimmsh, pcbranch);
  mux2 #(32)  pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);
  mux2 #(32)  pcmux(pcnextbr, {pcplus4[31:28], instr[25:0], 2'b00}, 
                    jump, pcnext);

  // Register file logic
  regfile     rf(clk, regwrite, instr[25:21],
                 instr[20:16], writereg,
                 result, srca, writedata);
  mux2 #(5)   wrmux(instr[20:16], instr[15:11], regdst, writereg);
  mux2 #(32)  resmux(aluout, readdata, memtoreg, result);
  signext     se(instr[15:0], signimm);

  // ALU logic
  mux2 #(32)  srcbmux(writedata, signimm, alusrc, srcb);
  alu         alu(.a(srca), .b(srcb), .f(alucontrol), .y(aluout), .zero(zero));
endmodule

