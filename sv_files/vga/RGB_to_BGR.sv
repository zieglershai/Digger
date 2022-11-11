//////
// invert from lab standart of RRRGGGBB to
// terrasic standart of BBGGGRRR
//////

module RGB_to_BGR(inRGB,
						oBGR
						);
						
input [7:0] inRGB;
output [7:0] oBGR;

assign oBGR [7:6] = inRGB [1:0]; // blue
assign oBGR [5:3] = inRGB [4:2]; //green
assign oBGR [2:0] = inRGB [7:5]; //red


endmodule
