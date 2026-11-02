// encore_monitor.sv
// Core register monitor / mismatch detector for ENCORE-style co-emulation.
// Compares architectural registers between FPGA DUT and software emulator.
// On mismatch, asserts pause and snapshot_req.

module encore_monitor #(n
  parameter int REG_WIDTH = 64,
  parameter int NUM_REGS  = 32,   // e.g. integer registers
  parameter int SAMPLE_EVERY = 1  // sample every N cycles (1 = every cycle)
) (
  input  logic                     clk,
  input  logic                     rst_n,

  // From DUT (FPGA fabric)
  input  logic [NUM_REGS-1:0][REG_WIDTH-1:0] dut_regs,
  input  logic                     dut_valid,     // DUT has committed a state

  // From software emulator (via AXI/lite or custom bridge from ARM)
  input  logic [NUM_REGS-1:0][REG_WIDTH-1:0] emu_regs,
  input  logic                     emu_valid,

  // Control
  output logic                     mismatch,
  output logic                     pause_req,
  output logic                     snapshot_req,
  output logic [$clog2(NUM_REGS)-1:0] mismatch_reg_idx
);

  logic [15:0] sample_cnt;
  logic        sample_en;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) sample_cnt <= '0;
    else if (sample_cnt == SAMPLE_EVERY-1) sample_cnt <= '0;
    else sample_cnt <= sample_cnt + 1;
  end

  assign sample_en = (sample_cnt == 0) && dut_valid && emu_valid;

  logic [NUM_REGS-1:0] reg_mismatch;
  always_comb begin
    for (int i = 0; i < NUM_REGS; i++) begin
      reg_mismatch[i] = (dut_regs[i] != emu_regs[i]);
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mismatch      <= 1'b0;
      pause_req     <= 1'b0;
      snapshot_req  <= 1'b0;
      mismatch_reg_idx <= '0;
    end else if (sample_en && |reg_mismatch) begin
      mismatch     <= 1'b1;
      pause_req    <= 1'b1;
      snapshot_req <= 1'b1;
      // Priority encoder for first mismatching register
      for (int i = 0; i < NUM_REGS; i++) begin
        if (reg_mismatch[i]) begin
          mismatch_reg_idx <= i[$clog2(NUM_REGS)-1:0];
          break;
        end
      end
    end else begin
      snapshot_req <= 1'b0; // one-cycle pulse
    end
  end

endmodule
