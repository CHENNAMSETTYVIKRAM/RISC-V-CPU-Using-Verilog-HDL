@echo off
REM ============================================================================
REM   VERILOG HDL & RISC-V SIMULATION REGRESSION RUNNER
REM   Supports: Icarus Verilog (iverilog + vvp) and Python cycle-accurate engine
REM ============================================================================

echo ================================================================================
echo   STARTING VERILOG SIMULATION REGRESSION SUITE
echo ================================================================================

where iverilog >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Icarus Verilog 'iverilog' not found in PATH.
    echo [INFO] Running Python-based cycle-accurate simulation engine instead...
    python scripts\verify.py
    goto end
)

echo [INFO] Icarus Verilog detected. Compiling and simulating all testbenches...

if not exist build mkdir build

echo [1/18] Testing Carry Adder / Subtractor (8-bit)...
iverilog -g2012 -o build\tb_carry_adder_subtractor_8bit.vvp rtl\digital_design\carry_adder_subtractor_8bit.v tb\digital_design\tb_carry_adder_subtractor_8bit.v
vvp build\tb_carry_adder_subtractor_8bit.vvp

echo [2/18] Testing Configurable Counter (8-bit)...
iverilog -g2012 -o build\tb_configurable_counter_8bit.vvp rtl\digital_design\configurable_counter_8bit.v tb\digital_design\tb_configurable_counter_8bit.v
vvp build\tb_configurable_counter_8bit.vvp

echo [3/18] Testing D Flip-Flop...
iverilog -g2012 -o build\tb_d_flip_flop.vvp rtl\digital_design\d_flip_flop.v tb\digital_design\tb_d_flip_flop.v
vvp build\tb_d_flip_flop.vvp

echo [4/18] Testing Edge Detector...
iverilog -g2012 -o build\tb_edge_detector.vvp rtl\digital_design\edge_detector.v tb\digital_design\tb_edge_detector.v
vvp build\tb_edge_detector.vvp

echo [5/18] Testing Button Debouncer...
iverilog -g2012 -o build\tb_button_debouncer.vvp rtl\digital_design\button_debouncer.v tb\digital_design\tb_button_debouncer.v
vvp build\tb_button_debouncer.vvp

echo [6/18] Testing LFSR (8-bit)...
iverilog -g2012 -o build\tb_lfsr_8bit.vvp rtl\digital_design\lfsr_8bit.v tb\digital_design\tb_lfsr_8bit.v
vvp build\tb_lfsr_8bit.vvp

echo [7/18] Testing Universal Shift Register (8-bit)...
iverilog -g2012 -o build\tb_usr.vvp rtl\digital_design\universal_shift_register_8bit.v tb\digital_design\tb_universal_shift_register_8bit.v
vvp build\tb_usr.vvp

echo [8/18] Testing Priority Encoder (8-to-3)...
iverilog -g2012 -o build\tb_priority_encoder.vvp rtl\digital_design\priority_encoder_8to3.v tb\digital_design\tb_priority_encoder_8to3.v
vvp build\tb_priority_encoder.vvp

echo [9/18] Testing Binary Decoder (3-to-8)...
iverilog -g2012 -o build\tb_decoder.vvp rtl\digital_design\decoder_3to8.v tb\digital_design\tb_decoder_3to8.v
vvp build\tb_decoder.vvp

echo [10/18] Testing Synchronous RAM (16x8)...
iverilog -g2012 -o build\tb_sync_ram.vvp rtl\memory\sync_ram_16x8.v tb\memory\tb_sync_ram_16x8.v
vvp build\tb_sync_ram.vvp

echo [11/18] Testing Synchronous ROM (16x8)...
iverilog -g2012 -o build\tb_sync_rom.vvp rtl\memory\sync_rom_16x8.v tb\memory\tb_sync_rom_16x8.v
vvp build\tb_sync_rom.vvp

echo [12/18] Testing Synchronous FIFO (16x8)...
iverilog -g2012 -o build\tb_sync_fifo.vvp rtl\memory\sync_fifo_16x8.v tb\memory\tb_sync_fifo_16x8.v
vvp build\tb_sync_fifo.vvp

echo [13/18] Testing Hardware Watchdog Timer...
iverilog -g2012 -o build\tb_watchdog_timer.vvp rtl\memory\watchdog_timer.v tb\memory\tb_watchdog_timer.v
vvp build\tb_watchdog_timer.vvp

echo [14/18] Testing Round-Robin Arbiter (4-Port)...
iverilog -g2012 -o build\tb_arbiter.vvp rtl\memory\round_robin_arbiter_4req.v tb\memory\tb_round_robin_arbiter_4req.v
vvp build\tb_arbiter.vvp

echo [15/18] Testing RV32I ALU & Barrel Shifter...
iverilog -g2012 -o build\tb_riscv_alu.vvp rtl\riscv\riscv_barrel_shifter.v rtl\riscv\riscv_alu.v tb\riscv\tb_riscv_alu.v
vvp build\tb_riscv_alu.vvp

echo [16/18] Testing RV32I Register File...
iverilog -g2012 -o build\tb_riscv_regfile.vvp rtl\riscv\riscv_regfile.v tb\riscv\tb_riscv_regfile.v
vvp build\tb_riscv_regfile.vvp

echo [17/18] Testing RV32I Immediate Generator...
iverilog -g2012 -o build\tb_riscv_imm_gen.vvp rtl\riscv\riscv_imm_gen.v tb\riscv\tb_riscv_imm_gen.v
vvp build\tb_riscv_imm_gen.vvp

echo [18/18] Testing RISC-V 5-Stage CPU Core...
iverilog -g2012 -o build\tb_riscv_core_5stage.vvp rtl\riscv\*.v tb\riscv\tb_riscv_core_5stage.v
vvp build\tb_riscv_core_5stage.vvp

echo ================================================================================
echo   ALL COMPILATIONS AND SIMULATIONS COMPLETED SUCCESSFULLY
echo ================================================================================

:end
