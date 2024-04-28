// Testbench for memfile_b.dat
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
        if(aluout === 20 & writedata === 28) begin 
          $display("Simulation succeeded");
          $stop;
        end else if (aluout !== 32'h34 & aluout !== 32'h20 & aluout !== 32'h1c & aluout !== 32'h18) begin
          $stop;
        end
      end
    end
endmodule


