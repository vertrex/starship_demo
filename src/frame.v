module frame(
  input          clk,
  input          rst,
  input          vblank,
  //
  
  input      [26:0] scene_asset_out, 
  input      [31:0] obj_asset_out, 
  input       [3:0] obj_list_addr,
  
  output      [2:0] scene_asset_addr, 
  output  reg [2:0] obj_asset_addr,
  // output current bk speed acording to current scene 
  output      [5:0] bk_speed,
  // generate obj_list that will be used by hvlist to 
  // determine object to draw on line  
  output     [31:0] obj_list_out,
  output      [2:0] obj_list_size 
);


wire _unused_ok = &{clk, rst, vblank};

//hardcode 1st scene for the moment 
assign scene_asset_addr = 3'd0; 
assign bk_speed = 6'd1; //speed for this scene (not yet in scene data so set it here) 

//is obj_list_out still usefull ??
//we may not need so much indirection
assign obj_list_out[31:0] = obj_asset_out[31:0];//  : 32'd0;
assign obj_list_size[2:0] = scene_asset_out[2:0];

always @* begin 
  case (obj_list_addr)
    4'd0 : obj_asset_addr = scene_asset_out[5:3];
    4'd1 : obj_asset_addr = scene_asset_out[8:6];
    4'd2 : obj_asset_addr = scene_asset_out[11:9];
    4'd3 : obj_asset_addr = scene_asset_out[14:12];
    4'd4 : obj_asset_addr = scene_asset_out[17:15];
    4'd5 : obj_asset_addr = scene_asset_out[20:18];
    4'd6 : obj_asset_addr = scene_asset_out[23:21];
    4'd7 : obj_asset_addr = scene_asset_out[26:24];
    default : obj_asset_addr = 3'd0;
  endcase 
end

endmodule 
