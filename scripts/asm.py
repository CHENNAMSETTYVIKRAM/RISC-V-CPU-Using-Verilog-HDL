#!/usr/bin/env python3
"""
RISC-V RV32I + RV32M Two-Pass Assembler
Supports labels, comments, ABI register names, pseudo-instructions, and direct machine code emission.
"""

import sys
import re

ABI_REG_MAP = {
    'zero': 0, 'ra': 1, 'sp': 2, 'gp': 3, 'tp': 4,
    't0': 5, 't1': 6, 't2': 7, 's0': 8, 'fp': 8, 's1': 9,
    'a0': 10, 'a1': 11, 'a2': 12, 'a3': 13, 'a4': 14, 'a5': 15,
    'a6': 16, 'a7': 17, 's2': 18, 's3': 19, 's4': 20, 's5': 21,
    's6': 22, 's7': 23, 's8': 24, 's9': 25, 's10': 26, 's11': 27,
    't3': 28, 't4': 29, 't5': 30, 't6': 31
}

for i in range(32):
    ABI_REG_MAP[f'x{i}'] = i

def parse_reg(token):
    tok = token.strip().lower()
    if tok in ABI_REG_MAP:
        return ABI_REG_MAP[tok]
    raise ValueError(f"Unknown register name: '{token}'")

def parse_imm(token, labels=None, current_pc=0):
    tok = token.strip()
    if labels and tok in labels:
        return labels[tok] - current_pc
    return int(tok, 0)

