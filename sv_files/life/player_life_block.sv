// module life

module player_life_block(
	input clk,
	input resetN,
	input startOfFrame,
	input player_died,  //player was hit
	input [10:0] pixelX,
	input [10:0] pixelY,
	
	output player_life_dr,
	output [11:0] player_life_RGB,
	output no_lives

);

wire [10:0] playerLifeOffsetX;
wire [10:0] playerLifeOffsetY;
wire InsideRectangle;


square_object 	#(
			.OBJECT_WIDTH_X(96),
			.OBJECT_HEIGHT_Y(32)
)
player_life_sq(
					.clk(clk),
					.resetN(resetN),
					.pixelX(pixelX),
					.pixelY(pixelY),
					.topLeftX(11'd128),
					.topLeftY(11'd128),
					.offsetX(playerLifeOffsetX),
					.offsetY(playerLifeOffsetY),
					.drawingRequest(InsideRectangle),
					.RGBout()
);


player_life_bitmap life_map_inst(
					.clk(clk),
					.resetN(resetN),
					.offsetX(playerLifeOffsetX),
					.offsetY(playerLifeOffsetY),
					.InsideRectangle(InsideRectangle),
					.player_died(player_died),
					.drawingRequest(player_life_dr),
					.RGBout(player_life_RGB),
					.no_lives(no_lives)	
);
endmodule