`timescale 1ns/1ps

// ============================================================================
// Module: riscv_regfile
// Description: RV32I 32x32-bit Register File.
//              - Dual combinational read ports with internal write-through bypass.
//              - Single synchronous write port on rising clock edge.
//              - Register x0 is hardwired to zero (reads always return 0; writes ignored).
//              - Synchronous active-high reset for deterministic ASIC/FPGA initialization.
// ============================================================================

module riscv_regfile (
    input  wire        clk,
    input  wire        reset,
    input  wire [4:0]  rs1_addr,
    input  wire [4:0]  rs2_addr,
    input  wire [4:0]  rd_addr,
    input  wire [31:0] wr_data,
    input  wire        wr_en,
    output wire [31:0] rs1_data,
    output wire [31:0] rs2_data
);

    reg [31:0] registers [0:31];
    integer i;

    // Synchronous write and reset
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'd0;
            end
        end else if (wr_en && (rd_addr != 5'd0)) begin
            registers[rd_addr] <= wr_data;
        end
    end

    // Combinational read with internal bypass
    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 :
                      (wr_en && (rd_addr == rs1_addr)) ? wr_data : registers[rs1_addr];

    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 :
                      (wr_en && (rd_addr == rs2_addr)) ? wr_data : registers[rs2_addr];

endmodule
