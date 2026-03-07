# RISC-V Pipelined CPU — SystemVerilog RTL Implementation

A fully functional 5-stage pipelined RISC-V (RV32I) processor implemented in
synthesizable SystemVerilog RTL, built from scratch including hazard detection
and data forwarding.

## Architecture Overview
```
IF → ID → EX → MEM → WB
```

Each stage is separated by pipeline registers that carry instructions and
control signals forward every clock cycle, allowing up to 5 instructions
to execute simultaneously.

## Features

- **5-stage pipeline** — Fetch, Decode, Execute, Memory, Writeback
- **Hazard detection unit** — detects load-use data hazards and inserts stalls
- **Data forwarding** — resolves EX-EX and MEM-EX hazards without stalling
- **Branch handling** — detects taken branches in MEM stage and flushes pipeline
- **Full RV32I support** — R-type, I-type, Load, Store, and Branch instructions
- **Synthesizable RTL** — clean module interfaces designed for FPGA integration

## Module Structure

| Module | Description |
|--------|-------------|
| `pipelined_cpu.sv` | Top-level CPU connecting all stages |
| `pipeline_registers.sv` | IF/ID, ID/EX, EX/MEM, MEM/WB registers |
| `alu.sv` | 32-bit ALU supporting ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT |
| `register_file.sv` | 32x32-bit register file, x0 hardwired to zero |
| `control_unit.sv` | Decodes opcode and generates control signals |
| `instruction_memory.sv` | Synchronous instruction memory, hex program loading |
| `data_memory.sv` | Synchronous read/write data memory |
| `program_counter.sv` | PC with synchronous reset and stall support |
| `single_cycle_cpu.sv` | Single-cycle implementation (reference design) |

## Simulation

### Requirements
- Icarus Verilog 13.0+
- GTKWave (optional, for waveform viewing)

### Run pipelined CPU simulation
```bash
iverilog -g2012 -o sim/pipelined_cpu_tb \
  rtl/pipelined_cpu.sv \
  rtl/pipeline_registers.sv \
  rtl/program_counter.sv \
  rtl/instruction_memory.sv \
  rtl/control_unit.sv \
  rtl/register_file.sv \
  rtl/alu.sv \
  rtl/data_memory.sv \
  tb/pipelined_cpu_tb.sv && vvp sim/pipelined_cpu_tb
```

### Expected output
```
=== Final Results ===
x1 = 5  (expected 5)
x2 = 10 (expected 10)
x3 = 15 (expected 15)
```

## Pipeline Diagram
```
Cycle:   1    2    3    4    5    6    7
addi x1  IF   ID   EX   MEM  WB
addi x2       IF   ID   EX   MEM  WB
add  x3            IF   ID   EX   MEM  WB
```

## Hazard Handling

**Data hazards** are resolved through forwarding — when an instruction in EX
needs a result being computed by the previous instruction, the result is
forwarded directly from the EX/MEM or MEM/WB pipeline register instead of
waiting for writeback.

**Load-use hazards** cannot be resolved by forwarding alone — the pipeline
stalls for one cycle while the load completes, then forwards the result.

**Control hazards** are handled by flushing the two instructions fetched
after a taken branch.

## Sample Program

The included `sim/program.hex` runs this program:
```
addi x1, x0, 5     # x1 = 5
addi x2, x0, 10    # x2 = 10
add  x3, x1, x2    # x3 = 15
```

## Author

Britney Kunchidi — Computing Science, University of Alberta  
Built as part of a deep dive into computer architecture and RTL design.