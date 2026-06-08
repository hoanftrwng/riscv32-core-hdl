module RiscV_ALU_Core (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        step_enable,

    output reg  [31:0] debug_pc,
    output reg  [31:0] debug_instr,
    output reg  [31:0] debug_result,
    output reg  [4:0]  debug_rd,
    output reg  [2:0]  debug_alu_sel,
    output reg         debug_reg_write
);

wire [31:0] pc;
wire [31:0] pc_next;
wire [31:0] instr;

assign pc_next = pc + 32'd4;

ProgramCounter pc_unit (
    .clk       (clk),
    .reset_n   (reset_n),
    .pc_enable (step_enable),
    .pc_next   (pc_next),
    .pc        (pc)
);

InstructionMemory imem (
    .pc    (pc),
    .instr (instr)
);

wire [6:0] opcode = instr[6:0];
wire [4:0] rd     = instr[11:7];
wire [2:0] funct3 = instr[14:12];
wire [4:0] rs1    = instr[19:15];
wire [4:0] rs2    = instr[24:20];
wire [6:0] funct7 = instr[31:25];

wire [2:0] alu_sel;
wire       alu_src;
wire       reg_write_decode;

RiscVControlUnit control_unit (
    .opcode    (opcode),
    .funct3    (funct3),
    .funct7    (funct7),
    .alu_sel   (alu_sel),
    .alu_src   (alu_src),
    .reg_write (reg_write_decode)
);

wire [31:0] rs1_data;
wire [31:0] rs2_data;
wire [31:0] imm_i;
wire [31:0] operand_b;
wire [31:0] alu_result;

assign imm_i     = {{20{instr[31]}}, instr[31:20]};
assign operand_b = alu_src ? imm_i : rs2_data;

wire reg_write_actual;
assign reg_write_actual = reg_write_decode & step_enable;

RegFile rf (
    .clk         (clk),
    .reset_n     (reset_n),

    .write_addr  (rd),
    .write_data  (alu_result),
    .write_en    (reg_write_actual),

    .read_addr_a (rs1),
    .operand_a   (rs1_data),

    .read_addr_b (rs2),
    .operand_b   (rs2_data)
);
wire zero_flag;
wire carry_flag;
wire overflow_flag;
wire negative_flag;

ALU alu_core (
    .operand_A     (rs1_data),
    .operand_B     (operand_b),
    .alu_sel       (alu_sel),
    .result        (alu_result),
    .zero_flag     (zero_flag),
    .carry_flag    (carry_flag),
    .overflow_flag (overflow_flag),
    .negative_flag (negative_flag)
);

// Capture the executed instruction information for debug display
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        debug_pc        <= 32'd0;
        debug_instr     <= 32'd0;
        debug_result    <= 32'd0;
        debug_rd        <= 5'd0;
        debug_alu_sel   <= 3'd0;
        debug_reg_write <= 1'b0;
    end
    else if (step_enable) begin
        debug_pc        <= pc;
        debug_instr     <= instr;
        debug_result    <= alu_result;
        debug_rd        <= rd;
        debug_alu_sel   <= alu_sel;
        debug_reg_write <= reg_write_decode;
    end
end

endmodule