`timescale 1ns / 1ps
module E_CU(
	 input  [5:0] op       ,
	 input  [5:0] rb       ,
    output [2:0] ALUOp    ,
    output [0:0] ALUIn2Op ,
	 output [1:0] fwAddrOp , 
	 output [1:0] fwDataOp ,
	 output [1:0] Tnew     ,
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
									 
	 assign ALUOp = add || lw || sw ? 3'b000 :
						 sub ? 3'b001 :
					    ori ? 3'b010 :
						 lui ? 3'b011 :
						 3'b111;
	 
	 assign ALUIn2Op = lui || sw || lw || ori ? 1'b1 : 1'b0;
	 
	 assign new = ne;
	 
	 assign fwAddrOp = add || sub ? 2'b00 : 
							 ori || lw || lui ? 2'b01 : 
							 jal ? 2'b10 :
							 2'b11; 
								
	 assign fwDataOp = add || sub || lui || ori ? 2'b00 :
							 lw  ? 2'b01 : 
							 jal ? 2'b10 :
							 2'b11;
	 
	 assign Tnew = add || sub || ori || lui ? 2'b01 :
						lw  ? 2'b10 :      
						jal ? 2'b00 :                
						2'b11; 

endmodule

