module InstructionMemory (
    input  wire [31:0] pc,
    output wire [31:0] instr
);

reg [31:0] rom [0:63];

initial begin
$readmemh("D:/altera/13.0sp/project/RISC_V_ALU/sim/firmware.hex", rom);
end

assign instr = rom[pc[7:2]];

endmodule