module data_memory_tb;

    logic        clk, we;
    logic [31:0] addr, wd, rd;

    // Connect testbench to data memory
    data_memory dut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .wd(wd),
        .rd(rd)
    );

    // Generate clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/data_memory.vcd");
        $dumpvars(0, data_memory_tb);

        clk = 0; we = 0;

        // Test 1: write 42 to address 0, read it back
        we = 1; addr = 32'd0; wd = 32'd42;
        @(posedge clk); #1;
        we = 0;
        #5;
        $display("Test 1 - Write/Read addr=0: got %0d (expected 42)", rd);

        // Test 2: write 100 to address 4, read it back
        we = 1; addr = 32'd4; wd = 32'd100;
        @(posedge clk); #1;
        we = 0; addr = 32'd4;
        #5;
        $display("Test 2 - Write/Read addr=4: got %0d (expected 100)", rd);

        // Test 3: read address 0 again, should still be 42
        addr = 32'd0; #5;
        $display("Test 3 - Read addr=0 again: got %0d (expected 42)", rd);

        // Test 4: write disabled, value should not change
        we = 0; addr = 32'd0; wd = 32'd999;
        @(posedge clk); #1;
        #5;
        $display("Test 4 - Write disabled: got %0d (expected 42)", rd);

        // Test 5: overwrite address 0 with new value
        we = 1; addr = 32'd0; wd = 32'd777;
        @(posedge clk); #1;
        we = 0;
        #5;
        $display("Test 5 - Overwrite addr=0: got %0d (expected 777)", rd);

        $display("Data memory tests done!");
        $finish;
    end

endmodule