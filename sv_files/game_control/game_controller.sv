
module game_controller
#(
	parameter  logic [10:0] board_position_X = 11'd32,
	parameter  logic [10:0] board_position_Y = 11'd160
)
	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input logic [10:0] pixelX,
			input logic [10:0] pixelY,
			input	logic	drawing_request_terrain,
			input	logic	empty_square_terrain,

			input	logic	drawing_request_player,
			input	logic	shot_dr,
			input	logic	alien_dr,
			input logic gold_1_dr,
			input logic [3:0]		gold_1_state,
			input logic player_awake,

			output logic collision_gold_1,
			output logic collision_player_terrain,
			output logic colision_fire,
			output logic player_eat_gold_1,
			output logic player_died,
			output logic alien_died_a

	
);
//	//wire out_of_field;
//	//assign out_of_field = (pixelX > board_position_X + (32 * 15)) || (pixelY > board_position_Y + (32 * 10)) ||(pixelX < board_position_X - 32) ||(pixelY < board_position_Y  - 32);
	
	assign collision_player_terrain = ( drawing_request_terrain &&  drawing_request_player );
	assign colision_fire = shot_dr  && ((drawing_request_terrain & !empty_square_terrain) || alien_dr /*|| out_of_field*/) ;
	assign collision_gold_1 = gold_1_dr && (drawing_request_player || alien_dr);
	assign player_eat_gold_1 = gold_1_dr && drawing_request_player && gold_1_state == 3'd2;
	assign player_died = (alien_dr  || (gold_1_dr && gold_1_state == 4'd1))  & drawing_request_player  && player_awake;
	assign alien_died_a = alien_dr & (shot_dr || (gold_1_dr && gold_1_state == 4'd1));
	
	
	
	
endmodule
