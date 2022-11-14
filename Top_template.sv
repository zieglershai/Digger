// Designer: Mor (Mordechai) Dahan, Avi Salmon,
// Sep. 2022
// ***********************************************

`define ENABLE_ADC_CLOCK
`define ENABLE_CLOCK1
`define ENABLE_CLOCK2
`define ENABLE_SDRAM
`define ENABLE_HEX0
`define ENABLE_HEX1
`define ENABLE_HEX2
`define ENABLE_HEX3
`define ENABLE_HEX4
`define ENABLE_HEX5
`define ENABLE_KEY
`define ENABLE_LED
`define ENABLE_SW
`define ENABLE_VGA
`define ENABLE_ACCELEROMETER
`define ENABLE_ARDUINO
`define ENABLE_GPIO

module Top_template(




	//////////// ADC CLOCK: 3.3-V LVTTL //////////
`ifdef ENABLE_ADC_CLOCK
	input 		          		ADC_CLK_10,
`endif
	//////////// CLOCK 1: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK1
	input 		          		MAX10_CLK1_50,
`endif
	//////////// CLOCK 2: 3.3-V LVTTL //////////
`ifdef ENABLE_CLOCK2
	input 		          		MAX10_CLK2_50,
`endif

	//////////// SDRAM: 3.3-V LVTTL //////////
`ifdef ENABLE_SDRAM
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,
`endif

	//////////// SEG7: 3.3-V LVTTL //////////
`ifdef ENABLE_HEX0
	output		     [7:0]		HEX0,
`endif
`ifdef ENABLE_HEX1
	output		     [7:0]		HEX1,
`endif
`ifdef ENABLE_HEX2
	output		     [7:0]		HEX2,
`endif
`ifdef ENABLE_HEX3
	output		     [7:0]		HEX3,
`endif
`ifdef ENABLE_HEX4
	output		     [7:0]		HEX4,
`endif
`ifdef ENABLE_HEX5
	output		     [7:0]		HEX5,
`endif

	//////////// KEY: 3.3 V SCHMITT TRIGGER //////////
`ifdef ENABLE_KEY
	input 		     [1:0]		KEY,
`endif

	//////////// LED: 3.3-V LVTTL //////////
`ifdef ENABLE_LED
	output		     [9:0]		LEDR,
`endif

	//////////// SW: 3.3-V LVTTL //////////
`ifdef ENABLE_SW
	input 		     [9:0]		SW,
`endif

	//////////// VGA: 3.3-V LVTTL //////////
`ifdef ENABLE_VGA
	output		     [3:0]		VGA_B,
	output		     [3:0]		VGA_G,
	output		          		VGA_HS,
	output		     [3:0]		VGA_R,
	output		          		VGA_VS,
`endif

	//////////// Accelerometer: 3.3-V LVTTL //////////
`ifdef ENABLE_ACCELEROMETER
	output		          		GSENSOR_CS_N,
	input 		     [2:1]		GSENSOR_INT,
	output		          		GSENSOR_SCLK,
	inout 		          		GSENSOR_SDI,
	inout 		          		GSENSOR_SDO,
`endif

	//////////// Arduino: 3.3-V LVTTL //////////
`ifdef ENABLE_ARDUINO
	output 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,
`endif

	//////////// GPIO, GPIO connect to GPIO Default: 3.3-V LVTTL //////////
`ifdef ENABLE_GPIO
	inout 		    [35:0]		GPIO
`endif
);


//=======================================================
//  REG/WIRE declarations
//=======================================================



// clock signals
wire				clk_25;
wire				clk_50;
wire				clk_100;

// Screens signals
wire	[31:0]	pxl_x;
wire	[31:0]	pxl_y;
wire				h_sync_wire;
wire				v_sync_wire;
wire	[3:0]		vga_r_wire;
wire	[3:0]		vga_g_wire;
wire	[3:0]		vga_b_wire;
wire	[7:0]		lcd_db;
wire				lcd_reset;
wire				lcd_wr;
wire				lcd_d_c;
wire				lcd_rd;
wire				lcd_buzzer;
wire				lcd_status_led;
wire	[3:0]		Red_level;
wire	[3:0]		Green_level;
wire	[3:0]		Blue_level;



// Periphery signals
wire	A;
wire	B;
wire	Select;
wire	Start;
wire	Right;
wire	Left;
wire	Up;
wire	Down;
wire [11:0]	Wheel;


