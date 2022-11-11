
module	alien_bitmap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input	logic	playerHit, //input that the pixel is within a bracket 

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout,  //rgb value from the bitmap 
					output	logic	[3:0] HitEdgeCode //one bit per edge 
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;  // 2^4 = 16
localparam  int OBJECT_NUMBER_OF_X_BITS = 5;  // 2^6 = 64


localparam  int OBJECT_HEIGHT_Y = 1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam  int OBJECT_WIDTH_X = 1 <<  OBJECT_NUMBER_OF_X_BITS;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 2; //how many pixel bits are in every collision pixel
localparam  int OBJECT_WIDTH_X_DIVIDER =  OBJECT_NUMBER_OF_X_BITS - 2;

// generating a smiley bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'h00 ;// RGB value in the bitmap representing a transparent pixel 

logic [0:OBJECT_HEIGHT_Y-1] [0:OBJECT_WIDTH_X-1] object_colors = {
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000011000000000110000000000,
	32'b00000000011000000000110000000000,
	32'b00000000011000000000110000000000,
	32'b00000000000110000011000000000000,
	32'b00000000000110000011000000000000,
	32'b00000000001110000011000000000000,
	32'b00000000011111111111110000000000,
	32'b00000000011111111111110000000000,
	32'b00000001111111111111111100000000,
	32'b00000001111001111100111100000000,
	32'b00000001111001111100111100000000,
	32'b00000011111111111111111110000000,
	32'b00000011111111111111111110000000,
	32'b00000011111111111111111110000000,
	32'b00000011111111111111111110000000,
	32'b00000011011111111111110110000000,
	32'b00000011011111111111110110000000,
	32'b00000011011000000000110110000000,
	32'b00000011011000000000110110000000,
	32'b00000011011111101111110110000000,
	32'b00000000000111101111000000000000,
	32'b00000000000111101111000000000000,
	32'b00000000000111101111000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000,
	32'b00000000000000000000000000000000
	};

//////////--------------------------------------------------------------------------------------------------------------=
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  


logic [0:3] [0:3] [3:0] hit_colors = 
		  {16'hC446,     
			16'h8C62,    
			16'h8932,
			16'h9113};

 

// pipeline (ff) to get the pixel color from the array 	 





//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		HitEdgeCode <= 4'h0;

	end
	else begin
		if (InsideRectangle == 1'b1 ) begin
		 // inside an external bracket 
			HitEdgeCode <= hit_colors[offsetY >> OBJECT_HEIGHT_Y_DIVIDER][offsetX >> OBJECT_WIDTH_X_DIVIDER];	//get hitting edge from the colors table  
			RGBout <= object_colors[offsetY][offsetX]? 8'hec: 8'h00;
		end  	
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule