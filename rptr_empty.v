module rptr_empty
#(
  parameter ADDRSIZE = 4
)
(
  input   rinc, rclk, rrst_n,
  input   [ADDRSIZE :0] rq2_wptr,
  output reg  rempty,
  output  [ADDRSIZE - 1:0] raddr,
  output reg [ADDRSIZE :0] rptr
);

  reg [ADDRSIZE:0] rbin;
  wire [ADDRSIZE:0] rgraynext, rbinnext;

  // GRAYSTYLE2 pointer
  always @(posedge rclk or negedge rrst_n)begin
		if (!rrst_n) {rbin, rptr} <= {{(2 * (ADDRSIZE + 1)){1'b0}}};
		else {rbin, rptr} <= {rbinnext, rgraynext};
  end

  // Memory read-address pointer
  assign raddr = rbin[ADDRSIZE - 1:0];
  assign rbinnext = rbin + (rinc & ~rempty);
  assign rgraynext = (rbinnext >> 1) ^ rbinnext;

  // read empty
  assign rempty_val = (rgraynext == rq2_wptr);

  always @(posedge rclk or negedge rrst_n)begin
		if (!rrst_n) rempty <= 1'b1;
		else rempty <= rempty_val;
  end

endmodule
