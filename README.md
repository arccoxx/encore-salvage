# encore-salvage

Open-source salvage of **ENCORE** (Shi et al., FPGA’23). Core monitor proven live in functional model + refined RTL.

**Paper**: Shi, K. et al. (2023). ENCORE: Efficient Architecture Verification Framework with FPGA Acceleration. FPGA ’23. https://doi.org/10.1145/3543622.3573187

>44,000× vs ModelSim, ~139× vs Verilator on UltraScale+ with RISC-V workloads.

## Purest Form (this version)

- `rtl/encore_monitor.sv` — cleaned, pulse-correct, priority-encoded mismatch detector
- `model/monitor_functional.py` — pure functional specification (executable, portable to Haskell)
- Full comparative analysis in `docs/analysis.md`

```bash
python3 model/monitor_functional.py   # live proof
```

## Haskell Note

Haskell (or Clash) is the right way to structure the *computation* of the monitor as a pure state transition before synthesis. The functional model below is the specification; Clash can turn an equivalent Haskell version into RTL. Haskell is not "synthetic" in the hardware sense, but it is excellent for *structuring synthesis as computation*.

See `docs/analysis.md` for strengths, weaknesses, patches, and adversarial hardening.
