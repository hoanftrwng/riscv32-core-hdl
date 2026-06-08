//==============================================================================
// File: ALU.v
// Description: 32-bit Arithmetic and Logic Unit (ALU) for RISC-V
//              Supports 6 operations: ADD, SUB, AND, OR, XOR, SLT
//              Generates flags: Zero, Carry, Overflow, Negative
// Author: FPGA Design Engineer
// Date: 2026-05-12
//==============================================================================

module ALU (
    input  wire [31:0] operand_A,      // Toán hạng A (32-bit)
    input  wire [31:0] operand_B,      // Toán hạng B (32-bit)
    input  wire [ 2:0] alu_sel,        // Tín hiệu chọn phép toán (3-bit)
    output reg  [31:0] result,         // Kết quả (32-bit)
    output wire        zero_flag,      // Cờ Zero (Result == 0)
    output wire        carry_flag,     // Cờ Carry (tràn bit cao)
    output wire        overflow_flag,  // Cờ Overflow (tràn số học có dấu)
    output wire        negative_flag   // Cờ Negative (Result[31])
);

//==============================================================================
// Định nghĩa các phép toán
//==============================================================================
localparam ALU_ADD = 3'b000;  // Cộng
localparam ALU_SUB = 3'b001;  // Trừ
localparam ALU_AND = 3'b010;  // AND logic
localparam ALU_OR  = 3'b011;  // OR logic
localparam ALU_XOR = 3'b100;  // XOR logic
localparam ALU_SLT = 3'b101;  // Set Less Than

//==============================================================================
// Biến nội bộ
//==============================================================================
wire [32:0] add_result;
wire [32:0] sub_result;
wire        add_carry;
wire        sub_carry;
wire        add_overflow;
wire        sub_overflow;

//==============================================================================
// Tính toán ADD (33-bit để lấy Carry)
//==============================================================================
assign add_result = {1'b0, operand_A} + {1'b0, operand_B};
assign add_carry = add_result[32];

//==============================================================================
// Tính toán SUB (33-bit để lấy Carry)
//==============================================================================
assign sub_result = {1'b0, operand_A} - {1'b0, operand_B};
assign sub_carry = ~sub_result[32];

//==============================================================================
// Tính toán Overflow
// ADD Overflow: (A[31]==B[31]) && (A[31]!=Result[31])
// SUB Overflow: (A[31]!=B[31]) && (A[31]!=Result[31])
//==============================================================================
assign add_overflow = (operand_A[31] == operand_B[31]) && 
                      (operand_A[31] != add_result[31]);

assign sub_overflow = (operand_A[31] != operand_B[31]) && 
                      (operand_A[31] != sub_result[31]);

//==============================================================================
// Mux logic chính - Lựa chọn phép toán
//==============================================================================
always @(*) begin
    case (alu_sel)
        ALU_ADD: result = add_result[31:0];
        ALU_SUB: result = sub_result[31:0];
        ALU_AND: result = operand_A & operand_B;
        ALU_OR:  result = operand_A | operand_B;
        ALU_XOR: result = operand_A ^ operand_B;
        ALU_SLT: result = {31'b0, (operand_A < operand_B) ? 1'b1 : 1'b0};
        default: result = 32'h00000000;
    endcase
end

//==============================================================================
// Tính toán các cờ trạng thái
//==============================================================================
assign zero_flag = (result == 32'h00000000);

assign carry_flag = (alu_sel == ALU_ADD) ? add_carry :
                    (alu_sel == ALU_SUB) ? sub_carry : 1'b0;

assign overflow_flag = (alu_sel == ALU_ADD) ? add_overflow :
                       (alu_sel == ALU_SUB) ? sub_overflow : 1'b0;

assign negative_flag = result[31];

endmodule
//==============================================================================
// End of ALU.v
//==============================================================================