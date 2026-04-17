`default_nettype none

module tt_um_vertrex(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);
  
  wire [1:0] r;
  wire [1:0] g;
  wire [1:0] b;
  wire hsync;
  wire vsync;
  wire hblank;
  wire vblank;
  wire display_on;
  wire sound;

  // TinyVGA PMOD
  assign uo_out = {hsync, b[0], g[0], r[0], vsync, b[1], g[1], r[1]};
  assign uio_out = {sound, 7'b0};
  assign uio_oe = 8'b10000000;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};
  wire _unused_2_ok = &{hblank, vblank, display_on};

  video video_u(
    .clk(clk),
    .rst(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .hblank(hblank),
    .vblank(vblank),
    .display_on(display_on),
    .r(r),
    .g(g),
    .b(b)
  );
 
  sound sound_u(
    .clk(clk),
    .rst(~rst_n),
    .speaker(sound)
  );

endmodule
