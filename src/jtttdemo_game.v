`default_nettype none

module jtttdemo_game(
    `include "jtframe_game_ports.inc"
    input test
);

wire hblank;
wire vblank;
wire hsync;
wire vsync;
wire display_on;

wire [1:0] r,g,b;



video video_u(
    .clk(pix_cen), //pix2_cen is 50mhz 
    .clk_cen(pix_cen), //pix_cen is 25mhz
    .rst(rst),

    .hsync(hsync),
    .vsync(vsync),
    .hblank(hblank),
    .vblank(vblank),
    .display_on(display_on),

    .r(r),
    .g(g),
    .b(b)
 );


assign snd = {14'b0 , pwm};

wire pwm;

 sound sound_u(
    .clk(pix_cen),
    .rst(rst),
    .speaker(pwm)
  );

assign red[3:0] = {r[1:0], 2'b0};
assign blue[3:0] = {b[1:0], 2'b0};
assign green[3:0] = {g[1:0], 2'b0};
assign HS = hsync;
assign VS = vsync;
assign LHBL = ~hblank;
assign LVBL = ~vblank;
assign pxl_cen = pix_cen;
assign pxl2_cen = pix2_cen;

endmodule
