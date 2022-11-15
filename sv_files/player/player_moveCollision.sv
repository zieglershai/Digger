// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updaed Eyal Lev Feb 2021


module	player_moveCollision
#(
	parameter  logic [10:0] board_position_X = 11'd32,
	parameter  logic [10:0] board_position_Y = 11'd160
)
(	
 
	input	logic	clk,
	input	logic	resetN,
	input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
	input	logic	leftArrow,  //move left
	input	logic	rightArrow, 	//move right
	input	logic	downArrow,  //move left
	input	logic	upArrow, 	//move right
	input logic collision,  //collision if player hits an side
	input	logic	[3:0] HitEdgeCode, //one bit per edge 
	output logic [1:0] player_direction,
	output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
	output	 logic signed	[10:0]	topLeftY,  // can be negative , if the object is partliy outside 
	output	logic 	[2:0]	image,
	output	logic		player_awake
		
);


// a module used to generate the  ball trajectory.  

	int INITIAL_X = board_position_X + (32 * 6);
	int INITIAL_Y = board_position_Y + (32 *9);
	int INITIAL_X_SPEED = 100;
	int INITIAL_Y_SPEED =  100;

	const int	FIXED_POINT_MULTIPLIER	=	64;
	// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
	// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
	// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

	int Xspeed, XcurrentSpeed, topLeftX_FixedPoint; // local parameters 
	int Yspeed, YcurrentSpeed, topLeftY_FixedPoint;
	logic rightFlag = 0;
	logic leftFlag = 0;
	logic upFlag = 0;
	logic downFlag = 0;
	
	wire [10:0] counter, next_counter;
	wire alive;


//////////--------------------------------------------------------------------------------------------------------------=
//  calculation X Axis speed using and position calculate regarding X_direction key or  colision

	always_ff@(posedge clk or negedge resetN)
	begin
		if(!resetN)
		begin
			XcurrentSpeed	<= 0;
			YcurrentSpeed	<= 0;
			topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
			topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
			Xspeed <= INITIAL_X_SPEED;
			Yspeed <= INITIAL_Y_SPEED;
			player_direction <= 2'b11;
			counter <= 11'd0;
			alive <= 1'b1;

		end
		else begin
			Xspeed <= Xspeed;
			Yspeed <= Yspeed;
			if (collision && alive) begin
				alive <= 1'b0;
			end	
					
			//  an edge input is tested here as it a very small instance   
			if (rightArrow && !leftArrow && !rightFlag)begin
				if(topLeftY[4:0] >= 5'd31 || topLeftY[4:0] <= 5'd0) begin // check if we are centered in the y axis	
					XcurrentSpeed <= Xspeed;
					player_direction <= 2'b01;
				end
				else if(topLeftY[4:0] >= 5'd14) begin
					YcurrentSpeed <= Yspeed;
				end	
				else begin					
					YcurrentSpeed <= -Yspeed;
				end	
			end
			// check collision with right border while moving right			
			if (HitEdgeCode [1] == 1 && collision || ((topLeftX >= board_position_X + (32*14)) && rightArrow))begin 
				rightFlag <= 1;
				XcurrentSpeed	<= 0;
			end
			
			// moving left	
			if (!rightArrow && leftArrow && !leftFlag)begin
				if(topLeftY[4:0] >= 5'd31 || topLeftY[4:0] <= 5'd0) begin // check if we are centered in the y axis	
					XcurrentSpeed <= -Xspeed;
					player_direction <= 2'b11;
				end
				else if(topLeftY[4:0] >= 5'd14) begin
					YcurrentSpeed <= Yspeed;
				end	
				else begin					
					YcurrentSpeed <= -Yspeed;
				end
			end
			// check collision with left border while moving left			
			if (HitEdgeCode [3] == 1 && collision || ((topLeftX <= board_position_X) && leftArrow )) begin
				leftFlag <= 1;
				XcurrentSpeed	<= 0;
			end
			
			if (/*!upArrow && */downArrow && !downFlag)begin
				if(topLeftX[4:0] >= 5'd31 || topLeftX[4:0] <= 5'd0) begin // check if we are centered in the y axis	
					YcurrentSpeed <= Yspeed;
					player_direction <= 2'b10;

				end
				else if(topLeftX[4:0] >= 5'd14) begin
					XcurrentSpeed <= Xspeed;
				end	
				else begin					
					XcurrentSpeed <= -Xspeed;
				end	
			end
			// check collision with left border while moving left			
			if (/*HitEdgeCode [2] == 1 && collision || */((topLeftY >= board_position_Y +(32 * 9)) && downArrow )) begin
				downFlag <= 1;
				YcurrentSpeed	<= 0;
			end
			
			if (!downArrow && upArrow && !upFlag)begin
				if(topLeftX[4:0] >= 5'd31 || topLeftX[4:0] <= 5'd0) begin // check if we are centered in the y axis	
					YcurrentSpeed <= -Yspeed;
					player_direction <= 2'b00;

				end
				else if(topLeftX[4:0] >= 5'd14) begin
					XcurrentSpeed <= Xspeed;
				end	
				else begin					
					XcurrentSpeed <= -Xspeed;
				end
			end
			// check collision with left border while moving left			
			if (HitEdgeCode [0] == 1 && collision || ((topLeftY <= board_position_Y) && upArrow )) begin
				upFlag <= 1;
				YcurrentSpeed	<= 0;
			end			
			// update location at end of frame	
			if (startOfFrame == 1'b1 ) begin//&& Yspeed != 0) 
				if (alive)begin
					rightFlag <= 0;
					leftFlag <= 0;
					upFlag <= 0;
					downFlag <= 0;
					topLeftX_FixedPoint <= topLeftX_FixedPoint + XcurrentSpeed;
					topLeftY_FixedPoint <= topLeftY_FixedPoint + YcurrentSpeed;
					if (XcurrentSpeed != 0  | YcurrentSpeed != 0)begin
						XcurrentSpeed	<= 0;
						YcurrentSpeed	<= 0;
					end
				end
				else begin
					if (counter <= 11'd255) begin
						counter <= counter + 11'b1;
					end
					else begin
						topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
						topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
						counter <= 11'b0;
						alive <= 1'b1; // count to 256 and than return alive
					end
				end
			end
		end
	end

	//get a better (64 times) resolution using integer   
	assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
	assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    
	assign image = counter[7:6];
	assign player_awake = alive;

endmodule
