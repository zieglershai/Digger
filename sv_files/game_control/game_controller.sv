
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
			input logic start,

			input	logic	drawing_request_player,
			input	logic	shot_dr,
			input	logic	alien_dr,
			input logic gold_1_dr,
			input logic [3:0]		gold_1_state,
			input logic player_awake,
			input logic no_dimond_left,
			input logic no_lives_left,

			output logic collision_gold_1,
			output logic collision_player_terrain,
			output logic colision_fire,
			output logic player_eat_gold_1,
			output logic player_died,
			output logic alien_died_a,
			output logic [2:0] game_state,
			output logic restart_gameN,
			output logic reset_scoreN

	
);
//	//wire out_of_field;
//	//assign out_of_field = (pixelX > board_position_X + (32 * 15)) || (pixelY > board_position_Y + (32 * 10)) ||(pixelX < board_position_X - 32) ||(pixelY < board_position_Y  - 32);
	
	assign collision_player_terrain = ( drawing_request_terrain &&  drawing_request_player );
	assign colision_fire = shot_dr  && ((drawing_request_terrain & !empty_square_terrain) || alien_dr /*|| out_of_field*/) ;
	assign collision_gold_1 = gold_1_dr && (drawing_request_player || alien_dr);
	assign player_eat_gold_1 = gold_1_dr && drawing_request_player && gold_1_state == 3'd2;
	assign player_died = (alien_dr  || (gold_1_dr && gold_1_state == 4'd1))  & drawing_request_player  && player_awake;
	assign alien_died_a = alien_dr & (shot_dr || (gold_1_dr && gold_1_state == 4'd1));
	
	
	
	typedef enum {idle, start_screen, game, game_over, winning} screen_state;
	screen_state current_state;
	screen_state next_state;
	wire [10:0] counter, next_counter;
	wire [2:0]  next_game_state;
	wire restart_gameN_next;
	wire reset_score_nextN;
	
	
	
	
	/// -----------------------------------------------------------//
	// below is the state machine of the game which control which screen will display and send the restart game signal
	always_ff@(posedge clk or negedge resetN)
	begin
		if(!resetN) begin
			counter <= 11'b0;
			current_state <= idle;
			game_state <= 3'b0;
			restart_gameN <= 1'b0;
			reset_scoreN <= 1'b0;
		end
		else begin
			counter <= next_counter;
			current_state <= next_state;
			game_state <= next_game_state;
			restart_gameN <= restart_gameN_next;
			reset_scoreN <= reset_score_nextN;


			end
	end
	
	
	
	always_comb begin
	
		next_state = idle;
		next_game_state = game_state;
		restart_gameN_next = 1'b1;
		reset_score_nextN = 1'b1;
		if (startOfFrame) begin
			next_counter = counter + 11'b1;
		end
		else begin
			next_counter = counter;
		end
	
		case(current_state) 
			idle : begin
				next_state = start_screen;
				next_game_state = 3'd1;
			end
			start_screen:begin
				if (start) begin
					restart_gameN_next = 1'b0;
					next_state = game;
					next_game_state = 3'd2;
					reset_score_nextN =  1'b0;
				end
				else begin
					next_state = current_state;
					next_game_state = 3'd1;
				end
			end
			game:begin
				if(no_dimond_left) begin
					next_counter = 11'b0;
					next_state = winning;
					next_game_state = 3'd3;
				end
				else if (no_lives_left) begin
					next_counter = 11'b0;
					next_state = game_over;
					next_game_state = 3'd4;
				end
				else begin
					next_state = current_state;
				end
			end
			game_over:begin
				if (counter >= 11'd1000) begin
					next_state = start_screen;
					next_game_state = 3'd1;
				end
				else begin
					next_state = current_state;
				end
			end
			winning:begin
				if (counter >= 11'd1000) begin
					next_state = start_screen;
					next_game_state = 3'd1;
				end
				else begin
					next_state = current_state;
				end
			end

		endcase
		
	end
	
endmodule
