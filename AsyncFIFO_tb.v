// =========================================================
// Verilog Testbench for AsyncFIFO
// =========================================================

`timescale 1ns/1ps

module AsyncFIFO_tb;

  parameter DSIZE = 8;
  parameter ASIZE = 4;

  wire [DSIZE-1:0] rdata;
  wire wfull;
  wire rempty;
  reg [DSIZE-1:0] wdata;
  reg winc, wclk, wrst_n;
  reg rinc, rclk, rrst_n;

  // 用來驗證資料順序的 queue
  reg [DSIZE-1:0] verif_data_q [0:255];
  integer head, tail, q_count; // queue 指標
  reg [DSIZE-1:0] verif_wdata;

  // DUT instance
  AsyncFIFO #(DSIZE, ASIZE) dut (
    .rdata (rdata),
    .wfull (wfull),
    .rempty(rempty),
    .wdata (wdata),
    .winc  (winc),
    .wclk  (wclk),
    .wrst_n(wrst_n),
    .rinc  (rinc),
    .rclk  (rclk),
    .rrst_n(rrst_n)
  );

  // -------------------------------
  // Clock Generation
  // -------------------------------
  initial begin
    wclk = 1'b0;
    rclk = 1'b0;
  end
  
  always #10 wclk = ~wclk;
  always #35 rclk = ~rclk;

  // -------------------------------
  // Write Domain Stimulus
  // -------------------------------
  integer iter, i;
  initial begin
    winc = 1'b0;
    wdata = 0;
    wrst_n = 1'b0;
    head = 0;
    tail = 0;
    q_count = 0;

    repeat(5) @(posedge wclk);
    wrst_n = 1'b1;

    for (iter = 0; iter < 2; iter = iter + 1) begin
      for (i = 0; i < 32; i = i + 1) begin
        @(posedge wclk);
        if (!wfull) begin
          winc = (i % 2 == 0) ? 1'b1 : 1'b0;
          if (winc) begin
            wdata = $random;
            verif_data_q[head] = wdata;
            head = (head + 1) % 256;
            q_count = q_count + 1;
          end
        end else begin
          winc = 1'b0;
        end
      end
      #1000; // #1us = 1000ns
    end
  end

  // -------------------------------
  // Read Domain Stimulus
  // -------------------------------
  initial begin
    rinc = 1'b0;
    rrst_n = 1'b0;

    repeat(8) @(posedge rclk);
    rrst_n = 1'b1;

    for (iter = 0; iter < 2; iter = iter + 1) begin
      for (i = 0; i < 32; i = i + 1) begin
        @(posedge rclk);
        if (!rempty) begin
          rinc = (i % 2 == 0) ? 1'b1 : 1'b0;
          if (rinc && q_count > 0) begin
            verif_wdata = verif_data_q[tail];
            tail = (tail + 1) % 256;
            q_count = q_count - 1;
				
            #1;

            $display("Correct! expected wdata = %h, rdata = %h", verif_wdata, rdata);
            if (rdata !== verif_wdata)
              $display("ERROR! Checking failed: expected wdata = %h, rdata = %h", verif_wdata, rdata);
          end
        end else begin
          rinc = 1'b0;
        end
      end
      #1000; // #1us
    end

    $finish;
  end

endmodule
