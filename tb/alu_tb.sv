
module alu_tb;

    logic [31:0] a, b, result;
    logic [3:0]  op;
    logic        zero;

    // Connect testbench to ALU
    alu dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .zero(zero)
    );

    initial begin
        $dumpfile("sim/alu.vcd");
        $dumpvars(0, alu_tb);

        // Test ADD
        a = 32'd10; b = 32'd5; op = 4'b0000;
        #10;
        $display("ADD: %0d + %0d = %0d (expected 15)", a, b, result);

        // Test SUB
        a = 32'd10; b = 32'd10; op = 4'b0001;
        #10;
        $display("SUB: %0d - %0d = %0d | zero = %0b (expected 0, zero=1)", a, b, result, zero);

        // Test AND
        a = 32'hFF; b = 32'h0F; op = 4'b0010;
        #10;
        $display("AND: %0h & %0h = %0h (expected 0f)", a, b, result);

        // Test OR
        a = 32'hF0; b = 32'h0F; op = 4'b0011;
        #10;
        $display("OR: %0h | %0h = %0h (expected ff)", a, b, result);

        // Test SLT
        a = 32'd3; b = 32'd7; op = 4'b1000;
        #10;
        $display("SLT: %0d < %0d = %0d (expected 1)", a, b, result);

        $display("ALU tests done!");
        $finish;
    end

endmodule