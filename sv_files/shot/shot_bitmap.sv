
module	shot_bitmap	(	
	input	logic	clk,
	input	logic	resetN,
	input startOfFrame,

	input logic	[10:0] offsetX,// offset from top left  position 
	input logic	[10:0] offsetY,
	input	logic	InsideRectangle, //input that the pixel is within a bracket 

	output	logic	drawingRequest, //output that the pixel should be dispalyed 
	output	logic	[11:0] RGBout  //rgb value from the bitmap 

 ) ;

localparam logic [7:0] TRANSPARENT_ENCODING = 12'h000 ;// RGB value in the bitmap representing a transparent pixel  
logic [0:1][0:7][0:7][11:0] object_colors = {
	{
	{12'h000,12'h000,12'h000,12'h000,12'h000,12'h000,12'h000,12'h000},
	{12'h000,12'h000,12'h900,12'h000,12'hC60,12'h900,12'hC60,12'h000},
	{12'h000,12'hCCC,12'h900,12'hC60,12'hC60,12'hC60,12'hC60,12'h000},
	{12'h000,12'hCCC,12'hF80,12'hCCC,12'hF80,12'hF80,12'hC60,12'h000},
	{12'h000,12'hCCC,12'h900,12'hC60,12'hC60,12'hC60,12'hC60,12'h000},
	{12'h000,12'hCCC,12'hF80,12'hCCC,12'hF80,12'hF80,12'hC60,12'h000},
	{12'h000,12'h000,12'h900,12'h000,12'hC60,12'h900,12'hC60,12'h000},
	{12'h000,12'h000,12'h000,12'h000,12'h000,12'h000,12'h000,12'h000}},
	
	{
	{12'h000,12'h000,12'h000,12'h000,12'h000,12'h000,12'h000,12'h000},
	{12'h000,12'h000,12'h000,12'h000,12'hC60,12'hC60,12'h000,12'h000},
	{12'h000,12'h000,12'h900,12'h900,12'h000,12'hF80,12'h900,12'h000},
	{12'h000,12'h900,12'h900,12'h900,12'h900,12'hC60,12'hC60,12'h000},
	{12'h000,12'h900,12'hF80,12'hF80,12'h000,12'hF80,12'hC60,12'h000},
	{12'h000,12'h900,12'h900,12'h900,12'hC60,12'hF80,12'hC60,12'h000},
	{12'h000,12'h000,12'h000,12'h000,12'h900,12'h900,12'h900,12'h000},
	{12'h000,12'h000,12'h000,12'h000,12'h000,12'h000,12'h000,12'h000}}
	};

 
 wire [7:0] counter; 
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
		RGBout <=	12'h000; 
		counter <= 8'h0;
	end 
	else begin 
		RGBout <= TRANSPARENT_ENCODING ; // default  
		if (startOfFrame) begin
			counter <= counter + 8'h1;
		end
		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket  
			RGBout <= object_colors[counter[4]][offsetY][offsetX]; 
		end  	 
		 
	end 
end 
 
//////////--------------------------------------------------------------------------------------------------------------= 
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
 
endmodule 
