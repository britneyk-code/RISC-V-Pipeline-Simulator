module instruction_memory_tb;

    logic [31:0] pc, instr;

    // Connect testbench to instruction memory
    instruction_memory dut (
        .pc(pc),
        .instr(instr)
    );

    initial begin
        $dumpfile("sim/instruction_memory.vcd");
        $dumpvars(0, instruction_memory_tb);

        // Test 1: fetch instruction at address 0
        pc = 32'd0; #10;
        $display("Test 1 - PC=0: instr=%h (expected 00500093)", instr);

        // Test 2: fetch instruction at address 4
        pc = 32'd4; #10;
        $display("Test 2 - PC=4: instr=%h (expected 00a00113)", instr);

        // Test 3: fetch instruction at address 8
        pc = 32'd8; #10;
        $display("Test 3 - PC=8: instr=%h (expected 00208233)", instr);

        // Test 4: fetch instruction at address 12
        pc = 32'd12; #10;
        $display("Test 4 - PC=12: instr=%h (expected 00000013)", instr);

        $display("Instruction memory tests done!");
        $finish;
    end

endmodule