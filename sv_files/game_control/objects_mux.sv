
module	objects_mux	(	
//		--------	Clock Input	 	
	input		logic	clk,
	input		logic	resetN,
	input		logic	[2:0] game_state,
// player
	input		logic	playerDR, // two set of inputs per unit
	input		logic	[11:0] playerRGB, 
// terrain
	input		logic	terrain_dr, // two set of inputs per unit
	input		logic	[11:0] terrain_RGB, 
	
	input		logic	alien_dr, // two set of inputs per unit
	input		logic	[11:0] alien_RGB,
	
	input		logic  shot_dr,	
	input		logic	[7:0]	shotRGB,
	

	input		logic  gold_1_dr,	
	input		logic	[11:0]	gold_1_RGB,
	

	input		logic  score_dr,	
	input		logic	[11:0]	scoreRGB,
	
	
	input		logic  player_life_dr,	
	input		logic	[11:0]	player_life_RGB,

	input		logic  game_over_dr,	
	input		logic	[11:0]	game_over_RGB,

	
	input		logic  start_screen_dr,	
	input		logic	[11:0]	start_screen_RGB,
	
	input		logic  win_screen_dr,	
	input		logic	[11:0]	win_screen_RGB,
////////////////////////
// background 

	input		logic	[11:0] backGroundRGB, 
			  
	output	[3:0]		Red_level,
	output	[3:0]		Green_level,
	output	[3:0]		Blue_level,
	output flag
);


	always_ff@(posedge clk or negedge resetN)
	begin
		if(!resetN) begin
			Red_level <= 4'b0;  //second priority 
			Green_level <= 4'b0;
			Blue_level <= 4'b0;
			flag <= 1'b0;
		end
		
		else if (game_state == 3'd2) begin
			flag <= 1'b0;

			if (playerDR == 1'b1 )begin   
				Red_level <= playerRGB[11:8];  //second priority 
				Green_level <= playerRGB[7:4];
				Blue_level <= playerRGB[3:0];
			end
			else if (alien_dr)begin
				Red_level <= alien_RGB[11:8];  //second priority 
				Green_level <= alien_RGB[7:4];
				Blue_level <= alien_RGB[3:0];
			end
			
			
			else if (gold_1_dr)begin
				Red_level <= gold_1_RGB[11:8];  //second priority 
				Green_level <= gold_1_RGB[7:4];
				Blue_level <= gold_1_RGB[3:0];
			end

			
			else if (shot_dr)begin
				Red_level <= {shotRGB[7:6], 2'b0};  //second priority 
				Green_level <= {shotRGB[5:3], 1'b0};
				Blue_level <= {shotRGB[2:0], 1'b0};
			end

			else if (score_dr)begin
//				Red_level <= scoreRGB[11:8];  //second priority 
//				Green_level <= scoreRGB[7:4];
//				Blue_level <= scoreRGB[3:0];
				
				Red_level <= 4'hF;  //second priority 
				Green_level <= 4'hF;
				Blue_level <= 4'hF;
			end
			
			else if (player_life_dr)begin
				Red_level <= player_life_RGB[11:8];  //second priority 
				Green_level <= player_life_RGB[7:4];
				Blue_level <= player_life_RGB[3:0];
			end
			
						
			else if (terrain_dr)begin
				Red_level <= terrain_RGB[11:8];  //second priority 
				Green_level <= terrain_RGB[7:4];
				Blue_level <= terrain_RGB[3:0];
			end

			else begin
				Red_level <= backGroundRGB[11:8];  //second priority 
				Green_level <= backGroundRGB[7:4];
				Blue_level <= backGroundRGB[3:0];
			end  
		end
		else if (game_state == 3'd1) begin
			if (start_screen_dr == 1'b1 )begin   
				Red_level <= start_screen_RGB[11:8];  //second priority 
				Green_level <= start_screen_RGB[7:4];
				Blue_level <= start_screen_RGB[3:0];
			end
			else begin
				Red_level <= 4'h0;  //second priority 
				Green_level <= 4'h0;
				Blue_level <= 4'h0;
			end
		end
		else if (game_state == 3'd4) begin
			if (game_over_dr == 1'b1 )begin   
				Red_level <= game_over_RGB[11:8];  //second priority 
				Green_level <= game_over_RGB[7:4];
				Blue_level <= game_over_RGB[3:0];
			end
			else begin
				Red_level <= 4'h0;  //second priority 
				Green_level <= 4'h0;
				Blue_level <= 4'h0;
			end
		end
		else if (game_state == 3'd3) begin
			if (win_screen_dr == 1'b1 )begin   
				Red_level <= win_screen_RGB[11:8];  //second priority 
				Green_level <= win_screen_RGB[7:4];
				Blue_level <= win_screen_RGB[3:0];
			end
			else begin
				Red_level <= 4'h0;  //second priority 
				Green_level <= 4'h0;
				Blue_level <= 4'h0;
			end
		end
		else begin
			Red_level <= 4'h0;  //second priority 				
			Green_level <= 4'h0;
			Blue_level <= 4'h0;
		end
	end

endmodule

