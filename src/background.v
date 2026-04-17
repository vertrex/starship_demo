module background(
  input        clk,
  //input        pxl_cen,
  input        rst,
  input        en, 
  input  [5:0] speed, //5:0 is a lot here just for speed !

  output [5:0] color
); 

// XXX 
// why 7:0 ? we can reduce lot of bit are unused 
wire [7:0] sf_star;
wire sf_on;

//display a white star or a blue background 
                                                                                        //2'b00 for black bk
assign color[5:0] = sf_on ? {sf_star[1:0], sf_star[1:0], sf_star[1:0]} : {2'b00, 2'b00, 2'b01};

//STARFIELD DRAWER 
//starfield #(.INC(-4), .MASK(21'h7FF)) starfield_u (
//starfield #(.INC(-2), .SEED(21'hA9A9A)) sartfield_u (
starfield starfield_u(
  .clk(clk),
  //.clk(pxl_cen),
  .rst(rst),
  .en(en),
  .speed(speed),
  // ????
  .sf_on(sf_on),
  .sf_star(sf_star)
);

endmodule 
