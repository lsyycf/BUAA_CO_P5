`timescale 1ns / 1ps
module E_ALU(
    input  [31:0] ALUIn1,
    input  [31:0] ALUIn2,
    input  [ 2:0] ALUOp ,
    output [31:0] ALURes
    );
	 
	 assign ALURes = (ALUOp == 3'b000)? ALUIn1 + ALUIn2 :
					     (ALUOp == 3'b001)? ALUIn1 - ALUIn2 :
					     (ALUOp == 3'b010)? ALUIn1 | ALUIn2 :
					     (ALUOp == 3'b011)? {ALUIn2[15:0], 16'h0000} :
					     32'h00000000;
					  
endmodule

