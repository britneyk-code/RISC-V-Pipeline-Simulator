module single_cycle_cpu_tb;

    logic clk, rst;

    single_cycle_cpu dut (
        .clk(clk),
        .rst(rst)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("sim/single_cycle_cpu.vcd");
        $dumpvars(0, single_cycle_cpu_tb);

        clk = 0; rst = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;

        repeat(10) begin
            #1;
            $display("PC=%0d instr=%h opcode=%b rs1=%0d rs2=%0d rd=%0d reg_write=%b alu_ctrl=%b alu_a=%0d alu_b=%0d alu_result=%0d x3=%0d",
                dut.pc, dut.instr, dut.opcode,
                dut.rs1, dut.rs2, dut.rd,
                dut.reg_write,
                dut.alu_ctrl,
                dut.alu_a, dut.alu_b,
                dut.alu_result,
                dut.RF.registers[3]);
            @(posedge clk);
        end

        $finish;
    end

endmodule