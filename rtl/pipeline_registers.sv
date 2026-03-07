// IF/ID Pipeline Register
module if_id_reg (
    input  logic        clk, rst, stall,
    input  logic [31:0] if_pc, if_instr,
    output logic [31:0] id_pc, id_instr
);
    always_ff @(posedge clk) begin
        if (rst) begin
            id_pc    <= 32'd0;
            id_instr <= 32'd0;
        end else if (!stall) begin
            id_pc    <= if_pc;
            id_instr <= if_instr;
        end
    end
endmodule

// ID/EX Pipeline Register
module id_ex_reg (
    input  logic        clk, rst, flush,
    input  logic [31:0] id_pc,
    input  logic [31:0] id_rd1, id_rd2, id_imm,
    input  logic [4:0]  id_rs1, id_rs2, id_rd,
    input  logic [2:0]  id_funct3,
    input  logic [6:0]  id_funct7,
    input  logic        id_reg_write, id_mem_read,
    input  logic        id_mem_write, id_mem_to_reg,
    input  logic        id_alu_src, id_branch,
    input  logic [1:0]  id_alu_op,
    output logic [31:0] ex_pc,
    output logic [31:0] ex_rd1, ex_rd2, ex_imm,
    output logic [4:0]  ex_rs1, ex_rs2, ex_rd,
    output logic [2:0]  ex_funct3,
    output logic [6:0]  ex_funct7,
    output logic        ex_reg_write, ex_mem_read,
    output logic        ex_mem_write, ex_mem_to_reg,
    output logic        ex_alu_src, ex_branch,
    output logic [1:0]  ex_alu_op
);
    always_ff @(posedge clk) begin
        if (rst || flush) begin
            ex_pc        <= 32'd0;
            ex_rd1       <= 32'd0;
            ex_rd2       <= 32'd0;
            ex_imm       <= 32'd0;
            ex_rs1       <= 5'd0;
            ex_rs2       <= 5'd0;
            ex_rd        <= 5'd0;
            ex_funct3    <= 3'd0;
            ex_funct7    <= 7'd0;
            ex_reg_write <= 0;
            ex_mem_read  <= 0;
            ex_mem_write <= 0;
            ex_mem_to_reg<= 0;
            ex_alu_src   <= 0;
            ex_branch    <= 0;
            ex_alu_op    <= 2'd0;
        end else begin
            ex_pc        <= id_pc;
            ex_rd1       <= id_rd1;
            ex_rd2       <= id_rd2;
            ex_imm       <= id_imm;
            ex_rs1       <= id_rs1;
            ex_rs2       <= id_rs2;
            ex_rd        <= id_rd;
            ex_funct3    <= id_funct3;
            ex_funct7    <= id_funct7;
            ex_reg_write <= id_reg_write;
            ex_mem_read  <= id_mem_read;
            ex_mem_write <= id_mem_write;
            ex_mem_to_reg<= id_mem_to_reg;
            ex_alu_src   <= id_alu_src;
            ex_branch    <= id_branch;
            ex_alu_op    <= id_alu_op;
        end
    end
endmodule

// EX/MEM Pipeline Register
module ex_mem_reg (
    input  logic        clk, rst,
    input  logic [31:0] ex_pc, ex_alu_result, ex_rd2,
    input  logic [4:0]  ex_rd,
    input  logic        ex_zero,
    input  logic        ex_reg_write, ex_mem_read,
    input  logic        ex_mem_write, ex_mem_to_reg, ex_branch,
    output logic [31:0] mem_pc, mem_alu_result, mem_rd2,
    output logic [4:0]  mem_rd,
    output logic        mem_zero,
    output logic        mem_reg_write, mem_mem_read,
    output logic        mem_mem_write, mem_mem_to_reg, mem_branch
);
    always_ff @(posedge clk) begin
        if (rst) begin
            mem_pc         <= 32'd0;
            mem_alu_result <= 32'd0;
            mem_rd2        <= 32'd0;
            mem_rd         <= 5'd0;
            mem_zero       <= 0;
            mem_reg_write  <= 0;
            mem_mem_read   <= 0;
            mem_mem_write  <= 0;
            mem_mem_to_reg <= 0;
            mem_branch     <= 0;
        end else begin
            mem_pc         <= ex_pc;
            mem_alu_result <= ex_alu_result;
            mem_rd2        <= ex_rd2;
            mem_rd         <= ex_rd;
            mem_zero       <= ex_zero;
            mem_reg_write  <= ex_reg_write;
            mem_mem_read   <= ex_mem_read;
            mem_mem_write  <= ex_mem_write;
            mem_mem_to_reg <= ex_mem_to_reg;
            mem_branch     <= ex_branch;
        end
    end
endmodule

// MEM/WB Pipeline Register
module mem_wb_reg (
    input  logic        clk, rst,
    input  logic [31:0] mem_alu_result, mem_read_data,
    input  logic [4:0]  mem_rd,
    input  logic        mem_reg_write, mem_mem_to_reg,
    output logic [31:0] wb_alu_result, wb_read_data,
    output logic [4:0]  wb_rd,
    output logic        wb_reg_write, wb_mem_to_reg
);
    always_ff @(posedge clk) begin
        if (rst) begin
            wb_alu_result <= 32'd0;
            wb_read_data  <= 32'd0;
            wb_rd         <= 5'd0;
            wb_reg_write  <= 0;
            wb_mem_to_reg <= 0;
        end else begin
            wb_alu_result <= mem_alu_result;
            wb_read_data  <= mem_read_data;
            wb_rd         <= mem_rd;
            wb_reg_write  <= mem_reg_write;
            wb_mem_to_reg <= mem_mem_to_reg;
        end
    end
endmodule