# ENCORE Architecture (Salvage Notes)

## Core Idea (from Shi et al. FPGA'23)

- Same FPGA SoC runs:
  - DUT RTL on programmable logic
  - Software ISA emulator on hardened ARM cores
- Hardware monitor continuously compares architectural state
- Mismatch → pause + snapshot → offline full-visibility debug in ModelSim/Verilator

## This Implementation

- `encore_monitor`: samples and compares register files, asserts pause/snapshot on first mismatch
- `encore_snapshot`: captures both sides' register state
- Interfaces are simple and can be bridged to AXI-Lite or custom interconnects from the ARM side

## Integration Steps (for real FPGA)

1. Choose a RISC-V core (Nutshell was used in the original; PicoRV32, Rocket, or any open core works)
2. Expose its architectural registers to the monitor
3. Run a lightweight ISS (Spike, or a custom one) on the ARM cores and stream register state
4. Connect pause signals into both the DUT clock gating / pipeline stall and the emulator
5. On snapshot, dump via AXI to DDR or host

## Improvements over original description

- Fully open-source
- Parameterized and modular
- Simulation-first verification path
- Clear mismatch index reporting