// Screens Assigns
assign ARDUINO_IO[7:0]	= lcd_db;
assign ARDUINO_IO[8] 	= lcd_reset;
assign ARDUINO_IO[9]		= lcd_wr;
assign ARDUINO_IO[10]	= lcd_d_c;
assign ARDUINO_IO[11]	= lcd_rd;
assign ARDUINO_IO[12]	= lcd_buzzer;
assign ARDUINO_IO[13]	= lcd_status_led;
assign VGA_HS = h_sync_wire;
assign VGA_VS = v_sync_wire;
assign VGA_R = vga_r_wire;
assign VGA_G = vga_g_wire;
assign VGA_B = vga_b_wire;


// Screens control (LCD and VGA)
Screens_dispaly Screen_control(
	.clk_25(clk_25),
	.clk_100(clk_100),
	.Red_level(Red_level),
	.Green_level(Green_level),
	.Blue_level(Blue_level),
	.pxl_x(pxl_x),
	.pxl_y(pxl_y),
	.Red(vga_r_wire),
	.Green(vga_g_wire),
	.Blue(vga_b_wire),
	.h_sync(h_sync_wire),
	.v_sync(v_sync_wire),
	.lcd_db(lcd_db),
	.lcd_reset(lcd_reset),
	.lcd_wr(lcd_wr),
	.lcd_d_c(lcd_d_c),
	.lcd_rd(lcd_rd)
);


// Utilities

// 25M clk generation
pll25	pll25_inst (
	.areset ( 1'b0 ),
	.inclk0 ( MAX10_CLK1_50 ),
	.c0 ( clk_25 ),
	.c1 ( clk_50 ),
	.c2 ( clk_100 ),
	.locked ( )
	);


//7-Seg default assign (all leds are off)
assign HEX0 = 8'b11111111;
assign HEX1 = 8'b11111111;
assign HEX2 = 8'b11111111;
assign HEX3 = 8'b11111111;

// periphery_control module for external units: joystick, wheel and buttons (A,B, Select and Start) 
periphery_control periphery_control_inst(
	.resetN(KEY[0]),
	.clk(clk_25),
	.A(A),
	.B(B),
	.Select(Select),
	.Start(Start),
	.Right(Right),
	.Left(Left),
	.Up(Up),
	.Down(Down),
	.Wheel(Wheel)
	);
	
	// Leds and 7-Seg show periphery_control outputs
	assign LEDR[0] = A; 			// A
	assign LEDR[1] = B; 			// B
	assign LEDR[2] = Select;	// Select
	assign LEDR[3] = Start; 	// Start
	assign LEDR[9] = Left; 		// Left
	assign LEDR[8] = Right; 	// Right
	assign LEDR[7] = Up; 		// UP
	assign LEDR[6] = Down; 		// DOWN

	seven_segment ss5(
	.in_hex(Wheel[11:8]),
	.out_to_ss(HEX5)
);

	seven_segment ss4(
	.in_hex(Wheel[7:4]),
	.out_to_ss(HEX4)
);



parameter logic [10:0] board_position_X = 11'd96;
parameter logic [10:0] board_position_Y = 11'd96;


wire restart_gameN;
wire reset_scoreN;
wire [2:0] game_state;

wire startOfFrame;
assign startOfFrame = pxl_x == 32'b0 && pxl_y == 32'b0; 
wire playerDR;
wire [11:0] playerRGB;
wire [10:0] playerTLX;
wire [10:0] playerTLY;
wire [1:0]	player_direction; 
wire player_awake;

wire terrain_dr;
wire [11:0] terrain_RGB;
wire dimond_eaten;
wire all_dimond_eaten;


wire alien_dr;
wire [11:0] alien_RGB;
wire [10:0] alien_a_top_leftX_a;
wire [10:0] alien_a_top_leftY_a;
wire [3:0] free_direction_alien_a ;
wire [10:0] alien_a_top_leftX_b;
wire [10:0] alien_a_top_leftY_b;
wire [3:0] free_direction_alien_b ;

wire	[7:0]	shotRGB;
wire  shot_dr;

wire	[11:0]	score_RGB;
wire  score_dr;

wire	[11:0]	player_life_RGB;
wire  player_life_dr;


wire	collision_player_terrain;
wire	colision_fire;
wire	collision_gold_1;
wire	player_eat_gold_1;
wire	player_died;
wire alien_died_a;

wire gold_1_dr;
wire [11:0] gold_1_RGB;
wire [10:0] gold_1_TLX;
wire [10:0] gold_1_TLY;
wire gold_1_can_fall;
wire [3:0]gold_1_state;

wire	game_over_dr;
wire	[11:0]	game_over_RGB;

wire	start_screen_dr;
wire	[11:0]	start_screen_RGB;


wire	win_screen_dr;
wire	[11:0]	win_screen_RGB;

wire [11:0] background_RGB;

game_controller
	#(
		.board_position_X(board_position_X),
		.board_position_Y(board_position_Y)
	)
 control_inst (

	.clk(clk_25),
	.resetN(~A),
	.start(Start),
	.pixelX(pxl_x[10:0]),
	.pixelY(pxl_y[10:0]),
	.startOfFrame(startOfFrame),  
	.drawing_request_terrain(terrain_dr),
	.empty_square_terrain(empty_square_terrain),
	.drawing_request_player(playerDR),
	.player_awake(player_awake),
	.shot_dr(shot_dr),
	.alien_dr(alien_dr),
	.gold_1_dr(gold_1_dr),
	.gold_1_state(gold_1_state),
	.no_dimond_left(all_dimond_eaten),
	.no_lives_left(no_lives),
	.collision_player_terrain(collision_player_terrain),
	.colision_fire(colision_fire),
	.collision_gold_1(collision_gold_1),
	.player_eat_gold_1(player_eat_gold_1),
	.player_died(player_died),
	.alien_died_a(alien_died_a),
	.restart_gameN(restart_gameN),
	.reset_scoreN(reset_scoreN),
	.game_state(game_state)
);

