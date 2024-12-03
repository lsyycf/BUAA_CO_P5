`timescale 1ns / 1ps

module test;

	reg clk;
	reg reset;

	mips uut (
		.clk(clk), 
		.reset(reset)
	);

	initial begin
		clk = 0;
		reset = 0;
	end
	
	always #5 clk = ~clk;
      
endmodule



