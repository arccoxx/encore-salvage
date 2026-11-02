# Comparative Analysis: Strengths, Weaknesses, Patches

## Strengths of the purest form

1. **Pulse correctness** — `snapshot_req` is a guaranteed one-cycle pulse (fixed sticky bug present in early models).
2. **Deterministic first-mismatch index** — priority encoding is explicit and synthesizable.
3. **Functional specification** — `monitor_functional.py` is the executable spec; RTL is the implementation. Divergence is immediately visible.
4. **Parameterization** — REG_WIDTH, NUM_REGS, SAMPLE_EVERY are clean.
5. **Open and simulation-first** — no proprietary tools required for the unit logic.

## Weaknesses (original salvage and residual)

| Weakness | Impact | Patch applied |
|----------|--------|---------------|
| Sticky snapshot pulse in early model | False continuous trigger | Forced `snapshot_req <= 0` every cycle except the detection cycle |
| Non-synthesizable priority loop style | Tool warnings | Comb always block with explicit break-free priority |
| No coverage of multi-register simultaneous mismatch | Ambiguous which reg reported | First-mismatch priority documented and tested |
| No adversarial / differential testing harness | Uncaught corner cases | Functional model is the oracle; can be driven by random generators |
| Limited to register file (no PC, CSR, memory) | Incomplete architectural state | Documented as extension point; core mechanism unchanged |

## Adversarial / Robustness Notes

- **Differential testing**: Drive both the functional model and a Verilator simulation of the RTL with the same random register streams; assert identical mismatch/index/pulse behavior.
- **Property style**:
  - `snapshot_req` is never high for two consecutive cycles.
  - `mismatch` once set stays set until reset (sticky for debug).
  - `mismatch_reg_idx` points to the lowest-index differing register on the cycle of detection.
- **Stress**: SAMPLE_EVERY > 1, simultaneous mismatches on many registers, valid signals toggling independently.
- Real-world benchmarking remains FPGA-board dependent (original paper numbers are the reference). This salvage prioritizes correctness and clarity of the monitor mechanism that enables those numbers.

## Haskell / Functional Synthesis

The draw of Haskell here is structuring the *computation* (pure state transition of the monitor) so that it can later be synthesized (via Clash or manual). The Python model is already that pure function. A Clash version would look almost identical and generate the RTL automatically. That is the "synthetic" power: the computation *is* the synthesis source.
