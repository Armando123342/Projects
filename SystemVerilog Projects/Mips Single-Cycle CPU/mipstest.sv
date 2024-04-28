// Example testbench for MIPS processor

module testbench();

  logic        reset;
  logic	[31:0] pc;
  logic        clk;
  logic [31:0] instr;
  logic [31:0] aluout;
  logic [31:0] writedata;
  logic        memwrite;

  // instantiate device to be tested
  top dut(clk, reset, writedata, aluout, memwrite, pc, instr, readdata);
  
  // initialize test
  initial
    begin
      reset <= 1; # 22; reset <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 5; clk <= 0; # 5;
    end

  // check that 7 gets written to address 84
  always@(negedge clk)
    begin
      if(memwrite) begin
        if(aluout === 32'h00000010 & writedata === 32'hfffffffa) begin // Part A: 54 7, Part B: 14 1c, Part C: 32'h00000010 & 32'hfffffffa
          $display("Simulation succeeded");
          $stop;
        end else if (aluout !== 32'h14 & aluout !== 32'h18 & aluout !== 32'h1c & aluout !== 32'h20 & aluout !== 32'h24 & aluout !== 32'h28) begin // Part A: 80, Part B: 34 20 1c 18, Part C: 14 18 1c 20 24 28
          $display("Simulation failed");
          $stop;
        end
      end
    end
endmodule



