module alien_moveCollision 
#(
	parameter int INITIAL_X = 504,
	parameter int INITIAL_Y = 344
)
(
	input	logic	clk,
	input	logic	resetN,
	input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
	input	logic	[3:0] HitEdgeCode, //one bit per edge 
	input logic [3:0] free_direction ,
	input logic [10:0] player_top_leftX,
	input logic [10:0] player_top_leftY,
	input logic alien_died,
	input logic player_died,
	output logic alive,
	output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
	output	 logic signed	[10:0]	topLeftY  // can be negative , if the object is partliy outside 

);

	parameter int INITIAL_X_SPEED = 128;
	parameter int INITIAL_Y_SPEED =  128;
	parameter int MAX_Y_SPEED = 230;
	const int  Y_ACCEL = 0;//-1;

	const int	FIXED_POINT_MULTIPLIER	=	64;
	// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
	// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
	// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

	typedef enum {idle, dead_end, two_way, junction} road_state;
	
	road_state current_state;
	road_state next_state;
	logic [3:0] free_direction_sum; 
	int Xspeed, XcurrentSpeed, topLeftX_FixedPoint; // local parameters 
	int Yspeed, YcurrentSpeed, topLeftY_FixedPoint;
	wire [5:0] x_dist, y_dist; // the distance between the alien and the player
	wire [1:0] direction; // 0 to 3 : up, right, down, left
	logic [1:0] next_direction;
	logic move;
	logic [10:0] counter;
