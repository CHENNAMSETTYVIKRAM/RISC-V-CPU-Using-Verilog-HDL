`timescale 1ns/1ps

// ============================================================================
// Module: riscv_single_cycle
// Description: Full Single-Cycle RV32I Processor Core (CPI = 1.0).
//              Executes one instruction per clock cycle with full support for:
//              - Arithmetic / Logic / Shifts: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA,
//                                            ADDI, SLTI, SLTIU, XORI, ORI, ANDI,
//                                            SLLI, SRLI, SRAI, LUI, AUIPC
//              - Branches / Jumps:           BEQ, BNE, BLT, BGE, BLTU, BGEU, JAL, JALR
//              - Memory Operations:          LW, SW, LB, LH, LBU, LHU, SB, SH
// ============================================================================

module riscv_single_cycle #(
    parameter IMEM_DEPTH = 256,
    parameter DMEM_DEPTH = 256
)(
    input  wire        clk,
    input  wire        reset,

    // Debug & Inspection Interface
    output wire [31:0] debug_pc,
    output wire [31:0] debug_instr,
    output wire [31:0] debug_alu_result,
    output wire [31:0] debug_wb_data,
    output wire        debug_branch_taken,
    output wire [31:0] debug_reg1,
    output wire [31:0] debug_reg2,
    output wire [31:0] debug_reg3,
    output wire [31:0] debug_reg4,
    output wire [31:0] debug_reg5,
    output wire [31:0] debug_dmem0,
    output wire [31:0] debug_dmem1,
    output wire [31:0] debug_dmem9
);

    // ------------------------------------------------------------------------
    // Memories and Register File
    // ------------------------------------------------------------------------
    reg [31:0] pc;
    reg [31:0] instruction_mem [0:IMEM_DEPTH-1];
    reg [31:0] data_mem        [0:DMEM_DEPTH-1];
    reg [31:0] registers       [0:31];

    // ------------------------------------------------------------------------
    // Instruction Fetch & PC Logic
    // ------------------------------------------------------------------------
    wire [31:0] instr = instruction_mem[pc[9:2]];
    wire [31:0] pc_plus_4 = pc + 32'd4;

    // ------------------------------------------------------------------------
    // Instruction Decode & Control
    // ------------------------------------------------------------------------
    wire [6:0] opcode = instr[6:0];
    wire [4:0] rd     = instr[11:7];
    wire [2:0] funct3 = instr[14:12];
    wire [4:0] rs1    = instr[19:15];
    wire [4:0] rs2    = instr[24:20];
    wire [6:0] funct7 = instr[31:25];

    wire       reg_write, mem_read, mem_write, mem_to_reg;
    wire       alu_src, branch, jump, jalr, lui, auipc, m_valid;
    wire [3:0] alu_ctrl;

    riscv_control ctrl_unit (
        .opcode     (opcode),
        .funct3     (funct3),
        .funct7     (funct7),
        .reg_write  (reg_write),
        .mem_read   (mem_read),
        .mem_write  (mem_write),
        .mem_to_reg (mem_to_reg),
        .alu_src    (alu_src),
        .branch     (branch),
        .jump       (jump),
        .jalr       (jalr),
        .lui        (lui),
        .auipc      (auipc),
        .m_valid    (m_valid),
        .alu_ctrl   (alu_ctrl)
    );

    wire [31:0] imm;
    riscv_imm_gen imm_unit (
        .instr   (instr),
        .imm_out (imm)
    );

    // Register Read (x0 permanently 0)
    wire [31:0] rs1_data = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    wire [31:0] rs2_data = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

    // ------------------------------------------------------------------------
    // Execute Stage (ALU & Branch)
    // ------------------------------------------------------------------------
    wire [31:0] alu_in_a = auipc ? pc : rs1_data;
    wire [31:0] alu_in_b = alu_src ? imm : rs2_data;

    wire [31:0] alu_result;
    wire        zero, negative, carry, overflow;

    riscv_alu alu_inst (
        .a        (alu_in_a),
        .b        (alu_in_b),
        .alu_ctrl (alu_ctrl),
        .result   (alu_result),
        .zero     (zero),
        .negative (negative),
        .carry    (carry),
        .overflow (overflow)
    );

    // Branch Condition Evaluation
    reg branch_taken;
    always @(*) begin
        branch_taken = 1'b0;
        if (branch) begin
            case (funct3)
                3'b000: branch_taken = (rs1_data == rs2_data);                  // BEQ
                3'b001: branch_taken = (rs1_data != rs2_data);                  // BNE
                3'b100: branch_taken = ($signed(rs1_data) < $signed(rs2_data)); // BLT
                3'b101: branch_taken = ($signed(rs1_data) >= $signed(rs2_data));// BGE
                3'b110: branch_taken = (rs1_data < rs2_data);                   // BLTU
                3'b111: branch_taken = (rs1_data >= rs2_data);                  // BGEU
                default: branch_taken = 1'b0;
            endcase
        end
    end

    wire [31:0] branch_target = pc + imm;
    wire [31:0] jal_target    = pc + imm;
    wire [31:0] jalr_target   = (rs1_data + imm) & ~32'd1;

    wire [31:0] next_pc = branch_taken ? branch_target :
                          (jump ? (jalr ? jalr_target : jal_target) : pc_plus_4);

    // ------------------------------------------------------------------------
    // Memory Stage & Writeback Selection
    // ------------------------------------------------------------------------
    wire [7:0]  dmem_word_addr   = alu_result[9:2];
    wire [1:0]  dmem_byte_offset = alu_result[1:0];
    wire [31:0] cur_mem_word     = data_mem[dmem_word_addr];

    // Store formatting (SB, SH, SW)
    reg [31:0] next_mem_word;
    always @(*) begin
        next_mem_word = cur_mem_word;
        if (mem_write) begin
            case (funct3)
                3'b000: begin // SB
                    case (dmem_byte_offset)
                        2'b00: next_mem_word = {cur_mem_word[31:8],  rs2_data[7:0]};
                        2'b01: next_mem_word = {cur_mem_word[31:16], rs2_data[7:0], cur_mem_word[7:0]};
                        2'b10: next_mem_word = {cur_mem_word[31:24], rs2_data[7:0], cur_mem_word[15:0]};
                        2'b11: next_mem_word = {rs2_data[7:0],       cur_mem_word[23:0]};
                        default: next_mem_word = cur_mem_word;
                    endcase
                end
                3'b001: begin // SH
                    if (dmem_byte_offset[1] == 1'b0)
                        next_mem_word = {cur_mem_word[31:16], rs2_data[15:0]};
                    else
                        next_mem_word = {rs2_data[15:0], cur_mem_word[15:0]};
                end
                3'b010: begin // SW
                    next_mem_word = rs2_data;
                end
                default: next_mem_word = rs2_data;
            endcase
        end
    end

    // Load formatting (LB, LH, LW, LBU, LHU)
    reg [31:0] mem_read_formatted;
    always @(*) begin
        case (funct3)
            3'b000: begin // LB
                case (dmem_byte_offset)
                    2'b00: mem_read_formatted = {{24{cur_mem_word[7]}},  cur_mem_word[7:0]};
                    2'b01: mem_read_formatted = {{24{cur_mem_word[15]}}, cur_mem_word[15:8]};
                    2'b10: mem_read_formatted = {{24{cur_mem_word[23]}}, cur_mem_word[23:16]};
                    2'b11: mem_read_formatted = {{24{cur_mem_word[31]}}, cur_mem_word[31:24]};
                    default: mem_read_formatted = cur_mem_word;
                endcase
            end
            3'b001: begin // LH
                if (dmem_byte_offset[1] == 1'b0)
                    mem_read_formatted = {{16{cur_mem_word[15]}}, cur_mem_word[15:0]};
                else
                    mem_read_formatted = {{16{cur_mem_word[31]}}, cur_mem_word[31:16]};
            end
            3'b010: begin // LW
                mem_read_formatted = cur_mem_word;
            end
            3'b100: begin // LBU
                case (dmem_byte_offset)
                    2'b00: mem_read_formatted = {24'd0, cur_mem_word[7:0]};
                    2'b01: mem_read_formatted = {24'd0, cur_mem_word[15:8]};
                    2'b10: mem_read_formatted = {24'd0, cur_mem_word[23:16]};
                    2'b11: mem_read_formatted = {24'd0, cur_mem_word[31:24]};
                    default: mem_read_formatted = cur_mem_word;
                endcase
            end
            3'b101: begin // LHU
                if (dmem_byte_offset[1] == 1'b0)
                    mem_read_formatted = {16'd0, cur_mem_word[15:0]};
                else
                    mem_read_formatted = {16'd0, cur_mem_word[31:16]};
            end
            default: mem_read_formatted = cur_mem_word;
        endcase
    end

    wire [31:0] wb_data = jump ? pc_plus_4 :
                         (mem_to_reg ? mem_read_formatted : alu_result);

    // ------------------------------------------------------------------------
    // Clocked State Updates (posedge clk)
    // ------------------------------------------------------------------------
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            pc <= 32'd0;
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'd0;
            for (i = 0; i < DMEM_DEPTH; i = i + 1)
                data_mem[i] <= 32'd0;
        end else begin
            pc <= next_pc;

            if (mem_write) begin
                data_mem[dmem_word_addr] <= next_mem_word;
            end

            if (reg_write && (rd != 5'd0)) begin
                registers[rd] <= wb_data;
            end
            registers[0] <= 32'd0;
        end
    end

    // ------------------------------------------------------------------------
    // Debug Outputs
    // ------------------------------------------------------------------------
    assign debug_pc           = pc;
    assign debug_instr        = instr;
    assign debug_alu_result   = alu_result;
    assign debug_wb_data      = wb_data;
    assign debug_branch_taken = branch_taken;
    assign debug_reg1         = registers[1];
    assign debug_reg2         = registers[2];
    assign debug_reg3         = registers[3];
    assign debug_reg4         = registers[4];
    assign debug_reg5         = registers[5];
    assign debug_dmem0        = data_mem[0];
    assign debug_dmem1        = data_mem[1];
    assign debug_dmem9        = data_mem[9];

endmodule
