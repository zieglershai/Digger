// Designer: Mor (Mordechai) Dahan,
// Sep. 2022
// ***********************************************



module periphery_control (
	input		resetN,
	input		clk,
	output	A,
	output	B,
	output	Select,
	output	Start,
	output	Right,
	output	Left,
	output	Up,
	output	Down,
	output	[11:0] Wheel
	);
	
	wire	[11:0]	a0;
	wire	[11:0]	a1;
	wire	[11:0]	a2;
	wire	[11:0]	a3;
	wire	[11:0]	a4;
	
	// Analog Read Module
analog_input analog_input_inst(
	.clk(clk),
	.a0(a0), // LEFT/RIGHT Left = High, Right = middle, 0 = nothing
	.a1(a1), // UP/DOWN - Hihg up, midle down. 0 nothing
	.a2(a2), // Select button HIGH is pressed
	.a3(a3), // Button A 0 is pressed
	.a4(a4),	// Button B 0 is pressed
	.a5(Wheel) // Wheel input
	);
	
	assign A = a3 < 2048 ? 1 : 0; // A
	assign B = a4 < 2048 ? 1 : 0; // B
	assign Select = a2 > 12'hCFF ? 1 : 0; // Select
	assign Start = a2 < 12'hCFF & a2 > 12'h5FF ? 1 : 0; // Start
	assign tmp_Left = a0 > 12'hCFF ? 1 : 0; // Left
	assign tmp_Right = a0 < 12'hCFF & a0 > 12'h5FF ? 1 : 0; // Right
	assign tmp_Up = a1 > 12'hCFF ? 1 : 0; // UP
	assign tmp_Down = a1 < 12'hCFF & a1 > 12'h5FF ? 1 : 0; // DOWN
	

	wire prev_Left;
	wire prev_Right;
	wire prev_Up;
	wire prev_Down;
	
	wire tmp_Left;
	wire tmp_Right;
	wire tmp_Up;
	wire tmp_Down;
	
	wire [31:0] counter;
	
	wire flag;
	
	
	always_ff@(posedge clk or negedge resetN) begin
		if(!resetN) begin
			Right <= 1'b0;
			Left <= 1'b0;
			Up <= 1'b0;
			Down <= 1'b0;   

			prev_Left <= 1'b0;
			prev_Right <= 1'b0;
			prev_Up <= 1'b0;
			prev_Down <= 1'b0;
			
			flag <= 1'b0;
			counter <= 32'b0;
		end
		else begin
			prev_Left <= tmp_Left;
			prev_Right <= tmp_Right;
			prev_Up <= tmp_Up;
			prev_Down <= tmp_Down;
		
			if (flag == 1'b1) begin // if there was an edge count till 3000 till another thing can be assign
				 Right <= 1'b0;
				 Left <= 1'b0;
				 Up <= 1'b0;
				 Down <= 1'b0;
				 
				 if (counter == 32'd3000) begin
					counter <= 0;
					flag <= 1'b0;
				 end
				 else begin
					counter <= counter + 32'b1;
				 end
			end
			else begin // there isn't an edge
				if ((prev_Left & !tmp_Left) || (prev_Right & !tmp_Right) || (prev_Up & !tmp_Up) || (prev_Down & !tmp_Down))begin // detect an edge
					Right <= 1'b0;
					Left <= 1'b0;
					Up <= 1'b0;
					Down <= 1'b0;
					flag <= 1'b1;
				end
				else begin
					Right <= tmp_Right;
					Left <= tmp_Left;
					Up <= tmp_Up;
					Down <= tmp_Down; 				
				end
			
			end
		
		end
	
	end
endmodule
