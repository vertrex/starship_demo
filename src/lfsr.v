module lfsr #(parameter TAPS = 8'b10111000,
                        LEN=8)
  (
    input  clk,             // clock
    input  rst,             // reset
    input  en,              // enable
    input  [LEN-1:0] seed,  // seed (uses default seed if zero)
    output reg [LEN-1:0] sreg// lfsr output
  );

  always @(posedge clk) begin
    if (rst) 
      sreg <= seed;
    else if (en)  
      sreg <= {1'b0, sreg[LEN-1:1]} ^ (sreg[0] ? TAPS : {LEN{1'b0}});
  end

endmodule