//////////--------------------------------------------------------------------------------------------------------------=
//  calculation X Axis speed using and position calculate regarding X_direction key or  colision

	always_ff@(posedge clk or negedge resetN)
	begin
		if(!resetN)
		begin
			direction <= 2'b11; 
			current_state = idle;
			XcurrentSpeed	<= 0;
			YcurrentSpeed	<= 0;
			topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
			topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
			Xspeed <= INITIAL_X_SPEED;
			Yspeed <= INITIAL_Y_SPEED;
			alive <= 1'b1;
			counter <= 11'b0;
		end
		else begin
			if (alien_died == 1'b1 || player_died == 1'b1) begin 
				// if alien was hit return him for the origin place and pause for 2 secoend
				alive <= 1'b0;
				counter <= 11'b0;
			end
				
		
			current_state = next_state;
			direction <= next_direction;
			// implement movment:
			if (next_direction == 2'b00) begin // if we need to move up
				YcurrentSpeed <= -Yspeed;
				XcurrentSpeed <= 0;
			end
			else if (next_direction == 2'b01) begin // if we want to move right
				XcurrentSpeed <= Xspeed;
				YcurrentSpeed <= 0;
				

			end
			else if (next_direction == 2'b10) begin // if we want to move down
				YcurrentSpeed <= Yspeed;
				XcurrentSpeed <= 0;
			end
			else begin // if we want to move left
				XcurrentSpeed <= -Xspeed;
				YcurrentSpeed <= 0;
			end
			// update location at end of frame	
			if (startOfFrame == 1'b1 & move ) begin//&& Yspeed != 0) 
				if (alive == 1'b1) begin
					topLeftX_FixedPoint <= topLeftX_FixedPoint + XcurrentSpeed;
					topLeftY_FixedPoint <= topLeftY_FixedPoint + YcurrentSpeed;
					if (XcurrentSpeed != 0 | YcurrentSpeed != 0)begin
						XcurrentSpeed	<= 0;
						YcurrentSpeed <= 0;
					end
				end
				else begin
					// below is the logic related to the being hit from fire 
					if (counter <= 11'd255) begin  // stay dead for 255 frames
						counter <= counter + 11'b1; 
					end
			
					else begin
					counter <= 11'b0; 
					alive <= 1'b1;
					topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
					topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
					end
				end
			end
		end
	end
	
	
	always_comb begin
		// defults:
		move = 1'b1;
		next_direction = 2'b11;
		free_direction_sum = {2'b0, free_direction[3]} + {2'b0, free_direction[2]} + {2'b0, free_direction[1]} + {2'b0, free_direction[0]}; // add a bit to the left to prevent overflow
		// select the next state based on number of possible ways
		if (free_direction_sum == 4'd3 || free_direction_sum == 4'd4)begin
			next_state = junction;
		end
		else if (free_direction_sum == 2'd2)begin
			next_state = two_way;
		end
		else begin
			next_state = dead_end;
		end

		case (free_direction_sum)
			2'b0: begin
				move = 1'b0;
			end
			2'b1: begin
			// there is one way find it:
				if (free_direction[3] == 1'b1)begin // only way is up
					next_direction = 2'b00;
				end
				else if (free_direction[2] == 1'b1)begin // only way is right
					next_direction = 2'b01;
				end
				else if (free_direction[1] == 1'b1)begin // only way is down
					next_direction = 2'b10;
				end
				else if (free_direction[0] == 1'b1)begin // only way is left
					next_direction = 2'b11;
				end
			end
			4'd2: begin

				// if we went up before
				if (direction == 2'b00) begin 
					if (free_direction[3] == 1'b1)begin // we can go the same direction (up)
						next_direction = 2'b00; // go up
					end
					// in two way if we can't go up check if to turn right or left
					else if(free_direction[2] == 1'b1)begin // we can go right
						next_direction = 2'b01; // go right
					end
					else begin
						next_direction = 2'b11; // go left
					end
				end
				// if we went right
				else if (direction == 2'b01) begin
					if (free_direction[2] == 1'b1)begin // we can go the same direction (right)
						next_direction = 2'b01; // go up
					end
					// in two way if we can't go right check if to turn up or down
					else if(free_direction[3] == 1'b1)begin // we can go up
						next_direction = 2'b00; // go up
					end
					else begin
						next_direction = 2'b10; // go down
					end
				end
				// if we went down
				else if (direction == 2'b10) begin
					if (free_direction[1] == 1'b1)begin // we can go the same direction (down)
						next_direction = 2'b10; // go down
					end
					// in two way if we can't go down check if to turn right or left
					else if(free_direction[2] == 1'b1)begin // we can go right
						next_direction = 2'b01; // go right
					end
					else begin
						next_direction = 2'b11; // go left
					end
				end
				// last possible direction is left
				else begin
					if (free_direction[0] == 1'b1)begin // we can go the same direction (left)
						next_direction = 2'b11; // go left
					end
					// in two way if we can't go left check if to turn up or down
					else if(free_direction[3] == 1'b1)begin // we can go right
						next_direction = 2'b00; // go up
					end
					else begin
						next_direction = 2'b10; // go down
					end
				end
			end
			4'd3, 4'd4: begin

				// if we are in juction we would choose the path that will lead us to the player:
				// and at eighther x axis or y-axis will be available
				// we want to compare the distance at block unit (32pixel * 32 pixel)
				if (x_dist >= y_dist ) begin
					if (player_top_leftX >= topLeftX && free_direction[2] == 1'b1) begin // if the player is to the right and we can go there
						next_direction = 2'b01; // go right
					end
					else if(player_top_leftX <= topLeftX && free_direction[0] == 1'b1) begin // if the player is to the left and we can go there
						next_direction = 2'b11; // go left
					end
					else begin // x-axis is blocked move the y-axis
						next_direction  =  player_top_leftY > topLeftY ? 2'b10 : 2'b00 ; // go x direction
					end
				end
				else begin // if the y distance is greater
					if (player_top_leftY >= topLeftY && free_direction[1] == 1'b1) begin // if the player is below and we can go there
						next_direction = 2'b10; // go down
					end
					else if (player_top_leftY <= topLeftY && free_direction[3] == 1'b1) begin // if the player is above and we can go there
						next_direction = 2'b00; // go up
					end
					else begin // if y-axis is blocked go the x axis
						next_direction  =  player_top_leftX > topLeftX ? 2'b01 : 2'b11 ; // go y direction
					end
				end
			end

		endcase
	end

	//get a better (64 times) resolution using integer   
	assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
	assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    
	assign	x_dist = player_top_leftX > topLeftX ? player_top_leftX[10:5]  - topLeftX[10:5] : topLeftX[10:5] - player_top_leftX[10:5];
	assign	y_dist = player_top_leftY > topLeftY ? player_top_leftY[10:5] - topLeftY[10:5] : topLeftY[10:5] - player_top_leftY[10:5];
endmodule
 