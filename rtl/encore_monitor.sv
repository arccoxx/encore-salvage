// encore_monitor.sv — purest form
// Register monitor for ENCORE-style co-emulation.
// Compares DUT vs emulator registers. On first mismatch: mismatch + pause + one-cycle snapshot_req.

module encore_monitor #(
  parameter int REG_WIDTH   = 64,
  parameter int NUM_REGS    = 32,
  parameter int SAMPLE_EVERY = 1
) (
  input  logic                     clk,
  input  logic                     rst_n,
  input  logic [NUM_REGS-1:0][REG_WIDTH-1:0] dut_regs,
  input  logic                     dut_valid,
  input  logic [NUM_REGS-1:0][REG_WIDTH-1:0] emu_regs,
  input  logic                     emu_valid,
  output logic                     mismatch,
  output logic                     pause_req,
  output logic                     snapshot_req,
  output logic [$clog2(NUM_REGS)-1:0] mismatch_reg_idx
);

  logic [15:0] sample_cnt;
  logic        sample_en;
  logic [NUM_REGS-1:0] reg_mismatch;
  logic        any_mismatch;
  logic [$clog2(NUM_REGS)-1:0] first_mismatch;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) sample_cnt <= '0;
    else        sample_cnt <= (sample_cnt == SAMPLE_EVERY-1) ? '0 : sample_cnt + 1;
  end

  assign sample_en = (sample_cnt == 0) && dut_valid && emu_valid;

  always_comb begin
    any_mismatch = 1'b0;
    first_mismatch = '0;
    for (int i = 0; i < NUM_REGS; i++) begin
      reg_mismatch[i] = (dut_regs[i] != emu_regs[i]);
      if (reg_mismatch[i] && !any_mismatch) begin
        any_mismatch = 1'b1;
        first_mismatch = i[$clog2(NUM_REGS)-1:0];
      end
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mismatch         <= 1'b0;
      pause_req        <= 1'b0;
      snapshot_req     <= 1'b0;
      mismatch_reg_idx <= '0;
    end else begin
      snapshot_req <= 1'b0;  // default pulse
      if (sample_en && any_mismatch) begin
        mismatch         <= 1'b1;
        pause_req        <= 1'b1;
        snapshot_req     <= 1'b1;
        mismatch_reg_idx <= first_mismatch;
      end
    end
  end

endmodule
