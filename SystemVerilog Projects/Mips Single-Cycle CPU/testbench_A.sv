// Testbench for memfile_a.dat
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
        if(aluout === 84 & writedata === 7) begin 
          $display("Simulation succeeded");
          $stop;
        end else if (aluout !== 32'h50) begin
          $stop;
        end
      end
    end
endmodule


