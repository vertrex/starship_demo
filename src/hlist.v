module hlist(
  input             clk,
  input             rst,
  input             hblank,
  input      [9:0]  vpos,

  // each frame can have 16 object 
  // which have 32 bits metadata
  // to describe them
  input      [31:0] frame_obj_list_out,
  input       [2:0] frame_obj_list_size,
  input      [11:0] pose_asset_out,
  input      [24:0] seg_asset_out,

  output reg  [3:0] frame_obj_list_addr,
  output      [4:0] pose_asset_addr,
  output reg  [5:0] seg_asset_addr,
  //
  // active_list format :
  //   [9:0] x_start 
  // [19:10] x_end
  // [23:20] color
  //
  // valid span if x_start <= x_end
  // invalid/unused entry if x_start > x_end
// one-pixel hit is just x_start == x_end
  output    [191:0] active_list
);

// active_list format :
//   [9:0] x_start 
// [19:10] x_end
// [23:20] color
reg [23:0] active_entry[0:7];

assign active_list[23:0]    = active_entry[0];
assign active_list[47:24]   = active_entry[1];
assign active_list[71:48]   = active_entry[2];
assign active_list[95:72]   = active_entry[3];
assign active_list[119:96]  = active_entry[4];
assign active_list[143:120] = active_entry[5];
assign active_list[167:144] = active_entry[6];
assign active_list[191:168] = active_entry[7];

//CURRENT OBJ INFO
wire               obj_enabled = frame_obj_list_out[0];
wire        [1:0]  obj_palette_bank = frame_obj_list_out[4:3];
wire        [9:0]  obj_x = frame_obj_list_out[19:10]; 
wire        [9:0]  obj_y = frame_obj_list_out[29:20]; 
assign pose_asset_addr = frame_obj_list_out[9:5];

//CURRENT POSE INFO (SEG LIST) 
wire        [6:0] pose_first_seg = pose_asset_out[6:0];
wire        [4:0] pose_seg_count = pose_asset_out[11:7];

//CURRENT SEG INFO 
wire        [2:0]  seg_type = seg_asset_out[2:0];
wire signed [10:0] seg_x_offset = {{4{seg_asset_out[9]}},  seg_asset_out[9:3]};
wire signed [10:0] seg_y_offset = {{4{seg_asset_out[16]}}, seg_asset_out[16:10]};
wire        [5:0]  seg_len = seg_asset_out[22:17];
wire        [1:0]  seg_color = seg_asset_out[24:23];
//wire     seg_flag = seg_asset_out[21];

wire signed [10:0] vpos_s = {1'b0, vpos};

wire signed [10:0] seg_x_abs    = {1'b0, obj_x} + seg_x_offset;
wire signed [10:0] seg_y_abs    = {1'b0, obj_y} + seg_y_offset;
wire signed [10:0] seg_x_end    = seg_x_abs + {5'b0, seg_len};
wire signed [10:0] seg_y_end    = seg_y_abs + {5'b0, seg_len};
wire signed [10:0] seg_x_slash  = seg_y_end - vpos_s +seg_x_abs;
wire signed [10:0] seg_x_bslash = vpos_s - seg_y_abs + seg_x_abs;

reg         [2:0] state; 
reg         [2:0] active_list_index; //current active segment

localparam STATE_START = 3'd0; 
localparam STATE_DECODE_OBJ = 3'd1; 
localparam STATE_DECODE_SEG = 3'd2;
localparam STATE_END = 3'd7; 

localparam SEG_HORIZONTAL = 3'd0;
localparam SEG_VERTICAL   = 3'd1;
localparam SEG_SLASH      = 3'd2;
localparam SEG_BACKSLASH  = 3'd3;
localparam INVALID_SPAN   = {4'hf, 10'd0, 10'h3ff};

integer i;

always @(posedge clk) begin 
    if (rst) begin 
      frame_obj_list_addr <= 4'd0;
      seg_asset_addr <= 6'd0;
      active_list_index <= 3'd0; 
      for (i = 0; i < 8; i = i + 1)
        active_entry[i] <= INVALID_SPAN;
      state <= STATE_START;
      end 
    else if (hblank) begin 
        case (state) 
          STATE_START: begin 
            frame_obj_list_addr <= 4'd0; //curent index in obj_list 
            seg_asset_addr <= 6'd0;
            active_list_index <= 3'd0;
            for (i = 0; i < 8; i = i + 1)
              active_entry[i] <= INVALID_SPAN;
            state <= STATE_DECODE_OBJ;   
          end 

          STATE_DECODE_OBJ: begin 
            if (frame_obj_list_addr[2:0] == frame_obj_list_size) //XXX obj_list_size < obj_list_add ?
              state <= STATE_END;
            else begin 
              if (~obj_enabled) begin 
                //if obj is disabled we go to the next one 
                frame_obj_list_addr <= frame_obj_list_addr + 4'd1; 
                state <= STATE_DECODE_OBJ;
                end 
              else  begin 
                //OBJ IS OK ENABLED NEED TO LOOP SEG NOW
                seg_asset_addr <= pose_first_seg[5:0];
                state <= STATE_DECODE_SEG;
                end
               // 
             end 
          end 

          STATE_DECODE_SEG:  begin 
            //get seg_asset_out and decode it; 
            //use seg type & seg 
            //add data to our lsit if list is not full
            //check if list is full or skip (if active-list _index == 15t) 
            //use case (seg_type) ?
            // later we need to check  if coordinate < 0,
            //   if coordinate > max, before resizing to 9:0 to avoid wrapping
            //   around the screen
            if ((seg_type == SEG_HORIZONTAL) && (seg_y_abs == vpos_s)) begin 
                                                    // color palette,     color,    x  end, x start
               active_entry[active_list_index] <= { obj_palette_bank, seg_color, seg_x_end[9:0], seg_x_abs[9:0] };
               active_list_index <= active_list_index + 3'd1;
               end 
            else if ((seg_type == SEG_VERTICAL) && (vpos_s >= seg_y_abs) && (vpos_s <= seg_y_end)) begin
               active_entry[active_list_index] <= { obj_palette_bank, seg_color, seg_x_abs[9:0], seg_x_abs[9:0] };
               active_list_index <= active_list_index + 3'd1; 
               end
            else if ((seg_type == SEG_SLASH) && (vpos_s >= seg_y_abs) && (vpos_s <= seg_y_end)) begin
               active_entry[active_list_index] <= { obj_palette_bank, seg_color, seg_x_slash[9:0], seg_x_slash[9:0] };
               active_list_index <= active_list_index + 3'd1; 
               end 
            else if ((seg_type == SEG_BACKSLASH) && (vpos_s >= seg_y_abs) && (vpos_s <= seg_y_end)) begin
               active_entry[active_list_index] <= { obj_palette_bank, seg_color, seg_x_bslash[9:0], seg_x_bslash[9:0] };
               active_list_index <= active_list_index + 3'd1; 
               end 

            if (active_list_index == 3'd7)
              state <= STATE_END;
            else if (seg_asset_addr + 6'd1 < pose_first_seg[5:0] + {1'b0, pose_seg_count}) begin 
               seg_asset_addr <= seg_asset_addr + 6'd1;
               state <= STATE_DECODE_SEG; //we're already at this state no need
               end 
            else begin
               frame_obj_list_addr <= frame_obj_list_addr + 1;
               state <= STATE_DECODE_OBJ; 
               end
            end

          STATE_END: begin 
            //we have finish wait until next state machine start 
            //@next hblank
          end 

          default : begin 
          end 

        endcase 
    end else 
      state <= STATE_START;
end 

endmodule
