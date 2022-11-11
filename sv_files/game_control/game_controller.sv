
module game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_terrain,
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

	assign collision_player_terrain = ( drawing_request_terrain &&  drawing_request_player );
	assign colision_fire = shot_dr  && ( drawing_request_terrain || alien_dr) ;
	assign collision_gold_1 = gold_1_dr && (drawing_request_player || alien_dr);
	assign player_eat_gold_1 = gold_1_dr && drawing_request_player && gold_1_state == 3'd2;
	assign player_died = (alien_dr  || (gold_1_dr && gold_1_state == 4'd1))  & drawing_request_player  && player_awake;
	assign alien_died_a = alien_dr & (shot_dr || (gold_1_dr && gold_1_state == 4'd1));
endmodule
