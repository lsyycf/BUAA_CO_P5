`timescale 1ns / 1ps
module Decoder(
	 input  [5:0] op ,
    input  [5:0] rb ,
    output [0:0] add,
    output [0:0] sub,
    output [0:0] ori,
    output [0:0] lw ,
    output [0:0] sw ,
    output [0:0] beq,
    output [0:0] lui,
    output [0:0] jal,
    output [0:0] jr ,
	 output [0:0] new
    );

    assign add = op == 6'b000000 && rb == 6'b100000;
    assign sub = op == 6'b000000 && rb == 6'b100010;
    assign ori = op == 6'b001101                   ;
    assign lw  = op == 6'b100011                   ;
    assign sw  = op == 6'b101011                   ;
    assign beq = op == 6'b000100                   ;
    assign lui = op == 6'b001111                   ;
    assign jal = op == 6'b000011                   ;
    assign jr  = op == 6'b000000 && rb == 6'b001000;
    assign new = op == 6'b111111 && rb == 6'b111111;

endmodule

