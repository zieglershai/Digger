module shots_block(
	input [10:0] pixelX,
	input [10:0] pixelY,
	input clk,
	input resetN,
	input startOfFrame,
	input fireCollision,
	input [10:0] playerXPosition,
	input [10:0] playerYPosition,
	input [1:0] player_direction,

	input fire_pressed,// fire pressed
	
	output [7:0] shotRGB,
	output	shot_dr

);

	wire [10:0] shotTLX;
	wire [10:0] shotTLY;
	wire shot_rec_dr;
	wire	alive;
	// logic and instantions
	assign shot_dr = alive & shot_rec_dr;

	shot_moveCollision player_shot_mv_inst(
		.clk(clk),
		.resetN(resetN),
		.startOfFrame(startOfFrame),
		.fireCollision(fireCollision),
		.playerXPosition(playerXPosition),
		.playerYPosition(playerYPosition),
		.player_direction(player_direction),
		.fire_pressed(fire_pressed),
		.topLeftX(shotTLX), 
		.topLeftY(shotTLY),  
		.alive(alive)
	);
	
	
	square_object 	#(
			.OBJECT_WIDTH_X(4),
			.OBJECT_HEIGHT_Y(4)
)
player_shot_sq(
		.clk(clk),
		.resetN(resetN),
		.pixelX(pixelX),
		.pixelY(pixelY),
		.topLeftX(shotTLX),
		.topLeftY(shotTLY),
		.offsetX(), // not important - all square filled with white 
		.offsetY(), // not important - all square filled with white 
		.drawingRequest(shot_rec_dr),
		.RGBout(shotRGB)
);
endmodule 