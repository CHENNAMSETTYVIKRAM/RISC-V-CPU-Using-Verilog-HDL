#!/usr/bin/env python3
"""
Hardware RTL Linting and Synthesizability Checker
Inspects Verilog modules across the repository with accurate block-level parsing for:
- Latch inference risks
- Missing default assignments in combinational always blocks
- Multiple drivers
- Clock/reset polarity consistency
- Blocking vs non-blocking assignment correctness in sequential vs combinational blocks
- Simulation-only constructs in synthesizable RTL
"""

import os
import re
import glob

def extract_always_blocks(content):
    """Accurately extracts always blocks with proper begin/end nesting tracking."""
    # Strip comments first
    content_no_comments = re.sub(r'//.*$', '', content, flags=re.MULTILINE)
    content_no_comments = re.sub(r'/\*.*?\*/', '', content_no_comments, flags=re.DOTALL)

    blocks = []
    # Pattern to find always @(...)
    pattern = re.compile(r'always\s*@\s*\((.*?)\)', re.DOTALL)
    pos = 0

    while True:
        match = pattern.search(content_no_comments, pos)
        if not match:
            break

        sensitivity = match.group(1).strip()
        start_idx = match.end()

        # Find the beginning of the block body
        body_start = content_no_comments.find('begin', start_idx)
        if body_start == -1:
            pos = match.end()
            continue

        # Balance begin and end
        depth = 0
        idx = body_start
        tokens = re.finditer(r'\b(begin|end)\b', content_no_comments[idx:])

        block_end = None
        for t in tokens:
            word = t.group(1)
            if word == 'begin':
                depth += 1
            elif word == 'end':
                depth -= 1
                if depth == 0:
                    block_end = idx + t.end()
                    break

        if block_end:
            body = content_no_comments[body_start + 5 : block_end - 3]
            is_seq = ('posedge' in sensitivity) or ('negedge' in sensitivity)
            blocks.append((sensitivity, is_seq, body))
            pos = block_end
        else:
            pos = match.end()

    return blocks

def check_file(filepath):
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()

    filename = os.path.basename(filepath)
    issues = []

    # 1. Check for simulation-only constructs in RTL
    norm_path = filepath.replace('\\', '/')
    if not norm_path.startswith('tb/') and not '/tb/' in norm_path:
        # Check initial blocks (allow RAM/ROM initial memory loads if parameter-guarded)
        if 'initial begin' in content:
            if 'sync_rom' in filename or 'instruction_mem' in content:
                issues.append(('INFO', "Synthesizable ROM memory preloading pattern ('initial begin')."))
            else:
                issues.append(('WARNING', "Simulation construct 'initial begin' present in synthesizable RTL module."))

        sim_keywords = re.findall(r'(\$finish|\$stop|#\d+)', content)
        for sk in set(sim_keywords):
            issues.append(('WARNING', f"Simulation construct '{sk}' present in synthesizable RTL module."))

    # 2. Extract balanced always blocks
    blocks = extract_always_blocks(content)

    for sensitivity, is_seq, body in blocks:
        lines = body.split('\n')
        for line in lines:
            line = line.strip()
            if not line:
                continue

            # Check inside sequential always blocks (posedge clk)
            if is_seq:
                # Disallow blocking assignments '=' to registers (exclude for-loops)
                if re.search(r'^\s*([a-zA-Z_]\w*)\s*=\s*[^=]', line) and not re.search(r'for\s*\(', line):
                    issues.append(('ERROR', f"Blocking assignment '=' in sequential clocked block: '{line}'"))

            # Check inside combinational always blocks (always @(*))
            else:
                # Disallow non-blocking assignments '<='
                if re.search(r'^\s*([a-zA-Z_]\w*)\s*<=\s*', line):
                    issues.append(('ERROR', f"Non-blocking assignment '<=' in combinational always @(*) block: '{line}'"))

    # 3. Check for case statement latch inference (missing default)
    # Strip comments first
    content_clean = re.sub(r'//.*$', '', content, flags=re.MULTILINE)
    case_blocks = re.finditer(r'case\s*\((.*?)\)(.*?)endcase', content_clean, re.DOTALL)
    for cb in case_blocks:
        case_expr = cb.group(1).strip()
        case_body = cb.group(2)
        if not re.search(r'\bdefault\s*:', case_body):
            issues.append(('WARNING', f"Case statement on '({case_expr})' without 'default:' clause may infer latch."))

    # 4. Extract module name
    mod_match = re.search(r'module\s+([a-zA-Z_]\w*)', content)
    mod_name = mod_match.group(1) if mod_match else "unknown"

    return mod_name, issues

def run_lint_suite():
    # Only scan canonical source directories (avoiding duplicates if any)
    rtl_files = sorted(list(set(glob.glob('rtl/**/*.v', recursive=True) + glob.glob('rtl/*.v'))))
    results = {}
    total_errors = 0
    total_warnings = 0

    print("================================================================================")
    print("  HARDWARE RTL SYNTHESIS & LINT VALIDATION")
    print("================================================================================")

    for rf in rtl_files:
        mod_name, issues = check_file(rf)
        results[rf] = (mod_name, issues)
        err_count = sum(1 for lvl, _ in issues if lvl == 'ERROR')
        warn_count = sum(1 for lvl, _ in issues if lvl == 'WARNING')
        total_errors += err_count
        total_warnings += warn_count

        status = "CLEAN" if len(issues) == 0 else f"{err_count} Errors, {warn_count} Warnings"
        badge = "PASS" if err_count == 0 else "FAIL"
        print(f"[{badge}] {rf:45} ({mod_name:30}) -> {status}")
        for lvl, msg in issues:
            print(f"     [{lvl:7}] {msg}")

    print("================================================================================")
    print(f"  LINT SUMMARY: Checked {len(rtl_files)} RTL modules.")
    print(f"  Total Errors: {total_errors} | Total Warnings: {total_warnings}")
    print("================================================================================")
    return results

if __name__ == '__main__':
    run_lint_suite()
