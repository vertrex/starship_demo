module object(
  input         clk,
  //input         pxl_cen,
  input         rst,

  input         hblank,
  input   [9:0] hpos,
  input   [9:0] vpos, 
  // 
  input  [31:0] frame_obj_list_out,
  input   [2:0] frame_obj_list_size,
  input  [11:0] pose_asset_out,
  input  [24:0] seg_asset_out,
  // OUTPUTS 
  output  [3:0] frame_obj_list_addr,
  output  [4:0] pose_asset_addr,
  output  [5:0] seg_asset_addr,
  // color
  // [3:2] palette_bank
  // [1:0] local_color
  // local_color == 2'b11 means transparent
  output  [3:0] color
);

wire [8*24-1:0] active_list; 
//horizontal list filtering 
//at each hblank 
//filter frame-obj_list and select only those that line 
//return a list of pointer to current frame_obj_list (to avoid a copy) 
hlist hlist_u(
 .clk(clk),
 .rst(rst),
 .hblank(hblank), 
 .vpos(vpos),
 .frame_obj_list_out(frame_obj_list_out),
 .frame_obj_list_size(frame_obj_list_size),
 .pose_asset_out(pose_asset_out),
 .seg_asset_out(seg_asset_out),
  //OUTPUT
 .frame_obj_list_addr(frame_obj_list_addr),
 .pose_asset_addr(pose_asset_addr),
 .seg_asset_addr(seg_asset_addr),
 .active_list(active_list)
); 

// visibility checker 
// check for each pixel  (@~hblank)
// if @hpos collide with a pixel in the active list 
// if yes output object color
// stop parsing list at first collision so if 
// two object is on top of each other the 1st in the list 
// is over the other one (XXX or have a prio bit per object ?)
vcheck vcheck_u(
  .hpos(hpos),
  .active_list(active_list),
  //OUTPUT 
  .color(color)
); 

endmodule
