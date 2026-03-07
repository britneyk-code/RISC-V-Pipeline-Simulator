module register_file_tb;

    logic        clk, we;
    logic [4:0]  rs1, rs2, rd;
    logic [31:0] wd, rd1, rd2;

    // Connect testbench to register file
    register_file dut (
        .clk(clk),
        .we(we),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .wd(wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    // Generate clock — flips every 5 time units
    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/register_file.vcd");
        $dumpvars(0, register_file_tb);

        clk = 0; we = 0;

        // Test 1: write 42 to x1, then read it back
        we = 1; rd = 5'd1; wd = 32'd42;
        @(posedge clk); #1;
        rs1 = 5'd1;
        #5;
        $display("Test 1 - Write/Read x1: got %0d (expected 42)", rd1);

        // Test 2: write 100 to x2, read both x1 and x2
        we = 1; rd = 5'd2; wd = 32'd100;
        @(posedge clk); #1;
        rs1 = 5'd1; rs2 = 5'd2;
        #5;
        $display("Test 2 - Read x1=%0d (expected 42), x2=%0d (expected 100)", rd1, rd2);

        // Test 3: try to write to x0, should stay 0
        we = 1; rd = 5'd0; wd = 32'd999;
        @(posedge clk); #1;
        rs1 = 5'd0;
        #5;
        $display("Test 3 - Write to x0: got %0d (expected 0)", rd1);

        // Test 4: write enable off, value should not change
        we = 0; rd = 5'd1; wd = 32'd999;
        @(posedge clk); #1;
        rs1 = 5'd1;
        #5;
        $display("Test 4 - Write disabled: x1=%0d (expected 42)", rd1);

        $display("Register file tests done!");
        $finish;
    end

endmodule