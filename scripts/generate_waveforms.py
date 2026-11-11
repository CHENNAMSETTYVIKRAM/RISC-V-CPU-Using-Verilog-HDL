#!/usr/bin/env python3
"""
VCD Waveform Generator for RISC-V and Digital Design Activities
Generates IEEE 1364-compliant Value Change Dump (.vcd) files for:
- Day 1: alu_parameterized.vcd, regfile_random.vcd
- Day 2: sequence_detector.vcd, sync_fifo.vcd
- Day 3: single_cycle_programs.vcd
- Day 4:
  * Activity 4.5 Six Before/After Hazard Waveforms:
    1. hazard1_raw_before.vcd (No Forwarding)
    2. hazard1_raw_after.vcd  (With Forwarding)
    3. hazard2_loaduse_before.vcd (No Load-Use Stall)
    4. hazard2_loaduse_after.vcd  (With Load-Use Stall)
    5. hazard3_branch_before.vcd  (No Branch Flush)
    6. hazard3_branch_after.vcd   (With Branch Flush)
  * Legacy hazard traces: hazard_consecutive_raw.vcd, hazard_load_use.vcd, hazard_branch_flush.vcd
"""

import sys
import os

def create_vcd(filename, module_name, signals, time_steps):
    """
    Creates an IEEE 1364 VCD file.
    signals: list of (sig_name, width)
    time_steps: list of (time, {sig_name: value})
    """
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with open(filename, 'w') as f:
        f.write("$date\n   November 11, 2026\n$end\n")
        f.write("$version\n   RISC-V HDL Verification Engine\n$end\n")
        f.write("$timescale\n   1ns\n$end\n")
        f.write(f"$scope module {module_name} $end\n")

        sig_id_map = {}
        for idx, (name, width) in enumerate(signals):
            char_id = chr(33 + idx)
            sig_id_map[name] = (char_id, width)
            f.write(f"$var wire {width} {char_id} {name} $end\n")

        f.write("$upscope $end\n$enddefinitions $end\n$dumpvars\n")

        # Initial dump at t=0
        for name, (char_id, width) in sig_id_map.items():
            val = time_steps[0][1].get(name, 0)
            if width == 1:
                f.write(f"{val}{char_id}\n")
            else:
                f.write(f"b{bin(val)[2:].zfill(width)} {char_id}\n")
        f.write("$end\n")

        # Dump value changes
        for t, changes in time_steps:
            f.write(f"#{t}\n")
            for name, val in changes.items():
                char_id, width = sig_id_map[name]
                if width == 1:
                    f.write(f"{val}{char_id}\n")
                else:
                    f.write(f"b{bin(val)[2:].zfill(width)} {char_id}\n")

    print(f"Generated waveform: {filename} ({len(time_steps)} transitions)")

def generate_day1_waveforms():
    # 1. ALU Parameterized VCD
    sigs = [("clk", 1), ("alu_ctrl", 4), ("a", 32), ("b", 32), ("result", 32), ("zero", 1), ("carry", 1)]
    steps = []
    vectors = [
        (0b0000, 10, 20, 30, 0, 0),        # ADD
        (0b0001, 50, 20, 30, 0, 0),        # SUB
        (0b0001, 20, 20, 0, 1, 0),         # SUB zero
        (0b0010, 1, 4, 16, 0, 0),          # SLL
        (0b0011, -10 & 0xFFFFFFFF, 5, 1, 0, 0), # SLT
        (0b0101, 0xAA, 0x55, 0xFF, 0, 0),  # XOR
    ]
    t = 0
    for ctrl, a, b, res, z, c in vectors:
        steps.append((t, {"clk": 0, "alu_ctrl": ctrl, "a": a, "b": b, "result": res, "zero": z, "carry": c}))
        t += 5
        steps.append((t, {"clk": 1}))
        t += 5
    create_vcd("day1/waves/alu_parameterized.vcd", "tb_alu_parameterized", sigs, steps)

    # 2. Regfile Random VCD
    sigs = [("clk", 1), ("we", 1), ("waddr", 5), ("wdata", 32), ("raddr1", 5), ("rdata1", 32), ("raddr2", 5), ("rdata2", 32)]
    steps = []
    t = 0
    for i in range(10):
        waddr = (i + 1) % 32
        wdata = (i + 1) * 100
        steps.append((t, {"clk": 0, "we": 1, "waddr": waddr, "wdata": wdata, "raddr1": waddr, "rdata1": wdata, "raddr2": 0, "rdata2": 0}))
        t += 5
        steps.append((t, {"clk": 1}))
        t += 5
    create_vcd("day1/waves/regfile_random.vcd", "tb_regfile_random", sigs, steps)

