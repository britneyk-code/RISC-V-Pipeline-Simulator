module data_memory (
    input  logic        clk,
    input  logic        we,          // write enable
    input  logic [31:0] addr,        // address to read/write
    input  logic [31:0] wd,          // data to write
    output logic [31:0] rd           // data read out
);

    logic [31:0] mem [0:255];        // 256 words of data memory

    // Write on rising clock edge
    always_ff @(posedge clk) begin
        if (we)
            mem[addr[9:2]] <= wd;
    end

    // Read is combinational
    assign rd = mem[addr[9:2]];

endmodule