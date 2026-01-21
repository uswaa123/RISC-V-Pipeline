# RISC-V 5-Stage Pipelined Processor

This repository contains a SystemVerilog implementation of a 32-bit RISC-V processor using a classic **5-stage pipeline** architecture.

## Architecture

The processor implements the standard RISC-V integer instruction set (RV32I subset) with the following five pipeline stages:

1.  **IF (Instruction Fetch)**: Fetches the instruction from instruction memory using the Program Counter (PC).
2.  **ID (Instruction Decode)**: Decodes the instruction, reads from the Register File, and generates control signals. Resolves hazards and stalls if necessary.
3.  **EX (Execute)**: Performs ALU operations, calculates branch targets, and handles data forwarding to resolve data hazards.
4.  **MEM (Memory Access)**: Accesses Data Memory for load/store instructions.
5.  **WB (Write Back)**: Writes the result (from ALU or Memory) back to the Register File.

### Key Features
*   **Pipelining**: Increases instruction throughput.
*   **Forwarding Unit**: Solves data hazards (Read-After-Write) by forwarding data from MEM and WB stages to the EX stage.
*   **Hazard Detection Unit**: Detects Load-Use hazards and inserts stalls to maintain correctness.
*   **Dynamic Branch Prediction (Static Assumption)**: Branches are assumed not taken (flushed if taken).

## Directory Structure

*   `processor.sv`: Top-level module connecting all pipeline stages.
*   **Pipeline Registers**:
    *   `if_id_reg.sv`: IF/ID Stage Register.
    *   `id_ex_reg.sv`: ID/EX Stage Register.
    *   `ex_mem_reg.sv`: EX/MEM Stage Register.
    *   `mem_wb_reg.sv`: MEM/WB Stage Register.
*   **Hazard Handling**:
    *   `forwarding_unit.sv`: Controls operand forwarding.
    *   `hazard_detection_unit.sv`: Controls pipeline stalls.
*   **Core Components**:
    *   `alu.sv`, `alu_mux.sv`: Arithmetic Logic Unit and operand selection.
    *   `reg_file.sv`: 32x32 Register File.
    *   `inst_mem.sv`, `data_mem.sv`: Instruction and Data Memories.
    *   `controller.sv`: Main Control Unit.
    *   `imm_gen.sv`: Immediate value generator.
    *   `branch_cond_gen.sv`: Branch condition logic.

## Simulation

A testbench is provided in `tb_processor.sv`. It instantiates the processor, initializes memory from hex files (`instruction_memory`, `data_memory`, `register_file`), and generates a VCD file for waveform analysis.

To run the simulation (requires Verilog or ModelSim/Questa):

```bash
# Compilation
vlog *.sv

# Execution
vsim -c tb_processor -voptargs=+acc -do "run -all"

# Waveform Viewing
vsim -gtkwave processor.vcd
```

## How to Use

1. Clone this repository:
     #git clone 
2. Open the project in VsCode and ensure you have the necessary SystemVerilog extensions installed.
3. Compile the SystemVerilog files using your preffered simulator.
4. Use GTKWAVE to to visualize the waveform, but note that Multisim is required to run GTKWave.
5. Run the testbench to observe the processor's functionality.
   