def enc_r(opcode, funct3, funct7, rd, rs1, rs2):
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def enc_i(opcode, funct3, rd, rs1, imm):
    return ((imm & 0xFFF) << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def enc_s(opcode, funct3, rs1, rs2, imm):
    imm11_5 = (imm >> 5) & 0x7F
    imm4_0 = imm & 0x1F
    return (imm11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm4_0 << 7) | opcode

def enc_b(opcode, funct3, rs1, rs2, imm):
    imm12 = (imm >> 12) & 0x1
    imm10_5 = (imm >> 5) & 0x3F
    imm4_1 = (imm >> 1) & 0xF
    imm11 = (imm >> 11) & 0x1
    return (imm12 << 31) | (imm10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm4_1 << 8) | (imm11 << 7) | opcode

def enc_u(opcode, rd, imm):
    return ((imm & 0xFFFFF000)) | (rd << 7) | opcode

def enc_j(opcode, rd, imm):
    imm20 = (imm >> 20) & 0x1
    imm10_1 = (imm >> 1) & 0x3FF
    imm11 = (imm >> 11) & 0x1
    imm19_12 = (imm >> 12) & 0xFF
    return (imm20 << 31) | (imm10_1 << 21) | (imm11 << 20) | (imm19_12 << 12) | (rd << 7) | opcode

def assemble_line(instr, args, pc, labels):
    instr = instr.lower()

    # R-Type Arithmetic & Logic
    r_ops = {
        'add':  (0x33, 0x0, 0x00),
        'sub':  (0x33, 0x0, 0x20),
        'sll':  (0x33, 0x1, 0x00),
        'slt':  (0x33, 0x2, 0x00),
        'sltu': (0x33, 0x3, 0x00),
        'xor':  (0x33, 0x4, 0x00),
        'srl':  (0x33, 0x5, 0x00),
        'sra':  (0x33, 0x5, 0x20),
        'or':   (0x33, 0x6, 0x00),
        'and':  (0x33, 0x7, 0x00),
        # RV32M Extension
        'mul':    (0x33, 0x0, 0x01),
        'mulh':   (0x33, 0x1, 0x01),
        'mulhsu': (0x33, 0x2, 0x01),
        'mulhu':  (0x33, 0x3, 0x01),
        'div':    (0x33, 0x4, 0x01),
        'divu':   (0x33, 0x5, 0x01),
        'rem':    (0x33, 0x6, 0x01),
        'remu':   (0x33, 0x7, 0x01)
    }

    if instr in r_ops:
        rd = parse_reg(args[0])
        rs1 = parse_reg(args[1])
        rs2 = parse_reg(args[2])
        op, f3, f7 = r_ops[instr]
        return [enc_r(op, f3, f7, rd, rs1, rs2)]

    # I-Type Arithmetic & Logic
    i_ops = {
        'addi':  (0x13, 0x0),
        'slti':  (0x13, 0x2),
        'sltiu': (0x13, 0x3),
        'xori':  (0x13, 0x4),
        'ori':   (0x13, 0x6),
        'andi':  (0x13, 0x7),
        'slli':  (0x13, 0x1),
        'srli':  (0x13, 0x5),
        'srai':  (0x13, 0x5)
    }

    if instr in i_ops:
        rd = parse_reg(args[0])
        rs1 = parse_reg(args[1])
        imm = parse_imm(args[2], labels, pc)
        op, f3 = i_ops[instr]
        if instr == 'srai':
            imm = (imm & 0x1F) | 0x400
        elif instr in ('slli', 'srli'):
            imm = imm & 0x1F
        return [enc_i(op, f3, rd, rs1, imm)]

    # Loads (LB, LH, LW, LBU, LHU)
    loads = {
        'lb':  (0x03, 0x0),
        'lh':  (0x03, 0x1),
        'lw':  (0x03, 0x2),
        'lbu': (0x03, 0x4),
        'lhu': (0x03, 0x5)
    }
    if instr in loads:
        rd = parse_reg(args[0])
        # Format: offset(rs1)
        m = re.match(r'([-\w\d]+)\(([\w\d]+)\)', args[1])
        if not m:
            raise ValueError(f"Invalid load syntax: '{args[1]}'")
        imm = parse_imm(m.group(1), labels, pc)
        rs1 = parse_reg(m.group(2))
        op, f3 = loads[instr]
        return [enc_i(op, f3, rd, rs1, imm)]

    # Stores (SB, SH, SW)
    stores = {
        'sb': (0x23, 0x0),
        'sh': (0x23, 0x1),
        'sw': (0x23, 0x2)
    }
    if instr in stores:
        rs2 = parse_reg(args[0])
        m = re.match(r'([-\w\d]+)\(([\w\d]+)\)', args[1])
        if not m:
            raise ValueError(f"Invalid store syntax: '{args[1]}'")
        imm = parse_imm(m.group(1), labels, pc)
        rs1 = parse_reg(m.group(2))
        op, f3 = stores[instr]
        return [enc_s(op, f3, rs1, rs2, imm)]

    # Branches (BEQ, BNE, BLT, BGE, BLTU, BGEU)
    branches = {
        'beq':  (0x63, 0x0),
        'bne':  (0x63, 0x1),
        'blt':  (0x63, 0x4),
        'bge':  (0x63, 0x5),
        'bltu': (0x63, 0x6),
        'bgeu': (0x63, 0x7)
    }
    if instr in branches:
        rs1 = parse_reg(args[0])
        rs2 = parse_reg(args[1])
        imm = parse_imm(args[2], labels, pc)
        op, f3 = branches[instr]
        return [enc_b(op, f3, rs1, rs2, imm)]

    # Upper Immediates (LUI, AUIPC)
    if instr == 'lui':
        rd = parse_reg(args[0])
        imm = parse_imm(args[1], labels, pc)
        return [enc_u(0x37, rd, imm << 12 if imm < 0x100000 else imm)]
    if instr == 'auipc':
        rd = parse_reg(args[0])
        imm = parse_imm(args[1], labels, pc)
        return [enc_u(0x17, rd, imm << 12 if imm < 0x100000 else imm)]

    # Jumps (JAL, JALR)
    if instr == 'jal':
        if len(args) == 1:
            rd = 1 # default ra
            target = args[0]
        else:
            rd = parse_reg(args[0])
            target = args[1]
        imm = parse_imm(target, labels, pc)
        return [enc_j(0x6F, rd, imm)]

    if instr == 'jalr':
        if len(args) == 1:
            rd = 1
            rs1 = parse_reg(args[0])
            imm = 0
        elif len(args) == 2:
            rd = parse_reg(args[0])
            m = re.match(r'([-\w\d]+)\(([\w\d]+)\)', args[1])
            if m:
                imm = parse_imm(m.group(1), labels, pc)
                rs1 = parse_reg(m.group(2))
            else:
                rs1 = parse_reg(args[1])
                imm = 0
        else:
            rd = parse_reg(args[0])
            rs1 = parse_reg(args[1])
            imm = parse_imm(args[2], labels, pc)
        return [enc_i(0x67, 0x0, rd, rs1, imm)]

    # Pseudo-instructions
    if instr == 'nop':
        return [enc_i(0x13, 0x0, 0, 0, 0)]
    if instr == 'mv':
        rd = parse_reg(args[0])
        rs = parse_reg(args[1])
        return [enc_i(0x13, 0x0, rd, rs, 0)]
    if instr == 'not':
        rd = parse_reg(args[0])
        rs = parse_reg(args[1])
        return [enc_i(0x13, 0x4, rd, rs, -1)]
    if instr == 'neg':
        rd = parse_reg(args[0])
        rs = parse_reg(args[1])
        return [enc_r(0x33, 0x0, 0x20, rd, 0, rs)]
    if instr == 'j':
        imm = parse_imm(args[0], labels, pc)
        return [enc_j(0x6F, 0, imm)]
    if instr == 'jr':
        rs = parse_reg(args[0])
        return [enc_i(0x67, 0x0, 0, rs, 0)]
    if instr == 'ret':
        return [enc_i(0x67, 0x0, 0, 1, 0)]
    if instr == 'beqz':
        rs = parse_reg(args[0])
        imm = parse_imm(args[1], labels, pc)
        return [enc_b(0x63, 0x0, rs, 0, imm)]
    if instr == 'bnez':
        rs = parse_reg(args[0])
        imm = parse_imm(args[1], labels, pc)
        return [enc_b(0x63, 0x1, rs, 0, imm)]
    if instr == 'li':
        rd = parse_reg(args[0])
        val = parse_imm(args[1], labels, pc)
        if -2048 <= val < 2048:
            return [enc_i(0x13, 0x0, rd, 0, val)]
        else:
            # lui + addi
            upper = (val + 0x800) >> 12
            lower = val - (upper << 12)
            return [
                enc_u(0x37, rd, upper << 12),
                enc_i(0x13, 0x0, rd, rd, lower)
            ]

    raise ValueError(f"Unrecognized instruction: '{instr}'")

def assemble(source_text):
    """Two-pass assembly of RISC-V assembly source into 32-bit machine code words."""
    lines = source_text.strip().split('\n')
    cleaned = []

    # Clean comments & blank lines
    for line in lines:
        line = re.sub(r'#.*$', '', line)
        line = re.sub(r'//.*$', '', line).strip()
        if not line:
            continue
        cleaned.append(line)

    # Pass 1: Label resolution & instruction counting
    labels = {}
    pc = 0
    instructions = []

    for line in cleaned:
        # Check label
        if ':' in line:
            parts = line.split(':', 1)
            label = parts[0].strip()
            labels[label] = pc
            line = parts[1].strip()
            if not line:
                continue

        # Split instruction & operands
        parts = re.split(r'[\s,]+', line.strip())
        instr = parts[0]
        args = [p for p in parts[1:] if p]

        # Calculate instruction count (li may expand to 2 instructions)
        if instr.lower() == 'li':
            val = int(args[1], 0) if (args[1].startswith('0x') or args[1].lstrip('-').isdigit()) else 0
            count = 1 if -2048 <= val < 2048 else 2
        else:
            count = 1

        instructions.append((pc, instr, args, line))
        pc += count * 4

    # Pass 2: Machine code emission
    words = []
    current_pc = 0
    for pc_expected, instr, args, raw_line in instructions:
        machine_codes = assemble_line(instr, args, current_pc, labels)
        for mc in machine_codes:
            words.append(mc & 0xFFFFFFFF)
            current_pc += 4

    return words

if __name__ == '__main__':
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r') as f:
            src = f.read()
        res = assemble(src)
        for w in res:
            print(f"{w:08x}")
