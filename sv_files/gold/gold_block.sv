module gold_block
#(
	parameter  logic [10:0] board_position_X = 11'd32,
	parameter  logic [10:0] board_position_Y = 11'd160
)
(
	input clk,
	input resetN,
	input startOfFrame,
	input collision,
	input been_eaten,
	input	can_fall,					
	input [10:0] pixelX,
	input [10:0] pixelY,	
	output gold_dr,
	output [11:0] gold_RGB,
	output [10:0] goldTLX,
	output [10:0] goldTLY,
	output [3:0] gold_state
);


	wire gold_dr_tmp;
	wire [3:0] HitEdgeCode;
	wire [10:0] gold_offsetX;
	wire [10:0] gold_offsetY;
	wire gold_rec_dr;
	wire [1:0] image; // determinate which image to display

	
	gold_moveCollision
	#(
			.INITIAL_X(board_position_X + (5 * 32)),
			.INITIAL_Y(board_position_Y + (1 * 32))
	)
	gold_mov_inst(
		.clk(clk),
		.resetN(resetN),
		.startOfFrame(startOfFrame),  // short pulse every start of frame 30Hz 
		.can_fall(can_fall),
		.HitEdgeCode(HitEdgeCode), //one bit per edge 
		.collision(collision),
		.been_eaten(been_eaten),
		.side(gold_offsetX[4]), // MSB of possible object offset (range is from 0 to 31)
		.image(image),
		.gold_state(gold_state), 
		.topLeftX(goldTLX), // output the top left corner 
		.topLeftY(goldTLY)  // can be negative , if the object is partliy outside 

	);
	

	square_object 	#(
				.OBJECT_WIDTH_X(32),
				.OBJECT_HEIGHT_Y(32)
	)
	gold_sq(
		.clk(clk),
		.resetN(resetN),
		.pixelX(pixelX),
		.pixelY(pixelY),
		.topLeftX(goldTLX),
		.topLeftY(goldTLY),
		.offsetX(gold_offsetX),
		.offsetY(gold_offsetY),
		.drawingRequest(gold_rec_dr),
		.RGBout()
	);
	
	gold_bit_map gold_bitmap(		
		.clk(clk),
		.resetN(resetN),
		.offsetX(gold_offsetX),
		.offsetY(gold_offsetY),
		.image(image),
		.InsideRectangle(gold_rec_dr),
		.drawingRequest(gold_dr_tmp),
		.RGBout(gold_RGB),  
		.HitEdgeCode(HitEdgeCode)
		
);

assign gold_dr = gold_dr_tmp && gold_state != 4'd3; // if gold wasn't eaten


endmodule 