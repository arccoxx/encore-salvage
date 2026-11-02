# encore-salvage

Open-source salvage and improved reimplementation of **ENCORE: Efficient Architecture Verification Framework with FPGA Acceleration** (Kan Shi et al., FPGA'23).

**Original paper**: Shi, K., Xu, S., Diao, Y., Boland, D., & Bao, Y. (2023). ENCORE: Efficient Architecture Verification Framework with FPGA Acceleration. In *Proceedings of the 2023 ACM/SIGDA International Symposium on Field Programmable Gate Arrays* (pp. 209–219). https://doi.org/10.1145/3543622.3573187

## What is ENCORE?

ENCORE co-emulates a processor Design-Under-Test (DUT, typically RISC-V RTL on the FPGA fabric) together with a software architectural emulator running on the FPGA's hardened ARM cores. Hardware monitors dynamically compare key architectural registers. On mismatch it pauses execution, captures a full snapshot, and offloads to a software simulator (ModelSim/Verilator) for full-visibility debugging.

**Reported performance** (on Xilinx UltraScale+ XCZU19EG with realistic RISC-V workloads):
- **>44,000×** speedup vs ModelSim
- **~139×** speedup vs Verilator
- Area overhead: ~1.17% BRAM, 0.11% LUTs

## This Salvage

The original authors did not release source. This repository provides a clean, modular, fully open-source reconstruction of the key mechanisms plus improvements:

- Pure open-source toolchain (Verilator, Icarus, open RISC-V cores)
- Modular monitor / checker / snapshot units
- Explicit interfaces for any RISC-V core + any ISS (Spike, custom, etc.)
- Unit tests that can be run without proprietary tools or real FPGA hardware
- Clear documentation of the co-emulation flow and snapshot hand-off

## Quick Start (Simulation)

```bash
# Requires Verilator
make sim
```

See `test/` and `docs/` for details.

## Architecture Overview

1. **DUT** runs on FPGA fabric (RTL).
2. **Software emulator** runs on hardened ARM cores of the same SoC FPGA.
3. **encore_monitor** samples key registers from both sides every cycle (or every N cycles) and flags mismatches.
4. On mismatch: pause both, trigger **encore_snapshot**, dump state to host or on-chip memory, then resume or hand off to offline simulator.

## Status

Core monitor and testbench are functional under Verilator. Full end-to-end FPGA deployment requires a Zynq UltraScale+ (or equivalent) board and a concrete RISC-V core + ISS pair. Contributions welcome.

## License

Apache-2.0 (or MIT — see LICENSE).
