// testbench for memfile_c
module testbenchpc();

  logic        clk;
  logic	[31:0] pc;
  logic        reset;
  logic [3:0]  state;
  logic [31:0] aluresult;
  logic [5:0]  op;
  logic	[5:0]  funct;
  logic [15:0] controlword;
  logic [31:0] dataadr, writedata;
  logic        memwrite;


  // instantiate device to be tested
  top dut(clk, reset, op, funct, state, controlword, pc, aluresult, dataadr, writedata, memwrite);
  

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
        if(dataadr === 108 & writedata === -6) begin 
          $display("Simulation succeeded");
          $stop;
        end else if (dataadr !== 80 & dataadr !== 84 & dataadr !== 88 & dataadr !== 92 & dataadr !== 96 & dataadr !== 100) begin 
          $display("Simulation failed");
          $stop;
        end
      end
    end
endmodule

