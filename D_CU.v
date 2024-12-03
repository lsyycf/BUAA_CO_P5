`timescale 1ns / 1ps
module D_CU(
	 input  [5:0] op    ,
	 input  [5:0] rb    ,
    output [1:0] pcOp  ,
    output [2:0] cmpOp ,
    output [0:0] extOp ,
	 output [1:0] rtTuse, 
	 output [1:0] rsTuse,
	 output [0:0] regWE ,
	 output [0:0] new
    );
	 
	 wire add;
    wire sub;
    wire ori;
    wire lw ;
    wire sw ;
    wire beq;
    wire lui;
    wire jal;
    wire jr ;
	 wire ne ;
	
	 Decoder Decoder_Instance(
	                          .op(op)  , 
									  .rb(rb)  , 
									  .add(add), 
									  .sub(sub),
									  .ori(ori), 
									  .lw(lw)  , 
									  .sw(sw)  , 
									  .beq(beq), 
									  .lui(lui), 
									  .jal(jal), 
									  .jr(jr)  ,
									  .new(ne)
	 );
									 
	 assign pcOp = beq ? 2'b01 :
						jal ? 2'b10 :
						jr  ? 2'b11 :
						2'b00; 
						
	 assign cmpOp = beq ? 3'b010 :
						 3'b001;
	
	 assign extOp = sw || lw || beq;
	 
	 assign new = ne;
	 
	 assign regWE = add || sub || ori || lw || lui || jal;
	 
	 assign rsTuse = add || sub || ori || lw || sw ? 2'b01 :              
						  beq || jr ? 2'b00 :                   
						  2'b11;
						  
	 assign rtTuse = add || sub ? 2'b01 :             
						  lw  || sw  ? 2'b10 :      
						  beq ? 2'b00 : 
						  2'b11;

endmodule

