`timescale 1ns/1ps

// ============================================================================
// Module: riscv_core_5stage
// Description: Production-Grade 5-Stage Pipelined RV32I + RV32M Processor.
//              Pipeline Stages: IF -> ID -> EX -> MEM -> WB
//              Features:
//              - Comprehensive RV32I base integer instruction set support:
//                R-type: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
//                I-type: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI,
//                        LB, LH, LW, LBU, LHU, JALR
//                S-type: SB, SH, SW
//                B-type: BEQ, BNE, BLT, BGE, BLTU, BGEU
//                U-type: LUI, AUIPC
//                J-type: JAL
//              - Complete RV32M standard extension support:
//                MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU
//              - Hazard Detection Unit with 1-cycle load-use hazard stall.
//              - Forwarding Unit resolving RAW hazards from EX/MEM and MEM/WB.
//              - Accurate speculative branch/jump resolution with pipeline flushing.
//              - Byte and halfword memory formatting with byte offsets & sign extension.
//              - Internal WB-to-ID register bypass for same-cycle read/write.
//              - Register x0 hardwired to zero.
//              - Synchronous active-high reset for deterministic behavior.
// ============================================================================

module riscv_core_5stage #(
    parameter IMEM_DEPTH = 256,
    parameter DMEM_DEPTH = 256
)(
    input  wire        clk,
    input  wire        reset,

    // Debug & Inspection Interface
    output wire [31:0] debug_pc,
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
    // Pipeline Registers
    // ------------------------------------------------------------------------

    // 1. IF/ID Pipeline Register
    reg [31:0] if_id_pc;
    reg [31:0] if_id_instr;

    // 2. ID/EX Pipeline Register
    reg [31:0] id_ex_pc;
    reg [31:0] id_ex_rs1_val;
    reg [31:0] id_ex_rs2_val;
    reg [31:0] id_ex_imm;
    reg [4:0]  id_ex_rs1;
    reg [4:0]  id_ex_rs2;
    reg [4:0]  id_ex_rd;
    reg [2:0]  id_ex_funct3;
    reg [6:0]  id_ex_funct7;
    reg [6:0]  id_ex_opcode;
    reg [3:0]  id_ex_alu_ctrl;
    reg        id_ex_reg_write;
    reg        id_ex_mem_read;
    reg        id_ex_mem_write;
    reg        id_ex_mem_to_reg;
    reg        id_ex_alu_src;
    reg        id_ex_branch;
    reg        id_ex_jump;
    reg        id_ex_jalr;
    reg        id_ex_lui;
    reg        id_ex_auipc;
    reg        id_ex_m_valid;

    // 3. EX/MEM Pipeline Register
    reg [31:0] ex_mem_alu_result;
    reg [31:0] ex_mem_store_data;
    reg [31:0] ex_mem_pc_plus_4;
    reg [4:0]  ex_mem_rd;
    reg [2:0]  ex_mem_funct3;
    reg        ex_mem_reg_write;
    reg        ex_mem_mem_read;
    reg        ex_mem_mem_write;
    reg        ex_mem_mem_to_reg;
    reg        ex_mem_jump;

    // 4. MEM/WB Pipeline Register
    reg [31:0] mem_wb_mem_data;
    reg [31:0] mem_wb_alu_result;
    reg [31:0] mem_wb_pc_plus_4;
    reg [4:0]  mem_wb_rd;
    reg        mem_wb_reg_write;
    reg        mem_wb_mem_to_reg;
    reg        mem_wb_jump;

    // ------------------------------------------------------------------------
    // STAGE 1: Instruction Fetch (IF)
    // ------------------------------------------------------------------------
    wire [31:0] if_instr = instruction_mem[pc[9:2]];
    wire [31:0] if_pc_plus_4 = pc + 32'd4;

    // ------------------------------------------------------------------------
    // STAGE 2: Instruction Decode & Register Read (ID)
    // ------------------------------------------------------------------------
    wire [6:0] id_opcode = if_id_instr[6:0];
    wire [4:0] id_rd     = if_id_instr[11:7];
    wire [2:0] id_funct3 = if_id_instr[14:12];
    wire [4:0] id_rs1    = if_id_instr[19:15];
    wire [4:0] id_rs2    = if_id_instr[24:20];
    wire [6:0] id_funct7 = if_id_instr[31:25];

    // Control Unit instance
    wire       dec_reg_write, dec_mem_read, dec_mem_write, dec_mem_to_reg;
    wire       dec_alu_src, dec_branch, dec_jump, dec_jalr, dec_lui, dec_auipc, dec_m_valid;
    wire [3:0] dec_alu_ctrl;

    riscv_control ctrl_unit (
        .opcode     (id_opcode),
        .funct3     (id_funct3),
        .funct7     (id_funct7),
        .reg_write  (dec_reg_write),
        .mem_read   (dec_mem_read),
        .mem_write  (dec_mem_write),
        .mem_to_reg (dec_mem_to_reg),
        .alu_src    (dec_alu_src),
        .branch     (dec_branch),
        .jump       (dec_jump),
        .jalr       (dec_jalr),
        .lui        (dec_lui),
        .auipc      (dec_auipc),
        .m_valid    (dec_m_valid),
        .alu_ctrl   (dec_alu_ctrl)
    );

    // Immediate Generator instance
    wire [31:0] dec_imm;
    riscv_imm_gen imm_unit (
        .instr  (if_id_instr),
        .imm_out(dec_imm)
    );

    // Writeback data computation
    wire [31:0] wb_write_data = mem_wb_jump ? mem_wb_pc_plus_4 :
                               (mem_wb_mem_to_reg ? mem_wb_mem_data : mem_wb_alu_result);

    // Register read with WB-stage forwarding bypass
    wire [31:0] id_rs1_data = (id_rs1 == 5'd0) ? 32'd0 :
                              ((mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_rs1)) ?
                               wb_write_data : registers[id_rs1]);

    wire [31:0] id_rs2_data = (id_rs2 == 5'd0) ? 32'd0 :
                              ((mem_wb_reg_write && (mem_wb_rd != 5'd0) && (mem_wb_rd == id_rs2)) ?
                               wb_write_data : registers[id_rs2]);

    // Identification of whether instruction uses rs1/rs2
    wire id_uses_rs1 = (id_opcode == 7'b0110011) || (id_opcode == 7'b0010011) ||
                       (id_opcode == 7'b0000011) || (id_opcode == 7'b0100011) ||
                       (id_opcode == 7'b1100011) || (id_opcode == 7'b1100111);

    wire id_uses_rs2 = (id_opcode == 7'b0110011) || (id_opcode == 7'b0100011) ||
                       (id_opcode == 7'b1100011);

    // ------------------------------------------------------------------------
    // STAGE 3: Execute (EX)
    // ------------------------------------------------------------------------
    // Forwarding Multiplexers
    wire [1:0] forward_a, forward_b;
    reg  [31:0] ex_fwd_a, ex_fwd_b;

    always @(*) begin
        case (forward_a)
            2'b10:   ex_fwd_a = ex_mem_alu_result;
            2'b01:   ex_fwd_a = wb_write_data;
            default: ex_fwd_a = id_ex_rs1_val;
        endcase

        case (forward_b)
            2'b10:   ex_fwd_b = ex_mem_alu_result;
            2'b01:   ex_fwd_b = wb_write_data;
            default: ex_fwd_b = id_ex_rs2_val;
        endcase
    end

    // ALU Input selection
    wire [31:0] alu_in_a = id_ex_auipc ? id_ex_pc : ex_fwd_a;
    wire [31:0] alu_in_b = id_ex_alu_src ? id_ex_imm : ex_fwd_b;

    // ALU instance
    wire [31:0] ex_alu_result;
    wire        ex_zero, ex_negative, ex_carry, ex_overflow;

    riscv_alu alu_inst (
        .a        (alu_in_a),
        .b        (alu_in_b),
        .alu_ctrl (id_ex_alu_ctrl),
        .result   (ex_alu_result),
        .zero     (ex_zero),
        .negative (ex_negative),
        .carry    (ex_carry),
        .overflow (ex_overflow)
    );

    // RV32M Extension instance
    wire [31:0] ex_m_result;
    riscv_m_extension m_ext_inst (
        .a      (alu_in_a),
        .b      (ex_fwd_b),
        .funct3 (id_ex_funct3),
        .result (ex_m_result)
    );

    wire [31:0] ex_final_result = id_ex_m_valid ? ex_m_result : ex_alu_result;

    // Branch Condition Evaluation
    reg ex_branch_taken;
    always @(*) begin
        ex_branch_taken = 1'b0;
        if (id_ex_branch) begin
            case (id_ex_funct3)
                3'b000: ex_branch_taken = (ex_fwd_a == ex_fwd_b);                          // BEQ
                3'b001: ex_branch_taken = (ex_fwd_a != ex_fwd_b);                          // BNE
                3'b100: ex_branch_taken = ($signed(ex_fwd_a) < $signed(ex_fwd_b));        // BLT
                3'b101: ex_branch_taken = ($signed(ex_fwd_a) >= $signed(ex_fwd_b));       // BGE
                3'b110: ex_branch_taken = (ex_fwd_a < ex_fwd_b);                           // BLTU
                3'b111: ex_branch_taken = (ex_fwd_a >= ex_fwd_b);                          // BGEU
                default: ex_branch_taken = 1'b0;
            endcase
        end
    end

    // Target PC calculations
    wire [31:0] ex_branch_target = id_ex_pc + id_ex_imm;
    wire [31:0] ex_jal_target    = id_ex_pc + id_ex_imm;
    wire [31:0] ex_jalr_target   = (ex_fwd_a + id_ex_imm) & ~32'd1;

    wire ex_jump_taken = id_ex_jump;
    wire [31:0] ex_target_pc = id_ex_jalr ? ex_jalr_target :
                               (id_ex_jump ? ex_jal_target : ex_branch_target);

    // ------------------------------------------------------------------------
    // STAGE 4: Memory Access (MEM)
    // ------------------------------------------------------------------------
    wire [7:0]  dmem_word_addr   = ex_mem_alu_result[9:2];
    wire [1:0]  dmem_byte_offset = ex_mem_alu_result[1:0];
    wire [31:0] cur_mem_word     = data_mem[dmem_word_addr];

    // Sub-word store formatting (SB, SH, SW)
    reg [31:0] next_mem_word;
    always @(*) begin
        next_mem_word = cur_mem_word;
        if (ex_mem_mem_write) begin
            case (ex_mem_funct3)
                3'b000: begin // SB
                    case (dmem_byte_offset)
                        2'b00: next_mem_word = {cur_mem_word[31:8],  ex_mem_store_data[7:0]};
                        2'b01: next_mem_word = {cur_mem_word[31:16], ex_mem_store_data[7:0], cur_mem_word[7:0]};
                        2'b10: next_mem_word = {cur_mem_word[31:24], ex_mem_store_data[7:0], cur_mem_word[15:0]};
                        2'b11: next_mem_word = {ex_mem_store_data[7:0], cur_mem_word[23:0]};
                        default: next_mem_word = cur_mem_word;
                    endcase
                end
                3'b001: begin // SH
                    if (dmem_byte_offset[1] == 1'b0)
                        next_mem_word = {cur_mem_word[31:16], ex_mem_store_data[15:0]};
                    else
                        next_mem_word = {ex_mem_store_data[15:0], cur_mem_word[15:0]};
                end
                3'b010: begin // SW
                    next_mem_word = ex_mem_store_data;
                end
                default: next_mem_word = ex_mem_store_data;
            endcase
        end
    end

    // Sub-word load formatting & sign extension (LB, LH, LW, LBU, LHU)
    reg [31:0] mem_read_formatted;
    always @(*) begin
        case (ex_mem_funct3)
            3'b000: begin // LB: sign-extended byte
                case (dmem_byte_offset)
                    2'b00: mem_read_formatted = {{24{cur_mem_word[7]}},  cur_mem_word[7:0]};
                    2'b01: mem_read_formatted = {{24{cur_mem_word[15]}}, cur_mem_word[15:8]};
                    2'b10: mem_read_formatted = {{24{cur_mem_word[23]}}, cur_mem_word[23:16]};
                    2'b11: mem_read_formatted = {{24{cur_mem_word[31]}}, cur_mem_word[31:24]};
                    default: mem_read_formatted = cur_mem_word;
                endcase
            end
            3'b001: begin // LH: sign-extended halfword
                if (dmem_byte_offset[1] == 1'b0)
                    mem_read_formatted = {{16{cur_mem_word[15]}}, cur_mem_word[15:0]};
                else
                    mem_read_formatted = {{16{cur_mem_word[31]}}, cur_mem_word[31:16]};
            end
            3'b010: begin // LW: full 32-bit word
                mem_read_formatted = cur_mem_word;
            end
            3'b100: begin // LBU: zero-extended byte
                case (dmem_byte_offset)
                    2'b00: mem_read_formatted = {24'd0, cur_mem_word[7:0]};
                    2'b01: mem_read_formatted = {24'd0, cur_mem_word[15:8]};
                    2'b10: mem_read_formatted = {24'd0, cur_mem_word[23:16]};
                    2'b11: mem_read_formatted = {24'd0, cur_mem_word[31:24]};
                    default: mem_read_formatted = cur_mem_word;
                endcase
            end
            3'b101: begin // LHU: zero-extended halfword
                if (dmem_byte_offset[1] == 1'b0)
                    mem_read_formatted = {16'd0, cur_mem_word[15:0]};
                else
                    mem_read_formatted = {16'd0, cur_mem_word[31:16]};
            end
            default: mem_read_formatted = cur_mem_word;
        endcase
    end

    // ------------------------------------------------------------------------
    // Hazard Detection & Forwarding Unit
    // ------------------------------------------------------------------------
    wire stall_pc, stall_if_id, flush_id_ex, flush_if_id;

    riscv_hazard_unit hazard_unit (
        .id_ex_rs1        (id_ex_rs1),
        .id_ex_rs2        (id_ex_rs2),
        .ex_mem_rd        (ex_mem_rd),
        .ex_mem_reg_write (ex_mem_reg_write),
        .ex_mem_mem_to_reg(ex_mem_mem_to_reg),
        .mem_wb_rd        (mem_wb_rd),
        .mem_wb_reg_write (mem_wb_reg_write),

        .if_id_rs1        (id_rs1),
        .if_id_rs2        (id_rs2),
        .id_ex_rd         (id_ex_rd),
        .id_ex_mem_read   (id_ex_mem_read),
        .id_uses_rs1      (id_uses_rs1),
        .id_uses_rs2      (id_uses_rs2),

        .branch_taken     (ex_branch_taken),
        .jump_taken       (ex_jump_taken),

        .forward_a        (forward_a),
        .forward_b        (forward_b),
        .stall_pc         (stall_pc),
        .stall_if_id      (stall_if_id),
        .flush_id_ex      (flush_id_ex),
        .flush_if_id      (flush_if_id)
    );

    // ------------------------------------------------------------------------
    // Sequential Pipeline Clocking
    // ------------------------------------------------------------------------
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            pc                <= 32'd0;
            if_id_pc          <= 32'd0;
            if_id_instr       <= 32'h00000013; // NOP (ADDI x0, x0, 0)

            id_ex_pc          <= 32'd0;
            id_ex_rs1_val     <= 32'd0;
            id_ex_rs2_val     <= 32'd0;
            id_ex_imm         <= 32'd0;
            id_ex_rs1         <= 5'd0;
            id_ex_rs2         <= 5'd0;
            id_ex_rd          <= 5'd0;
            id_ex_funct3      <= 3'd0;
            id_ex_funct7      <= 7'd0;
            id_ex_opcode      <= 7'd0;
            id_ex_alu_ctrl    <= 4'd0;
            id_ex_reg_write   <= 1'b0;
            id_ex_mem_read    <= 1'b0;
            id_ex_mem_write   <= 1'b0;
            id_ex_mem_to_reg  <= 1'b0;
            id_ex_alu_src     <= 1'b0;
            id_ex_branch      <= 1'b0;
            id_ex_jump        <= 1'b0;
            id_ex_jalr        <= 1'b0;
            id_ex_lui         <= 1'b0;
            id_ex_auipc       <= 1'b0;
            id_ex_m_valid     <= 1'b0;

            ex_mem_alu_result <= 32'd0;
            ex_mem_store_data <= 32'd0;
            ex_mem_pc_plus_4  <= 32'd0;
            ex_mem_rd         <= 5'd0;
            ex_mem_funct3     <= 3'd0;
            ex_mem_reg_write  <= 1'b0;
            ex_mem_mem_read   <= 1'b0;
            ex_mem_mem_write  <= 1'b0;
            ex_mem_mem_to_reg <= 1'b0;
            ex_mem_jump       <= 1'b0;

            mem_wb_mem_data   <= 32'd0;
            mem_wb_alu_result <= 32'd0;
            mem_wb_pc_plus_4  <= 32'd0;
            mem_wb_rd         <= 5'd0;
            mem_wb_reg_write  <= 1'b0;
            mem_wb_mem_to_reg <= 1'b0;
            mem_wb_jump       <= 1'b0;

            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'd0;
            for (i = 0; i < DMEM_DEPTH; i = i + 1)
                data_mem[i] <= 32'd0;
        end else begin
            // -------------------- WB Stage --------------------
            if (mem_wb_reg_write && (mem_wb_rd != 5'd0)) begin
                registers[mem_wb_rd] <= wb_write_data;
            end
            registers[0] <= 32'd0; // Strict x0 hardwired invariant

            // -------------------- MEM Stage -------------------
            if (ex_mem_mem_write) begin
                data_mem[dmem_word_addr] <= next_mem_word;
            end

            mem_wb_mem_data   <= ex_mem_mem_read ? mem_read_formatted : 32'd0;
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_pc_plus_4  <= ex_mem_pc_plus_4;
            mem_wb_rd         <= ex_mem_rd;
            mem_wb_reg_write  <= ex_mem_reg_write;
            mem_wb_mem_to_reg <= ex_mem_mem_to_reg;
            mem_wb_jump       <= ex_mem_jump;

            // -------------------- EX Stage --------------------
            ex_mem_alu_result <= ex_final_result;
            ex_mem_store_data <= ex_fwd_b;
            ex_mem_pc_plus_4  <= id_ex_pc + 32'd4;
            ex_mem_rd         <= id_ex_rd;
            ex_mem_funct3     <= id_ex_funct3;
            ex_mem_reg_write  <= id_ex_reg_write;
            ex_mem_mem_read   <= id_ex_mem_read;
            ex_mem_mem_write  <= id_ex_mem_write;
            ex_mem_mem_to_reg <= id_ex_mem_to_reg;
            ex_mem_jump       <= id_ex_jump;

            // -------------------- ID Stage --------------------
            if (flush_id_ex) begin
                // Inject bubble (NOP) into ID/EX
                id_ex_pc          <= 32'd0;
                id_ex_rs1_val     <= 32'd0;
                id_ex_rs2_val     <= 32'd0;
                id_ex_imm         <= 32'd0;
                id_ex_rs1         <= 5'd0;
                id_ex_rs2         <= 5'd0;
                id_ex_rd          <= 5'd0;
                id_ex_funct3      <= 3'd0;
                id_ex_funct7      <= 7'd0;
                id_ex_opcode      <= 7'd0;
                id_ex_alu_ctrl    <= 4'd0;
                id_ex_reg_write   <= 1'b0;
                id_ex_mem_read    <= 1'b0;
                id_ex_mem_write   <= 1'b0;
                id_ex_mem_to_reg  <= 1'b0;
                id_ex_alu_src     <= 1'b0;
                id_ex_branch      <= 1'b0;
                id_ex_jump        <= 1'b0;
                id_ex_jalr        <= 1'b0;
                id_ex_lui         <= 1'b0;
                id_ex_auipc       <= 1'b0;
                id_ex_m_valid     <= 1'b0;
            end else begin
                id_ex_pc          <= if_id_pc;
                id_ex_rs1_val     <= id_rs1_data;
                id_ex_rs2_val     <= id_rs2_data;
                id_ex_imm         <= dec_imm;
                id_ex_rs1         <= id_rs1;
                id_ex_rs2         <= id_rs2;
                id_ex_rd          <= id_rd;
                id_ex_funct3      <= id_funct3;
                id_ex_funct7      <= id_funct7;
                id_ex_opcode      <= id_opcode;
                id_ex_alu_ctrl    <= dec_alu_ctrl;
                id_ex_reg_write   <= dec_reg_write;
                id_ex_mem_read    <= dec_mem_read;
                id_ex_mem_write   <= dec_mem_write;
                id_ex_mem_to_reg  <= dec_mem_to_reg;
                id_ex_alu_src     <= dec_alu_src;
                id_ex_branch      <= dec_branch;
                id_ex_jump        <= dec_jump;
                id_ex_jalr        <= dec_jalr;
                id_ex_lui         <= dec_lui;
                id_ex_auipc       <= dec_auipc;
                id_ex_m_valid     <= dec_m_valid;
            end

            // -------------------- IF Stage --------------------
            if (ex_branch_taken || ex_jump_taken) begin
                // Control hazard redirect
                pc          <= ex_target_pc;
                if_id_pc    <= 32'd0;
                if_id_instr <= 32'h00000013; // Flush IF/ID
            end else if (!stall_pc) begin
                pc <= if_pc_plus_4;
                if (!stall_if_id) begin
                    if_id_pc    <= pc;
                    if_id_instr <= if_instr;
                end
            end
        end
    end

    // ------------------------------------------------------------------------
    // Debug Interface Wiring
    // ------------------------------------------------------------------------
    assign debug_pc     = pc;
    assign debug_reg1   = registers[1];
    assign debug_reg2   = registers[2];
    assign debug_reg3   = registers[3];
    assign debug_reg4   = registers[4];
    assign debug_reg5   = registers[5];
    assign debug_dmem0  = data_mem[0];
    assign debug_dmem1  = data_mem[1];
    assign debug_dmem9  = data_mem[9];

endmodule
