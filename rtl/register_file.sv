module register_file (
    input  logic        clk,
    input  logic        we,          // write enable
    input  logic [4:0]  rs1,         // source register 1
    input  logic [4:0]  rs2,         // source register 2
    input  logic [4:0]  rd,          // destination register
    input  logic [31:0] wd,          // write data
    output logic [31:0] rd1,         // read data 1
    output logic [31:0] rd2          // read data 2
);

    logic [31:0] registers [31:0];   // 32 registers, each 32 bits wide

    // x0 is always 0 in RISC-V
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'd0;
    end

    // Write on rising clock edge
    always_ff @(posedge clk) begin
        if (we && rd != 5'd0)        // never write to x0
            registers[rd] <= wd;
    end

    // Read is combinational (immediate)
    assign rd1 = (rs1 != 5'd0) ? registers[rs1] : 32'd0;
    assign rd2 = (rs2 != 5'd0) ? registers[rs2] : 32'd0;

endmodule