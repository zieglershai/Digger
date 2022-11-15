module shots_block
//#(
//	parameter  logic [10:0] board_position_X = 11'd32,
//	parameter  logic [10:0] board_position_Y = 11'd160
//)
(
	input [10:0] pixelX,
	input [10:0] pixelY,
	input clk,
	input resetN,
	input startOfFrame,
	input fireCollision,
	input [10:0] playerXPosition,
	input [10:0] playerYPosition,
	input [1:0] player_direction,
	input  player_awake,

	input fire_pressed,// fire pressed
	
	output [11:0] shotRGB,
	output	shot_dr

);

	wire [10:0] shotTLX;
	wire [10:0] shotTLY;
	wire [10:0] OffsetX;
	wire [10:0] OffsetY;
	wire shot_rec_dr;
	wire	alive;
	wire InsideRectangle;

	// logic and instantions
	assign shot_dr = alive & shot_rec_dr;

	shot_moveCollision
//	#(
//		.board_position_X(board_position_X),
//		.board_position_Y(board_position_Y)
//	)

	player_shot_mv_inst(
	.clk(clk),
	.resetN(resetN),
	.startOfFrame(startOfFrame),
	.fireCollision(fireCollision),
	.playerXPosition(playerXPosition),
	.playerYPosition(playerYPosition),
	.player_direction(player_direction),
	.fire_pressed(fire_pressed),
	.player_awake(player_awake),
	.topLeftX(shotTLX), 
	.topLeftY(shotTLY),  
	.alive(alive)
	);
	
	
	square_object 	#(
			.OBJECT_WIDTH_X(8),
			.OBJECT_HEIGHT_Y(8)
)
player_shot_sq(
		.clk(clk),
		.resetN(resetN),
		.pixelX(pixelX),
		.pixelY(pixelY),
		.topLeftX(shotTLX),
		.topLeftY(shotTLY),
		.offsetX(OffsetX), // not important - all square filled with white 
		.offsetY(OffsetY), // not important - all square filled with white 
		.drawingRequest(InsideRectangle),
		.RGBout()
);

shot_bitmap life_map_inst(
	.clk(clk),
	.resetN(resetN),
	.startOfFrame(startOfFrame),
	.offsetX(OffsetX),
	.offsetY(OffsetY),
	.InsideRectangle(InsideRectangle),
	.drawingRequest(shot_rec_dr),
	.RGBout(shotRGB),
);
endmodule 