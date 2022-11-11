module alien_bloc 
#(
	parameter  logic [10:0] board_position_X = 11'd32,
	parameter  logic [10:0] board_position_Y = 11'd160
)

(
	input clk,
	input resetN,
	input startOfFrame,
	input [10:0] pixelX,
	input [10:0] pixelY,
	input [10:0] player_top_leftX,
	input [10:0] player_top_leftY,
	input	[3:0]		free_direction_alien_a ,					
	input 		alien_died,
	input 		player_died,
	output [10:0] alien_top_leftX,
	output [10:0] alien_top_leftY,					
	output alien_dr,
	output [7:0] alien_RGB
);

	// wires
	wire [10:0] alienTLX;
	wire [10:0] alienTLY;
	wire [3:0] HitEdgeCode;
	wire [10:0] alien_offsetX;
	wire [10:0] alien_offsetY;
	wire alien_rec_dr;
	wire bitmap_dr;
	wire alive;

	alien_moveCollision
	#(
			.INITIAL_X(board_position_X + (13 * 32)),
			.INITIAL_Y(board_position_Y + 0)
	)
	 alien_mov_inst(
		.clk(clk),
		.resetN(resetN),
		.startOfFrame(startOfFrame),
		.HitEdgeCode(HitEdgeCode),
		.player_top_leftX(player_top_leftX),
		.free_direction(free_direction_alien_a),
		.player_top_leftY(player_top_leftY),
		.alien_died(alien_died),
		.player_died(player_died),
		.alive(alive),
		.topLeftX(alienTLX),
		.topLeftY(alienTLY)
	);

	square_object 	#(
		.OBJECT_WIDTH_X(32),
		.OBJECT_HEIGHT_Y(32)
	)
	alien_sq(
		.clk(clk),
		.resetN(resetN),
		.pixelX(pixelX),
		.pixelY(pixelY),
		.topLeftX(alienTLX),
		.topLeftY(alienTLY),
		.offsetX(alien_offsetX),
		.offsetY(alien_offsetY),
		.drawingRequest(alien_rec_dr),
		.RGBout()
	);


	alien_bitmap alien_bitmap(		
		.clk(clk),
		.resetN(resetN),
		.offsetX(alien_offsetX),
		.offsetY(alien_offsetY),
		.InsideRectangle(alien_rec_dr),
		.playerHit(1'b0),
		.drawingRequest(bitmap_dr),
		.RGBout(alien_RGB),  
		.HitEdgeCode(HitEdgeCode)
	);

	assign  alien_top_leftX = alienTLX;
	assign  alien_top_leftY =	alienTLY;
	assign  alien_dr = bitmap_dr & alive;

endmodule 