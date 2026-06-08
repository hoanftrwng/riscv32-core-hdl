//==============================================================================
// File: ControlUnit.v
// Description: Control Unit - Điều khiển các tín hiệu cho ALU
//              Dịch mã lệnh thành các tín hiệu điều khiển
// Author: FPGA Design Engineer
// Date: 2026-05-12
//==============================================================================

module ControlUnit (
    input  wire [ 2:0] opcode,         // Mã lệnh (3-bit cho 6 phép toán)
    output reg  [ 2:0] alu_sel,        // Tín hiệu chọn ALU
    output reg         reg_write_en    // Tín hiệu cho phép ghi thanh ghi
);

//==============================================================================
// Định nghĩa các mã lệnh (Opcode)
//==============================================================================
localparam OP_ADD = 3'b000;
localparam OP_SUB = 3'b001;
localparam OP_AND = 3'b010;
localparam OP_OR  = 3'b011;
localparam OP_XOR = 3'b100;
localparam OP_SLT = 3'b101;

//==============================================================================
// Khối lôgic Không đồng bộ - Dịch mã lệnh
//==============================================================================
always @(*) begin
    case (opcode)
        OP_ADD: begin
            alu_sel      = 3'b000;  // ADD operation
            reg_write_en = 1'b1;    // Enable register write
        end
        OP_SUB: begin
            alu_sel      = 3'b001;  // SUB operation
            reg_write_en = 1'b1;
        end
        OP_AND: begin
            alu_sel      = 3'b010;  // AND operation
            reg_write_en = 1'b1;
        end
        OP_OR: begin
            alu_sel      = 3'b011;  // OR operation
            reg_write_en = 1'b1;
        end
        OP_XOR: begin
            alu_sel      = 3'b100;  // XOR operation
            reg_write_en = 1'b1;
        end
        OP_SLT: begin
            alu_sel      = 3'b101;  // SLT operation
            reg_write_en = 1'b1;
        end
        default: begin
            alu_sel      = 3'b000;  // Default: ADD
            reg_write_en = 1'b0;    // Disable write
        end
    endcase
end

endmodule
//==============================================================================
// End of ControlUnit.v
//==============================================================================