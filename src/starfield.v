module starfield #(parameter H=21'd800,
                   V=21'd525,
                   SEED=21'h1FFFFF,
                   MASK=21'hFFF) 
  (
    input  clk,           // clock
    input  rst,           // reset
    input  en,            // enable
    input  [5:0] speed, 
    output reg sf_on,         // star on ??? why output it 
    //XXX why use 8 bits if display is 6bits color only ?
    output reg [7:0] sf_star  // star brightness 
  );

    wire [20:0] rst_cnt;
    
    wire [20:0] sf_reg;
    reg  [20:0] sf_cnt;

    assign rst_cnt =  H * V - {15'b0, speed} - 21'd1; 
    
    always @(posedge clk) begin
      if (rst) begin 
            sf_cnt <= 0;
      end
        else if (en) begin
            sf_cnt <= sf_cnt + 21'd1;
            if (sf_cnt == rst_cnt) 
              sf_cnt <= 0;
        end

    end

    // select some bits to form stars
    always @(posedge clk) begin 
        begin
            sf_on <= &{sf_reg | MASK};
            sf_star <= sf_reg[7:0];
        end
    end

    lfsr #(
        .LEN(21),
        .TAPS(21'b101000000000000000000)
        ) lsfr_u (
        .clk(clk),
        .rst(sf_cnt == 21'b0),
        .en(en),
        .seed(SEED),
        .sreg(sf_reg)
    );

endmodule
