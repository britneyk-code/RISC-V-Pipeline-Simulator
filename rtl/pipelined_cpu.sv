module pipelined_cpu (
    input  logic        clk,
    input  logic        rst
);

    // ── IF stage wires ──
    logic [31:0] pc, next_pc, pc_plus4;
    logic [31:0] if_instr;

    // ── ID stage wires ──
    logic [31:0] id_pc, id_instr;
    logic [31:0] id_rd1, id_rd2, id_imm;
    logic [4:0]  id_rs1, id_rs2, id_rd;
    logic [2:0]  id_funct3;
    logic [6:0]  id_funct7, id_opcode;
    logic        id_reg_write, id_mem_read, id_mem_write;
    logic        id_mem_to_reg, id_alu_src, id_branch;
    logic [1:0]  id_alu_op;

    // ── EX stage wires ──
    logic [31:0] ex_pc, ex_rd1, ex_rd2, ex_imm;
    logic [4:0]  ex_rs1, ex_rs2, ex_rd;
    logic [2:0]  ex_funct3;
    logic [6:0]  ex_funct7;
    logic        ex_reg_write, ex_mem_read, ex_mem_write;
    logic        ex_mem_to_reg, ex_alu_src, ex_branch;
    logic [1:0]  ex_alu_op;
    logic [3:0]  ex_alu_ctrl;
    logic [31:0] ex_alu_a, ex_alu_b, ex_alu_result;
    logic        ex_alu_zero;

    // ── MEM stage wires ──
    logic [31:0] mem_pc, mem_alu_result, mem_rd2, mem_read_data;
    logic [4:0]  mem_rd;
    logic        mem_zero, mem_reg_write, mem_mem_read;
    logic        mem_mem_write, mem_mem_to_reg, mem_branch;
    logic        mem_branch_taken;

    // ── WB stage wires ──
    logic [31:0] wb_alu_result, wb_read_data, wb_wd;
    logic [4:0]  wb_rd;
    logic        wb_reg_write, wb_mem_to_reg;

    // ── Hazard signals ──
    logic        stall;
    logic        flush;
    logic [1:0]  fwd_a, fwd_b;

    // ── PC logic ──
    assign pc_plus4      = pc + 32'd4;
    assign mem_branch_taken = mem_branch && mem_zero;
    assign next_pc       = mem_branch_taken ? mem_pc : pc_plus4;

    // ── Instruction decode ──
    assign id_opcode = id_instr[6:0];
    assign id_rd     = id_instr[11:7];
    assign id_funct3 = id_instr[14:12];
    assign id_rs1    = id_instr[19:15];
    assign id_rs2    = id_instr[24:20];
    assign id_funct7 = id_instr[31:25];

    // ── Immediate extension ──
    always_comb begin
        case (id_opcode)
            7'b0010011,
            7'b0000011: id_imm = {{20{id_instr[31]}}, id_instr[31:20]};
            7'b0100011: id_imm = {{20{id_instr[31]}}, id_instr[31:25], id_instr[11:7]};
            7'b1100011: id_imm = {{20{id_instr[31]}}, id_instr[7], id_instr[30:25], id_instr[11:8], 1'b0};
            default:    id_imm = 32'd0;
        endcase
    end

    // ── ALU control ──
    always_comb begin
        ex_alu_ctrl = 4'b0000;
        case (ex_alu_op)
            2'b00: ex_alu_ctrl = 4'b0000;
            2'b01: ex_alu_ctrl = 4'b0001;
            2'b10: begin
                if (ex_funct3 == 3'b000)
                    ex_alu_ctrl = (ex_funct7 == 7'b0100000) ? 4'b0001 : 4'b0000;
                else if (ex_funct3 == 3'b111) ex_alu_ctrl = 4'b0010;
                else if (ex_funct3 == 3'b110) ex_alu_ctrl = 4'b0011;
                else if (ex_funct3 == 3'b100) ex_alu_ctrl = 4'b0100;
                else if (ex_funct3 == 3'b010) ex_alu_ctrl = 4'b1000;
                else ex_alu_ctrl = 4'b0000;
            end
            default: ex_alu_ctrl = 4'b0000;
        endcase
    end

    // ── Forwarding muxes ──
    always_comb begin
        case (fwd_a)
            2'b00: ex_alu_a = ex_rd1;
            2'b01: ex_alu_a = wb_wd;
            2'b10: ex_alu_a = mem_alu_result;
            default: ex_alu_a = ex_rd1;
        endcase
        case (fwd_b)
            2'b00: ex_alu_b = ex_alu_src ? ex_imm : ex_rd2;
            2'b01: ex_alu_b = wb_wd;
            2'b10: ex_alu_b = mem_alu_result;
            default: ex_alu_b = ex_alu_src ? ex_imm : ex_rd2;
        endcase
    end

    // ── Writeback data ──
    assign wb_wd = wb_mem_to_reg ? wb_read_data : wb_alu_result;

    // ── Hazard detection ──
    assign stall = ex_mem_read &&
                   ((ex_rd == id_rs1) || (ex_rd == id_rs2));
    assign flush = mem_branch_taken;

    // ── Forwarding unit ──
    always_comb begin
        fwd_a = 2'b00;
        fwd_b = 2'b00;
        if (mem_reg_write && mem_rd != 5'd0 && mem_rd == ex_rs1)
            fwd_a = 2'b10;
        if (mem_reg_write && mem_rd != 5'd0 && mem_rd == ex_rs2)
            fwd_b = 2'b10;
        if (wb_reg_write && wb_rd != 5'd0 && wb_rd == ex_rs1 &&
            !(mem_reg_write && mem_rd != 5'd0 && mem_rd == ex_rs1))
            fwd_a = 2'b01;
        if (wb_reg_write && wb_rd != 5'd0 && wb_rd == ex_rs2 &&
            !(mem_reg_write && mem_rd != 5'd0 && mem_rd == ex_rs2))
            fwd_b = 2'b01;
    end

    // ── Module instances ──
    program_counter PC (
        .clk(clk), .rst(rst), .stall(stall),
        .next_pc(next_pc), .pc(pc)
    );

    instruction_memory IMEM (
        .pc(pc), .instr(if_instr)
    );

    if_id_reg IF_ID (
        .clk(clk), .rst(rst), .stall(stall),
        .if_pc(pc), .if_instr(if_instr),
        .id_pc(id_pc), .id_instr(id_instr)
    );

    control_unit CU (
        .opcode(id_opcode),
        .reg_write(id_reg_write), .mem_read(id_mem_read),
        .mem_write(id_mem_write), .mem_to_reg(id_mem_to_reg),
        .alu_src(id_alu_src), .branch(id_branch), .alu_op(id_alu_op)
    );

    register_file RF (
        .clk(clk), .we(wb_reg_write),
        .rs1(id_rs1), .rs2(id_rs2), .rd(wb_rd),
        .wd(wb_wd), .rd1(id_rd1), .rd2(id_rd2)
    );

    id_ex_reg ID_EX (
        .clk(clk), .rst(rst), .flush(flush),
        .id_pc(id_pc),
        .id_rd1(id_rd1), .id_rd2(id_rd2), .id_imm(id_imm),
        .id_rs1(id_rs1), .id_rs2(id_rs2), .id_rd(id_rd),
        .id_funct3(id_funct3), .id_funct7(id_funct7),
        .id_reg_write(id_reg_write), .id_mem_read(id_mem_read),
        .id_mem_write(id_mem_write), .id_mem_to_reg(id_mem_to_reg),
        .id_alu_src(id_alu_src), .id_branch(id_branch), .id_alu_op(id_alu_op),
        .ex_pc(ex_pc),
        .ex_rd1(ex_rd1), .ex_rd2(ex_rd2), .ex_imm(ex_imm),
        .ex_rs1(ex_rs1), .ex_rs2(ex_rs2), .ex_rd(ex_rd),
        .ex_funct3(ex_funct3), .ex_funct7(ex_funct7),
        .ex_reg_write(ex_reg_write), .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write), .ex_mem_to_reg(ex_mem_to_reg),
        .ex_alu_src(ex_alu_src), .ex_branch(ex_branch), .ex_alu_op(ex_alu_op)
    );

    alu ALU (
        .a(ex_alu_a), .b(ex_alu_b),
        .op(ex_alu_ctrl),
        .result(ex_alu_result), .zero(ex_alu_zero)
    );

    ex_mem_reg EX_MEM (
        .clk(clk), .rst(rst),
        .ex_pc(ex_pc), .ex_alu_result(ex_alu_result),
        .ex_rd2(ex_rd2), .ex_rd(ex_rd), .ex_zero(ex_alu_zero),
        .ex_reg_write(ex_reg_write), .ex_mem_read(ex_mem_read),
        .ex_mem_write(ex_mem_write), .ex_mem_to_reg(ex_mem_to_reg),
        .ex_branch(ex_branch),
        .mem_pc(mem_pc), .mem_alu_result(mem_alu_result),
        .mem_rd2(mem_rd2), .mem_rd(mem_rd), .mem_zero(mem_zero),
        .mem_reg_write(mem_reg_write), .mem_mem_read(mem_mem_read),
        .mem_mem_write(mem_mem_write), .mem_mem_to_reg(mem_mem_to_reg),
        .mem_branch(mem_branch)
    );

    data_memory DMEM (
        .clk(clk), .we(mem_mem_write),
        .addr(mem_alu_result), .wd(mem_rd2),
        .rd(mem_read_data)
    );

    mem_wb_reg MEM_WB (
        .clk(clk), .rst(rst),
        .mem_alu_result(mem_alu_result), .mem_read_data(mem_read_data),
        .mem_rd(mem_rd), .mem_reg_write(mem_reg_write),
        .mem_mem_to_reg(mem_mem_to_reg),
        .wb_alu_result(wb_alu_result), .wb_read_data(wb_read_data),
        .wb_rd(wb_rd), .wb_reg_write(wb_reg_write),
        .wb_mem_to_reg(wb_mem_to_reg)
    );

endmodule