module palette(
    input       [3:0] addr,
    output  reg [5:0] out 
);

//this is not the best format for the palette 
// color is 6 bits : there is 64 possible color 
// is palette really usefull here ?
//
always @* begin
  case (addr)
    4'h0: out = 6'b000011;
    4'h1: out = 6'b001100;
    4'h2: out = 6'b110000;
    4'h3: out = 6'b000001;
    4'h4: out = 6'b000111;
    4'h5: out = 6'b001111;
    4'h6: out = 6'b111111;
    4'h7: out = 6'b010101;
    4'h8: out = 6'b101010;
    4'h9: out = 6'b111111;
    4'hA: out = 6'b111100;
    4'hB: out = 6'b110000;
    4'hC: out = 6'b100000;
    4'hD: out = 6'b110000;
    4'hE: out = 6'b111000;
    default: out = 6'b111100;
  endcase
end

endmodule 
