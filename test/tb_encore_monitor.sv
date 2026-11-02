// Simple Verilator-friendly testbench for encore_monitor

`timescale 1ns/1ps

module tb_encore_monitor;

  localparam REG_WIDTH = 64;
  localparam NUM_REGS  = 8;   // reduced for test

  logic clk, rst_n;
  logic [NUM_REGS-1:0][REG_WIDTH-1:0] dut_regs, emu_regs;
  logic dut_valid, emu_valid;
  logic mismatch, pause_req, snapshot_req;
  logic [$clog2(NUM_REGS)-1:0] mismatch_reg_idx;

  encore_monitor #(
    .REG_WIDTH(REG_WIDTH),
    .NUM_REGS(NUM_REGS),
    .SAMPLE_EVERY(1)
  ) dut (
    .clk(clk), .rst_n(rst_n),
    .dut_regs(dut_regs), .dut_valid(dut_valid),
    .emu_regs(emu_regs), .emu_valid(emu_valid),
    .mismatch(mismatch), .pause_req(pause_req),
    .snapshot_req(snapshot_req),
    .mismatch_reg_idx(mismatch_reg_idx)
  );

  always #5 clk = ~clk;

  initial begin
    clk = 0; rst_n = 0;
    dut_regs = '0; emu_regs = '0;
    dut_valid = 0; emu_valid = 0;
    #20 rst_n = 1;

    // Matching case
    dut_regs[0] = 64'hDEADBEEF;
    emu_regs[0] = 64'hDEADBEEF;
    dut_valid = 1; emu_valid = 1;
    #20;
    if (mismatch) $display("ERROR: false mismatch");
    else $display("PASS: no mismatch on equal registers");

    // Mismatch case
    emu_regs[3] = 64'hBAD;
    #20;
    if (mismatch && pause_req && mismatch_reg_idx == 3)
      $display("PASS: mismatch detected on reg 3");
    else
      $display("ERROR: mismatch not correctly detected");

    $finish;
  end

endmodule
