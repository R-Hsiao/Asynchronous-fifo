module fifomem
#(
  parameter DATASIZE = 8, // Memory data word width
  parameter ADDRSIZE = 4  // Number of mem address bits
)
(
  input   winc, wfull, wclk,
  input   [ADDRSIZE - 1:0] waddr, raddr,
  input   [DATASIZE - 1:0] wdata,
  output  [DATASIZE - 1:0] rdata
);

  localparam DEPTH = 1 << ADDRSIZE;

  reg [DATASIZE - 1:0] mem [0:DEPTH - 1];

  assign rdata = mem[raddr];

  always @(posedge wclk)begin
		if (winc && !wfull) mem[waddr] <= wdata;
  end

endmodule

