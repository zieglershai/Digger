
module	objects_mux	(	
//		--------	Clock Input	 	
	input		logic	clk,
	input		logic	resetN,
		  
// player
	input		logic	playerDR, // two set of inputs per unit
	input		logic	[11:0] playerRGB, 
// terrain
	input		logic	terrain_dr, // two set of inputs per unit
	input		logic	[11:0] terrain_RGB, 
	
	input		logic	alien_dr, // two set of inputs per unit
	input		logic	[7:0] alien_RGB,
	
	input		logic  shot_dr,	
	input		logic	[7:0]	shotRGB,
	

	input		logic  gold_1_dr,	
	input		logic	[11:0]	gold_1_RGB,
	

	input		logic  score_dr,	
	input		logic	[11:0]	scoreRGB,
	
	
	input		logic  player_life_dr,	
	input		logic	[11:0]	player_life_RGB,



////////////////////////
// background 

	input		logic	[7:0] backGroundRGB, 
			  
	output	[3:0]		Red_level,
	output	[3:0]		Green_level,
	output	[3:0]		Blue_level
);

	always_ff@(posedge clk or negedge resetN)
	begin
		if(!resetN) begin
			Red_level <= 4'b0;  //second priority 
			Green_level <= 4'b0;
			Blue_level <= 4'b0;		end
		
		else begin
					 
			if (playerDR == 1'b1 )begin   
				Red_level <= playerRGB[11:8];  //second priority 
				Green_level <= playerRGB[7:4];
				Blue_level <= playerRGB[3:0];
			end
			else if (alien_dr)begin
				Red_level <= {alien_RGB[7:6], 2'b0};  //second priority 
				Green_level <= {alien_RGB[5:3], 1'b0};
				Blue_level <= {alien_RGB[2:0], 1'b0};
			end
			
			
			else if (gold_1_dr)begin
				Red_level <= gold_1_RGB[11:8];  //second priority 
				Green_level <= gold_1_RGB[7:4];
				Blue_level <= gold_1_RGB[3:0];
			end
			
			else if (terrain_dr)begin
				Red_level <= terrain_RGB[11:8];  //second priority 
				Green_level <= terrain_RGB[7:4];
				Blue_level <= terrain_RGB[3:0];
			end
			
			else if (shot_dr)begin
				Red_level <= {shotRGB[7:6], 2'b0};  //second priority 
				Green_level <= {shotRGB[5:3], 1'b0};
				Blue_level <= {shotRGB[2:0], 1'b0};
			end

			else if (score_dr)begin
				Red_level <= scoreRGB[11:8];  //second priority 
				Green_level <= scoreRGB[7:4];
				Blue_level <= scoreRGB[3:0];
			end
			
			else if (player_life_dr)begin
				Red_level <= player_life_RGB[11:8];  //second priority 
				Green_level <= player_life_RGB[7:4];
				Blue_level <= player_life_RGB[3:0];
			end

			else begin
				Red_level <= 4'b0;  //second priority 
				Green_level <= 4'b0;
				Blue_level <= 4'b0;
			end  
		end
	end

endmodule

