module player
#(
	parameter  logic [10:0] board_position_X = 11'd32,
	parameter  logic [10:0] board_position_Y = 11'd160
)
(
	input clk,
	input resetN,
	input startOfFrame,
	input leftArrowPressed,
	input rightArrowPressed,
	input downArrowPressed,
	input upArrowPressed,
	input player_died,
	input [10:0] pixelX,
	input [10:0] pixelY,
	output playerDR,
	output [11:0] playerRGB,
	output [10:0] playerTLX,
	output [10:0] playerTLY,
	output [1:0] player_direction,
	output player_awake		
);

// wires

wire [3:0] HitEdgeCode;
wire [10:0] playerOffsetX;
wire [10:0] playerOffsetY;
wire [2:0] image;
wire playerRecDR;


player_moveCollision
#(
	.board_position_X(board_position_X),
	.board_position_Y(board_position_Y)
)
 player_mov_inst(
	.clk(clk),
	.resetN(resetN),
	.startOfFrame(startOfFrame),
	.leftArrow(leftArrowPressed),
	.rightArrow(rightArrowPressed),
	.downArrow(downArrowPressed),
	.upArrow(upArrowPressed),
	.collision(player_died),
	.HitEdgeCode(HitEdgeCode),
	.image(image),
	.topLeftX(playerTLX),
	.topLeftY(playerTLY),
	.player_direction(player_direction),
	.player_awake(player_awake)
);

square_object 	#(
			.OBJECT_WIDTH_X(32),
			.OBJECT_HEIGHT_Y(32)
)
player_sq(
					.clk(clk),
					.resetN(resetN),
					.pixelX(pixelX),
					.pixelY(pixelY),
					.topLeftX(playerTLX),
					.topLeftY(playerTLY),
					.offsetX(playerOffsetX),
					.offsetY(playerOffsetY),
					.drawingRequest(playerRecDR),
					.RGBout()
);

player_bit_map player_bit_inst(		
					.clk(clk),
					.resetN(resetN),
					.offsetX(playerOffsetX),
					.offsetY(playerOffsetY),
					.InsideRectangle(playerRecDR),
					.playerHit(1'b0),
					.drawingRequest(playerDR),
					.RGBout(playerRGB),  
					.image(image),
					.HitEdgeCode(HitEdgeCode),
					.player_direction(player_direction)
);
			
			
endmodule
