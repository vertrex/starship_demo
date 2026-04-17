//object & asset store
module assets(
  input       [2:0] scene_asset_addr,
  input       [2:0] obj_asset_addr,
  input       [4:0] pose_asset_addr,
  input       [5:0] seg_asset_addr,

  output reg [26:0] scene_asset_out,
  output reg [31:0] obj_asset_out,
  output reg [11:0] pose_asset_out,
  output reg [24:0] seg_asset_out
); 

// scene 
// list of object used in current frame 
// (& pos per obj ??)
// scene 0 : welcome text 
// scene 1 : ship arrives 
// scene 2 : enemy fight 
// scene 3 : tunnel 
// scene 4 : final explosion 
// there is 16 object max visible per screen so scene max id obj is 16 
//
// obj id : 3 bits -> ????? this is clearly not enough we need a list of obj per scene 
// etc... 
// XXX ADD NUMBER OOF OBJ PER SCENE SO WE CAN STOP COPYING THEM TO THE CURRENT
// LIST 
// add direction of object so we can make them move ? 
// add number of frame that a scene is displayed  
// add initial position of each obj ? 
always @* begin
  case (scene_asset_addr)
    // scene 0: V E R T R E X
    3'd0: scene_asset_out = {3'd0, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0, 3'd7};
    default: scene_asset_out = 27'd0;
  endcase
end

// obj_asset_out:
//   [0]     enable
//   [1]     mirror_x
//   [2]     mirror_y
//   [4:3]   palette_bank
//   [9:5]   pose_id
//   [19:10] obj_x
//   [29:20] obj_y
//   [30]    sim_x
//   [31]    sim_y 
//
//   ???? we have 32 pose for 8 object, when do we
//   change pose_id ? in frame ? or scene ? there is something strange here as 
//   we select only one pose per object 
// 8 objects can exist with 31 bits of metadata 
//
always @* begin
  case (obj_asset_addr)
    // V
    3'd0: obj_asset_out = {2'b00, 10'd208, 10'd70,  5'd0, 2'b01, 1'b0, 1'b0, 1'b1};
    // E
    3'd1: obj_asset_out = {2'b00, 10'd184, 10'd132, 5'd1, 2'b01, 1'b0, 1'b0, 1'b1};
    // R
    3'd2: obj_asset_out = {2'b00, 10'd164, 10'd188, 5'd2, 2'b01, 1'b0, 1'b0, 1'b1};
    // T
    3'd3: obj_asset_out = {2'b00, 10'd148, 10'd248, 5'd3, 2'b01, 1'b0, 1'b0, 1'b1};
    // R
    3'd4: obj_asset_out = {2'b00, 10'd164, 10'd308, 5'd2, 2'b01, 1'b0, 1'b0, 1'b1};
    // E
    3'd5: obj_asset_out = {2'b00, 10'd184, 10'd364, 5'd1, 2'b01, 1'b0, 1'b0, 1'b1};
    // X
    3'd6: obj_asset_out = {2'b00, 10'd208, 10'd426, 5'd4, 2'b01, 1'b0, 1'b0, 1'b1};

    default: obj_asset_out = 32'd0;
  endcase
end

// 32 pose
// pose point to the list of segment used by this object version  
// eg we can create a rotated pose or zoomed pose 

// pose_asset_out :
//   [6:0] first_seg  //this define 128 seg in total XXX not 64 !  
//   [11:7] seg_count  //this define 16 seg per obj max
always @* begin
  case (pose_asset_addr)
    //                       count,first seg
    5'd0: pose_asset_out = {5'd6,  7'd0};   // V
    5'd1: pose_asset_out = {5'd11, 7'd6};   // E
    5'd2: pose_asset_out = {5'd13, 7'd17};  // R
    5'd3: pose_asset_out = {5'd7,  7'd30};  // T
    5'd4: pose_asset_out = {5'd8,  7'd37};  // X
    default: pose_asset_out = 12'd0;
  endcase
end

// list of segment that compose each object pose (x/y line that draw a line 
// of an object pose) 

localparam SEG_HORIZONTAL = 3'd0; 
localparam SEG_VERTICAL   = 3'd1;
localparam SEG_SLASH      = 3'd2; 
localparam SEG_BACKSLASH  = 3'd3; 

