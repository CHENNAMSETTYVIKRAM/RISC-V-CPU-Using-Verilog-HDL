`timescale 1ns/1ps

// ============================================================================
// Module: riscv_core_2stage
// Description: Educational 2-Stage RISC-V RV32I Core.
//              Stage 1: Instruction Fetch (IF)
//              Stage 2: Instruction Decode, Execute, Memory, & Writeback (EX)
//              Supported Instructions: ADD, SUB, AND, OR, XOR, SLT, SLTU,
//                                      ADDI, ANDI, ORI, XORI, SLTI,
//                                      LW, SW, BEQ, BNE, JAL
// ============================================================================

module riscv_core_2stage #(
    parameter IMEM_DEPTH = 64,
    parameter DMEM_DEPTH = 64
)(
    input  wire        clk,
    input  wire        reset,
    output wire [31:0] debug_pc,
    output wire [31:0] debug_reg3   // For observing x3 in verification
);

    reg [31:0] pc;
    reg [31:0] instruction_mem [0:IMEM_DEPTH-1];
    reg [31:0] data_mem        [0:DMEM_DEPTH-1];
    reg [31:0] registers       [0:31];

    // IF/EX Pipeline Register
    reg [31:0] if_id_instruction;
    reg [31:0] if_id_pc;

    wire [6:0] opcode = if_id_instruction[6:0];
    wire [4:0] rd     = if_id_instruction[11:7];
    wire [2:0] funct3 = if_id_instruction[14:12];
    wire [4:0] rs1    = if_id_instruction[19:15];
    wire [4:0] rs2    = if_id_instruction[24:20];
    wire [6:0] funct7 = if_id_instruction[31:25];

    // Read registers with x0 hardwired to 0
    wire [31:0] read_data1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    wire [31:0] read_data2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

    // Immediates
    wire [31:0] imm_i = {{20{if_id_instruction[31]}}, if_id_instruction[31:20]};
    wire [31:0] imm_s = {{20{if_id_instruction[31]}}, if_id_instruction[31:25], if_id_instruction[11:7]};
    wire [31:0] imm_b = {{19{if_id_instruction[31]}}, if_id_instruction[31], if_id_instruction[7],
                         if_id_instruction[30:25], if_id_instruction[11:8], 1'b0};
    wire [31:0] imm_j = {{11{if_id_instruction[31]}}, if_id_instruction[31], if_id_instruction[19:12],
                         if_id_instruction[20], if_id_instruction[30:21], 1'b0};

    reg [31:0] alu_result;
    reg [31:0] write_data;
    reg        reg_write;
    reg        mem_write;
    reg        mem_read;
    reg        branch_taken;
    reg [31:0] target_pc;

    // Combinational Execution
    always @(*) begin
        alu_result   = 32'd0;
        write_data   = 32'd0;
        reg_write    = 1'b0;
        mem_write    = 1'b0;
        mem_read     = 1'b0;
        branch_taken = 1'b0;
        target_pc    = if_id_pc + 32'd4;

        case (opcode)
            7'b0110011: begin // R-type
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_result = funct7[5] ? (read_data1 - read_data2) : (read_data1 + read_data2);
                    3'b010: alu_result = ($signed(read_data1) < $signed(read_data2)) ? 32'd1 : 32'd0;
                    3'b011: alu_result = (read_data1 < read_data2) ? 32'd1 : 32'd0;
                    3'b100: alu_result = read_data1 ^ read_data2;
                    3'b110: alu_result = read_data1 | read_data2;
                    3'b111: alu_result = read_data1 & read_data2;
                    default: alu_result = 32'd0;
                endcase
                write_data = alu_result;
            end

            7'b0010011: begin // I-type arithmetic
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_result = read_data1 + imm_i;
                    3'b010: alu_result = ($signed(read_data1) < $signed(imm_i)) ? 32'd1 : 32'd0;
                    3'b100: alu_result = read_data1 ^ imm_i;
                    3'b110: alu_result = read_data1 | imm_i;
                    3'b111: alu_result = read_data1 & imm_i;
                    default: alu_result = read_data1 + imm_i;
                endcase
                write_data = alu_result;
            end

            7'b0000011: begin // LW
                if (funct3 == 3'b010) begin
                    alu_result = read_data1 + imm_i;
                    mem_read   = 1'b1;
                    reg_write  = 1'b1;
                    write_data = data_mem[alu_result[7:2]];
                end
            end

            7'b0100011: begin // SW
                if (funct3 == 3'b010) begin
                    alu_result = read_data1 + imm_s;
                    mem_write  = 1'b1;
                end
            end

            7'b1100011: begin // Branch (BEQ, BNE)
                case (funct3)
                    3'b000: branch_taken = (read_data1 == read_data2); // BEQ
                    3'b001: branch_taken = (read_data1 != read_data2); // BNE
                    default: branch_taken = 1'b0;
                endcase
                target_pc = if_id_pc + imm_b;
            end

            7'b1101111: begin // JAL
                reg_write    = 1'b1;
                write_data   = if_id_pc + 32'd4;
                branch_taken = 1'b1;
                target_pc    = if_id_pc + imm_j;
            end

            default: ;
        endcase
    end

    // Sequential Clock Updates
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            pc                <= 32'd0;
            if_id_instruction <= 32'h00000013; // NOP (ADDI x0, x0, 0)
            if_id_pc          <= 32'd0;
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'd0;
            for (i = 0; i < DMEM_DEPTH; i = i + 1)
                data_mem[i] <= 32'd0;
        end else begin
            // Memory write
            if (mem_write)
                data_mem[alu_result[7:2]] <= read_data2;

            // Register write
            if (reg_write && (rd != 5'd0))
                registers[rd] <= write_data;

            registers[0] <= 32'd0;

            // Fetch / Branch
            if (branch_taken) begin
                pc                <= target_pc;
                if_id_instruction <= 32'h00000013; // Flush with NOP
                if_id_pc          <= target_pc;
            end else begin
                if_id_instruction <= instruction_mem[pc[7:2]];
                if_id_pc          <= pc;
                pc                <= pc + 32'd4;
            end
        end
    end

    assign debug_pc   = pc;
    assign debug_reg3 = registers[3];

endmodule