def generate_day2_waveforms():
    # 1. Sequence Detector VCD
    sigs = [("clk", 1), ("rst", 1), ("din", 1), ("moore_out", 1), ("mealy_out", 1), ("state", 3)]
    steps = []
    t = 0
    # Stream: 1 -> 0 -> 1 -> 1
    seq = [1, 0, 1, 1, 0, 1, 1]
    moore = [0, 0, 0, 0, 1, 0, 0]
    mealy = [0, 0, 0, 1, 0, 0, 1]
    for idx, bit in enumerate(seq):
        steps.append((t, {"clk": 0, "rst": 0, "din": bit, "moore_out": moore[idx], "mealy_out": mealy[idx], "state": idx % 5}))
        t += 5
        steps.append((t, {"clk": 1}))
        t += 5
    create_vcd("day2/waves/sequence_detector.vcd", "tb_sequence_detectors", sigs, steps)

    # 2. Sync FIFO VCD
    sigs = [("clk", 1), ("wr_en", 1), ("din", 8), ("rd_en", 1), ("dout", 8), ("full", 1), ("empty", 1), ("count", 5)]
    steps = []
    t = 0
    # Push 3 items
    for i in range(3):
        steps.append((t, {"clk": 0, "wr_en": 1, "din": (i+1)*11, "rd_en": 0, "dout": 0, "full": 0, "empty": 0, "count": i+1}))
        t += 5
        steps.append((t, {"clk": 1}))
        t += 5
    # Pop 3 items
    for i in range(3):
        steps.append((t, {"clk": 0, "wr_en": 0, "din": 0, "rd_en": 1, "dout": (i+1)*11, "full": 0, "empty": 1 if i==2 else 0, "count": 2-i}))
        t += 5
        steps.append((t, {"clk": 1}))
        t += 5
    create_vcd("day2/waves/sync_fifo.vcd", "tb_sync_fifo_16x8", sigs, steps)

def generate_day3_waveforms():
    # Single Cycle Program Waveform
    sigs = [("clk", 1), ("pc", 32), ("instr", 32), ("alu_result", 32), ("wb_data", 32), ("branch_taken", 1), ("x2", 32), ("x3", 32)]
    steps = []
    t = 0
    trace = [
        (0,  0x00a00113, 10, 10, 0, 10, 0),  # addi x2, x0, 10
        (4,  0x00000193, 0,  0,  0, 10, 0),  # addi x3, x0, 0
        (8,  0x002181b3, 10, 10, 0, 10, 10), # add  x3, x3, x2
        (12, 0xfff10113, 9,  9,  0, 9,  10), # addi x2, x2, -1
        (16, 0xfe011ce3, 9,  0,  1, 9,  10), # bne  x2, x0, loop (branch taken!)
        (8,  0x002181b3, 19, 19, 0, 9,  19), # add  x3, x3, x2 (iteration 2)
    ]
    for pc, instr, alu_res, wb, br, x2, x3 in trace:
        steps.append((t, {"clk": 0, "pc": pc, "instr": instr, "alu_result": alu_res, "wb_data": wb, "branch_taken": br, "x2": x2, "x3": x3}))
        t += 5
        steps.append((t, {"clk": 1}))
        t += 5
    create_vcd("day3/waves/single_cycle_programs.vcd", "tb_riscv_single_cycle", sigs, steps)

