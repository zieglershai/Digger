module	terrain_bit_map
#(
	parameter  logic [10:0] board_position_X = 11'd32,
	parameter  logic [10:0] board_position_Y = 11'd160
)

	(	
	input	logic	clk,
	input	logic	resetN,
	input logic	[10:0] offsetX,// offset from top left  position 
	input logic	[10:0] offsetY,
	input 	[10:0]	alien_top_leftX_a,
	input 	[10:0]	alien_top_leftY_a,
	input 	[10:0]	alien_top_leftX_b,
	input 	[10:0]	alien_top_leftY_b,
	input 	[10:0]	gold_1_top_leftX_a,
	input 	[10:0]	gold_1_top_leftY_a,
	input 	[10:0]	gold_1_top_leftX_b,
	input 	[10:0]	gold_1_top_leftY_b,
	input	logic	InsideRectangle, //input that the pixel is within a bracket 
	input logic playerHit,


	output	logic  [3:0] free_direction_alien_a ,
	output	logic  [3:0] free_direction_alien_b ,

	output 				gold_1_can_fall_a,
	output 				gold_1_can_fall_b,

	output 				empty_square_terrain,
	output	logic		dimond_eaten,
	output	logic		all_dimond_eaten,
	output	logic	drawingRequest, //output that the pixel should be dispalyed 
	output	logic	[11:0] RGBout,  //rgb value from the bitmap 
	output	logic [3:0] dimond_counter

 ) ;
 
	wire [3:0] alien_up_a, alien_right_a, alien_down_a, alien_left_a;
	wire [10:0] alien_x_cell_a , alien_y_cell_a;
	wire [3:0] alien_up_b, alien_right_b, alien_down_b, alien_left_b;
	wire [10:0] alien_x_cell_b , alien_y_cell_b;
