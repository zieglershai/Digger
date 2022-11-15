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
	input	can_fall_a,
	input	can_fall_b,					
	
	input [10:0] pixelX,
	input [10:0] pixelY,	
	output gold_dr,
	output [11:0] gold_RGB,
	output [10:0] goldTLX_a,
	output [10:0] goldTLY_a,
	output [10:0] goldTLX_b,
	output [10:0] goldTLY_b,
	output [3:0] gold_state
);




///------------------------------------------------------------------
///////////////// gold A

	wire gold_dr_tmp_a;
	wire [10:0] gold_offsetX_a;
	wire [10:0] gold_offsetY_a;
	wire gold_rec_dr_a;
	wire [1:0] image_a; // determinate which image to display
	wire gold_dr_a;
	wire [11:0] gold_RGB_a;
	wire [3:0] gold_state_a;
	wire been_eaten_a;
	wire collision_a;
	
	gold_moveCollision
	#(
			.INITIAL_X(board_position_X + (5 * 32)),
			.INITIAL_Y(board_position_Y + (1 * 32))
	)
	gold_mov_inst(
		.clk(clk),
		.resetN(resetN),
		.startOfFrame(startOfFrame),  // short pulse every start of frame 30Hz 
		.can_fall(can_fall_a),
		.collision(collision_a),
		.been_eaten(been_eaten_a),
		.side(gold_offsetX_a[4]), // MSB of possible object offset (range is from 0 to 31)
		.image(image_a),
		.gold_state(gold_state_a), 
		.topLeftX(goldTLX_a), // output the top left corner 
		.topLeftY(goldTLY_a)  // can be negative , if the object is partliy outside 

	);
	

	square_object 	#(
				.OBJECT_WIDTH_X(32),
				.OBJECT_HEIGHT_Y(32)
	)
	gold_sq_a(
		.clk(clk),
		.resetN(resetN),
		.pixelX(pixelX),
		.pixelY(pixelY),
		.topLeftX(goldTLX_a),
		.topLeftY(goldTLY_a),
		.offsetX(gold_offsetX_a),
		.offsetY(gold_offsetY_a),
		.drawingRequest(gold_rec_dr_a),
		.RGBout()
	);
	
	gold_bit_map gold_bitmap(		
		.clk(clk),
		.resetN(resetN),
		.offsetX(gold_offsetX_a),
		.offsetY(gold_offsetY_a),
		.image(image_a),
		.InsideRectangle(gold_rec_dr_a),
		.drawingRequest(gold_dr_tmp_a),
		.RGBout(gold_RGB_a)
		
);

assign gold_dr_a = gold_dr_tmp_a && gold_state_a != 4'd3; // if gold wasn't eaten



/////---------------------------------------------
///---------gold b---------------------------------
	wire gold_dr_tmp_b;
	wire [10:0] gold_offsetX_b;
	wire [10:0] gold_offsetY_b;
	wire gold_rec_dr_b;
	wire [1:0] image_b; // determinate which image to display
	wire gold_dr_b;
	wire [11:0] gold_RGB_b;
	wire [3:0] gold_state_b;
	wire been_eaten_b;
	wire collision_b;


	
	gold_moveCollision
	#(
			.INITIAL_X(board_position_X + (9 * 32)),
			.INITIAL_Y(board_position_Y + (3 * 32))
	)
	gold_mov_inst_b(
		.clk(clk),
		.resetN(resetN),
		.startOfFrame(startOfFrame),  // short pulse every start of frame 30Hz 
		.can_fall(can_fall_b),
		.collision(collision_b),
		.been_eaten(been_eaten_b),
		.side(gold_offsetX_b[4]), // MSB of possible object offset (range is from 0 to 31)
		.image(image_b),
		.gold_state(gold_state_b), 
		.topLeftX(goldTLX_b), // output the top left corner 
		.topLeftY(goldTLY_b)  // can be negative , if the object is partliy outside 

	);
	

	square_object 	#(
				.OBJECT_WIDTH_X(32),
				.OBJECT_HEIGHT_Y(32)
	)
	gold_sq_b(
		.clk(clk),
		.resetN(resetN),
		.pixelX(pixelX),
		.pixelY(pixelY),
		.topLeftX(goldTLX_b),
		.topLeftY(goldTLY_b),
		.offsetX(gold_offsetX_b),
		.offsetY(gold_offsetY_b),
		.drawingRequest(gold_rec_dr_b),
		.RGBout()
	);
	
	gold_bit_map gold_bitmap_b(		
		.clk(clk),
		.resetN(resetN),
		.offsetX(gold_offsetX_b),
		.offsetY(gold_offsetY_b),
		.image(image_b),
		.InsideRectangle(gold_rec_dr_b),
		.drawingRequest(gold_dr_tmp_b),
		.RGBout(gold_RGB_b)
		
);

assign gold_dr_b = gold_dr_tmp_b && gold_state_b != 4'd3; // if gold wasn't eaten


// -------------- logic of the iterface mux ---
	always_comb begin
		if(gold_dr_a) begin
			collision_a = collision;
			been_eaten_a = been_eaten; 
			collision_b = 1'b0;
			been_eaten_b = 1'b0;		
			
			gold_state = gold_state_a;
			gold_dr = gold_dr_a;
			gold_RGB = gold_RGB_a;
			


		end
		else begin
			collision_b = collision;
			been_eaten_b = been_eaten; 
			collision_a = 1'b0;
			been_eaten_a = 1'b0;		
			
			gold_state = gold_state_b;
			gold_dr = gold_dr_b;
			gold_RGB = gold_RGB_b;

		end
	end

endmodule 