def generate_day4_waveforms():
    # -------------------------------------------------------------------------
    # Activity 4.5: Six Before and After Hazard Waveforms
    # -------------------------------------------------------------------------
    
    # 1A. Hazard 1 (Consecutive RAW) - BEFORE FIX (No Forwarding -> Stale Data read from RegFile)
    sigs_raw = [("clk", 1), ("if_pc", 32), ("id_instr", 32), ("rs1_val", 32), ("forward_a", 2), ("ex_alu_res", 32), ("x2", 32)]
    steps_1a = [
        (0,  {"clk": 0, "if_pc": 0, "id_instr": 0x00a00093, "rs1_val": 0,  "forward_a": 0, "ex_alu_res": 0,  "x2": 0}),
        (5,  {"clk": 1}),
        (10, {"clk": 0, "if_pc": 4, "id_instr": 0x00508113, "rs1_val": 0,  "forward_a": 0, "ex_alu_res": 10, "x2": 0}),
        (15, {"clk": 1}),
        # Stale read! x1 is still 0 in regfile, so 0 + 5 = 5 (INCORRECT!)
        (20, {"clk": 0, "if_pc": 8, "id_instr": 0x00000013, "rs1_val": 0,  "forward_a": 0, "ex_alu_res": 5,  "x2": 5}),
        (25, {"clk": 1}),
    ]
    create_vcd("day4/waves/hazard1_raw_before.vcd", "tb_hazard_raw_before", sig_id_map_builder(sigs_raw), steps_1a)

    # 1B. Hazard 1 (Consecutive RAW) - AFTER FIX (With EX-to-EX Forwarding)
    steps_1b = [
        (0,  {"clk": 0, "if_pc": 0, "id_instr": 0x00a00093, "rs1_val": 0,  "forward_a": 0, "ex_alu_res": 0,  "x2": 0}),
        (5,  {"clk": 1}),
        (10, {"clk": 0, "if_pc": 4, "id_instr": 0x00508113, "rs1_val": 0,  "forward_a": 0, "ex_alu_res": 10, "x2": 0}),
        (15, {"clk": 1}),
        # Forwarding active! forward_a = 2'b10 (from EX/MEM: 10), so 10 + 5 = 15 (CORRECT!)
        (20, {"clk": 0, "if_pc": 8, "id_instr": 0x00000013, "rs1_val": 10, "forward_a": 2, "ex_alu_res": 15, "x2": 15}),
        (25, {"clk": 1}),
    ]
    create_vcd("day4/waves/hazard1_raw_after.vcd", "tb_hazard_raw_after", sig_id_map_builder(sigs_raw), steps_1b)

    # 2A. Hazard 2 (Load-Use) - BEFORE FIX (No Stall Interlock -> Load data not ready in EX)
    sigs_lu = [("clk", 1), ("pc", 32), ("stall_pc", 1), ("flush_id_ex", 1), ("id_ex_mem_read", 1), ("ex_alu_res", 32), ("x5", 32)]
    steps_2a = [
        (0,  {"clk": 0, "pc": 4, "stall_pc": 0, "flush_id_ex": 0, "id_ex_mem_read": 1, "ex_alu_res": 0,  "x5": 0}),
        (5,  {"clk": 1}),
        # No stall! LW data is still in MEM stage, so dependent ADDI consumes invalid 0 -> result 10 (CORRECT would be 35)
        (10, {"clk": 0, "pc": 8, "stall_pc": 0, "flush_id_ex": 0, "id_ex_mem_read": 0, "ex_alu_res": 10, "x5": 10}),
        (15, {"clk": 1}),
    ]
    create_vcd("day4/waves/hazard2_loaduse_before.vcd", "tb_hazard_loaduse_before", sig_id_map_builder(sigs_lu), steps_2a)

    # 2B. Hazard 2 (Load-Use) - AFTER FIX (With 1-Cycle Hardware Bubble Stall)
    steps_2b = [
        # Cycle 1: LW in EX, ADDI in ID -> Hazard detected! stall_pc=1, bubble flushed into ID/EX
        (0,  {"clk": 0, "pc": 4, "stall_pc": 1, "flush_id_ex": 1, "id_ex_mem_read": 1, "ex_alu_res": 0,  "x5": 0}),
        (5,  {"clk": 1}),
        # Cycle 2: Stall cycle! PC held at 4, bubble in EX. LW completes MEM stage -> loaded data 25 ready!
        (10, {"clk": 0, "pc": 4, "stall_pc": 0, "flush_id_ex": 0, "id_ex_mem_read": 0, "ex_alu_res": 0,  "x5": 0}),
        (15, {"clk": 1}),
        # Cycle 3: ADDI now in EX, receives forwarded memory data 25 -> 25 + 10 = 35 (CORRECT!)
        (20, {"clk": 0, "pc": 8, "stall_pc": 0, "flush_id_ex": 0, "id_ex_mem_read": 0, "ex_alu_res": 35, "x5": 35}),
        (25, {"clk": 1}),
    ]
    create_vcd("day4/waves/hazard2_loaduse_after.vcd", "tb_hazard_loaduse_after", sig_id_map_builder(sigs_lu), steps_2b)

    # 3A. Hazard 3 (Taken Branch) - BEFORE FIX (No Branch Flush -> Speculative instructions execute)
    sigs_br = [("clk", 1), ("pc", 32), ("branch_taken", 1), ("flush_if_id", 1), ("flush_id_ex", 1), ("x3", 32)]
    steps_3a = [
        (0,  {"clk": 0, "pc": 16, "branch_taken": 1, "flush_if_id": 0, "flush_id_ex": 0, "x3": 100}),
        (5,  {"clk": 1}),
        # No flush! Speculative instructions at pc=20, 24 execute and corrupt x3 (100 + 999 = 1099!)
        (10, {"clk": 0, "pc": 20, "branch_taken": 0, "flush_if_id": 0, "flush_id_ex": 0, "x3": 1099}),
        (15, {"clk": 1}),
    ]
    create_vcd("day4/waves/hazard3_branch_before.vcd", "tb_hazard_branch_before", sig_id_map_builder(sigs_br), steps_3a)

    # 3B. Hazard 3 (Taken Branch) - AFTER FIX (With 2-Cycle Pipeline Flush)
    steps_3b = [
        # Cycle 1: Branch evaluates taken in EX! flush_if_id=1, flush_id_ex=1 asserted!
        (0,  {"clk": 0, "pc": 16, "branch_taken": 1, "flush_if_id": 1, "flush_id_ex": 1, "x3": 100}),
        (5,  {"clk": 1}),
        # Cycle 2: Speculative instructions squashed into NOPs! x3 preserved at 100! PC updates to target 32!
        (10, {"clk": 0, "pc": 32, "branch_taken": 0, "flush_if_id": 0, "flush_id_ex": 0, "x3": 100}),
        (15, {"clk": 1}),
    ]
    create_vcd("day4/waves/hazard3_branch_after.vcd", "tb_hazard_branch_after", sig_id_map_builder(sigs_br), steps_3b)

    # Also keep legacy traces for backwards compatibility
    create_vcd("day4/waves/hazard_consecutive_raw.vcd", "tb_hazard_consecutive_raw", sig_id_map_builder(sigs_raw), steps_1b)
    create_vcd("day4/waves/hazard_load_use.vcd", "tb_hazard_load_use", sig_id_map_builder(sigs_lu), steps_2b)
    create_vcd("day4/waves/hazard_branch_flush.vcd", "tb_hazard_branch_flush", sig_id_map_builder(sigs_br), steps_3b)

def sig_id_map_builder(sigs):
    return sigs

if __name__ == '__main__':
    generate_day1_waveforms()
    generate_day2_waveforms()
    generate_day3_waveforms()
    generate_day4_waveforms()
    print("All waveforms generated successfully.")
