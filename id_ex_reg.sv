module id_ex_reg (
    input logic clk,
    input logic rst,
    input logic clear,
    
    // Control signals
    // WB
    input logic rf_en_in,
    input logic [1:0] wb_sel_in,
    // MEM
    input logic mem_read_in,
    input logic mem_write_in,
    // EX
    input logic [3:0] aluop_in,
    input logic sel_A_in,
    input logic imm_en_in,
    input logic jump_en_in,
    
    // Data
    input logic [31:0] pc_in,
    input logic [31:0] rdata1_in,
    input logic [31:0] rdata2_in,
    input logic [31:0] imm_in,
    input logic [2:0] func3_in,
    input logic [4:0] rs1_in,
    input logic [4:0] rs2_in,
    input logic [4:0] rd_in,

    // Outputs
    output logic rf_en_out,
    output logic [1:0] wb_sel_out,
    output logic mem_read_out,
    output logic mem_write_out,
    output logic [3:0] aluop_out,
    output logic sel_A_out,
    output logic imm_en_out,
    output logic jump_en_out,
    
    output logic [31:0] pc_out,
    output logic [31:0] rdata1_out,
    output logic [31:0] rdata2_out,
    output logic [31:0] imm_out,
    output logic [2:0] func3_out,
    output logic [4:0] rs1_out,
    output logic [4:0] rs2_out,
    output logic [4:0] rd_out
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rf_en_out <= 1'b0;
            wb_sel_out <= 2'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            aluop_out <= 4'b0;
            sel_A_out <= 1'b0;
            imm_en_out <= 1'b0;
            jump_en_out <= 1'b0;
            
            pc_out <= 32'b0;
            rdata1_out <= 32'b0;
            rdata2_out <= 32'b0;
            imm_out <= 32'b0;
            func3_out <= 3'b0;
            rs1_out <= 5'b0;
            rs2_out <= 5'b0;
            rd_out <= 5'b0;
        end else if (clear) begin
            rf_en_out <= 1'b0;
            wb_sel_out <= 2'b0;
            mem_read_out <= 1'b0;
            mem_write_out <= 1'b0;
            aluop_out <= 4'b0;
            sel_A_out <= 1'b0;
            imm_en_out <= 1'b0;
            jump_en_out <= 1'b0;
            
            pc_out <= 32'b0;
            rdata1_out <= 32'b0;
            rdata2_out <= 32'b0;
            imm_out <= 32'b0;
            func3_out <= 3'b0;
            rs1_out <= 5'b0;
            rs2_out <= 5'b0;
            rd_out <= 5'b0;
        end else begin
            rf_en_out <= rf_en_in;
            wb_sel_out <= wb_sel_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            aluop_out <= aluop_in;
            sel_A_out <= sel_A_in;
            imm_en_out <= imm_en_in;
            jump_en_out <= jump_en_in;
            
            pc_out <= pc_in;
            rdata1_out <= rdata1_in;
            rdata2_out <= rdata2_in;
            imm_out <= imm_in;
            func3_out <= func3_in;
            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            rd_out <= rd_in;
        end
    end
endmodule
