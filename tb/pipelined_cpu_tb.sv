module pipelined_cpu_tb;

    logic clk, rst;

    pipelined_cpu dut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/pipelined_cpu.vcd");
        $dumpvars(0, pipelined_cpu_tb);

        clk = 0; rst = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;

        // Run enough cycles for pipeline to fill and complete
        repeat(20) begin
            #1;
            $display("PC=%0d x1=%0d x2=%0d x3=%0d",
                dut.pc,
                dut.RF.registers[1],
                dut.RF.registers[2],
                dut.RF.registers[3]);
            @(posedge clk);
        end

        $display("=== Final Results ===");
        $display("x1 = %0d (expected 5)",  dut.RF.registers[1]);
        $display("x2 = %0d (expected 10)", dut.RF.registers[2]);
        $display("x3 = %0d (expected 15)", dut.RF.registers[3]);

        $finish;
    end

endmodule