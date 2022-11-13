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
	input	[3:0]		free_direction_alien_b ,					
	
	input 		alien_died,
	input 		player_died,
	output [10:0] alien_top_leftX_a,
	output [10:0] alien_top_leftY_a,	
	output [10:0] alien_top_leftX_b,
	output [10:0] alien_top_leftY_b,		
	output alien_dr,
	output [11:0] alien_RGB
);


	//---------------------------------------------------------------------------------------------
	/* alien b */
	// wires for alien a
	wire [10:0] alienTLX_a;
	wire [10:0] alienTLY_a;
	wire [3:0] HitEdgeCode_a;
	wire [10:0] alien_offsetX_a;
	wire [10:0] alien_offsetY_a;
	wire alien_rec_dr_a;
	wire bitmap_dr_a;
	wire alive_a;
	wire alien_dr_a;
	wire [11:0] alien_RGB_a;

	alien_moveCollision
	#(
			.INITIAL_X(board_position_X + (13 * 32)),
			.INITIAL_Y(board_position_Y + 0),
			.Time_To_Live(11'd100)
	)
	 alien_mov_inst(
		.clk(clk),
		.resetN(resetN),
		.startOfFrame(startOfFrame),
		.HitEdgeCode(HitEdgeCode_a),
		.player_top_leftX(player_top_leftX),
		.free_direction(free_direction_alien_a),
		.player_top_leftY(player_top_leftY),
		.alien_died(alien_died_a),
		.player_died(player_died),
		.alive(alive_a),
		.topLeftX(alienTLX_a),
		.topLeftY(alienTLY_a)
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
		.topLeftX(alienTLX_a),
		.topLeftY(alienTLY_a),
		.offsetX(alien_offsetX_a),
		.offsetY(alien_offsetY_a),
		.drawingRequest(alien_rec_dr_a),
		.RGBout()
	);


	alien_bitmap alien_bitmap(		
		.clk(clk),
		.resetN(resetN),
		.startOfFrame(startOfFrame),
		.offsetX(alien_offsetX_a),
		.offsetY(alien_offsetY_a),
		.InsideRectangle(alien_rec_dr_a),
		.playerHit(1'b0),
		.drawingRequest(bitmap_dr_a),
		.RGBout(alien_RGB_a),  
		.HitEdgeCode(HitEdgeCode_a)
	);
	
	// logic dor alien a
	assign  alien_top_leftX_a = alienTLX_a;
	assign  alien_top_leftY_a =	alienTLY_a;
	assign  alien_dr_a = bitmap_dr_a & alive_a;
	
	
	//---------------------------------------------------------------------------------------------
	/* alien b */
	
	// wires for alien b
	wire [10:0] alienTLX_b;
	wire [10:0] alienTLY_b;
	wire [3:0] HitEdgeCode;
	wire [10:0] alien_offsetX_b;
	wire [10:0] alien_offsetY_b;
	wire alien_rec_dr_b;
	wire bitmap_dr_b;
	wire alive_b;
	wire alien_dr_b;
	wire [11:0] alien_RGB_b;


	alien_moveCollision
	#(
			.INITIAL_X(board_position_X + (14 * 32)),
			.INITIAL_Y(board_position_Y + 0),
			.Time_To_Live(11'd500)

	)
	 alien_mov_inst_b(
		.clk(clk),
		.resetN(resetN),
		.startOfFrame(startOfFrame),
		.HitEdgeCode(HitEdgeCode),
		.player_top_leftX(player_top_leftX),
		.free_direction(free_direction_alien_b),
		.player_top_leftY(player_top_leftY),
		.alien_died(alien_died_b),
		.player_died(player_died),
		.alive(alive_b),
		.topLeftX(alienTLX_b),
		.topLeftY(alienTLY_b)
	);

	square_object 	#(
		.OBJECT_WIDTH_X(32),
		.OBJECT_HEIGHT_Y(32)
	)
	alien_sq_b(
		.clk(clk),
		.resetN(resetN),
		.pixelX(pixelX),
		.pixelY(pixelY),
		.topLeftX(alienTLX_b),
		.topLeftY(alienTLY_b),
		.offsetX(alien_offsetX_b),
		.offsetY(alien_offsetY_b),
		.drawingRequest(alien_rec_dr_b),
		.RGBout()
	);


	alien_bitmap alien_bitmap_b(		
		.clk(clk),
		.resetN(resetN),
		.startOfFrame(startOfFrame),
		.offsetX(alien_offsetX_b),
		.offsetY(alien_offsetY_b),
		.InsideRectangle(alien_rec_dr_b),
		.playerHit(1'b0),
		.drawingRequest(bitmap_dr_b),
		.RGBout(alien_RGB_b),  
		.HitEdgeCode(HitEdgeCode)
	);
	// logic for alien b
	assign  alien_top_leftX_b = alienTLX_b;
	assign  alien_top_leftY_b =	alienTLY_b;
	assign  alien_dr_b = bitmap_dr_b & alive_b;
	
	
	//-----------------------------------------------------------------------------
	// rewire the signals 
	always_comb begin
		if(alien_dr_a) begin
			alien_died_a = alien_died;
			alien_died_b = 1'b0;
			alien_dr = alien_dr_a;
			alien_RGB = alien_RGB_a;

		end
		else begin
			alien_died_a = 1'b0;
			alien_died_b = alien_died;
			alien_dr = alien_dr_b;
			alien_RGB = alien_RGB_b;

		end
	end

endmodule 