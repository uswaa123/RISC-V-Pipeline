module if_id_reg (
    input logic clk,
    input logic rst,
    input logic en,
    input logic clear,
    input logic [31:0] pc_in,
    input logic [31:0] inst_in,
    output logic [31:0] pc_out,
    output logic [31:0] inst_out
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 32'b0;
            inst_out <= 32'h00000013; // NOP
        end else if (clear) begin
            pc_out <= 32'b0;
            inst_out <= 32'h00000013; // NOP
        end else if (en) begin
            pc_out <= pc_in;
            inst_out <= inst_in;
        end
    end
endmodule
