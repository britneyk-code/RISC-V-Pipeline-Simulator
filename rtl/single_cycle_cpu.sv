module single_cycle_cpu (
    input  logic        clk,
    input  logic        rst
);

    // ── Wires connecting all modules ──
    logic [31:0] pc, next_pc, pc_plus4;
    logic [31:0] instr;
    logic [31:0] reg_rd1, reg_rd2;
    logic [31:0] imm_ext;
    logic [31:0] alu_a, alu_b, alu_result;
    logic [31:0] mem_rd;
    logic [31:0] reg_wd;
    logic        alu_zero;
    logic        branch_taken;

    // ── Control signals ──
    logic        reg_write, mem_read, mem_write;
    logic        mem_to_reg, alu_src, branch;
    logic [1:0]  alu_op;
    logic [3:0]  alu_ctrl;

    // ── Instruction fields ──
    logic [6:0]  opcode;
    logic [4:0]  rs1, rs2, rd;
    logic [2:0]  funct3;
    logic [6:0]  funct7;

    // ── Decode instruction fields ──
    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];

    // ── Immediate extension ──
    always_comb begin
        case (opcode)
            7'b0010011,
            7'b0000011: imm_ext = {{20{instr[31]}}, instr[31:20]};           // I-type
            7'b0100011: imm_ext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type
            7'b1100011: imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
            default:    imm_ext = 32'd0;
        endcase
    end

    // ── ALU control ──
    always_comb begin
        alu_ctrl = 4'b0000; // default ADD
        case (alu_op)
            2'b00: alu_ctrl = 4'b0000;  // ADD (load/store)
            2'b01: alu_ctrl = 4'b0001;  // SUB (branch)
            2'b10: begin
                if (funct3 == 3'b000)
                    alu_ctrl = (funct7 == 7'b0100000) ? 4'b0001 : 4'b0000;
                else if (funct3 == 3'b111) alu_ctrl = 4'b0010;
                else if (funct3 == 3'b110) alu_ctrl = 4'b0011;
                else if (funct3 == 3'b100) alu_ctrl = 4'b0100;
                else if (funct3 == 3'b010) alu_ctrl = 4'b1000;
                else alu_ctrl = 4'b0000;
            end
            default: alu_ctrl = 4'b0000;
        endcase
    end

    // ── PC logic ──
    assign pc_plus4    = pc + 32'd4;
    assign branch_taken = branch && alu_zero;
    assign next_pc     = branch_taken ? (pc + imm_ext) : pc_plus4;

    // ── ALU inputs ──
    assign alu_a = reg_rd1;
    assign alu_b = alu_src ? imm_ext : reg_rd2;

    // ── Writeback ──
    assign reg_wd = mem_to_reg ? mem_rd : alu_result;

    // ── Module instances ──
    program_counter PC (
        .clk(clk), .rst(rst), .stall(1'b0),
        .next_pc(next_pc), .pc(pc)
    );

    instruction_memory IMEM (
        .pc(pc), .instr(instr)
    );

    control_unit CU (
        .opcode(opcode),
        .reg_write(reg_write), .mem_read(mem_read),
        .mem_write(mem_write), .mem_to_reg(mem_to_reg),
        .alu_src(alu_src), .branch(branch), .alu_op(alu_op)
    );

    register_file RF (
        .clk(clk), .we(reg_write),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .wd(reg_wd), .rd1(reg_rd1), .rd2(reg_rd2)
    );

    alu ALU (
        .a(alu_a), .b(alu_b),
        .op(alu_ctrl),
        .result(alu_result), .zero(alu_zero)
    );

    data_memory DMEM (
        .clk(clk), .we(mem_write),
        .addr(alu_result), .wd(reg_rd2),
        .rd(mem_rd)
    );

endmodule