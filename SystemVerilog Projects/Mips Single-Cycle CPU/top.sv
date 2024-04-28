module top(input  logic        clk, reset, 
           output logic [31:0] writedata, dataadr, 
           output logic        memwrite,
	   output logic [31:0] pc, instr, readdata);


  // The core of the code
  mips mips(clk, reset, pc, instr, memwrite, dataadr, writedata, readdata);

  // Instruction Memory
  imem imem(pc[7:2], instr);

  // Data Memory
  dmem dmem(clk, memwrite, dataadr, writedata, readdata);

endmodule

