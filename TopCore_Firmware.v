//==============================================================================
// File: TopCore_Firmware.v
// Description: Top-level module for running firmware-based RISC-V ALU Core
//              on Altera DE2 board.
//==============================================================================

module TopCore_Firmware (
    input  wire        CLOCK_50,
    input  wire [17:0] SW,
    input  wire [ 3:0] KEY,

    output wire [17:0] LEDR,
    output wire [ 8:0] LEDG,

    output wire [6:0] HEX0,
    output wire [6:0] HEX1,
    output wire [6:0] HEX2,
    output wire [6:0] HEX3,
    output wire [6:0] HEX4,
    output wire [6:0] HEX5,
    output wire [6:0] HEX6,
    output wire [6:0] HEX7
);

//==============================================================================
// Reset and button synchronization
//==============================================================================

wire reset_n;
assign reset_n = KEY[3];   // KEY[3] active-low reset

reg key2_sync_0;
reg key2_sync_1;
reg key2_prev;

always @(posedge CLOCK_50 or negedge reset_n) begin
    if (!reset_n) begin
        key2_sync_0 <= 1'b0;
        key2_sync_1 <= 1'b0;
        key2_prev   <= 1'b0;
    end
    else begin
        key2_sync_0 <= ~KEY[2];       // KEY[2] active-low, invert to active-high
        key2_sync_1 <= key2_sync_0;
        key2_prev   <= key2_sync_1;
    end
end

wire step_enable;
assign step_enable = key2_sync_1 & ~key2_prev;

//==============================================================================
// Firmware-based RISC-V ALU Core
//==============================================================================

wire [31:0] debug_pc;
wire [31:0] debug_instr;
wire [31:0] debug_result;
wire [4:0]  debug_rd;
wire [2:0]  debug_alu_sel;
wire        debug_reg_write;

RiscV_ALU_Core core_inst (
    .clk             (CLOCK_50),
    .reset_n         (reset_n),
    .step_enable     (step_enable),

    .debug_pc        (debug_pc),
    .debug_instr     (debug_instr),
    .debug_result    (debug_result),
    .debug_rd        (debug_rd),
    .debug_alu_sel   (debug_alu_sel),
    .debug_reg_write (debug_reg_write)
);

//==============================================================================
// Display mode selection using SW[1:0]
//==============================================================================
// SW[1:0] = 00: show ALU result
// SW[1:0] = 01: show PC
// SW[1:0] = 10: show instruction machine code
// SW[1:0] = 11: show debug info {rd, alu_sel, reg_write}

reg [31:0] display_data;

always @(*) begin
    case (SW[1:0])
        2'b00: display_data = debug_result;
        2'b01: display_data = debug_pc;
        2'b10: display_data = debug_instr;
        2'b11: display_data = {23'd0, debug_reg_write, debug_rd, debug_alu_sel};
        default: display_data = debug_result;
    endcase
end

//==============================================================================
// LED outputs
//==============================================================================

assign LEDR = display_data[17:0];

assign LEDG[0]   = step_enable;
assign LEDG[1]   = debug_reg_write;
assign LEDG[4:2] = debug_alu_sel;
assign LEDG[8:5] = debug_rd[3:0];

//==============================================================================
// 7-segment HEX decoder
// DE2 HEX is active-low
//==============================================================================

function [6:0] hex_to_7seg;
    input [3:0] hex;
    begin
        case (hex)
            4'h0: hex_to_7seg = 7'b1000000;
            4'h1: hex_to_7seg = 7'b1111001;
            4'h2: hex_to_7seg = 7'b0100100;
            4'h3: hex_to_7seg = 7'b0110000;
            4'h4: hex_to_7seg = 7'b0011001;
            4'h5: hex_to_7seg = 7'b0010010;
            4'h6: hex_to_7seg = 7'b0000010;
            4'h7: hex_to_7seg = 7'b1111000;
            4'h8: hex_to_7seg = 7'b0000000;
            4'h9: hex_to_7seg = 7'b0010000;
            4'hA: hex_to_7seg = 7'b0001000;
            4'hB: hex_to_7seg = 7'b0000011;
            4'hC: hex_to_7seg = 7'b1000110;
            4'hD: hex_to_7seg = 7'b0100001;
            4'hE: hex_to_7seg = 7'b0000110;
            4'hF: hex_to_7seg = 7'b0001110;
            default: hex_to_7seg = 7'b1111111;
        endcase
    end
endfunction

assign HEX0 = hex_to_7seg(display_data[ 3: 0]);
assign HEX1 = hex_to_7seg(display_data[ 7: 4]);
assign HEX2 = hex_to_7seg(display_data[11: 8]);
assign HEX3 = hex_to_7seg(display_data[15:12]);
assign HEX4 = hex_to_7seg(display_data[19:16]);
assign HEX5 = hex_to_7seg(display_data[23:20]);
assign HEX6 = hex_to_7seg(display_data[27:24]);
assign HEX7 = hex_to_7seg(display_data[31:28]);

endmodule