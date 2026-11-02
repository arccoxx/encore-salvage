// encore_snapshot.sv
// Snapshot capture trigger and simple on-chip buffer interface.
// In a full system this would dump to DDR or host via AXI.

module encore_snapshot #(n
  parameter int REG_WIDTH = 64,
  parameter int NUM_REGS  = 32
) (
  input  logic                     clk,
  input  logic                     rst_n,
  input  logic                     snapshot_req,
  input  logic [NUM_REGS-1:0][REG_WIDTH-1:0] dut_regs,
  input  logic [NUM_REGS-1:0][REG_WIDTH-1:0] emu_regs,

  output logic                     snapshot_done,
  output logic [NUM_REGS-1:0][REG_WIDTH-1:0] snap_dut,
  output logic [NUM_REGS-1:0][REG_WIDTH-1:0] snap_emu
);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      snapshot_done <= 1'b0;
      snap_dut      <= '0;
      snap_emu      <= '0;
    end else if (snapshot_req) begin
      snap_dut      <= dut_regs;
      snap_emu      <= emu_regs;
      snapshot_done <= 1'b1;
    end else begin
      snapshot_done <= 1'b0;
    end
  end

endmodule