objects_mux mux_inst(                               
	 .clk(clk_25),
	 .resetN(~A),
	.game_state(game_state),
	 .playerDR(playerDR), 
	 .playerRGB(playerRGB),
	 .terrain_dr(terrain_dr),
	 .terrain_RGB(terrain_RGB),  
	 .backGroundRGB(background_RGB),
	 .alien_dr(alien_dr), 
	 .alien_RGB(alien_RGB),
	 .shot_dr(shot_dr),
	 .shotRGB(shotRGB),
	 .gold_1_dr(gold_1_dr),
	 .gold_1_RGB(gold_1_RGB),
	 .score_dr(score_dr),
	 .scoreRGB(score_RGB),
	 .player_life_RGB(player_life_RGB),
	 .player_life_dr(player_life_dr),
	 .game_over_dr(game_over_dr),
	 .game_over_RGB(game_over_RGB),
    .start_screen_dr(start_screen_dr),
	 .start_screen_RGB(start_screen_RGB),	
	 .win_screen_dr(win_screen_dr),
 	 .win_screen_RGB(win_screen_RGB), 
	 .Red_level(Red_level),
	 .Green_level(Green_level),
	 .Blue_level(Blue_level)
);


background back_inst (
	.clk(clk_25),
	.resetN(~A),
	.pixelX(pxl_x[10:0]),
	.pixelY(pxl_y[10:0]),
	.background_RGB(background_RGB)
);


player
#(
	.board_position_X(board_position_X),
	.board_position_Y(board_position_Y)
)
 player_inst(
	 .clk(clk_25),
	 .resetN(restart_gameN),
	 .startOfFrame(startOfFrame),
	 .leftArrowPressed(Left),
	 .rightArrowPressed(Right),
	 .upArrowPressed(Up),
	 .downArrowPressed(Down),
	 .player_died(player_died),
	 .pixelX(pxl_x[10:0]),
	 .pixelY(pxl_y[10:0]),
	 .playerTLX(playerTLX),
	 .playerTLY(playerTLY),
	 .playerDR(playerDR),
	 .playerRGB(playerRGB),
	 .player_direction(player_direction),
	 .player_awake(player_awake)
);


terrain
#(
	.board_position_X(board_position_X),
	.board_position_Y(board_position_Y)
)
terrain_inst(
	 .clk(clk_25),
	 .resetN(restart_gameN),
	 .pixelX(pxl_x[10:0]),
	 .pixelY(pxl_y[10:0]),
	 .player_inside(playerDR),
	 .alien_a_top_leftX_a(alien_a_top_leftX_a),
	 .alien_a_top_leftY_a(alien_a_top_leftY_a),
	 .free_direction_alien_a(free_direction_alien_a),
	 .alien_a_top_leftX_b(alien_a_top_leftX_b),
	 .alien_a_top_leftY_b(alien_a_top_leftY_b),
	 .free_direction_alien_b(free_direction_alien_b),
	 .gold_1_top_leftX(gold_1_TLX),
	 .gold_1_top_leftY(gold_1_TLY),
	 .gold_1_can_fall(gold_1_can_fall),
	 .dimond_eaten(dimond_eaten),
	 .empty_square_terrain(empty_square_terrain),
	 .all_dimond_eaten(all_dimond_eaten),
	 .terrainDR(terrain_dr),
	 .terrainRGB(terrain_RGB)
);

