//-- feb 2021 add all colors square 
// (c) Technion IIT, Department of Electrical Engineering 2021


module	back_ground_draw	(	

					input	logic	clk,
					input	logic	resetN,
					input 	logic	[10:0]	pixelX,
					input 	logic	[10:0]	pixelY,

					output	logic	[7:0]	BG_RGB,
					output	logic		boardersDrawReq 
);

const int	xFrameSize	=	635;
const int	yFrameSize	=	475;
const int	bracketOffset =	30;
const int   COLOR_MARTIX_SIZE  = 16*8 ; // 128 

logic [2:0] redBits;
logic [2:0] greenBits;
logic [1:0] blueBits;
logic [10:0] shift_pixelX;


 	

always_comb begin
		
	if (pixelX == bracketOffset ||
		 pixelY == bracketOffset ||
		 pixelX == (xFrameSize-bracketOffset) || 
		 pixelY == (yFrameSize-bracketOffset)) begin 

		boardersDrawReq = 	1'b1 ; // pulse if drawing the boarders 
	end
	else begin
		boardersDrawReq = 	1'b0 ;
	end
		
	BG_RGB =  {3'b000 , 3'b000  , 2'b00 } ; //collect color nibbles to an 8 bit word 
			


end
 
endmodule

