module score_bit_map	(	
	input		logic	clk,
	input		logic	resetN,
	input		logic	startOfFrame,
	input 	logic	[10:0] offsetX,// offset from top left  position 
	input 	logic	[10:0] offsetY,
	input		logic	InsideRectangle, //input that the pixel is within a bracket 
	input 	logic	player_eat_gold, // points to add
	input 	logic player_eat_dimond,
	
	output	logic				drawingRequest, //output that the pixel should be dispalyed 
	output	logic	[11:0]		RGBout

);



wire logic[4:0] singles, tens, hunderes, thousands;
bit [0:9] [0:15] [0:7] number_bitmap  = {


{
// 0

	8'b11000011,
	8'b10000001,
	8'b00000000,
	8'b00011000,
	8'b00011000,
	8'b00011000,
	8'b00011000,
	8'b00011000,
	8'b00011000,
	8'b00011000,
	8'b00011000,
	8'b00011000,
	8'b00011000,
	8'b00000000,
	8'b10000001,
	8'b11000011},
			
// 1
			
{
	8'b11000000,
	8'b11000000,
	8'b11110000,
	8'b11110000,
	8'b11110000,
	8'b11110000,
	8'b11110000,
	8'b11110000,
	8'b11110000,
	8'b11110000,
	8'b11110000,
	8'b11110000,
	8'b11110000,
	8'b11110000,
	8'b11110000,
	8'b11110000},
		
// 2
{
	8'b11000011,
	8'b10000001,
	8'b00000000,
	8'b00011000,
	8'b00011000,
	8'b11111000,
	8'b11110000,
	8'b11100001,
	8'b11000011,
	8'b10000111,
	8'b10001111,
	8'b00011111,
	8'b00011111,
	8'b00000000,
	8'b00000000,
	8'b00000000},
	
// 3
{	
	8'b11000011,
	8'b10000001,
	8'b00000000,
	8'b00011000,
	8'b00011000,
	8'b11111000,
	8'b11110001,
	8'b11100011,
	8'b11100011,
	8'b11111001,
	8'b11111000,
	8'b00011000,
	8'b00011000,
	8'b00000000,
	8'b10000001,
	8'b11000011},
			
// 4
																			
{
	8'b11110011,
	8'b11110011,
	8'b11100011,
	8'b11100011,
	8'b11000011,
	8'b11000011,
	8'b10010011,
	8'b10010011,
	8'b10110011,
	8'b00110011,
	8'b00000000,
	8'b00000000,
	8'b10000001,
	8'b11110011,
	8'b11110011,
	8'b11110011},
			
// 5
																			
{
	8'b00000001,
	8'b00000001,
	8'b00000001,
	8'b00011111,
	8'b00011111,
	8'b00011111,
	8'b00000011,
	8'b10000001,
	8'b11000000,
	8'b11111000,
	8'b11111000,
	8'b00011000,
	8'b00011000,
	8'b00000000,
	8'b10000001,
	8'b11000011},
			
// 6
																			
{
	8'b11000011,
	8'b10000001,
	8'b00000000,
	8'b00011000,
	8'b00011000,
	8'b00011111,
	8'b00011111,
	8'b00000001,
	8'b00000000,
	8'b00011000,
	8'b00011000,
	8'b00011000,
	8'b00011000,
	8'b00000000,
	8'b10000001,
	8'b11000011},
			
// 7
																			
{
	8'b00000000,
	8'b00000000,
	8'b00000000,
	8'b00011000,
	8'b11111001,
	8'b11110001,
	8'b11110001,
	8'b11100011,
	8'b11100011,
	8'b11100011,
	8'b11000111,
	8'b11000111,
	8'b11000111,
	8'b10001111,
	8'b10001111,
	8'b10001111
},
			
// 8
																			
{
	8'b11000011,
	8'b10000001,
	8'b00000000,
	8'b00011000,
	8'b00011000,
	8'b00011000,
	8'b10000001,
	8'b10000011,
	8'b10000001,
	8'b00000000,
	8'b00011000,
	8'b00011000,
	8'b00011000,
	8'b00000000,
	8'b10000001,
	8'b11000011},
			
// 9
																			
{
	8'b11000011,
	8'b10000001,
	8'b00000000,
	8'b00011000,
	8'b00011000,
	8'b00011000,
	8'b00011000,
	8'b00000000,
	8'b10000000,
	8'b11111000,
	8'b11111000,
	8'b00011000,
	8'b00011000,
	8'b00000000,
	8'b10000001,
	8'b11000011}

};



	always_ff@(posedge clk or negedge resetN)
	begin
		if(!resetN) begin
			singles <= 5'b0;
			tens <= 5'b0;
			hunderes <= 5'b0;
			thousands <= 5'b0;
		end
		else begin
			if (player_eat_gold) begin
				if (hunderes == 5'd9) begin
					thousands <= thousands + 5'd1;
					hunderes  <= 5'b1;
				end
				else if (hunderes == 5'd8) begin
					thousands <= thousands + 5'd1;
					hunderes  <= 5'b0;
				end
				else begin
					hunderes  <= hunderes +  5'd2;
				end
			end
			if (player_eat_dimond)begin
				if (hunderes == 5'd9) begin
					thousands <= thousands + 5'd1;
					hunderes  <= 5'b0;
				end
				else begin
					hunderes  <= hunderes +  5'd1;
				end
			end
		end
	end

	always_comb begin
		if (offsetX[6:3] == 4'd0)begin
			RGBout = number_bitmap[thousands][offsetY[3:0]][offsetX[2:0]]? 12'b0 : 12'hFFF ; // this is a fixed color
		end
		else if (offsetX[6:3] == 4'd1)begin
			RGBout = number_bitmap[hunderes][offsetY[3:0]][offsetX[2:0]]? 12'b0 : 12'hFFF ; // this is a fixed color
		end
		else begin
			RGBout = number_bitmap[5'd0][offsetY[3:0]][offsetX[2:0]]? 12'b0 : 12'hFFF ; // this is a fixed color
		end
	end
	
	
	
	assign drawingRequest =  RGBout[0]; 

endmodule 