//64 segments for our 8 obj (they can be reused between obj) 
//seg_asset_out:
//  [2:0] seg type,h|,v_,diag/,diag XXX we can usue only 4 seg type |_/\ no
//  need for point so we can shorten that to [1:0] XXX do it later
//  [9:3]   x offset (7 bits + signed)
//  [16:10] y offset (7 bits + signed)
//  [22:17] len
//  [24:23] color
always @* begin
  case (seg_asset_addr)
    // V front + back extrusion
    6'd0:  seg_asset_out = {2'd2, 6'd28, 7'd0,  7'd0,  SEG_BACKSLASH};
    6'd1:  seg_asset_out = {2'd2, 6'd28, 7'd0,  7'd28, SEG_SLASH};
    6'd2:  seg_asset_out = {2'd0, 6'd28, 7'd4,  7'd4,  SEG_BACKSLASH};
    6'd3:  seg_asset_out = {2'd0, 6'd28, 7'd4,  7'd32, SEG_SLASH};
    6'd4:  seg_asset_out = {2'd1, 6'd4,  7'd0,  7'd0,  SEG_BACKSLASH};
    6'd5:  seg_asset_out = {2'd1, 6'd4,  7'd0,  7'd56, SEG_BACKSLASH};

    // E front + back extrusion
    6'd6:  seg_asset_out = {2'd2, 6'd28, 7'd0,  7'd0,  SEG_VERTICAL};
    6'd7:  seg_asset_out = {2'd2, 6'd22, 7'd0,  7'd0,  SEG_HORIZONTAL};
    6'd8:  seg_asset_out = {2'd2, 6'd18, 7'd14, 7'd0,  SEG_HORIZONTAL};
    6'd9:  seg_asset_out = {2'd2, 6'd22, 7'd28, 7'd0,  SEG_HORIZONTAL};
    6'd10: seg_asset_out = {2'd0, 6'd28, 7'd4,  7'd4,  SEG_VERTICAL};
    6'd11: seg_asset_out = {2'd0, 6'd22, 7'd4,  7'd4,  SEG_HORIZONTAL};
    6'd12: seg_asset_out = {2'd0, 6'd18, 7'd18, 7'd4,  SEG_HORIZONTAL};
    6'd13: seg_asset_out = {2'd0, 6'd22, 7'd32, 7'd4,  SEG_HORIZONTAL};
    6'd14: seg_asset_out = {2'd1, 6'd4,  7'd0,  7'd22, SEG_BACKSLASH};
    6'd15: seg_asset_out = {2'd1, 6'd4,  7'd14, 7'd18, SEG_BACKSLASH};
    6'd16: seg_asset_out = {2'd1, 6'd4,  7'd28, 7'd22, SEG_BACKSLASH};

    // R front + back extrusion
    6'd17: seg_asset_out = {2'd2, 6'd28, 7'd0,  7'd0,  SEG_VERTICAL};
    6'd18: seg_asset_out = {2'd2, 6'd20, 7'd0,  7'd0,  SEG_HORIZONTAL};
    6'd19: seg_asset_out = {2'd2, 6'd20, 7'd14, 7'd0,  SEG_HORIZONTAL};
    6'd20: seg_asset_out = {2'd2, 6'd14, 7'd0,  7'd20, SEG_VERTICAL};
    6'd21: seg_asset_out = {2'd2, 6'd14, 7'd14, 7'd0,  SEG_BACKSLASH};
    6'd22: seg_asset_out = {2'd0, 6'd28, 7'd4,  7'd4,  SEG_VERTICAL};
    6'd23: seg_asset_out = {2'd0, 6'd20, 7'd4,  7'd4,  SEG_HORIZONTAL};
    6'd24: seg_asset_out = {2'd0, 6'd20, 7'd18, 7'd4,  SEG_HORIZONTAL};
    6'd25: seg_asset_out = {2'd0, 6'd14, 7'd4,  7'd24, SEG_VERTICAL};
    6'd26: seg_asset_out = {2'd0, 6'd14, 7'd18, 7'd4,  SEG_BACKSLASH};
    6'd27: seg_asset_out = {2'd1, 6'd4,  7'd0,  7'd20, SEG_BACKSLASH};
    6'd28: seg_asset_out = {2'd1, 6'd4,  7'd14, 7'd20, SEG_BACKSLASH};
    6'd29: seg_asset_out = {2'd1, 6'd4,  7'd28, 7'd14, SEG_BACKSLASH};

    // T front + back extrusion
    6'd30: seg_asset_out = {2'd2, 6'd24, 7'd0,  7'd0,  SEG_HORIZONTAL};
    6'd31: seg_asset_out = {2'd2, 6'd28, 7'd0,  7'd12, SEG_VERTICAL};
    6'd32: seg_asset_out = {2'd0, 6'd24, 7'd4,  7'd4,  SEG_HORIZONTAL};
    6'd33: seg_asset_out = {2'd0, 6'd28, 7'd4,  7'd16, SEG_VERTICAL};
    6'd34: seg_asset_out = {2'd1, 6'd4,  7'd0,  7'd0,  SEG_BACKSLASH};
    6'd35: seg_asset_out = {2'd1, 6'd4,  7'd0,  7'd24, SEG_BACKSLASH};
    6'd36: seg_asset_out = {2'd1, 6'd4,  7'd28, 7'd12, SEG_BACKSLASH};

    // X front + back extrusion
    6'd37: seg_asset_out = {2'd2, 6'd28, 7'd0,  7'd0,  SEG_BACKSLASH};
    6'd38: seg_asset_out = {2'd2, 6'd28, 7'd0,  7'd0,  SEG_SLASH};
    6'd39: seg_asset_out = {2'd0, 6'd28, 7'd4,  7'd4,  SEG_BACKSLASH};
    6'd40: seg_asset_out = {2'd0, 6'd28, 7'd4,  7'd4,  SEG_SLASH};
    6'd41: seg_asset_out = {2'd1, 6'd4,  7'd0,  7'd0,  SEG_BACKSLASH};
    6'd42: seg_asset_out = {2'd1, 6'd4,  7'd0,  7'd28, SEG_BACKSLASH};
    6'd43: seg_asset_out = {2'd1, 6'd4,  7'd28, 7'd0,  SEG_BACKSLASH};
    6'd44: seg_asset_out = {2'd1, 6'd4,  7'd28, 7'd28, SEG_BACKSLASH};

    default: seg_asset_out = 25'd0;
  endcase
