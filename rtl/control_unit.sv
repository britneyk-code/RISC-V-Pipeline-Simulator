module control_unit (
    input  logic [6:0]  opcode,      // bits [6:0] of the instruction
    output logic        reg_write,   // write to register file?
    output logic        mem_read,    // read from data memory?
    output logic        mem_write,   // write to data memory?
    output logic        mem_to_reg,  // send memory data to register?
    output logic        alu_src,     // ALU second input from immediate or register?
    output logic        branch,      // is this a branch instruction?
    output logic [1:0]  alu_op       // hint to ALU control what operation to do
);

    always_comb begin
        // default all signals to 0
        reg_write  = 0;
        mem_read   = 0;
        mem_write  = 0;
        mem_to_reg = 0;
        alu_src    = 0;
        branch     = 0;
        alu_op     = 2'b00;

        case (opcode)
            7'b0110011: begin // R-type (add, sub, and, or, xor)
                reg_write = 1;
                alu_op    = 2'b10;
            end
            7'b0010011: begin // I-type (addi, andi, ori)
                reg_write = 1;
                alu_src   = 1;
                alu_op    = 2'b10;
            end
            7'b0000011: begin // Load (lw)
                reg_write  = 1;
                mem_read   = 1;
                mem_to_reg = 1;
                alu_src    = 1;
                alu_op     = 2'b00;
            end
            7'b0100011: begin // Store (sw)
                mem_write = 1;
                alu_src   = 1;
                alu_op    = 2'b00;
            end
            7'b1100011: begin // Branch (beq)
                branch = 1;
                alu_op = 2'b01;
            end
            default: begin
                // NOP - do nothing
            end
        endcase
    end

endmodule