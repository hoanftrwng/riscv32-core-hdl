//==============================================================================
// File: TopCore.v
// Description: Top-Level Module for Altera DE2 board
// Board I/O:
//   CLOCK_50  : 50 MHz clock
//   SW[17:0]  : input data / opcode
//   KEY[0]    : Load operand A
//   KEY[1]    : Load operand B
//   KEY[2]    : Execute ALU
//   KEY[3]    : Reset, active-low
//   LEDR      : result low 18 bits
//   LEDG      : flags + opcode
//   HEX0-HEX7 : 32-bit result in hexadecimal
//==============================================================================

module TopCore (
    input  wire        CLOCK_50,
    input  wire [17:0] SW,
    input  wire [ 3:0] KEY,

    output wire [17:0] LEDR,
    output wire [ 8:0] LEDG,

    output wire [ 6:0] HEX0,
    output wire [ 6:0] HEX1,
    output wire [ 6:0] HEX2,
    output wire [ 6:0] HEX3,
    output wire [ 6:0] HEX4,
    output wire [ 6:0] HEX5,
    output wire [ 6:0] HEX6,
    output wire [ 6:0] HEX7
);

//==============================================================================
// Internal registers
//==============================================================================

reg [31:0] operand_a_reg;
reg [31:0] operand_b_reg;
reg [ 2:0] opcode_reg;
reg [31:0] result_reg;

reg zero_reg;
reg carry_reg;
reg overflow_reg;
reg negative_reg;

//==============================================================================
// Reset
// KEY on DE2 is active-low
// KEY[3] = reset
//==============================================================================

wire reset_n;
assign reset_n = KEY[3];

//==============================================================================
// Button processing
// KEY[0], KEY[1], KEY[2] are active-low on DE2
// Convert them to active-high internal signals
//==============================================================================

reg  [2:0] key_sync_0;
reg  [2:0] key_sync_1;
reg  [2:0] key_prev;
wire [2:0] key_pressed;

// key_pressed[0] = KEY0 pressed
// key_pressed[1] = KEY1 pressed
// key_pressed[2] = KEY2 pressed

always @(posedge CLOCK_50 or negedge reset_n) begin
    if (!reset_n) begin
        key_sync_0 <= 3'b000;
        key_sync_1 <= 3'b000;
        key_prev   <= 3'b000;
    end
    else begin
        key_sync_0 <= ~KEY[2:0];
        key_sync_1 <= key_sync_0;
        key_prev   <= key_sync_1;
    end
end

assign key_pressed = key_sync_1 & ~key_prev;

//==============================================================================
// ALU wires
//==============================================================================

wire [31:0] result_alu;
wire        zero_flag;
wire        carry_flag;
wire        overflow_flag;
wire        negative_flag;

// Delay one clock after pressing Execute
// This allows opcode_reg to update before capturing result
reg execute_pending;

//==============================================================================
// Main control logic
//==============================================================================

always @(posedge CLOCK_50 or negedge reset_n) begin
    if (!reset_n) begin
        operand_a_reg   <= 32'h00000000;
        operand_b_reg   <= 32'h00000000;
        opcode_reg      <= 3'b000;
        result_reg      <= 32'h00000000;

        zero_reg        <= 1'b0;
        carry_reg       <= 1'b0;
        overflow_reg    <= 1'b0;
        negative_reg    <= 1'b0;

        execute_pending <= 1'b0;
    end
    else begin
        // KEY0: Load operand A from switches
        if (key_pressed[0]) begin
            operand_a_reg <= {14'b0, SW[17:0]};
        end

        // KEY1: Load operand B from switches
        if (key_pressed[1]) begin
            operand_b_reg <= {14'b0, SW[17:0]};
        end

        // KEY2: Load opcode from SW[2:0]
        if (key_pressed[2]) begin
            opcode_reg <= SW[2:0];
        end

        // Create one-clock delay after execute button
        execute_pending <= key_pressed[2];

        // Capture ALU result one clock after pressing KEY2
        if (execute_pending) begin
            result_reg   <= result_alu;

            zero_reg     <= zero_flag;
            carry_reg    <= carry_flag;
            overflow_reg <= overflow_flag;
            negative_reg <= negative_flag;
        end
    end
end

//==============================================================================
// ALU instance
// Make sure ALU.v uses the same port names:
// operand_A, operand_B, alu_sel, result,
// zero_flag, carry_flag, overflow_flag, negative_flag
//==============================================================================

ALU alu_inst (
    .operand_A     (operand_a_reg),
    .operand_B     (operand_b_reg),
    .alu_sel       (opcode_reg),
    .result        (result_alu),
    .zero_flag     (zero_flag),
    .carry_flag    (carry_flag),
    .overflow_flag (overflow_flag),
    .negative_flag (negative_flag)
);

//==============================================================================
// LED outputs
//==============================================================================

// Red LEDs show lower 18 bits of result
assign LEDR = result_reg[17:0];

// Green LEDs:
// LEDG[0] = Zero flag
// LEDG[1] = Carry flag
// LEDG[2] = Overflow flag
// LEDG[3] = Negative flag
// LEDG[6:4] = Current opcode
// LEDG[8:7] = unused
assign LEDG[0]   = zero_reg;
assign LEDG[1]   = carry_reg;
assign LEDG[2]   = overflow_reg;
assign LEDG[3]   = negative_reg;
assign LEDG[6:4] = opcode_reg;
assign LEDG[8:7] = 2'b00;

//==============================================================================
// 7-segment decoder
// DE2 HEX displays are active-low
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

//==============================================================================
// HEX display output
// Display result_reg as 8 hexadecimal digits
// HEX7 HEX6 HEX5 HEX4 HEX3 HEX2 HEX1 HEX0
//==============================================================================

assign HEX0 = hex_to_7seg(result_reg[ 3: 0]);
assign HEX1 = hex_to_7seg(result_reg[ 7: 4]);
assign HEX2 = hex_to_7seg(result_reg[11: 8]);
assign HEX3 = hex_to_7seg(result_reg[15:12]);
assign HEX4 = hex_to_7seg(result_reg[19:16]);
assign HEX5 = hex_to_7seg(result_reg[23:20]);
assign HEX6 = hex_to_7seg(result_reg[27:24]);
assign HEX7 = hex_to_7seg(result_reg[31:28]);

endmodule