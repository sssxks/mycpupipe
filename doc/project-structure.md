# Documentation

## Project Structure

The following is an overview of the project directory structure:

```plaintext
.
├── doc                 # Documentation and supporting files
├── linter              # Linter tools and scripts
│   ├── stub
│   ├── update_linter.sh
├── project             # Vivado project files
│   ├── ...             # Additional Vivado project files
│   └── mycpupipe.xpr   # Main Vivado project file
├── simulation          # Simulation scripts and files
└── src                 # Source files for the CPU and SoC
    ├── cpu             # Main CPU design
    │   ├── cpu.sv
    │   ├── memory_control
    │   └── pipeline
    ├── include         # Shared include files
    │   ├── control_signals.sv
    │   ├── definitions.sv
    │   ├── pipeline_flow.sv
    │   └── register_file_type.sv
    └── soc             # System-on-Chip design
        ├── data_memory.sv
        ├── instruction_memory.sv
        ├── soc_simulation.sv
        └── soc_simulation_tb.sv
```

## Pipeline Overview

The RISC-V architecture uses a 5-stage pipeline CPU design to improve instruction throughput. The stages are:

1. **Instruction Fetch (IF)**: Fetch the instruction from memory.
2. **Instruction Decode (ID)**: Decode the fetched instruction and read registers.
3. **Execute (EX)**: Perform arithmetic or logical operations in the ALU, calculate branches, or prepare memory addresses.
4. **Memory Access (MEM)**: Access memory for load or store instructions.
5. **Write-Back (WB)**: Write results back to registers.

Data passes through these stages via designated **flows** (forward and backward). Forward flows transmit data and control signals between stages, while backward flows handle stall and flush signals (e.g., WB → ID and EX → IF).

## Naming Conventions

- **Datapath Signals**: Use `lower_case_with_underscores`.
- **Control Signals**: Use `CamelCase`.
- **Structs**: Use `_t` suffix (e.g., `mem_wb_flow_t`).
- **Constants**: Use `UPPER_CASE_WITH_UNDERSCORES`.

## Pipeline Flows

Pipeline data flows (forward flows) are grouped into structs and defined in the `pipeline_flow.sv` file. Each struct corresponds to the data passed between two pipeline stages.

### Forward Flows

about to change
<!-- 1. **`if_id_flow_t`: From Instruction Fetch (IF) to Instruction Decode (ID)**
   - `logic [31:0] pc`: Program Counter.
   - `logic [31:0] instr`: Instruction fetched from memory.

2. **`id_ex_flow_t`: From Instruction Decode (ID) to Execute (EX)**
   - `logic [31:0] pc`: Program Counter.
   - `logic [31:0] rs1_data`: Data of source register 1.
   - `logic [31:0] rs2_data`: Data of source register 2.
   - `logic [4:0] rd_addr`: Destination register address.
   - `logic [31:0] immediate`: Immediate value.
   - `ex_control_t ex_ctrl`: Execution control signals (see [Control Signals](#control-signals)).
   - `mem_control_t mem_ctrl`: Memory control signals.
   - `wb_control_t wb_ctrl`: Write-back control signals.

3. **`ex_mem_flow_t`: From Execute (EX) to Memory Access (MEM)**
   - Includes ALU results, PC updates, and downstream control signals. Key fields:
     - `logic [31:0] alu_result`: Result from ALU operations.
     - `logic zero`: Zero flag from the ALU (used for branching decisions).

4. **`mem_wb_flow_t`: From Memory Access (MEM) to Write-Back (WB)**
   - Key fields in this stage include data read from memory and settings for writing back results:
     - `logic [31:0] data_in`: Data read from memory.
     - `logic [31:0] pc_write`: Program Counter value to write back. -->

### Backward Flows

Backward flows include MEM -> IF and WB -> ID.

<!-- - **From Memory Access (MEM) to Instruction Fetch (IF)**
  - `logic PCSrc`: Determines the source of the next PC value.
  - `logic [31:0] pc_offset`: Offset to add to the current PC.
- **From Write-Back (WB) to Instruction Decode (ID)**
  - `logic RegWrite`: Enables register write-back.
  - `logic [4:0] rd_addr`: Destination register address.
  - `logic [31:0] rd_data`: Data to write back. -->

## Control Signals

Control signals are defined in the `control_signals.sv` file and are organized by the pipeline stage they control. Each stage has its own control signal struct:

### Instruction Decode (ID)

<!-- - `logic [2:0] ImmSel`: Immediate generator selection.
  - Determines the type of immediate (e.g., I-type, S-type, SB-type, UJ-type). -->

### Execute (EX)

<!-- - `logic [3:0] ALUControl`: Operation code for the ALU.
- `logic ALUSrcB`: Determines ALU source operand (register or immediate). -->

### Memory Access (MEM)

<!-- - `logic MemRW`: Control signal for memory read/write operations.
- `logic [2:0] RWType`: Determines the type of access (e.g., byte, half-word).
- `logic Branch`, `logic Jump`: Signals for conditional/unconditional branches.
- `logic InverseBranch`: Optional inversion for branch conditions. -->

### Write-Back (WB)

<!-- - `logic [1:0] MemtoReg`: Determines the data to write back (e.g., ALU result, memory data).
- `logic RegWrite`: Enables register write-back. -->

## Memory Access Support

To handle diverse memory access types (e.g., byte, half-word), the `RWType` signal in the `mem_control_t` struct is used. The supported access modes are:

| RWType   | Description         |
|----------|---------------------|
| `3'b000` | Byte (signed)       |
| `3'b100` | Byte (unsigned)     |
| `3'b001` | Half-word (signed)  |
| `3'b101` | Half-word (unsigned)|
| `3'b010` | Word                |

Vivado block memory natively supports word access only. The `memory_handler` module translates these access types to ensure compatibility.
