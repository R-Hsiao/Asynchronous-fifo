module wptr_full
#(
  parameter ADDRSIZE = 4
)
(
  input   winc, wclk, wrst_n,
  input   [ADDRSIZE :0] wq2_rptr,
  output reg  wfull,
  output  [ADDRSIZE - 1:0] waddr,
  output reg [ADDRSIZE :0] wptr
);

   reg [ADDRSIZE:0] wbin;
  wire [ADDRSIZE:0] wgraynext, wbinnext;

  // GRAYSTYLE2 pointer
  always @(posedge wclk or negedge wrst_n)begin
		if (!wrst_n) {wbin, wptr} <= {{(2 * (ADDRSIZE + 1)){1'b0}}};
    else {wbin, wptr} <= {wbinnext, wgraynext};
  end

  // Memory write-address pointer 
  assign waddr = wbin[ADDRSIZE-1:0];
  assign wbinnext = wbin + (winc & ~wfull);
  assign wgraynext = (wbinnext >> 1) ^ wbinnext;
  
  //write full
  assign wfull_val = (wgraynext=={~wq2_rptr[ADDRSIZE:ADDRSIZE - 1], wq2_rptr[ADDRSIZE - 2:0]});

  always @(posedge wclk or negedge wrst_n)begin
		if (!wrst_n) wfull <= 1'b0;
		else wfull <= wfull_val;
  end

endmodule
