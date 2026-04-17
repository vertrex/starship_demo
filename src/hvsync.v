// Video timing module
module hvsync(
  //input 50mhz ? 25mhz ? 
  input clk,
  input rst,
  // generate pxl_cen 
 
  // Video out 
  output reg pxl_cen,
  output reg hsync,
  output reg vsync,
  output reg hblank,
  output reg vblank,
  
  output display_on,
  
  output reg [9:0] hpos,
  output reg [9:0] vpos
);

wire _unused_ok = pxl_cen;

parameter HBLANK_START  = 640-1;
parameter HBLANK_END 	= 800-1;   
parameter HSYNC_START 	= 640 + 16;  
parameter HSYNC_END 		= 640 + 16 + 96;// 752  //+96 
parameter H_TOTAL			= 800;

parameter VBLANK_START  = 480-1;//400-1;//480;
parameter VBLANK_END		= 525-1;//449-1;//524;
parameter VSYNC_START	= 480+12;//412;//480 + 10;
parameter VSYNC_END		= 480+12+2;//414;//480 + 10 + 2; //+2 
parameter V_TOTAL			= 525;//449;//525;

//divid 50mhz clk by 2 (or 48mhz clk?)
always @(posedge clk)
  if (rst) 
    pxl_cen <= 1'b0; 
  else 
    pxl_cen <= ~pxl_cen;


always @(posedge clk) begin
  if (rst) begin
    hpos <= 10'b0;
    vpos <= 10'b0; 
    hblank <= 1'b1;
    vblank <= 1'b0;
    hsync <= 1'b0;
    vsync <= 1'b0;
  end else if (pxl_cen) begin
    if (hpos == H_TOTAL-1) begin
      hpos <= 0;
      vpos <= vpos + 1'd1;
     
      if (vpos == V_TOTAL-1) begin
        vpos <= 0;	
         end
      end 
    else begin
      hpos <= hpos + 1'd1;
    end

    case (hpos)
      HBLANK_START : hblank <= 1;
       HBLANK_END   : hblank <= 0;
      HSYNC_START  : hsync <= 1;
      HSYNC_END    : hsync <= 0;
    endcase 
    
    case (vpos)
       VBLANK_START : if (hpos == HBLANK_START) vblank <= 1;
      VBLANK_END   : if (hpos == HBLANK_END) vblank <= 0;
      VSYNC_START  : if (hpos == HSYNC_START) vsync <= 1;
      VSYNC_END 	: if (hpos == HSYNC_START) vsync <= 0;
    endcase
  end 
end	
		
assign display_on = ~(vblank | hblank);
  

endmodule
