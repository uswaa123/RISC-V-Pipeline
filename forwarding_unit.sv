module forwarding_unit (
    input logic [4:0] rs1_ex,
    input logic [4:0] rs2_ex,
    input logic [4:0] rd_mem,
    input logic rf_en_mem,
    input logic [4:0] rd_wb,
    input logic rf_en_wb,
    
    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);
    always_comb begin
        forward_a = 2'b00;
        forward_b = 2'b00;

        // EX Hazard
        if (rf_en_mem && (rd_mem != 0) && (rd_mem == rs1_ex)) begin
            forward_a = 2'b10;
        end
        if (rf_en_mem && (rd_mem != 0) && (rd_mem == rs2_ex)) begin
            forward_b = 2'b10;
        end

        // MEM Hazard
        if (rf_en_wb && (rd_wb != 0) && (rd_wb == rs1_ex) && !(rf_en_mem && (rd_mem != 0) && (rd_mem == rs1_ex))) begin
            forward_a = 2'b01;
        end
        if (rf_en_wb && (rd_wb != 0) && (rd_wb == rs2_ex) && !(rf_en_mem && (rd_mem != 0) && (rd_mem == rs2_ex))) begin
            forward_b = 2'b01;
        end
    end
endmodule
