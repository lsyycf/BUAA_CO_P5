`timescale 1ns / 1ps
module M_CU(
	 input  [5:0] op       ,
	 input  [5:0] rb       ,
    output [0:0] memWE    ,
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
									 
	 assign memWE = sw;
	 
	 assign new = ne;
	 
	 assign fwAddrOp = add || sub ? 2'b00 :
							 ori || lw || lui ? 2'b01 :
							 jal ? 2'b10 :
							 2'b11;
	
	 assign fwDataOp = add || sub || lui || ori ? 2'b00 :
							 lw  ? 2'b01 :
							 jal ? 2'b10 :
							 2'b11; 
	 
	 assign Tnew = add || sub || ori || lui || jal ? 2'b00 : 
						lw  ? 2'b01 :                            
						2'b11;
						
endmodule

