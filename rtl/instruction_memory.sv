module instruction_memory (
    input  logic [31:0] pc,          // address to fetch from
    output logic [31:0] instr        // instruction at that address
);

    logic [31:0] mem [0:255];        // 256 words of instruction memory

    // Load instructions from a file
    initial begin
        $readmemh("sim/program.hex", mem);
    end

    // Read is combinational — give instruction immediately
    assign instr = mem[pc[9:2]];     // pc[9:2] converts byte address to word index

endmodule