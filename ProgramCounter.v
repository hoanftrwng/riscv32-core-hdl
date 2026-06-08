module ProgramCounter (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        pc_enable,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            pc <= 32'd0;
        else if (pc_enable)
            pc <= pc_next;
    end

endmodule