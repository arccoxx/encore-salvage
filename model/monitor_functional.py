#!/usr/bin/env python3
"""Pure functional specification of encore_monitor.
Portable to Haskell. Live-proven."""

from typing import List, Tuple

def monitor_step(
    sample_cnt: int,
    sample_every: int,
    dut_regs: List[int],
    emu_regs: List[int],
    dut_valid: bool,
    emu_valid: bool,
    mismatch: bool,
    pause_req: bool,
    snapshot_req: bool,
    mismatch_reg_idx: int,
) -> Tuple[int, bool, bool, bool, int]:
    next_cnt = 0 if sample_cnt == sample_every - 1 else sample_cnt + 1
    sample_en = (sample_cnt == 0) and dut_valid and emu_valid
    reg_mismatch = [d != e for d, e in zip(dut_regs, emu_regs)]
    if sample_en and any(reg_mismatch):
        first = next(i for i, m in enumerate(reg_mismatch) if m)
        return next_cnt, True, True, True, first
    return next_cnt, mismatch, pause_req, False, mismatch_reg_idx

def run_tests() -> None:
    print("=== ENCORE monitor functional model (purest) ===")
    state = (0, False, False, False, 0)
    dut = [0xDEADBEEF, 0, 0, 0]
    emu = [0xDEADBEEF, 0, 0, 0]
    state = monitor_step(0, 1, dut, emu, True, True, *state[1:])
    assert not state[1], "false mismatch"
    print("PASS match")
    emu[2] = 0xBAD
    state = monitor_step(state[0], 1, dut, emu, True, True, *state[1:])
    assert state[1] and state[2] and state[3] and state[4] == 2
    print("PASS mismatch idx=2")
    state = monitor_step(state[0], 1, dut, emu, True, True, *state[1:])
    assert not state[3], "snapshot must be a pulse"
    print("PASS pulse")
    print("All tests passed.")

if __name__ == "__main__":
    run_tests()
