module video(
  input clk,
  input rst,

  output            hsync,
  output            vsync, 
  output            hblank,
  output            vblank,
  output 			  display_on,
  // RGB out
  output [1:0]      r,
  output [1:0]      g,
  output [1:0]      b
);

  // HV sync module 
  // Generate vga clock 
  // and all other video clock signal
  wire pxl_cen;
  wire [9:0] hpos;
  wire [9:0] vpos;
  
  hvsync hvsync_u(
    //25 or 50mhz clock  ? 
    .clk(clk),
    .rst(rst),

    .pxl_cen(pxl_cen),
    .hsync(hsync),
    .vsync(vsync),
    .hblank(hblank),
    .vblank(vblank),
    .display_on(display_on),
    .hpos(hpos),
    .vpos(vpos)
  );

  //assets 
  //this is hardcoded rom with all info draw object
  //and our scene per frame 
  wire [2:0] scene_asset_addr;
  wire [2:0] obj_asset_addr;
  wire [4:0] pose_asset_addr;
  wire [5:0] seg_asset_addr;

  wire [26:0] scene_asset_out;
  wire [31:0] obj_asset_out;
  wire [11:0] pose_asset_out;
  wire [24:0] seg_asset_out;

  assets assets_u(
    .scene_asset_addr(scene_asset_addr),
    .obj_asset_addr(obj_asset_addr),
    .pose_asset_addr(pose_asset_addr),
    .seg_asset_addr(seg_asset_addr),

    .scene_asset_out(scene_asset_out),
    .obj_asset_out(obj_asset_out),
    .pose_asset_out(pose_asset_out),
    .seg_asset_out(seg_asset_out)
  );

  // this module output the object that will 
  // be displayed on the current frame
  // and also how the background behave
  // it follow the demo 'scene'
  wire  [5:0] bk_speed;
  wire  [3:0] frame_obj_list_addr;
  wire [31:0] frame_obj_list_out;
  wire  [2:0] frame_obj_list_size;

  frame frame_u(
    .clk(clk),
    .rst(rst),
 
    //update bk_speed, bk_on, obj_list 
    //at each vblank 
    .vblank(vblank), 

    .scene_asset_out(scene_asset_out), 
    .obj_asset_out(obj_asset_out),
    .obj_list_addr(frame_obj_list_addr),

    //OUTPUTS
    .bk_speed(bk_speed),
    //.bk_on(bk_on), 
    //output current frame obj list 
    .scene_asset_addr(scene_asset_addr),
    .obj_asset_addr(obj_asset_addr),
    .obj_list_out(frame_obj_list_out),
    .obj_list_size(frame_obj_list_size)
  );

  // Object drawing 
  // collision of object per line 
  // check collision of object per x 
  // output pixel if collision 
  wire [3:0] obj_color;

  object object_u(
    .clk(clk),
    //.pxl_cen(pxl_cen),
    .rst(rst),

    .hblank(hblank),
    .hpos(hpos),
    .vpos(vpos),

    .pose_asset_out(pose_asset_out),
    .seg_asset_out(seg_asset_out),
    .frame_obj_list_out(frame_obj_list_out),

    //OUTPUTS 
    .pose_asset_addr(pose_asset_addr),
    .seg_asset_addr(seg_asset_addr),
    .frame_obj_list_addr(frame_obj_list_addr),
    .frame_obj_list_size(frame_obj_list_size),
    .color(obj_color)
  );


  // Background of the scene 
  // used a lsfr to show a star field 
  wire [5:0] bk_color;

  background bk_u(
    .clk(clk),
    .rst(rst), 
    //enable / disable star field
    .en(pxl_cen),

    //scroll speed 
    .speed(bk_speed),
    .color(bk_color)
  );

  // Palette color selection
  // 4 palette, containing 4 color each of 6 bits depth
  wire [3:0] palette_addr;
  wire [5:0] palette_out;

  // Static rom palette 
  // May change it to a RAM later so we change the palette content 
  palette palette_u(
    .addr(palette_addr),
    .out(palette_out)
  );

  // COLOR MIXING 

  // if a color is assigned to the obj it's displayed 
  // otherwise we display background
  wire [5:0] mixed_color;
  assign palette_addr[3:0] = obj_color[3:0]; 
  assign mixed_color = obj_color[1:0] != 'd3 ? palette_out : bk_color;
  // color assignement
  assign r = mixed_color[5:4];
  assign g = mixed_color[3:2];
  assign b = mixed_color[1:0];
endmodule
