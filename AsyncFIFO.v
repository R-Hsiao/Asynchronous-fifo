module AsyncFIFO
#(
  parameter DSIZE = 8,
  parameter ASIZE = 4
 )
(
  input   winc, wclk, wrst_n,
  input   rinc, rclk, rrst_n,
  input   [DSIZE - 1:0] wdata,

  output  [DSIZE - 1:0] rdata,
  output  wfull,
  output  rempty
);

  wire [ASIZE - 1:0] waddr, raddr;
  wire [ASIZE:0] wptr, rptr, wq2_rptr, rq2_wptr;

  sync_r2w sync_r2w (.wclk(wclk), .wrst_n(wrst_n), .rptr(rptr), .wq2_rptr(wq2_rptr));
  sync_w2r sync_w2r (.rclk(rclk), .rrst_n(rrst_n), .wptr(wptr), .rq2_wptr(rq2_wptr));
  fifomem #(DSIZE, ASIZE) fifomem (.winc(winc), .wfull(wfull), .wclk(wclk), .waddr(waddr), .raddr(raddr), .wdata(wdata), .rdata(rdata));
  rptr_empty #(ASIZE) rptr_empty (.rinc(rinc), .rclk(rclk), .rrst_n(rrst_n), .rq2_wptr(rq2_wptr), .rempty(rempty), .raddr(raddr), .rptr(rptr));
  wptr_full #(ASIZE) wptr_full (.winc(winc), .wclk(wclk), .wrst_n(wrst_n), .wq2_rptr(wq2_rptr), .wfull(wfull), .waddr(waddr), .wptr(wptr));

endmodule
