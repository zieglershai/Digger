module end_screen(
		input clk,
		input resetN,
		input startOfFrame,
		input gameEnded,
		input [10:0] pixelX,
		input [10:0] pixelY,
		
		output game_over_dr,
		output [11:0] game_over_RGB

);

wire [10:0] gameOver_sq_inst_offsetX;
wire [10:0] gameOver_sq_inst_offsetY;
wire gameOver_sq_RecDR;
//wire gameOverspaceDR;
wire gameOverDR; // typo

wire [7:0] gameOverRGB;

square_object 	#(
			.OBJECT_WIDTH_X(128), //dec
			.OBJECT_HEIGHT_Y(128)//dec
)
gameover_sq_inst(
					.clk(clk),
					.resetN(resetN),
					.pixelX(pixelX),
					.pixelY(pixelY),
					.topLeftX(11'd192),
					.topLeftY(11'd80),
					.offsetX(gameOver_sq_inst_offsetX),
					.offsetY(gameOver_sq_inst_offsetY),
					.drawingRequest(gameOver_sq_RecDR),
					.RGBout()
);

game_over_bitmap gameOver_map_inst(

					.clk(clk), 
					.resetN(resetN), 
					.offsetX(gameOver_sq_inst_offsetX),// offset from top left  position 
					.offsetY(gameOver_sq_inst_offsetY), 
					.InsideRectangle(gameOver_sq_RecDR), //input that the pixel is within a bracket 
					.drawingRequest(game_over_dr), //output that the pixel should be dispalyed 
					.RGBout(game_over_RGB)  //rgb value from the bitmap 
 ) ;
 
endmodule 