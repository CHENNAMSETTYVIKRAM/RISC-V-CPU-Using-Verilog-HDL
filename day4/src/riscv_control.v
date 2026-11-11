`timescale 1ns/1ps

// ============================================================================
// Module: riscv_control
// Description: Main Control Unit & ALU Decoder for RV32I and RV32M.
//              Generates datapath control signals based on instruction fields.
// ============================================================================

module riscv_control (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,

    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg        alu_src,
    output reg        branch,
    output reg        jump,
    output reg        jalr,
    output reg        lui,
    output reg        auipc,
    output reg        m_valid,
    output reg  [3:0] alu_ctrl
);

    localparam OPC_RTYPE  = 7'b0110011,
               OPC_ITYPE  = 7'b0010011,
               OPC_LOAD   = 7'b0000011,
               OPC_STORE  = 7'b0100011,
               OPC_BRANCH = 7'b1100011,
               OPC_LUI    = 7'b0110111,
               OPC_AUIPC  = 7'b0010111,
               OPC_JAL    = 7'b1101111,
               OPC_JALR   = 7'b1100111;

    localparam ALU_ADD  = 4'b0000,
               ALU_SUB  = 4'b1000,
               ALU_SLL  = 4'b0001,
               ALU_SLT  = 4'b0010,
               ALU_SLTU = 4'b0011,
               ALU_XOR  = 4'b0100,
               ALU_SRL  = 4'b0101,
               ALU_SRA  = 4'b1101,
               ALU_OR   = 4'b0110,
               ALU_AND  = 4'b0111,
               ALU_LUI  = 4'b1111;

    always @(*) begin
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        alu_src    = 1'b0;
        branch     = 1'b0;
        jump       = 1'b0;
        jalr       = 1'b0;
        lui        = 1'b0;
        auipc      = 1'b0;
        m_valid    = 1'b0;
        alu_ctrl   = ALU_ADD;

        case (opcode)
            OPC_RTYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;
                if (funct7 == 7'b0000001) begin
                    // RV32M Extension (MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU)
                    m_valid  = 1'b1;
                    alu_ctrl = ALU_ADD;
                end else begin
                    case (funct3)
                        3'b000: alu_ctrl = (funct7[5]) ? ALU_SUB : ALU_ADD; // ADD/SUB
                        3'b001: alu_ctrl = ALU_SLL;
                        3'b010: alu_ctrl = ALU_SLT;
                        3'b011: alu_ctrl = ALU_SLTU;
                        3'b100: alu_ctrl = ALU_XOR;
                        3'b101: alu_ctrl = (funct7[5]) ? ALU_SRA : ALU_SRL; // SRL/SRA
                        3'b110: alu_ctrl = ALU_OR;
                        3'b111: alu_ctrl = ALU_AND;
                        default: alu_ctrl = ALU_ADD;
                    endcase
                end
            end

            OPC_ITYPE: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                case (funct3)
                    3'b000: alu_ctrl = ALU_ADD; // ADDI
                    3'b001: alu_ctrl = ALU_SLL; // SLLI
                    3'b010: alu_ctrl = ALU_SLT; // SLTI
                    3'b011: alu_ctrl = ALU_SLTU;// SLTIU
                    3'b100: alu_ctrl = ALU_XOR; // XORI
                    3'b101: alu_ctrl = (funct7[5]) ? ALU_SRA : ALU_SRL; // SRLI/SRAI
                    3'b110: alu_ctrl = ALU_OR;  // ORI
                    3'b111: alu_ctrl = ALU_AND; // ANDI
                    default: alu_ctrl = ALU_ADD;
                endcase
            end

            OPC_LOAD: begin
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                alu_src    = 1'b1;
                alu_ctrl   = ALU_ADD; // Address calculation
            end

            OPC_STORE: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;
                alu_ctrl  = ALU_ADD; // Address calculation
            end

            OPC_BRANCH: begin
                branch   = 1'b1;
                alu_src  = 1'b0;
                alu_ctrl = ALU_SUB; // Comparison
            end

            OPC_LUI: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                lui       = 1'b1;
                alu_ctrl  = ALU_LUI;
            end

            OPC_AUIPC: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                auipc     = 1'b1;
                alu_ctrl  = ALU_ADD;
            end

            OPC_JAL: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                alu_ctrl  = ALU_ADD;
            end

            OPC_JALR: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                jalr      = 1'b1;
                alu_src   = 1'b1;
                alu_ctrl  = ALU_ADD;
            end

            default: ; // NOP
        endcase
    end

endmodule
