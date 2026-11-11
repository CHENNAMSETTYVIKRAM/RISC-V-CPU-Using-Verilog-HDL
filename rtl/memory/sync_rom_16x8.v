`timescale 1ns/1ps

// ============================================================================
// Module: sync_rom_16x8
// Description: Synchronous ROM (16 words x 8 bits). Initialized with default
//              patterns or loaded from an external HEX file via parameter.
// ============================================================================

module sync_rom_16x8 #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8,
    parameter INIT_FILE  = ""
)(
    input  wire                  clk,
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [DATA_WIDTH-1:0] data_out
);

    localparam DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] rom [0:DEPTH-1];

    integer i;
    initial begin
        // Default deterministic initialization
        rom[0]  = 8'hA0; rom[1]  = 8'hA1; rom[2]  = 8'hA2; rom[3]  = 8'hA3;
        rom[4]  = 8'hB0; rom[5]  = 8'hB1; rom[6]  = 8'hB2; rom[7]  = 8'hB3;
        rom[8]  = 8'hC0; rom[9]  = 8'hC1; rom[10] = 8'hC2; rom[11] = 8'hC3;
        rom[12] = 8'hD0; rom[13] = 8'hD1; rom[14] = 8'hD2; rom[15] = 8'hD3;

        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, rom);
        end
    end

    always @(posedge clk) begin
        data_out <= rom[addr];
    end

endmodule