//	wire [3:0] dimond_counter;

	wire [10:0] gold_1_x_cell_a , gold_1_y_cell_a;
	wire [10:0] gold_1_x_cell_b , gold_1_y_cell_b;

	logic unsigned [0:9] [0:14] [1:0] terrain_maze ;
	logic unsigned [0:9] [0:14] [1:0] initial_game_map   = 
       {{2'h0, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h0, 2'h0},
        {2'h0, 2'h0, 2'h0, 2'h0, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h0, 2'h0},
        {2'h2, 2'h2, 2'h1, 2'h0, 2'h1, 2'h1, 2'h2, 2'h2, 2'h2, 2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1},
        {2'h2, 2'h2, 2'h1, 2'h0, 2'h1, 2'h1, 2'h2, 2'h2, 2'h2, 2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1},
        {2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h2, 2'h2},
        {2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h2, 2'h2},
        {2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1},
        {2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1},
        {2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1},
        {2'h1, 2'h1, 2'h1, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h1, 2'h1}}; 

	logic unsigned [0:31] [0:31] [11:0]dimond_patch =  
		{
		{12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00},
		{12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00},
		{12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60},
		{12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60},
		{12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60},
		{12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60},
		{12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00},
		{12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00},
		{12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00},
		{12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00},
		{12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60},
		{12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hCFC,12'hCFC,12'hCFC,12'hCFC,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'h3F3,12'h3F3,12'h6C0,12'h000,12'h000,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60},
		{12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hCFC,12'hCFC,12'hCFC,12'hCFC,12'hCFC,12'hCFC,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h6C0,12'h000,12'h000,12'hC00,12'hC00,12'hC60,12'hC60},
		{12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hCFC,12'hCFC,12'hCFC,12'hCFC,12'hCFC,12'hCFC,12'hCFC,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h6C0,12'h6C0,12'h000,12'hC00,12'hC00,12'hC60},
		{12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hCFC,12'hCFC,12'hCFC,12'hCFC,12'hCFC,12'hCFC,12'hCFC,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h6C0,12'hC00,12'hC00,12'hC00},
		{12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hCFC,12'hCFC,12'hCFC,12'hCFC,12'hCFC,12'hBF6,12'hBF6,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h6C0,12'h6C0,12'h6C0,12'h6C0,12'h6C0,12'h6C0,12'hC00,12'hC00,12'hC00},
		{12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hCFC,12'hCFC,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h6C0,12'h6C0,12'h6C0,12'h6C0,12'h6C0,12'h6C0,12'h000,12'hC60,12'hC00,12'hC00},
		{12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h6C0,12'h6C0,12'h6C0,12'h6C0,12'h6C0,12'h000,12'h000,12'hC60,12'hC60,12'hC60,12'hC00},
		{12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'hBF6,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h6C0,12'h6C0,12'h6C0,12'h6C0,12'h6C0,12'h000,12'h000,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60},
		{12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hCFC,12'hCFC,12'hBF6,12'hBF6,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h6C0,12'h6C0,12'h6C0,12'h000,12'h000,12'h000,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60},
		{12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hCFC,12'hCFC,12'hBF6,12'h3F3,12'h3F3,12'h3F3,12'h3F3,12'h6C0,12'h6C0,12'h6C0,12'h000,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60},
		{12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hCFC,12'hBF6,12'hBF6,12'h3F3,12'h3F3,12'h6C0,12'h6C0,12'h000,12'h000,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60},
		{12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hBF6,12'h3F3,12'h6C0,12'h6C0,12'h000,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00},
		{12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00},
		{12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00},
		{12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00},
		{12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60},
		{12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60},
		{12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60},
		{12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60},
		{12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00},
		{12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00}
		};
	
	
	logic unsigned [0:31] [0:31] [11:0] regular_patch =  {
	{12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00},
	{12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00},
	{12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60},
	{12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60},
	{12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60},
	{12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60},
	{12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00},
	{12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00},
	{12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00},
	{12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00},
	{12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60},
	{12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60},
	{12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60},
	{12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60},
	{12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00},
	{12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00},
	{12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00},
	{12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00},
	{12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60},
	{12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60},
	{12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60},
	{12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60},
	{12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00},
	{12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00},
	{12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00},
	{12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00},
	{12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60},
	{12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60},
	{12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60},
	{12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60},
	{12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00,12'hC00},
	{12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC60,12'hC00,12'hC00,12'hC00,12'hC00},
	};
	
	
	
	always_ff@(posedge clk or negedge resetN)
		begin
			if(!resetN) begin
				RGBout <=	12'h000; // transparent colour
				terrain_maze <= initial_game_map;
				empty_square_terrain <= 1'b1;
				dimond_eaten <= 1'b0;
				all_dimond_eaten <= 1'b0;
				dimond_counter <= 4'd14;

			end 
			else begin
				dimond_eaten <= 1'b0;
				all_dimond_eaten <= 1'b0;
				if ( terrain_maze[offsetY[9:5] ][offsetX[9:5]] == 2'd1) begin
					RGBout <= regular_patch [offsetY[4:0] ][offsetX[4:0]];
					empty_square_terrain <= 1'b0;
				end
				else if ( terrain_maze[offsetY[9:5] ][offsetX[9:5]] == 2'd2) begin
					RGBout <= dimond_patch [offsetY[4:0] ][offsetX[4:0]];
					empty_square_terrain <= 1'b0;
				end
				else begin
					RGBout <= 12'h000;
					empty_square_terrain <= 1'b1;
				end				
				if (playerHit == 1) begin
					terrain_maze[offsetY[9:5] ][offsetX[9:5]] <= 0; // to be replaced with explod
					if(terrain_maze[offsetY[9:5] ][offsetX[9:5]] == 2'd2) begin // if there was a dimond 
						dimond_eaten <= 1'b1;  // signal to update score
						dimond_counter <= dimond_counter - 4'b1;  // update how much there left
						if (dimond_counter == 4'b1)begin  // if was the last one signal it
							all_dimond_eaten <= 1'b1;		
						end
					end
				end
			end
	end
	
	always_comb begin
	
	//-------------gold falling logic----------------------------------------------------------------
	
		gold_1_x_cell_a = (gold_1_top_leftX_a - board_position_X) >> 5;
		gold_1_y_cell_a = (gold_1_top_leftY_a - board_position_Y) >> 5;
		// condition to going down is if we not at the last line and line below us is empty
		gold_1_can_fall_a = gold_1_y_cell_a != 11'd9  && terrain_maze[gold_1_y_cell_a + 11'b1][gold_1_x_cell_a] == 2'b00; 
		
		gold_1_x_cell_b = (gold_1_top_leftX_b - board_position_X) >> 5;
		gold_1_y_cell_b = (gold_1_top_leftY_b - board_position_Y) >> 5;
		// condition to going down is if we not at the last line and line below us is empty
		gold_1_can_fall_b = gold_1_y_cell_b != 11'd9  && terrain_maze[gold_1_y_cell_b + 11'b1][gold_1_x_cell_b] == 2'b00; 
	
	
	//------------------------------------------------------------------------------------------------
		/*  logic for alien a */
	//-------------------------------------------------------------------------------------------------	
		alien_x_cell_a = (alien_top_leftX_a - board_position_X) >> 5;
		alien_y_cell_a = (alien_top_leftY_a - board_position_Y) >> 5;
		
		drawingRequest =  InsideRectangle;
		
		//condition to go up : terrain_maze [ the tile which above the alien in ] == empty tile && not exiting maze
		if (alien_top_leftY_a[4:0] == 5'd0)begin // if the upper part is getting close to the next cell
			alien_up_a = terrain_maze[alien_y_cell_a - 11'b1][alien_x_cell_a] == 2'b00 &&  alien_y_cell_a != 11'b0 && alien_top_leftX_a[4:0] == 5'd0;
		end
		else begin
			alien_up_a = 1'b1;
		end
		
		//condition to go right : terrain_maze [ the tile which to the right the alien in ] == empty tile && not exiting maze
		if(alien_top_leftX_a[4:0] == 5'd0)begin // if the right side of us is getting closure to the right edge
			alien_right_a = terrain_maze[alien_y_cell_a][alien_x_cell_a + 1'b1] == 2'b00 &&  alien_x_cell_a !=  11'd14 && alien_top_leftY_a[4:0] == 5'd0;
		end
		else begin
			alien_right_a = 1'b1; // the right part is already in the next cell
		end
		//condition to go down : terrain_maze [ the tile which down the alien in ] == empty tile && not exiting maze
		if (alien_top_leftY_a[4:0] == 5'd0)begin // if the lower part of us is close to the next cell 
			alien_down_a = terrain_maze[alien_y_cell_a + 11'b1][alien_x_cell_a] == 2'b00 &&  alien_y_cell_a != 11'd9 && alien_top_leftX_a[4:0] == 5'd0;
		end
		else begin // we the lower part is already in the next cell keep going
			alien_down_a = 1'b1;
		end
		
		//condition to go left : terrain_maze [ the tile which left to the alien in ] == empty tile && not exiting maze
		if (alien_top_leftX_a[4:0] == 5'd0)begin // if we are in the left part of the cell and close to the next one
			alien_left_a = terrain_maze[alien_y_cell_a][alien_x_cell_a - 11'b1] == 2'b00 &&  alien_x_cell_a > 11'd0 && alien_top_leftY_a[4:0] == 5'd0;
		end
		else begin
			alien_left_a = 1'b1; // if we are far from the left edge of the cell we can move left
		end
		free_direction_alien_a = (alien_up_a << 3) + (alien_right_a << 2) + (alien_down_a << 1 ) + alien_left_a;
		
		
		
	//------------------------------------------------------------------------------------------------
		/*  logic for alien b */
	//-------------------------------------------------------------------------------------------------		
		
		alien_x_cell_b = (alien_top_leftX_b - board_position_X) >> 5;
		alien_y_cell_b = (alien_top_leftY_b - board_position_Y) >> 5;
		
		drawingRequest =  InsideRectangle;
		
		//condition to go up : terrain_maze [ the tile which above the alien in ] == empty tile && not exiting maze
		if (alien_top_leftY_b[4:0] == 5'd0)begin // if the upper part is getting close to the next cell
			alien_up_b = terrain_maze[alien_y_cell_b - 11'b1][alien_x_cell_b] == 2'b00 &&  alien_y_cell_b != 11'b0 && alien_top_leftX_b[4:0] == 5'd0;
		end
		else begin
			alien_up_b = 1'b1;
		end
		
		//condition to go right : terrain_maze [ the tile which to the right the alien in ] == empty tile && not exiting maze
		if(alien_top_leftX_b[4:0] == 5'd0)begin // if the right side of us is getting closure to the right edge
			alien_right_b = terrain_maze[alien_y_cell_b][alien_x_cell_b + 1'b1] == 2'b00 &&  alien_x_cell_b !=  11'd14 && alien_top_leftY_b[4:0] == 5'd0;
		end
		else begin
			alien_right_b = 1'b1; // the right part is already in the next cell
		end
		//condition to go down : terrain_maze [ the tile which down the alien in ] == empty tile && not exiting maze
		if (alien_top_leftY_b[4:0] == 5'd0)begin // if the lower part of us is close to the next cell 
			alien_down_b = terrain_maze[alien_y_cell_b + 11'b1][alien_x_cell_b] == 2'b00 &&  alien_y_cell_b != 11'd9 && alien_top_leftX_b[4:0] == 5'd0;
		end
		else begin // we the lower part is already in the next cell keep going
			alien_down_b = 1'b1;
		end
		
		//condition to go left : terrain_maze [ the tile which left to the alien in ] == empty tile && not exiting maze
		if (alien_top_leftX_b[4:0] == 5'd0)begin // if we are in the left part of the cell and close to the next one
			alien_left_b = terrain_maze[alien_y_cell_b][alien_x_cell_b - 11'b1] == 2'b00 &&  alien_x_cell_b > 11'd0 && alien_top_leftY_b[4:0] == 5'd0;
		end
		else begin
			alien_left_b = 1'b1; // if we are far from the left edge of the cell we can move left
		end
		free_direction_alien_b = (alien_up_b << 3) + (alien_right_b << 2) + (alien_down_b << 1 ) + alien_left_b;
		
	end
endmodule 