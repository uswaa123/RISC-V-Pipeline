module ex_mem_reg (
    input logic clk,
    input logic rst,
    
    // Control
    input logic rf_en_in,
    input logic [1:0] wb_sel_in,
    input logic mem_read_in,
    input logic mem_write_in,
    input logic [2:0] func3_in,
    
    // Data
    input logic [31:0] alu_result_in,
    input logic [31:0] write_data_in,
    input logic [4:0] rd_in,
    input logic [31:0] pc_in,

    // Outputs
    output logic rf_en_out,
    output logic [1:0] wb_sel_out,
    output logic mem_read_out,
    output logic mem_write_out,
    output logic [2:0] func3_out,
    
    output logic [31:0] alu_result_out,
    output logic [31:0] write_data_out,
    output logic [4:0] rd_out,
    output logic [31:0] pc_out
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
             rf_en_out <= 1'b0;
             wb_sel_out <= 2'b0;
             mem_read_out <= 1'b0;
             mem_write_out <= 1'b0;
             func3_out <= 3'b0;
             alu_result_out <= 32'b0;
             write_data_out <= 32'b0;
             rd_out <= 5'b0;
             pc_out <= 32'b0;
        end else begin
             rf_en_out <= rf_en_in;
             wb_sel_out <= wb_sel_in;
             mem_read_out <= mem_read_in;
             mem_write_out <= mem_write_in;
             func3_out <= func3_in;
             alu_result_out <= alu_result_in;
             write_data_out <= write_data_in;
             rd_out <= rd_in;
             pc_out <= pc_in;
        end
    end
endmodule
