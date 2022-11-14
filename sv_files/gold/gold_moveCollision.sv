module  gold_moveCollision 
#(
	parameter int INITIAL_X = 32,
	parameter int INITIAL_Y = 160
)
(
	input	logic	clk,
	input	logic	resetN,
	input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
	input logic can_fall,
	input	logic	[3:0] HitEdgeCode, //one bit per edge 
	input logic collision,
	input logic side, // 0 for left 1 for right
	input logic been_eaten,
	output	 logic signed 	[3:0]		gold_state, 
	output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
	output	 logic signed	[10:0]	topLeftY,  // can be negative , if the object is partliy outside 
	output logic [2:0] state,
	output logic [2:0] image // tilting side when about to fall 
 
	
);




	parameter int INITIAL_X_SPEED = 128;
	parameter int INITIAL_Y_SPEED =  128;
	parameter int MAX_Y_SPEED = 400;
	


	const int	FIXED_POINT_MULTIPLIER	=	64;

	typedef enum {idle, pre_moving_r, moving_r, pre_moving_l, moving_l, pre_falling, falling, crashed, eaten} sm_state;

	sm_state current_state, next_state;
	
	logic signed [31:0] Xspeed, topLeftX_FixedPoint; // local parameters 
	logic signed [31:0] Yspeed, topLeftY_FixedPoint;

	wire collsion_flag;
	wire [9:0]	counter, next_counter, falling_counter, falling_counter_next;
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
			current_state <= idle;
			collsion_flag <= 1'b0;
			counter <= 10'b0;
			falling_counter <= 10'b0;
			
		end
		else begin
			current_state <= next_state;
			if (startOfFrame == 1'b1 )begin //&& Yspeed != 0) 
				falling_counter <= falling_counter_next;
				counter <= next_counter;
				topLeftX_FixedPoint <= topLeftX_FixedPoint + Xspeed;
				topLeftY_FixedPoint <= topLeftY_FixedPoint + Yspeed;
				collsion_flag <= 1'b0;
			end
			else begin
				collsion_flag <= collision | collsion_flag; // we want to remember if there was a collision until we move at the start of frame
			end		
		end
	end
	
	always_comb begin
		next_state = idle;
		Xspeed = 32'b0;
		Yspeed = 32'b0;
		state = 3'b0;
		gold_state = 4'd0;
		next_counter = 10'b0;
		image = 3'b0;// tilt side is normal
		falling_counter_next = 10'b0;
		case(current_state)
		
			idle: begin
				if (collsion_flag == 1'b1) begin
					if (side == 1'b1) begin // a collision from the right
						Xspeed = -INITIAL_X_SPEED;
						next_state = pre_moving_l;
					end
					else begin
						Xspeed =  INITIAL_X_SPEED;  // a collision from the left
						next_state = pre_moving_r;
					end
				end
				else if (can_fall == 1'b1) begin
					Yspeed =  INITIAL_Y_SPEED;  // a collision from the left
					next_state = pre_falling;
					next_counter = 10'b0;
				end
				else if (falling_counter >= 10'd18) begin
					next_state = crashed;
				end 
			end
			pre_moving_r:begin
			state = 3'd1;
				Xspeed =  INITIAL_X_SPEED;
				if (topLeftX[4:0] == 5'b0) begin
					next_state = pre_moving_r;
				end
				else begin
					next_state = moving_r;
				end			end
			pre_moving_l:begin
				state = 3'd2;

				Xspeed = -INITIAL_X_SPEED;
				if (topLeftX[4:0] == 5'b0) begin
					next_state = pre_moving_l;
				end
				else begin
					next_state = moving_l;
				end
			end
			moving_r:begin
				if (topLeftX[4:0] == 5'b0)begin // if we got to new cell
					next_state = idle;
				end
				else begin
					next_state = moving_r;
					Xspeed =  INITIAL_X_SPEED;  // keep move till the next cell
				end
			end
			moving_l:begin
				if (topLeftX[4:0] == 5'b0)begin // if we got to new cell
					next_state = idle;
				end
				else begin
					next_state = moving_l;
					Xspeed =  -INITIAL_X_SPEED;  // keep move till the next cell
				end
			end
			pre_falling: begin
				state = 3'd3;
				next_counter = counter + 10'b1;
				if (counter <= 10'd90)begin // wait 500 frames till start to fall
					next_state = pre_falling;
					if (counter[5:4] == 2'b0 || counter[5:4] == 2'd2) begin
						image = 3'd0;
					end
					else if (counter[5:4] == 2'b1) begin
						image = 3'd1;
					end
					else begin
						image = 3'd2;
					end
				end
				else begin
					if (topLeftY[4:0] == 5'b0) begin // wait till it starts falling 
						next_state = pre_falling;
						Yspeed =  INITIAL_Y_SPEED;  //start_moving down
					end
					else begin // when it move seitch to falling state
						next_state = falling;
						Yspeed =  INITIAL_Y_SPEED;  //start_moving down					
					end
				end
			end
			falling:begin
				gold_state = 4'd1;
				falling_counter_next = falling_counter + 10'b1;
				if (topLeftY[4:0] == 5'b0 && can_fall == 1'b0)begin
						next_state = idle;
				end
				else begin
					Yspeed =  INITIAL_Y_SPEED;  // keep move till the next cell
					next_state = falling;
				end
			end
			crashed:begin
				gold_state = 4'd2;
				if (been_eaten) begin
					next_state = eaten;
				end
				else begin
					next_state = crashed;
					image = 3'd3;
				end

			end
			eaten:begin
				gold_state = 4'd3;
				next_state = eaten;
			end
		endcase
	end
	
	//get a better (64 times) resolution using integer   
	assign 	topLeftX = topLeftX_FixedPoint[16:6]  ;   // note it must be 2^n 
	assign 	topLeftY = topLeftY_FixedPoint[16:6]  ;    



endmodule 