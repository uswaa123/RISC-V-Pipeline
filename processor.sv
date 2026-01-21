module processor (
    input logic clk,
    input logic rst
);
    // =========================================================================
    // Signal Declarations
    // =========================================================================
    
    // --- IF Stage ---
    logic [31:0] pc_if;
    logic [31:0] pc_plus_4_if;
    logic [31:0] next_pc;
    logic [31:0] inst_if;
    logic stall_if; // From hazard unit
    logic flush_if; // From branch taken
    
    // --- IF/ID Register ---
    logic [31:0] pc_id;
    logic [31:0] inst_id;
    
    // --- ID Stage ---
    logic [6:0] opcode;
    logic [2:0] func3;
    logic [6:0] func7;
    logic [4:0] rs1_id, rs2_id, rd_id;
    logic [31:0] rdata1_id, rdata2_id;
    logic [31:0] imm_id;
    
    // Control Signals (ID)
    logic rf_en_id, mem_read_id, mem_write_id, imm_en_id, jump_en_id, sel_A_id;
    logic [3:0] aluop_id;
    logic [1:0] wb_sel_id;
    logic csr_rd_id, csr_wr_id, is_mret_id; // CSR ignored/stubbed for now
    
    logic stall_id; // From hazard
    logic flush_id; // From branch
    
    // --- ID/EX Register ---
    logic [31:0] pc_ex;
    logic [31:0] rdata1_ex, rdata2_ex;
    logic [31:0] imm_ex;
    logic [4:0] rs1_ex, rs2_ex, rd_ex;
    logic [2:0] func3_ex;
    
    // Control Signals (EX)
    logic rf_en_ex, mem_read_ex, mem_write_ex, imm_en_ex, jump_en_ex, sel_A_ex;
    logic [3:0] aluop_ex;
    logic [1:0] wb_sel_ex;
    
    // --- EX Stage ---
    logic [31:0] opr_a_fwd, opr_b_fwd; // After forwarding
    logic [31:0] opr_a_final, opr_b_final; // After Muxes
    logic [31:0] alu_result_ex;
    logic br_true_ex;
    logic [1:0] forward_a, forward_b;
    logic branch_taken; // Combined branch/jump logic
    
    // --- EX/MEM Register ---
    logic [31:0] pc_mem; 
    logic [31:0] alu_result_mem;
    logic [31:0] write_data_mem; // This is rdata2 (opr_b_fwd)
    logic [4:0] rd_mem;
    logic [2:0] func3_mem; 
    
    // Control Signals (MEM)
    logic rf_en_mem, mem_read_mem, mem_write_mem;
    logic [1:0] wb_sel_mem;
    
    // --- MEM Stage ---
    logic [31:0] read_data_mem;
    
    // --- MEM/WB Register ---
    logic [31:0] pc_wb;
    logic [31:0] alu_result_wb;
    logic [31:0] read_data_wb;
    logic [4:0] rd_wb;
    
    // Control Signals (WB)
    logic rf_en_wb;
    logic [1:0] wb_sel_wb;
    
    // --- WB Stage ---
    logic [31:0] wdata_wb;

    // =========================================================================
    // IF Stage
    // =========================================================================
    
    assign pc_plus_4_if = pc_if + 4;
    
    // Next PC Logic (Mux)
    always_comb begin
        if (branch_taken) begin
            next_pc = alu_result_ex; // Branch target calculated in EX
        end else begin
            next_pc = pc_plus_4_if;
        end
    end

    pc pc_inst (
        .clk(clk),
        .rst(rst),
        .pc_in(stall_if ? pc_if : next_pc), // Stall logic: keep PC
        .pc_out(pc_if)
    );

    inst_mem imem (
        .addr(pc_if),
        .data(inst_if)
    );
    
    if_id_reg if_id (
        .clk(clk),
        .rst(rst),
        .en(!stall_id), // Stall ID means don't update IF/ID
        .clear(flush_id), // Flush on branch
        .pc_in(pc_if),
        .inst_in(inst_if),
        .pc_out(pc_id),
        .inst_out(inst_id)
    );
    
    // =========================================================================
    // ID Stage
    // =========================================================================
    
    inst_dec inst_instance (
        .inst(inst_id),
        .rs1(rs1_id),
        .rs2(rs2_id),
        .rd(rd_id),
        .opcode(opcode),
        .func3(func3),
        .func7(func7)
    );

    controller contr_inst (
        .opcode(opcode),
        .func3(func3),
        .func7(func7),
        .rf_en(rf_en_id),
        .csr_rd(csr_rd_id),
        .csr_wr(csr_wr_id),
        .aluop(aluop_id),
        .imm_en(imm_en_id),
        .mem_read(mem_read_id),
        .mem_write(mem_write_id),
        .sel_A(sel_A_id),
        .jump_en(jump_en_id),
        .wb_sel(wb_sel_id),
        .is_mret(is_mret_id)
    );

    reg_file reg_file_inst (
        .rs1(rs1_id),
        .rs2(rs2_id),
        .rd(rd_wb),       // From WB stage
        .rf_en(rf_en_wb), // From WB stage
        .clk(clk),
        .rdata1(rdata1_id),
        .rdata2(rdata2_id),
        .wdata(wdata_wb)  // From WB stage
    );
    
    imm_gen imm_gen_inst (
        .inst(inst_id),
        .sign_extended_imm(imm_id),
        .func3(func3),
        .opcode(opcode)
    );

    hazard_detection_unit hazard_unit (
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .rd_ex(rd_ex),
        .mem_read_ex(mem_read_ex),
        .stall(stall_id) // This signal stalls PC and IF/ID, and flushes ID/EX (clear)
    );

    // Hazard Logic
    assign stall_if = stall_id;
    // Flush if branch taken
    assign flush_if = branch_taken; 
    assign flush_id = branch_taken; 
    
    logic clear_id_ex;
    assign clear_id_ex = stall_id || branch_taken; // Flush on hazard or branch

    id_ex_reg id_ex (
        .clk(clk),
        .rst(rst),
        .clear(clear_id_ex),
        
        .rf_en_in(rf_en_id),
        .wb_sel_in(wb_sel_id),
        .mem_read_in(mem_read_id),
        .mem_write_in(mem_write_id),
        .aluop_in(aluop_id),
        .sel_A_in(sel_A_id),
        .imm_en_in(imm_en_id),
        .jump_en_in(jump_en_id),
        
        .pc_in(pc_id),
        .rdata1_in(rdata1_id),
        .rdata2_in(rdata2_id),
        .imm_in(imm_id),
        .func3_in(func3),
        .rs1_in(rs1_id),
        .rs2_in(rs2_id),
        .rd_in(rd_id),
        
        .rf_en_out(rf_en_ex),
        .wb_sel_out(wb_sel_ex),
        .mem_read_out(mem_read_ex),
        .mem_write_out(mem_write_ex),
        .aluop_out(aluop_ex),
        .sel_A_out(sel_A_ex),
        .imm_en_out(imm_en_ex),
        .jump_en_out(jump_en_ex),
        
        .pc_out(pc_ex),
        .rdata1_out(rdata1_ex),
        .rdata2_out(rdata2_ex),
        .imm_out(imm_ex),
        .func3_out(func3_ex),
        .rs1_out(rs1_ex),
        .rs2_out(rs2_ex),
        .rd_out(rd_ex)
    );
    
    // =========================================================================
    // EX Stage
    // =========================================================================
    
    forwarding_unit fwd_unit (
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rd_mem(rd_mem),
        .rf_en_mem(rf_en_mem),
        .rd_wb(rd_wb),
        .rf_en_wb(rf_en_wb),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );
    
    // Forwarding Muxes
    always_comb begin
        case (forward_a)
            2'b00: opr_a_fwd = rdata1_ex;
            2'b10: opr_a_fwd = alu_result_mem; // Forward from MEM
            2'b01: opr_a_fwd = wdata_wb;       // Forward from WB
            default: opr_a_fwd = rdata1_ex;
        endcase
        
        case (forward_b)
            2'b00: opr_b_fwd = rdata2_ex;
            2'b10: opr_b_fwd = alu_result_mem;
            2'b01: opr_b_fwd = wdata_wb;
            default: opr_b_fwd = rdata2_ex;
        endcase
    end
    
    // ALU Input Muxes
    assign opr_a_final = sel_A_ex ? pc_ex : opr_a_fwd;
    assign opr_b_final = imm_en_ex ? imm_ex : opr_b_fwd;
    
    alu alu_inst (
        .opr_a(opr_a_final),
        .opr_b(opr_b_final),
        .aluop(aluop_ex),
        .opr_res(alu_result_ex)
    );
    
    branch_cond_gen branch_cond_gen_inst (
        .func3(func3_ex),
        .rdata1(opr_a_fwd), // Must use forwarded data!
        .rdata2(opr_b_fwd), // Must use forwarded data!
        .br_true(br_true_ex)
    );
    
    assign branch_taken = br_true_ex || jump_en_ex;
    
    ex_mem_reg ex_mem (
        .clk(clk),
        .rst(rst),
        
        .rf_en_in(rf_en_ex),
        .wb_sel_in(wb_sel_ex),
        .mem_read_in(mem_read_ex),
        .mem_write_in(mem_write_ex),
        .func3_in(func3_ex),
        
        .alu_result_in(alu_result_ex),
        .write_data_in(opr_b_fwd), // Store value comes from rdata2 (forwarded)
        .rd_in(rd_ex),
        .pc_in(pc_ex),
        
        .rf_en_out(rf_en_mem),
        .wb_sel_out(wb_sel_mem),
        .mem_read_out(mem_read_mem),
        .mem_write_out(mem_write_mem),
        .func3_out(func3_mem),
        
        .alu_result_out(alu_result_mem),
        .write_data_out(write_data_mem),
        .rd_out(rd_mem),
        .pc_out(pc_mem)
    );

    // =========================================================================
    // MEM Stage
    // =========================================================================
    
    data_mem data_mem_inst (
        .clk(clk),
        .addr(alu_result_mem),
        .write_data(write_data_mem),
        .mem_read(mem_read_mem),
        .mem_write(mem_write_mem),
        .func3(func3_mem),
        .rdata(read_data_mem)
    );
    
    mem_wb_reg mem_wb (
        .clk(clk),
        .rst(rst),
        
        .rf_en_in(rf_en_mem),
        .wb_sel_in(wb_sel_mem),
        
        .read_data_in(read_data_mem),
        .alu_result_in(alu_result_mem),
        .rd_in(rd_mem),
        .pc_in(pc_mem),
        
        .rf_en_out(rf_en_wb),
        .wb_sel_out(wb_sel_wb),
        
        .read_data_out(read_data_wb),
        .alu_result_out(alu_result_wb),
        .rd_out(rd_wb),
        .pc_out(pc_wb)
    );

    // =========================================================================
    // WB Stage
    // =========================================================================
    
    always_comb begin
        case (wb_sel_wb)
            2'b00: wdata_wb = alu_result_wb;
            2'b01: wdata_wb = read_data_wb;
            2'b10: wdata_wb = pc_wb + 4; // JAL/JALR return address
            default: wdata_wb = alu_result_wb;
        endcase
    end

endmodule