alien_bloc 
#(
	.board_position_X(board_position_X),
	.board_position_Y(board_position_Y)
)
alien_1
(
	.clk(clk_25),
	.resetN(restart_gameN),
	.startOfFrame(startOfFrame),
	.pixelX(pxl_x[10:0]),
	.pixelY(pxl_y[10:0]),
	.player_top_leftX(playerTLX),
	.player_top_leftY(playerTLY),
	.alien_top_leftX_a(alien_a_top_leftX_a),
	.alien_top_leftY_a(alien_a_top_leftY_a),
	.alien_top_leftX_b(alien_a_top_leftX_b),
	.alien_top_leftY_b(alien_a_top_leftY_b),
	
	.alien_died(alien_died_a),
	.player_died(player_died),
	.free_direction_alien_a(free_direction_alien_a),
	.free_direction_alien_b(free_direction_alien_b),

	.alien_dr(alien_dr),
	.alien_RGB(alien_RGB)
);

shots_block
//#(
//	.board_position_X(board_position_X),
//	.board_position_Y(board_position_Y)
//)
 shot_inst (
	.clk(clk_25),
	.resetN(restart_gameN),
	.pixelX(pxl_x[10:0]),
	.pixelY(pxl_y[10:0]),
	.startOfFrame(startOfFrame),
	.fireCollision(colision_fire),
	.playerXPosition(playerTLX),
	.playerYPosition(playerTLY),
	.player_direction(player_direction),
	.fire_pressed(B),// fire pressed
	.shotRGB(shotRGB),
	.shot_dr(shot_dr)
	);


gold_block
#(
	.board_position_X(board_position_X),
	.board_position_Y(board_position_Y)
)
gold_bloc_1_inst(
	.clk(clk_25),
	.resetN(restart_gameN),
	.startOfFrame(startOfFrame),
	.can_fall(gold_1_can_fall),
	.collision(collision_gold_1),
	.been_eaten(player_eat_gold_1),
	.pixelX(pxl_x[10:0]),
	.pixelY(pxl_y[10:0]),    
	.gold_dr(gold_1_dr),
	.gold_RGB(gold_1_RGB),
	.goldTLX(gold_1_TLX),
	.goldTLY(gold_1_TLY),
	.gold_state(gold_1_state)

);

score_block
#(
	.board_position_X(board_position_X),
	.board_position_Y(board_position_Y)
)
 score_inst(
	.clk(clk_25),
	.resetN(reset_scoreN),	
	.pixelX(pxl_x[10:0]),
	.pixelY(pxl_y[10:0]),	
	

	.player_eat_gold(player_eat_gold_1),
	.player_eat_dimond(dimond_eaten),

	
	.score_RGB(score_RGB),
	.score_dr(score_dr)

);

player_life_block
#(
	.board_position_X(board_position_X),
	.board_position_Y(board_position_Y)
)
 life_inst(
	.clk(clk_25),
	.resetN(restart_gameN),	
	.pixelX(pxl_x[10:0]),
	.pixelY(pxl_y[10:0]),
	.startOfFrame(startOfFrame),
	.player_died(player_died),  //player was hit
	.player_life_dr(player_life_dr),
	.player_life_RGB(player_life_RGB),
	.no_lives(no_lives)
);


end_screen end_screen_inst (
	.clk(clk_25),
	.resetN(restart_gameN),
	.pixelX(pxl_x[10:0]),
	.pixelY(pxl_y[10:0]),
	.startOfFrame(startOfFrame),
	.game_over_dr(game_over_dr),
	.game_over_RGB(game_over_RGB)
);

start_screen start_screen_inst (
	.clk(clk_25),
	.resetN(restart_gameN),
	.pixelX(pxl_x[10:0]),
	.pixelY(pxl_y[10:0]),
	.startOfFrame(startOfFrame),
	.start_screen_dr(start_screen_dr),
	.start_screen_RGB(start_screen_RGB)
);

win_screen win_screen_inst (
	.clk(clk_25),
	.resetN(restart_gameN),
	.pixelX(pxl_x[10:0]),
	.pixelY(pxl_y[10:0]),
	.startOfFrame(startOfFrame),
	.win_screen_dr(win_screen_dr),
	.win_screen_RGB(win_screen_RGB)
);
endmodule
