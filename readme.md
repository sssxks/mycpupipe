# Lab5 Pipeline CPU

浙大计组 2024 秋冬的 Lab5，实现了一个简单的 CPU 流水线。  
This project is Lab5 of Zhejiang University's Computer Organization course for Fall-Winter 2024, implementing a simple CPU pipeline.

CPU 的设计介绍见 [my-pipe-design.md](./doc/my-pipe-design.md)。  
The CPU design is introduced in [my-pipe-design.md](./doc/my-pipe-design.md).

[readme_en.md](./readme_en.md)

[实验报告 Report](./doc/report/report.typ) clone项目后即可查看pdf

## 项目结构

项目结构如下所示，主要包含了 CPU 设计的源代码、linter 相关文件以及仿真相关文件。由于 Vivado 仿真耗时较长，我使用了 Verilator 作为 linter，并结合 [VS Code 插件](https://marketplace.visualstudio.com/items?itemName=mshr-h.veriloghdl) 用于检查语法错误。仿真文件主要指的是汇编以及 Vivado 波形图配置文件。

```plaintext
.
├── doc                           # 文档文件
├── linter
│   ├── stub                      # 欺骗 linter 的源码
│   └── update_linter.sh          # 更新 linter (Verilator) 的脚本
├── project                       # Vivado 项目文件
│   ├── ...                       # 其他 Vivado 项目文件
│   └── mycpupipe.xpr             # Vivado 项目文件
├── simulation                    # 仿真脚本和文件
└── src                           # CPU 和 SoC 的源代码
    ├── cpu
    │   ├── cpu.sv
    │   ├── memory_control        # 内存控制逻辑
    │   └── pipeline              # 流水线阶段
    │       ├── pipeline.sv
    │       ├── hazard            # 冒险检测逻辑
    │       ├── stage_regs        # 流水线阶段寄存器
    │       ├── if                # 指令取指阶段
    │       ├── id                # 指令译码阶段
    │       ├── ex                # 执行阶段
    │       ├── mem               # 内存访问阶段
    │       └── wb                # 写回阶段
    ├── include                   # 共享的 include 文件
    └── soc                       # 用于仿真的片上系统设计
        ├── data_memory.sv
        ├── instruction_memory.sv
        ├── soc_simulation.sv
        └── soc_simulation_tb.sv
```

## 快速开始

### Vivado 项目设置

1. Clone 这个 repo，然后创建一个文件夹（你可以用别的名字）：

   ```sh
   git clone https://github.com/sssxks/mycpupipe.git
   cd mycpupipe
   mkdir project
   ```

2. 用 Vivado 在 `project/` 创建项目：
   - **添加 Design Sources**：
     - 将 `src/` 目录添加到项目中。
     - 不勾选 `Copy sources into project`，勾选 `Scan and add RTL include files` 和 `Add sources from subdirectories`。
   - **添加 Simulation Sources**：
     - 将 `simulation/soc_simulation_tb_behav.wcfg` 添加到项目中。
     - 不勾选 `Copy sources into project`。

3. 创建数据内存 IP 核：
   - **Flow Navigator** -> **IP Catalog** -> 搜索 `block`。
   - 选择 `Block Memory Generator`，并设置如下：
     - 名字：`data_memory_impl`
     - `Memory Type`：`Single Port RAM`
     - `Byte Write Enable`：打勾
     - `Byte Size`：`8`
     - `Write Width` 和 `Read Width`：`32`
     - `Write Depth` 和 `Read Depth`：`1024`
     - `Operating Mode`：`Write First`
     - **重要！** `Primitives Output Register`：取消打勾
     - `Load Init File`：选择 [simulation/data_memory.coe](./simulation/data_memory.coe)
     - 其他保持默认。
   - 点击 `Generate`。

4. 创建指令内存 IP 核：
   - **Flow Navigator** -> **IP Catalog** -> 搜索 `dist`。
   - 选择 `Distributed Memory Generator`，并设置如下：
     - 名字：`instruction_memory_impl`
     - `Memory Type`：`ROM`
     - `Depth`：`1024`
     - `Data Width`：`32`
     - `Load COE File`：选择 [simulation/Hazard_Stall.coe](./simulation/Hazard_Stall.coe)，或者你想用的其他 COE 文件。
     - 其他保持默认。
   - 点击 `Generate`。

5. 跑个仿真：
   - **Run Simulation** -> **Run Behavioral Simulation**。

### Linter 设置

如果你想用和我一样的 linter，你可以在 VS Code 中安装 [Verilog HDL 插件](https://marketplace.visualstudio.com/items?itemName=mshr-h.veriloghdl) ，并使用以下配置：

```json
"verilog.linting.linter": "verilator",
// a little bit of hacking, put # to ignore arguments added by extension
"verilog.linting.verilator.arguments": "-f linter/verilator.f # ",
```

`verilator` 可以通过以下命令安装 (Ubuntu)：

```sh
sudo apt update
sudo apt install verilator
```

然后运行 `linter/update_linter.sh` 脚本，它会生成一个 `linter/verilator.f` 文件，用于指定 verilator 的命令行参数。

## 如何编程这个 CPU？

如果你想用其他的 COE (coefficient)文件，可以在 `simulation/` 目录下找到一些 COE 文件，或者自己写一个 COE 文件。可以使用 [`build.sh`](./simulation/build.sh) 从汇编代码生成 COE 文件。（注：COE 文件的格式见 [这里](https://docs.amd.com/r/en-US/ug896-vivado-ip/COE-File-Syntax)）

以下是脚本的基本逻辑：

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

你也可以修改脚本，从 C 或 C++ 编译。

### 安装 GNU 交叉编译 Toolchain

脚本用到的 GNU 交叉编译 toolchain 可以这样安装（以 Ubuntu 为例）：

```sh
sudo apt update
sudo apt install gcc-riscv64-unknown-elf
```

> **注意**：这个 package 的命名分成三部分：`<架构>-<供应商>-<操作系统或环境>`。`elf` 表示目标环境是基于 ELF 文件格式的嵌入式系统（Executable and Linkable Format），也就是裸机（bare-metal）程序。

## 仿真结果

见[实验报告](./doc/report/report.typ)。

## 资源和参考

- 浙大采用的课本：
  - Patterson, David A., and John L. Hennessy. *Computer Organization and Design: The Hardware Software Interface; RISC-V Edition*. San Diego: Elsevier Science & Technology, 2018.
- **Ripes 汇编器、CPU 和 Cache 模拟器（强烈推荐）**
  <https://github.com/mortbopet/Ripes>
