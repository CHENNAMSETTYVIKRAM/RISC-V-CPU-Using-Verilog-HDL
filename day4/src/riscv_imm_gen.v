`timescale 1ns/1ps

// ============================================================================
// Module: riscv_imm_gen
// Description: RV32I Sign-Extended Immediate Generator.
//              Decodes I-type, S-type, B-type, U-type, and J-type immediates.
// ============================================================================

module riscv_imm_gen (
    input  wire [31:0] instr,
    output reg  [31:0] imm_out
);

    wire [6:0] opcode = instr[6:0];

    // Standard RV32I Opcode categories:
    localparam OPC_LOAD   = 7'b0000011,
               OPC_IMM    = 7'b0010011,
               OPC_STORE  = 7'b0100011,
               OPC_BRANCH = 7'b1100011,
               OPC_LUI    = 7'b0110111,
               OPC_AUIPC  = 7'b0010111,
               OPC_JAL    = 7'b1101111,
               OPC_JALR   = 7'b1100111;

    always @(*) begin
        case (opcode)
            OPC_IMM, OPC_LOAD, OPC_JALR: begin
                // I-type immediate
                imm_out = {{20{instr[31]}}, instr[31:20]};
            end

            OPC_STORE: begin
                // S-type immediate
                imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            end

            OPC_BRANCH: begin
                // B-type immediate (13-bit signed, bit 0 is 0)
                imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            end

            OPC_LUI, OPC_AUIPC: begin
                // U-type immediate (Upper 20 bits)
                imm_out = {instr[31:12], 12'b0};
            end

            OPC_JAL: begin
                // J-type immediate (21-bit signed, bit 0 is 0)
                imm_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            end

            default: begin
                imm_out = 32'd0;
            end
        endcase
    end

endmodule
