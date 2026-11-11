`timescale 1ns/1ps

// ============================================================================
// Module: riscv_hazard_unit
// Description: Hazard Detection & Data Forwarding Unit for 5-Stage RV32I CPU.
//              - Resolves RAW data hazards via EX/MEM and MEM/WB forwarding.
//              - Injects a 1-cycle bubble (stall) on load-use data hazards.
//              - Flushes speculative stages on branch taken and jumps.
// ============================================================================

module riscv_hazard_unit (
    // Inputs for Data Forwarding
    input  wire [4:0] id_ex_rs1,
    input  wire [4:0] id_ex_rs2,
    input  wire [4:0] ex_mem_rd,
    input  wire       ex_mem_reg_write,
    input  wire       ex_mem_mem_to_reg,
    input  wire [4:0] mem_wb_rd,
    input  wire       mem_wb_reg_write,

    // Inputs for Load-Use Hazard Stall
    input  wire [4:0] if_id_rs1,
    input  wire [4:0] if_id_rs2,
    input  wire [4:0] id_ex_rd,
    input  wire       id_ex_mem_read,
    input  wire       id_uses_rs1,
    input  wire       id_uses_rs2,

    // Inputs for Branch/Jump Flush
    input  wire       branch_taken,
    input  wire       jump_taken,

    // Outputs
    output reg  [1:0] forward_a,      // 00: RegFile, 10: EX/MEM, 01: MEM/WB
    output reg  [1:0] forward_b,      // 00: RegFile, 10: EX/MEM, 01: MEM/WB
    output wire       stall_pc,
    output wire       stall_if_id,
    output wire       flush_id_ex,
    output wire       flush_if_id
);

    // ------------------------------------------------------------------------
    // 1. Data Forwarding Logic (EX Stage Operand Forwarding)
    // ------------------------------------------------------------------------
    always @(*) begin
        // Forwarding for Operand A (rs1)
        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && !ex_mem_mem_to_reg &&
            (ex_mem_rd == id_ex_rs1)) begin
            forward_a = 2'b10; // Forward from EX/MEM stage
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) &&
                     (mem_wb_rd == id_ex_rs1)) begin
            forward_a = 2'b01; // Forward from MEM/WB stage
        end else begin
            forward_a = 2'b00; // No forwarding; read from register file
        end

        // Forwarding for Operand B (rs2)
        if (ex_mem_reg_write && (ex_mem_rd != 5'd0) && !ex_mem_mem_to_reg &&
            (ex_mem_rd == id_ex_rs2)) begin
            forward_b = 2'b10; // Forward from EX/MEM stage
        end else if (mem_wb_reg_write && (mem_wb_rd != 5'd0) &&
                     (mem_wb_rd == id_ex_rs2)) begin
            forward_b = 2'b01; // Forward from MEM/WB stage
        end else begin
            forward_b = 2'b00; // No forwarding; read from register file
        end
    end

    // ------------------------------------------------------------------------
    // 2. Load-Use Hazard Stall Logic
    // ------------------------------------------------------------------------
    wire load_use_hazard = id_ex_mem_read && (id_ex_rd != 5'd0) &&
                           ((id_uses_rs1 && (id_ex_rd == if_id_rs1)) ||
                            (id_uses_rs2 && (id_ex_rd == if_id_rs2)));

    // On load-use hazard: freeze PC and IF/ID, clear ID/EX controls (bubble)
    assign stall_pc     = load_use_hazard;
    assign stall_if_id  = load_use_hazard;

    // ------------------------------------------------------------------------
    // 3. Pipeline Flush Logic (Control Hazards)
    // ------------------------------------------------------------------------
    wire control_hazard = branch_taken || jump_taken;

    assign flush_if_id  = control_hazard;
    assign flush_id_ex  = control_hazard || load_use_hazard;

endmodule
