//==============================================================================
// File: Datapath.v
// Description: Datapath - Tích hợp ALU, RegFile, và ControlUnit
//              Điều phối luồng dữ liệu từ RegFile → ALU → Result
// Author: FPGA Design Engineer
// Date: 2026-05-12
//==============================================================================

module Datapath (
    input  wire        clk,
    input  wire        reset_n,
    
    // Tín hiệu điều khiển
    input  wire [ 2:0] opcode,
    
    // Tín hiệu từ TopCore
    input  wire [ 4:0] reg_addr_a,     // Địa chỉ thanh ghi A
    input  wire [ 4:0] reg_addr_b,     // Địa chỉ thanh ghi B
    input  wire [ 4:0] write_addr,     // Địa chỉ ghi
    input  wire [31:0] write_data,     // Dữ liệu ghi
    input  wire        write_en,       // Tín hiệu ghi
    
    // Kết quả ALU đầu ra
    output wire [31:0] result,         // Kết quả ALU
    output wire        zero_flag,      // Cờ Zero
    output wire        carry_flag,     // Cờ Carry
    output wire        overflow_flag,  // Cờ Overflow
    output wire        negative_flag   // Cờ Negative
);

//==============================================================================
// Biến nội bộ
//==============================================================================
wire [ 2:0] alu_sel;
wire        reg_write_en;
wire [31:0] operand_a;
wire [31:0] operand_b;

//==============================================================================
// Instantiate ControlUnit
//==============================================================================
ControlUnit ctrl_unit (
    .opcode       (opcode),
    .alu_sel      (alu_sel),
    .reg_write_en (reg_write_en)
);

//==============================================================================
// Instantiate RegFile
//==============================================================================
RegFile regfile (
    .clk          (clk),
    .reset_n      (reset_n),
    .read_addr_a  (reg_addr_a),
    .operand_a    (operand_a),
    .read_addr_b  (reg_addr_b),
    .operand_b    (operand_b),
    .write_addr   (write_addr),
    .write_data   (write_data),
    .write_en     (write_en & reg_write_en)
);

//==============================================================================
// Instantiate ALU
//==============================================================================
ALU alu_unit (
    .operand_A    (operand_a),
    .operand_B    (operand_b),
    .alu_sel      (alu_sel),
    .result       (result),
    .zero_flag    (zero_flag),
    .carry_flag   (carry_flag),
    .overflow_flag(overflow_flag),
    .negative_flag(negative_flag)
);

endmodule
//==============================================================================
// End of Datapath.v
//==============================================================================