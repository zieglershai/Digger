module score_block
#(
	parameter  logic [10:0] board_position_X = 11'd32,
	parameter  logic [10:0] board_position_Y = 11'd160
)
(
	input [10:0] pixelX,
	input [10:0] pixelY,
	input clk,
	input resetN,
	input player_eat_gold,
	input player_eat_dimond,

	
	output [11:0] score_RGB,
	output	score_dr

);

	wire [10:0] scoreOffsetX;
	wire [10:0] scoreOffsetY;
	wire score_rec_dr;
	// logic and instantions

	
	
square_object 	#(
			.OBJECT_WIDTH_X(64),
			.OBJECT_HEIGHT_Y(32)
)
score_sq(
	.clk(clk),
	.resetN(resetN),
	.pixelX(pixelX),
	.pixelY(pixelY),
	.topLeftX(board_position_X),
	.topLeftY(board_position_Y - 11'd40),
	.offsetX(scoreOffsetX),
	.offsetY(scoreOffsetY),
	.drawingRequest(score_rec_dr),
	.RGBout()
);

score_bit_map score_bit_inst(		
	.clk(clk),
	.resetN(resetN),
	.offsetX(scoreOffsetX),
	.offsetY(scoreOffsetY),
	.InsideRectangle(score_rec_dr),
	.player_eat_gold(player_eat_gold),
	.player_eat_dimond(player_eat_dimond),
	.drawingRequest(score_dr),
	.RGBout(score_RGB)
);
endmodule 