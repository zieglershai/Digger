module digger_top(
	input					MAX10_CLK1_50,
	input		[1:0]		KEY,

	inout    [35:0]   GPIO,

	output   [3:0]		VGA_B,
	output   [3:0]    VGA_R,
	output   [3:0]    VGA_G,
	output            VGA_HS,
	output            VGA_VS
);



//=======================================================
//  REG/WIRE declarations
//=======================================================


wire clk;


wire [7:0] RGB; // from mux to convertor
wire [7:0] BGR; // from convertor to vga


wire [10:0] pixelX;
wire [10:0] pixelY;
wire startOfFrame;

wire playerDR;
wire [7:0] playerRGB;

wire terrain_dr;
wire [7:0] terrain_RGB;


//=======================================================
//  Structural coding
//=======================================================

// clock 
vga_pll u1(
    .areset(),
    .inclk0(MAX10_CLK1_50),
    .c0(clk),
    .locked());



	 
// vga controller   
vga_controller vga_ins(
                            .iRST_n(KEY[0]),
                            .iVGA_CLK(clk),
                            .bgr_data_8(BGR),
                            .oHS(VGA_HS),
                            .oVS(VGA_VS),
                            .oVGA_B(VGA_B),
                            .oVGA_G(VGA_G),
                            .oVGA_R(VGA_R),
                            .pixelX(pixelX),
                            .pixelY(pixelY),
                            .startOfFrame(startOfFrame));
									 
RGB_to_BGR cnvt_rgb (
                            .inRGB(RGB),
                            .oBGR(BGR));
 
 
 
 
objects_mux mux_inst(                               
                            .clk(clk),
                            .resetN(KEY[0]),
                            .playerDR(playerDR), 
                            .playerRGB(playerRGB),
									 .terrain_dr(terrain_dr),
									 .terrain_RGB(terrain_RGB),  
                            .backGroundRGB(BG_RGB), 
                            .RGBOut(RGB)
);





player player_inst(
                            .clk(clk),
                            .resetN(KEY[0]),
                            .startOfFrame(startOfFrame),
									 .leftArrowPressed(~GPIO[33]/*leftArrowPressed*/),
                            .rightArrowPressed(~GPIO[29]/*rightArrowPressed*/),
                            .collisionPlayerBoarder(collisionPlayerBoarder),
                            .pixelX(pixelX),
                            .pixelY(pixelY),
                            .playerDR(playerDR),
                            .playerRGB(playerRGB)
);


terrain	terrain_inst(
									 .clk(clk),
                            .resetN(KEY[0]),
									 .pixelX(pixelX),
									 .pixelY(pixelY),
				 					 .player_inside(playerDR),
									 .terrainDR(terrain_dr),
									 .terrainRGB(terrain_RGB)
);

endmodule






