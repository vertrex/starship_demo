module sound(
  input clk,
  input rst,
  output wire speaker
);

  reg [24:0] timebase;
  reg [19:0] phase;
  reg [4:0] base_inc;

  wire [4:0] step;
  wire [1:0] note_sel;
  wire [5:0] inc;
  wire lead;
  wire lead_on;
  wire bass;
  wire bass_on;

  assign step = timebase[24:20];
  assign note_sel = step[3] ? {step[1], step[2]} : step[2:1];

  //always @* begin
    //case (note_sel)
      //2'b00: base_inc = 5'd9;  // A3
      //2'b01: base_inc = 5'd11; // C4
      //2'b10: base_inc = 5'd14; // E4
      //default: base_inc = 5'd16; // G4
    //endcase
  //end

 always @* begin
    case (step)
      5'd0:  base_inc = 5'd9;
      5'd1:  base_inc = 5'd9;
      5'd2:  base_inc = 5'd11;
      5'd3:  base_inc = 5'd14;
      5'd4:  base_inc = 5'd16;
      5'd5:  base_inc = 5'd14;
      5'd6:  base_inc = 5'd11;
      5'd7:  base_inc = 5'd9;
      default: base_inc = 5'd0;
    endcase
  end

  assign inc = step[4] ? {base_inc, 1'b0} : {1'b0, base_inc};
  assign lead = phase[19] ^ phase[17];
  assign lead_on = step[0] | ~step[1];
  assign bass = step[3] ? timebase[17] : timebase[16];
  assign bass_on = ~step[0] & ~step[4];
  assign speaker = (lead_on & lead) ^ (bass_on & bass);

  always @(posedge clk) begin
    if (rst) begin
      timebase <= 25'd0;
      phase <= 20'd0;
    end else begin
      timebase <= timebase + 1'b1;
      phase <= phase + {14'd0, inc};
    end
  end

endmodule
