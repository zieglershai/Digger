module terrain
#(
	parameter  logic [10:0] board_position_X = 11'd32,
	parameter  logic [10:0] board_position_Y = 11'd160


)
(
	input 				clk,
	input 				resetN,
	input 	[10:0] 	pixelX,
	input 	[10:0]	pixelY,
	input					player_inside,
	input 	[10:0]	alien_a_top_leftX,
	input 	[10:0]	alien_a_top_leftY,
	input 	[10:0]	gold_1_top_leftX,
	input 	[10:0]	gold_1_top_leftY,					
	
	output	[3:0]		free_direction_alien_a ,
	output 				gold_1_can_fall,
	output 				terrainDR,
	output 	[11:0] 	terrainRGB

);


wire 	[10:0] 	terrainTLX;
wire 	[10:0] 	terrainTLY;
wire 	[10:0] 	terrainOffsetX;
wire 	[10:0] 	terrainOffsetY;
wire 				terrain_rec_dr;

square_object 	#(
			.OBJECT_WIDTH_X(480),
			.OBJECT_HEIGHT_Y(320)
)
terrain_sq(
					.clk(clk),
					.resetN(resetN),
					.pixelX(pixelX),
					.pixelY(pixelY),
					.topLeftX(board_position_X),
					.topLeftY(board_position_Y),
					.offsetX(terrainOffsetX),
					.offsetY(terrainOffsetY),
					.drawingRequest(terrain_rec_dr),
					.RGBout()
);

terrain_bit_map
#(
	.board_position_X(board_position_X),
	.board_position_Y(board_position_Y)
)
 terrain_bit_inst(		
					.clk(clk),
					.resetN(resetN),
					.offsetX(terrainOffsetX),
					.offsetY(terrainOffsetY),
					.InsideRectangle(terrain_rec_dr),
					.playerHit(player_inside),
					.alien_a_top_leftX(alien_a_top_leftX),
					.alien_a_top_leftY(alien_a_top_leftY),
					.free_direction_alien_a(free_direction_alien_a),
					.gold_1_top_leftX(gold_1_top_leftX),
					.gold_1_top_leftY(gold_1_top_leftY),
					.gold_1_can_fall(gold_1_can_fall),
					.drawingRequest(terrainDR),
					.RGBout(terrainRGB)
);
endmodule 