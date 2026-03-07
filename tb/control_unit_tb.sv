module control_unit_tb;

    logic [6:0] opcode;
    logic       reg_write, mem_read, mem_write, mem_to_reg, alu_src, branch;
    logic [1:0] alu_op;

    // Connect testbench to control unit
    control_unit dut (
        .opcode(opcode),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .alu_op(alu_op)
    );

    initial begin
        $dumpfile("sim/control_unit.vcd");
        $dumpvars(0, control_unit_tb);

        // Test 1: R-type (add, sub, and, or)
        opcode = 7'b0110011; #10;
        $display("Test 1 - R-type: reg_write=%b alu_op=%b (expected 1, 10)", reg_write, alu_op);

        // Test 2: I-type (addi, andi)
        opcode = 7'b0010011; #10;
        $display("Test 2 - I-type: reg_write=%b alu_src=%b (expected 1, 1)", reg_write, alu_src);

        // Test 3: Load (lw)
        opcode = 7'b0000011; #10;
        $display("Test 3 - Load: reg_write=%b mem_read=%b mem_to_reg=%b (expected 1, 1, 1)", reg_write, mem_read, mem_to_reg);

        // Test 4: Store (sw)
        opcode = 7'b0100011; #10;
        $display("Test 4 - Store: mem_write=%b alu_src=%b (expected 1, 1)", mem_write, alu_src);

        // Test 5: Branch (beq)
        opcode = 7'b1100011; #10;
        $display("Test 5 - Branch: branch=%b alu_op=%b (expected 1, 01)", branch, alu_op);

        // Test 6: Unknown opcode, everything should be 0
        opcode = 7'b1111111; #10;
        $display("Test 6 - Unknown: reg_write=%b mem_read=%b mem_write=%b branch=%b (expected 0,0,0,0)", reg_write, mem_read, mem_write, branch);

        $display("Control unit tests done!");
        $finish;
    end

endmodule