end


/* 
* TEST SEGMENT 

   // top horizontal
    //obj 0, 1st segment, top square horizontal line _
      // seg type 0 : horizontal line, (x,y) (0,0), len 15 (max enough?), color  2'b10 
    6'd0: seg_asset_out = {2'b10, 6'd63, 7'd0, 7'd0, SEG_HORIZONTAL};
    // left vertical
    //obj 0, 1st segment, left square vertiacal line |
    //seg type 1 : vert line, (x,y) (0,0), len 15 (max enough?), color  2'b10 
    6'd1: seg_asset_out = { 2'b10, 6'd63, 7'd0, 7'd0, SEG_VERTICAL};
    // right vertical
    //obj 0, 3rd segment, right square vertical line | (XXX use mirroring later
    //for that a square is 2 vertical and horizontal mirrored segments only) 
    //seg type 1 : vert line, (x,y) (15,0), len 15 (max enough?), color  2'b10 
    6'd2: seg_asset_out = {2'b10, 6'd63, 7'd0, 7'd63, SEG_VERTICAL};
    // bottom horizontal
    //obj 0, 4rd segment, bottom square horizontal line _ (XXX use Y mirror
    //seg type 0 : vert line, (x,y) (15,15), len 15 (max enough?), color  2'b10 
    6'd3: seg_asset_out = {2'b10, 6'd63, 7'd63, 7'd0, SEG_HORIZONTAL};

    //SECOND OBJ TEST SECOND SQUARE 
    //let's put a second square elsewhere to see if a second object work
    6'd4: seg_asset_out = {2'b01, 6'd63, 7'd0, 7'd0, SEG_HORIZONTAL};
    // left vertical
    //obj 0, 1st segment, left square vertiacal line |
    //seg type 1 : vert line, (x,y) (0,0), len 15 (max enough?), color  2'b10 
    6'd5: seg_asset_out = {2'b01, 6'd63, 7'd0, 7'd0, SEG_VERTICAL};
    // right verticalj
    //obj 0, 3rd segment, right square vertical line | (XXX use mirroring later
    //for that a square is 2 vertical and horizontal mirrored segments only) 
    //seg type 1 : vert line, (x,y) (15,0), len 15 (max enough?), color  2'b10 
    6'd6: seg_asset_out = {2'b01, 6'd63, 7'd0, 7'd63, SEG_VERTICAL};
    // bottom horizontal
    //obj 0, 4rd segment, bottom square horizontal line _ (XXX use Y mirror
    //seg type 0 : vert line, (x,y) (15,15), len 15 (max enough?), color  2'b10 
    6'd7: seg_asset_out = {2'b01, 6'd63, 7'd63, 7'd0, SEG_HORIZONTAL};

    //DIAMOND TEST
    //                     flags, color, len, y off, x off, type
    6'd8: seg_asset_out = { 2'b01, 6'd63, 7'd0, 7'd0, SEG_SLASH};
    6'd9: seg_asset_out = { 2'b01, 6'd63, 7'd0, 7'd63, SEG_BACKSLASH};
    6'ha: seg_asset_out = { 2'b01, 6'd63, 7'd63, 7'd0, SEG_BACKSLASH};
    6'hb: seg_asset_out = { 2'b01, 6'd63, 7'd63, 7'd63, SEG_SLASH};
    //only one diamond double symetryc test
    //6'hc: seg_asset_out = {1'b0, 2'b01, 4'd15, 6'd0, 6'd0, SEG_SLASH};
*/


endmodule 
