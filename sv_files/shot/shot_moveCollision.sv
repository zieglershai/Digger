module	shot_moveCollision
//	#(
//		parameter  logic [10:0] board_position_X = 11'd32,
//		parameter  logic [10:0] board_position_Y = 11'd160
//	)
	(	
 
	input	logic	clk,
	input	logic	resetN,
	input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
	input	logic	fireCollision,  //move left
	input	logic	fire_pressed,  //move left
	
	input		logic		[1:0]		player_direction,
	input		logic  	[10:0]	playerXPosition, // output the top left corner 
	input	 	logic 	[10:0]	playerYPosition,  // can be negative , if the object is partliy outside 
	
	output	logic		alive,
	output	logic  	[10:0]	topLeftX, // output the top left corner 
	output	logic 	[10:0]	topLeftY  // can be negative , if the object is partliy outside 
					
);

parameter int INITIAL_X = 0;
parameter int INITIAL_Y = 200;
parameter int INITIAL_X_SPEED = 200;
parameter int INITIAL_Y_SPEED =  200;
parameter int MAX_Y_SPEED = 400;


const int	FIXED_POINT_MULTIPLIER	=	64;


int Xspeed, topLeftX_FixedPoint; // local parameters 
int Yspeed, topLeftY_FixedPoint;


//////////--------------------------------------------------------------------------------------------------------------=
//  calculation X Axis speed using and position calculate regarding X_direction key or  colision
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		//Yspeed	<= INITIAL_Y_SPEED;
		//Xspeed	<= 0;
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
		alive <= 0;
	end
	else begin
		
		if(fire_pressed && !alive) begin
			topLeftX_FixedPoint <= (playerXPosition + 16) * FIXED_POINT_MULTIPLIER;
			topLeftY_FixedPoint <= (playerYPosition + 16) * FIXED_POINT_MULTIPLIER;
			alive <= 1;
			if (player_direction == 2'b00) begin 
				Xspeed <= 0;
				Yspeed <= -INITIAL_Y_SPEED;
			end
			else if (player_direction == 2'b01) begin 
				Xspeed <= INITIAL_X_SPEED;
				Yspeed <= 0;
			end
			else if (player_direction == 2'b10) begin 
				Xspeed <= 0;
				Yspeed <= INITIAL_Y_SPEED;
			end
			else begin 
				Xspeed <= -INITIAL_X_SPEED;
				Yspeed <= 0;
			end

		end 
		else if (fireCollision)
			alive <= 0;
		   
		if (startOfFrame == 1'b1 )begin //&& Yspeed != 0) 
	
			topLeftX_FixedPoint <= topLeftX_FixedPoint + Xspeed;
			topLeftY_FixedPoint <= topLeftY_FixedPoint + Yspeed;
						  //Yspeed <= 0;
		end
			
	end
end

//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint[16:6]  ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint[16:6]  ;    


endmodule
