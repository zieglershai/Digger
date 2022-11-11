module	terrain_bit_map	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input 	[10:0]	alien_a_top_leftX,
					input 	[10:0]	alien_a_top_leftY,
					input 	[10:0]	gold_1_top_leftX,
					input 	[10:0]	gold_1_top_leftY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic playerHit,
	
	
					output	logic  [3:0] free_direction_alien_a ,
					output 				gold_1_can_fall,

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[11:0] RGBout,  //rgb value from the bitmap 
					output	logic	[3:0] HitEdgeCode //one bit per edge 
 ) ;
 
	wire [3:0] alien_a_up, alien_a_right, alien_a_down, alien_a_left;
	wire [10:0] alien_x_cell , alien_y_cell;

	wire [10:0] gold_1_x_cell , gold_1_y_cell;

	logic unsigned [0:9] [0:14] [1:0] terrain_maze ;
	logic unsigned [0:9] [0:14] [1:0] initial_game_map   = 
       {{2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h0, 2'h0},
        {2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h0, 2'h0},
        {2'h1, 2'h2, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1},
        {2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1},
        {2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1},
        {2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h2, 2'h2},
        {2'h1, 2'h1, 2'h1, 2'h2, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1},
        {2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1},
        {2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h1, 2'h1},
        {2'h1, 2'h1, 2'h1, 2'h1, 2'h1, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h0, 2'h1, 2'h1}}; 

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
				RGBout <=	8'h00; // transparent colour
				HitEdgeCode <= 4'h0;
				terrain_maze <= initial_game_map;
			end 
			else begin
				if ( terrain_maze[offsetY[9:5] ][offsetX[9:5]] == 2'd1) begin
					RGBout <= regular_patch [offsetY[4:0] ][offsetX[4:0]];
				end
				else if ( terrain_maze[offsetY[9:5] ][offsetX[9:5]] == 2'd2) begin
					RGBout <= dimond_patch [offsetY[4:0] ][offsetX[4:0]];
				end
				else begin
					RGBout <= 8'h00;
				end				
				if (playerHit == 1) begin
					terrain_maze[offsetY[9:5] ][offsetX[9:5]] <= 0; // to be replaced with explod
				end
			end
	end
	
	always_comb begin
	
		gold_1_x_cell = (gold_1_top_leftX - 11'd32) >> 5;
		gold_1_y_cell = (gold_1_top_leftY - 11'd160) >> 5;
		// condition to going down is if we not at the last line and line below us is empty
		gold_1_can_fall = gold_1_y_cell != 11'd9  && terrain_maze[gold_1_y_cell + 11'b1][gold_1_x_cell] == 2'b00; 
		
		alien_x_cell = (alien_a_top_leftX - 11'd32) >> 5;
		alien_y_cell = (alien_a_top_leftY - 11'd160) >> 5;
		
		drawingRequest = terrain_maze[offsetY[9:5] ][offsetX[9:5]] != 2'd00  & InsideRectangle;
		
		//condition to go up : terrain_maze [ the tile which above the alien in ] == empty tile && not exiting maze
		if (alien_a_top_leftY[4:0] == 5'd0)begin // if the upper part is getting close to the next cell
			alien_a_up = terrain_maze[alien_y_cell - 11'b1][alien_x_cell] == 2'b00 &&  alien_y_cell != 11'b0 && alien_a_top_leftX[4:0] == 5'd0;
		end
		else begin
			alien_a_up = 1'b1;
		end
		
		//condition to go right : terrain_maze [ the tile which to the right the alien in ] == empty tile && not exiting maze
		if(alien_a_top_leftX[4:0] == 5'd0)begin // if the right side of us is getting closure to the right edge
			alien_a_right = terrain_maze[alien_y_cell][alien_x_cell + 1'b1] == 2'b00 &&  alien_x_cell !=  11'd14 && alien_a_top_leftY[4:0] == 5'd0;
		end
		else begin
			alien_a_right = 1'b1; // the right part is already in the next cell
		end
		//condition to go down : terrain_maze [ the tile which down the alien in ] == empty tile && not exiting maze
		if (alien_a_top_leftY[4:0] == 5'd0)begin // if the lower part of us is close to the next cell 
			alien_a_down = terrain_maze[alien_y_cell + 11'b1][alien_x_cell] == 2'b00 &&  alien_y_cell != 11'd9 && alien_a_top_leftX[4:0] == 5'd0;
		end
		else begin // we the lower part is already in the next cell keep going
			alien_a_down = 1'b1;
		end
		
		//condition to go left : terrain_maze [ the tile which left to the alien in ] == empty tile && not exiting maze
		if (alien_a_top_leftX[4:0] == 5'd0)begin // if we are in the left part of the cell and close to the next one
			alien_a_left = terrain_maze[alien_y_cell][alien_x_cell - 11'b1] == 2'b00 &&  alien_x_cell > 11'd0 && alien_a_top_leftY[4:0] == 5'd0;
		end
		else begin
			alien_a_left = 1'b1; // if we are far from the left edge of the cell we can move left
		end
		free_direction_alien_a = (alien_a_up << 3) + (alien_a_right << 2) + (alien_a_down << 1 ) + alien_a_left;
	end
endmodule 