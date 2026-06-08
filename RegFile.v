//==============================================================================
// File: RegFile.v
// Description: Register File - 32 thanh ghi x 32 bits
//              Hỗ trợ 2 cổng đọc (Read) và 1 cổng ghi (Write)
// Author: FPGA Design Engineer
// Date: 2026-05-12
//==============================================================================

module RegFile (
    input  wire        clk,
    input  wire        reset_n,
    
    // Cổng ghi (Write Port)
    input  wire [ 4:0] write_addr,
    input  wire [31:0] write_data,
    input  wire        write_en,
    
    // Cổng đọc 1 (Read Port A)
    input  wire [ 4:0] read_addr_a,
    output reg  [31:0] operand_a,
    
    // Cổng đọc 2 (Read Port B)
    input  wire [ 4:0] read_addr_b,
    output reg  [31:0] operand_b
);

//==============================================================================
// Khai báo mảng thanh ghi (32 thanh ghi x 32 bits)
//==============================================================================
reg [31:0] registers [0:31];

//==============================================================================
// Khối lôgic Đồng bộ (Synchronous) - Ghi dữ liệu
//==============================================================================
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        registers[0]  <= 32'h00000000;
        registers[1]  <= 32'h00000000;
        registers[2]  <= 32'h00000000;
        registers[3]  <= 32'h00000000;
        registers[4]  <= 32'h00000000;
        registers[5]  <= 32'h00000000;
        registers[6]  <= 32'h00000000;
        registers[7]  <= 32'h00000000;
        registers[8]  <= 32'h00000000;
        registers[9]  <= 32'h00000000;
        registers[10] <= 32'h00000000;
        registers[11] <= 32'h00000000;
        registers[12] <= 32'h00000000;
        registers[13] <= 32'h00000000;
        registers[14] <= 32'h00000000;
        registers[15] <= 32'h00000000;
        registers[16] <= 32'h00000000;
        registers[17] <= 32'h00000000;
        registers[18] <= 32'h00000000;
        registers[19] <= 32'h00000000;
        registers[20] <= 32'h00000000;
        registers[21] <= 32'h00000000;
        registers[22] <= 32'h00000000;
        registers[23] <= 32'h00000000;
        registers[24] <= 32'h00000000;
        registers[25] <= 32'h00000000;
        registers[26] <= 32'h00000000;
        registers[27] <= 32'h00000000;
        registers[28] <= 32'h00000000;
        registers[29] <= 32'h00000000;
        registers[30] <= 32'h00000000;
        registers[31] <= 32'h00000000;
    end
    else begin
        if (write_en) begin
            registers[write_addr] <= write_data;
        end
    end
end

//==============================================================================
// Khối lôgic Không đồng bộ (Combinational) - Đọc dữ liệu
//==============================================================================
always @(*) begin
    operand_a = registers[read_addr_a];
    operand_b = registers[read_addr_b];
end

endmodule
//==============================================================================
// End of RegFile.v
//==============================================================================