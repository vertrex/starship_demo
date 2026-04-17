module vcheck(
  input   [9:0] hpos,
  input   [8*24-1:0] active_list,
  // {2 bit palette, 2bit color}
  output  [3:0] color
);

wire [23:0] active_0 = active_list[23:0];
wire [23:0] active_1 = active_list[47:24];
wire [23:0] active_2 = active_list[71:48];
wire [23:0] active_3 = active_list[95:72];
wire [23:0] active_4 = active_list[119:96];
wire [23:0] active_5 = active_list[143:120];
wire [23:0] active_6 = active_list[167:144];
wire [23:0] active_7 = active_list[191:168];

wire hit_0 = (active_0[9:0] <= active_0[19:10]) && (hpos >= active_0[9:0]) && (hpos <= active_0[19:10]);
wire hit_1 = (active_1[9:0] <= active_1[19:10]) && (hpos >= active_1[9:0]) && (hpos <= active_1[19:10]);
wire hit_2 = (active_2[9:0] <= active_2[19:10]) && (hpos >= active_2[9:0]) && (hpos <= active_2[19:10]);
wire hit_3 = (active_3[9:0] <= active_3[19:10]) && (hpos >= active_3[9:0]) && (hpos <= active_3[19:10]);
wire hit_4 = (active_4[9:0] <= active_4[19:10]) && (hpos >= active_4[9:0]) && (hpos <= active_4[19:10]);
wire hit_5 = (active_5[9:0] <= active_5[19:10]) && (hpos >= active_5[9:0]) && (hpos <= active_5[19:10]);
wire hit_6 = (active_6[9:0] <= active_6[19:10]) && (hpos >= active_6[9:0]) && (hpos <= active_6[19:10]);
wire hit_7 = (active_7[9:0] <= active_7[19:10]) && (hpos >= active_7[9:0]) && (hpos <= active_7[19:10]);

assign color = hit_0 ? active_0[23:20] :
               hit_1 ? active_1[23:20] :
               hit_2 ? active_2[23:20] :
               hit_3 ? active_3[23:20] :
               hit_4 ? active_4[23:20] :
               hit_5 ? active_5[23:20] :
               hit_6 ? active_6[23:20] :
               hit_7 ? active_7[23:20] :
               4'hf;

endmodule
