module credit_screen(
	input clk,
	input resetN,
	input startOfFrame,
	input gameEnded,
	input [10:0] pixelX,
	input [10:0] pixelY,
	
	output credit_screen_dr,
	output [11:0] credit_screen_RGB

);

	wire [10:0] offsetX;
	wire [10:0] offsetY;
	wire sq_RecDR;
	//wire gameOverspaceDR;


	square_object 	#(
		.OBJECT_WIDTH_X(64), //dec
		.OBJECT_HEIGHT_Y(32)//dec
	)
	win_screen_sq_inst(
		.clk(clk),
		.resetN(resetN),
		.pixelX(pixelX),
		.pixelY(pixelY),
		.topLeftX(11'd288),
		.topLeftY(11'd380),
		.offsetX(offsetX),
		.offsetY(offsetY),
		.drawingRequest(sq_RecDR),
		.RGBout()
	);

	credit_bitmap credit_map_inst(

		.clk(clk), 
		.resetN(resetN), 
		.offsetX(offsetX),// offset from top left  position 
		.offsetY(offsetY), 
		.InsideRectangle(sq_RecDR), //input that the pixel is within a bracket 
		.drawingRequest(credit_screen_dr), //output that the pixel should be dispalyed 
		.RGBout(credit_screen_RGB)  //rgb value from the bitmap 
	 ) ;
 
endmodule 