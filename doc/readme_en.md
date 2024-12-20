# Lab5 Pipeline CPU

## Project Structure

The project structure is as follows, mainly including the source code for CPU design, linter-related files, and simulation-related files. Since Vivado simulation is time-consuming, I used Verilator as the linter and combined it with the [VS Code plugin](https://marketplace.visualstudio.com/items?itemName=mshr-h.veriloghdl) to check for syntax errors. Simulation files mainly refer to assembly files and Vivado waveform configuration files.

```plaintext
.
├── doc                           # Documentation files
├── linter
│   ├── stub                      # Stub files for linter
│   └── update_linter.sh          # Script to update linter(verilator)
├── project                       # Vivado project files
│   ├── ...                       # Additional Vivado project files
│   └── mycpupipe.xpr             # Main Vivado project file
├── simulation                    # Simulation scripts and files
└── src                           # Source files for the CPU and SoC
    ├── cpu
    │   ├── cpu.sv
    │   ├── memory_control        # Memory control logic
    │   └── pipeline              # Pipeline stages
    │       ├── pipeline.sv
    │       ├── hazard            # Hazard detection logic
    │       ├── stage_regs        # Pipeline stage registers
    │       ├── if                # Instruction fetch stage
    │       ├── id                # Instruction decode stage
    │       ├── ex                # Execute stage
    │       ├── mem               # Memory access stage
    │       └── wb                # Write-back stage
    ├── include                   # Shared include files
    └── soc                       # System-on-Chip design for Simulation
        ├── data_memory.sv
        ├── instruction_memory.sv
        ├── soc_simulation.sv
        └── soc_simulation_tb.sv
```

## Getting Started

### Vivado Project Setup

1. Clone this repo and create a folder (you can use a different name):

   ```sh
   git clone https://github.com/sssxks/mycpupipe.git
   cd mycpupipe
   mkdir project
   ```

2. Create a project in `project/` using Vivado:
   - **Add Design Sources**:
     - Add the `src/` directory to the project.
     - Uncheck `Copy sources into project`, and check `Scan and add RTL include files` and `Add sources from subdirectories`.
   - **Add Simulation Sources**:
     - Add `simulation/soc_simulation_tb_behav.wcfg` to the project.
     - Uncheck `Copy sources into project`.

3. Create the data memory IP core:
   - **Flow Navigator** -> **IP Catalog** -> Search for `block`.
   - Select `Block Memory Generator` and configure as follows:
     - Name: `data_memory_impl`
     - `Memory Type`: `Single Port RAM`
     - `Byte Write Enable`: Checked
     - `Byte Size`: `8`
     - `Write Width` and `Read Width`: `32`
     - `Write Depth` and `Read Depth`: `1024`
     - `Operating Mode`: `Write First`
     - **Important!** `Primitives Output Register`: Unchecked
     - `Load Init File`: Select [simulation/data_memory.coe](../simulation/data_memory.coe)
     - Keep other settings as default.
   - Click `Generate`.

4. Create the instruction memory IP core:
   - **Flow Navigator** -> **IP Catalog** -> Search for `dist`.
   - Select `Distributed Memory Generator` and configure as follows:
     - Name: `instruction_memory_impl`
     - `Memory Type`: `ROM`
     - `Depth`: `1024`
     - `Data Width`: `32`
     - `Load COE File`: Select [simulation/Hazard_Stall.coe](../simulation/Hazard_Stall.coe) or any other COE file you want to use.
     - Keep other settings as default.
   - Click `Generate`.

5. Run a simulation:
   - **Run Simulation** -> **Run Behavioral Simulation**.

## How to Program this CPU?

If you want to use other COE (coefficient) files, you can find some COE files in the `simulation/` directory or write your own. You can use [`build.sh`](../simulation/build.sh) to generate COE files from assembly code. (Note: The COE file format is described [here](https://docs.amd.com/r/en-US/ug896-vivado-ip/COE-File-Syntax))

The basic logic of the script is as follows:

```sh
if ! riscv32-unknown-elf-as -o "$OBJ" "$SRC"; then
    echo "Assembly failed for $SRC"
    exit 1
fi

# Link the object file
if ! riscv32-unknown-elf-ld -T linker.ld -o "$ELF" "$OBJ"; then
    echo "Linking failed for $OBJ"
    exit 1
fi

# Generate disassembly (optional)
if ! riscv32-unknown-elf-objdump -S "$ELF" > "$DUMP"; then
    echo "Objdump failed for $ELF"
    exit 1
fi

# Generate binary file from ELF
if ! riscv32-unknown-elf-objcopy -O binary "$ELF" "$BIN"; then
    echo "Binary extraction failed for $ELF"
    exit 1
fi

# Convert binary to hexadecimal format, 4 bytes per line
if ! xxd -p -c 4 "$BIN" > "$HEX"; then
    echo "Hexadecimal conversion failed for $BIN"
    exit 1
fi

# Adjust the byte order (convert little-endian to big-endian)
if ! awk '
{
    line = $0;
    first = substr(line, 7, 2);  # Byte 4
    second = substr(line, 5, 2); # Byte 3
    third = substr(line, 3, 2);  # Byte 2
    fourth = substr(line, 1, 2); # Byte 1
    printf("%s%s%s%s\n", first, second, third, fourth);
}' "$HEX" > "$HEX_REV"; then
    echo "Byte order adjustment failed for $HEX"
    exit 1
fi

# Format the hexadecimal data as Vivado COE file
echo "memory_initialization_radix=16;" > "$COE"
echo "memory_initialization_vector=" >> "$COE"
sed 's/$/,/' "$HEX_REV" | sed '$ s/,$/;/' >> "$COE"
```

You can also modify the script to compile from C or C++.

### Installing the GNU Cross-Compilation Toolchain

The GNU cross-compilation toolchain used in the script can be installed as follows (using Ubuntu as an example):

```sh
sudo apt update
sudo apt install gcc-riscv64-unknown-elf
```

> **Note**: The package name is divided into three parts: `<architecture>-<vendor>-<OS or environment>`. `elf` indicates that the target environment is an embedded system based on the ELF file format (Executable and Linkable Format), i.e., bare-metal programs.

### Linter Settings

If you want to use the same linter as I do, you can install the [Verilog HDL extension](https://marketplace.visualstudio.com/items?itemName=mshr-h.veriloghdl) in VS Code and use the following configuration:

```json
"verilog.linting.linter": "verilator",
// A little bit of hacking: add # to ignore arguments added by the extension
"verilog.linting.verilator.arguments": "-f linter/verilator.f # ",
```

You can install `verilator` using the following command (Ubuntu):

```sh
sudo apt update
sudo apt install verilator
```

Then, run the `linter/update_linter.sh` script, which will generate a `linter/verilator.f` file to specify the command-line arguments for `verilator`.

## Resources and References

- The textbook used by Zhejiang University:
  - Patterson, David A., and John L. Hennessy. *Computer Organization and Design: The Hardware Software Interface; RISC-V Edition*. San Diego: Elsevier Science & Technology, 2018.
- **Ripes Assembler, CPU, and Cache Simulator (Highly Recommended)**
  <https://github.com/mortbopet/Ripes>
