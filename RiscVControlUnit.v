module RiscVControlUnit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,

    output reg  [2:0] alu_sel,
    output reg        alu_src,
    output reg        reg_write
);

localparam OP_RTYPE = 7'b0110011;
localparam OP_ITYPE = 7'b0010011;

always @(*) begin
    alu_sel   = 3'b000;
    alu_src   = 1'b0;
    reg_write = 1'b0;

    case (opcode)

        OP_RTYPE: begin
            alu_src   = 1'b0;
            reg_write = 1'b1;

            case (funct3)
                3'b000: begin
                    if (funct7 == 7'b0100000)
                        alu_sel = 3'b001; // SUB
                    else
                        alu_sel = 3'b000; // ADD
                end

                3'b111: alu_sel = 3'b010; // AND
                3'b110: alu_sel = 3'b011; // OR
                3'b100: alu_sel = 3'b100; // XOR
                3'b010: alu_sel = 3'b101; // SLT

                default: alu_sel = 3'b000;
            endcase
        end

        OP_ITYPE: begin
            alu_src   = 1'b1;
            reg_write = 1'b1;

            case (funct3)
                3'b000: alu_sel = 3'b000; // ADDI
                default: alu_sel = 3'b000;
            endcase
        end

        default: begin
            alu_sel   = 3'b000;
            alu_src   = 1'b0;
            reg_write = 1'b0;
        end
    endcase
end

endmodule