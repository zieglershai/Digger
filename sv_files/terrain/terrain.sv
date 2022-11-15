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
	input 	[10:0]	alien_a_top_leftX_a,
	input 	[10:0]	alien_a_top_leftY_a,
	input 	[10:0]	alien_a_top_leftX_b,
	input 	[10:0]	alien_a_top_leftY_b,
	input 	[10:0]	gold_1_top_leftX_a,
	input 	[10:0]	gold_1_top_leftY_a,					
	input 	[10:0]	gold_1_top_leftX_b,
	input 	[10:0]	gold_1_top_leftY_b,		
	output	[3:0]		free_direction_alien_a ,
	output	[3:0]		free_direction_alien_b ,

	output 				gold_1_can_fall_a,
	output 				gold_1_can_fall_b,

	output 				empty_square_terrain,
	output	logic		dimond_eaten,
	output	logic		all_dimond_eaten,
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


/// below implement all the logic which tell the object where they can go 
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
	.alien_top_leftX_a(alien_a_top_leftX_a),
	.alien_top_leftY_a(alien_a_top_leftY_a),
	.alien_top_leftX_b(alien_a_top_leftX_b),
	.alien_top_leftY_b(alien_a_top_leftY_b),
	.free_direction_alien_a(free_direction_alien_a),
	.free_direction_alien_b(free_direction_alien_b),

	.gold_1_top_leftX_a(gold_1_top_leftX_a),
	.gold_1_top_leftY_a(gold_1_top_leftY_a),
	.gold_1_can_fall_a(gold_1_can_fall_a),
	.gold_1_top_leftX_b(gold_1_top_leftX_b),
	.gold_1_top_leftY_b(gold_1_top_leftY_b),
	.gold_1_can_fall_b(gold_1_can_fall_b),
	.empty_square_terrain(empty_square_terrain),
	.all_dimond_eaten(all_dimond_eaten),
	.dimond_eaten(dimond_eaten),
	.drawingRequest(terrainDR),
	.RGBout(terrainRGB)
);
endmodule 