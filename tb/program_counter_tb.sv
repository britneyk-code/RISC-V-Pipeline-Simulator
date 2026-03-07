module program_counter_tb;

    logic        clk, rst, stall;
    logic [31:0] next_pc, pc;

    // Connect testbench to program counter
    program_counter dut (
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .next_pc(next_pc),
        .pc(pc)
    );

    // Generate clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/program_counter.vcd");
        $dumpvars(0, program_counter_tb);

        clk = 0; rst = 1; stall = 0; next_pc = 32'd0;

        // Test 1: reset holds PC at 0
        @(posedge clk); #1;
        $display("Test 1 - Reset: pc=%0d (expected 0)", pc);

        // Test 2: release reset, PC advances
        rst = 0; next_pc = 32'd4;
        @(posedge clk); #1;
        $display("Test 2 - Advance: pc=%0d (expected 4)", pc);

        // Test 3: keep advancing
        next_pc = 32'd8;
        @(posedge clk); #1;
        $display("Test 3 - Advance: pc=%0d (expected 8)", pc);

        // Test 4: stall freezes PC
        stall = 1; next_pc = 32'd12;
        @(posedge clk); #1;
        $display("Test 4 - Stall: pc=%0d (expected 8)", pc);

        // Test 5: release stall, PC advances again
        stall = 0; next_pc = 32'd12;
        @(posedge clk); #1;
        $display("Test 5 - Unstall: pc=%0d (expected 12)", pc);

        // Test 6: reset mid-execution
        rst = 1;
        @(posedge clk); #1;
        $display("Test 6 - Mid reset: pc=%0d (expected 0)", pc);

        $display("Program counter tests done!");
        $finish;
    end

endmodule