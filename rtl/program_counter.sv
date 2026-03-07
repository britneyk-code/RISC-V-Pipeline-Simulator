module program_counter (
    input  logic        clk,
    input  logic        rst,         // reset
    input  logic        stall,       // freeze PC (we'll use this later for hazards)
    input  logic [31:0] next_pc,     // next address to jump to
    output logic [31:0] pc           // current address
);

    always_ff @(posedge clk) begin
        if (rst)
            pc <= 32'd0;             // on reset, go back to address 0
        else if (!stall)
            pc <= next_pc;           // otherwise advance to next address
    end

endmodule