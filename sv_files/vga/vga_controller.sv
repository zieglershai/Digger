module vga_controller(iRST_n,
                      iVGA_CLK,
							 bgr_data_8,
                      oBLANK_n,
                      oHS,
                      oVS,
                      oVGA_B,
                      oVGA_G,
                      oVGA_R,
							 pixelX,
							 pixelY,
							 startOfFrame);
input iRST_n;
input iVGA_CLK;
input [7:0] bgr_data_8;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [3:0] oVGA_B;
output [3:0] oVGA_G;  
output [3:0] oVGA_R; 
output [10:0] pixelX;
output [10:0] pixelY;
output startOfFrame;                    
///////// ////                     
///////// ////                     
reg [18:0] ADDR ;
wire VGA_CLK_n;
wire [7:0] index;
wire [23:0] bgr_data_raw;
wire cBLANK_n,cHS,cVS,rst;
wire [10:0] pixelX;
wire [9:0] pixelY;
////
assign rst = ~iRST_n;

video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS),
										.pixelX(pixelX),
										.pixelY(pixelY)
										);

////Addresss generator
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
     ADDR<=19'd0;
  else if (cBLANK_n==1'b1)
     ADDR<=ADDR+1;
	  else
	    ADDR<=19'd0;
end
										
reg [23:0] bgr_data;
//reg [7:0] bgr_data_8;


parameter VIDEO_W	= 640;
parameter VIDEO_H	= 480;

always@(posedge iVGA_CLK)
begin
  if (~iRST_n)
  begin
     bgr_data<=24'h000000;
	  //bgr_data_8<=8'h00;
  end
    else
    begin
	       // four strips 
			 /*if (0<ADDR && ADDR <= VIDEO_W/9)
			 		bgr_data <= {8'h00, 8'he0, 8'he0}; // yellow
				else if (VIDEO_W/9 < ADDR && ADDR <= VIDEO_W/3)
					bgr_data <= {8'he0, 8'h00, 8'h00}; // blue
				else if (ADDR > VIDEO_W/3 && ADDR <= VIDEO_W*2/3)
					bgr_data <= {8'h00,8'he0, 8'h00};  // green
				else if(ADDR > VIDEO_W*2/3 && ADDR <=VIDEO_W)
					bgr_data <= {8'h00, 8'h00, 8'he0}; // red
				else bgr_data <= 24'h0000;*/
			
			//squre at (0,0)
			/*if (pixelX <= 100 && pixelY <= 200)
				bgr_data <= {8'hff, 8'hff, 8'h00}; // yellow
			else
				bgr_data <= 24'h0000;  */
				
	       // four strips - 8 bits
			// asssumption 3-blue, 3-green, 2-red 
			 /*if (0<ADDR && ADDR <= VIDEO_W/9)
			 		bgr_data_8 <= {3'b000, 3'b111, 2'b11}; // yellow
				else if (VIDEO_W/9 < ADDR && ADDR <= VIDEO_W/3)
					bgr_data_8 <= {3'b111, 3'b000, 2'b00}; // blue
				else if (ADDR > VIDEO_W/3 && ADDR <= VIDEO_W*2/3)
					bgr_data_8 <= {3'b000,3'b111, 2'b00};  // green
				else if(ADDR > VIDEO_W*2/3 && ADDR <=VIDEO_W)
					bgr_data_8 <= {3'b000, 3'b000, 2'b11}; // red
				else bgr_data_8 <= 8'h00;*/
		
			// asssumption 3-blue, 3-green, 2-red 
			if (0<ADDR && ADDR <= VIDEO_W)
					bgr_data = {bgr_data_8[7:6],{6{bgr_data_8[6]}},bgr_data_8[5:3],{5{bgr_data_8[3]}},bgr_data_8[2:0],{5{bgr_data_8[0]}}};
			else bgr_data <= 8'h00;

				
				


 
    end
end

//assign bgr_data = {bgr_data_8[7:6],{6{bgr_data_8[6]}},bgr_data_8[5:3],{5{bgr_data_8[3]}},bgr_data_8[2:0],{5{bgr_data_8[0]}}};
//assign bgr_data = {bgr_data_8[7:6],{6{bgr_data_8[6]}},16'h0000};

assign oVGA_B=bgr_data[23:20];
assign oVGA_G=bgr_data[15:12]; 
assign oVGA_R=bgr_data[7:4];
///////////////////
//////Delay the iHD, iVD,iDEN for one clock cycle;
reg mHS, mVS, mBLANK_n;
always@(posedge iVGA_CLK)
begin
  mHS<=cHS;
  mVS<=cVS;
  mBLANK_n<=cBLANK_n;
  oHS<=mHS;
  oVS<=mVS;
  oBLANK_n<=mBLANK_n;
end


////for signaltap ii/////////////
reg [18:0] H_Cont/*synthesis noprune*/;
always@(posedge iVGA_CLK,negedge iRST_n)
begin
  if (!iRST_n)
     H_Cont<=19'd0;
  else if (mHS==1'b1)
     H_Cont<=H_Cont+1;
	  else
	    H_Cont<=19'd0;
end

assign startOfFrame = pixelX == 640 && pixelY == 480; 
endmodule
