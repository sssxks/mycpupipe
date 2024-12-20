#import "memset0_template/template.typ": *

#show: project.with(
  theme: "lab",
  title: "RV32I 流水线CPU",
  course: "计算机组成",
  name: "Lab5 流水线CPU",
  author: "项科深",
  school_id: "浙江大学",
  major: "计算机科学与技术",
  place: "浙江大学紫金港校区",
  semester: "2024 秋",
  teacher: "杨坤",
  date: "2024/12/20",
)

#set table(
  inset: 6pt,
  stroke: none,
)

= 流水线CPU设计与实现

== 实验内容和原理

这部分即为`my-pipe-design.md`内容，介绍了CPU的设计。

#[
  #set heading(offset: 1)

  #let horizontalrule = line(start: (25%, 0%), end: (75%, 0%))

  #show terms: it => {
    it
      .children
      .map(child => [
        #strong[#child.term]
        #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
      .join()
  }

  #show figure.where(kind: table): set figure.caption(position: top)

  #show figure.where(kind: image): set figure.caption(position: bottom)

  #let content-to-string(content) = {
    if content.has("text") {
      content.text
    } else if content.has("children") {
      content.children.map(content-to-string).join("")
    } else if content.has("body") {
      content-to-string(content.body)
    } else if content == [ ] {
      " "
    }
  }

  == 创新点 & 不足之处 & TLDR
  <创新点-不足之处-tldr>
  #strong[创新点];：

  - 支持hazard处理，额外实现了forwarding和flush，速度杠杠滴；
  - 代码经过多次重构，使用了大量的struct，enum和interface，不使用宏；
  - 相比我的Lab4，代码风格更统一，模块、变量和文件命名规范；
  - 支持内存访问，支持byte、half-word和word的读写（当然lab4也有）；
  - #strike[不是连线实验];全是自己写的，当然copilot帮了大忙。

  #strong[不足之处];：

  - 没有上板验证，只有仿真验证。估计如果要上的话，工作量还是不小的
    - 因为cpu全是自己写的，lab2的SoC应该用不了，甚至VGA模块也得大改
  - `jalr`, `auipc`, `lui`
    Lab4实现了，这个实验也沿用了，但是没有仿真测试过
    - #strike[希望能用]

  #strong[TLDR];：

  - ex阶段(而不是mem阶段)做跳转判断，如果跳转成功，会Flush掉后面的指令；
    - Flush时，IF-ID写入nop，ID-EX写入nop，PC不暂停（此时PC已是跳转后的地址）
  - load-use会Stall，也就是ex阶段判断是load时触发Stall
    - 此时EX为load，ID为use，IF为use后一条指令；
    - Stall会暂停PC更新、IF-ID之间的寄存器更新，ID-EX之间的寄存器写入NOP；
    - 实现IF仍然为use后一条指令，ID仍然为use，EX为nop，MEM为load；
  - 若ex阶段用到了mem阶段的数据，会forwarding；
    - forward时，ex阶段的rs1, rs2通过mux选择mem阶段forwarding过来的数据；
  - 为了支持内存访问，pipeline模块的内存接口使用了inner\_memory\_if，将内存接口转化为data\_memory\_if；

  如果需要更多细节，请继续阅读。

  == Project Structure
  <project-structure>
  项目结构如下所示。主要包含了CPU设计的源代码，linter有关文件以及仿真有关文件。由于vivado仿真耗时较长，我使用了Verilator作为linter结合#link("https://marketplace.visualstudio.com/items?itemName=mshr-h.veriloghdl")[VS Code 插件];，用于检查语法错误。仿真文件主要指的是汇编以及vivado波形图配置文件。

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

  == SoC Design
  <soc-design>
  非常简单的SoC，仅供仿真使用。代码定义了一个CPU和两个内存模块，其中CPU与内存模块之间通过接口进行通信。

  ```systemverilog
  module soc_simulation_tb;
      reg clk;
      reg reset;

      soc_simulation m0(.clk(clk), .reset(reset));

      initial begin
          clk = 1'b0;
          reset = 1'b1;
          #5;
          reset = 1'b0;
      end

      always #50 clk = ~clk;
  endmodule
  ```

  ```systemverilog
  module soc_simulation(
      input wire clk,
      input wire reset
  );
      instr_memory_if instr_mem_if();
      data_memory_if data_mem_if();

      cpu uut (
          .clk(clk),
          .reset(reset),

          .instr_mem_if(instr_mem_if.user),
          .data_mem_if(data_mem_if.cpu)
      );

      instruction_memory U2(
          .instr_mem_if(instr_mem_if.mem)
      );

      data_memory U3 (
          .clk(clk),
          .mem_if(data_mem_if.mem)
      );
  endmodule
  ```

  == CPU Design
  <cpu-design>
  CPU
  主要逻辑如下，将pipeline模块使用的inner\_mem\_if连接到memory\_handler模块，进而转化为data\_memory\_if。源代码见#link("../src/cpu/cpu.sv")[cpu.sv];。

  ```systemverilog
  module cpu (
      input logic clk,
      input logic reset,

      instr_memory_if.user instr_mem_if,
      data_memory_if.cpu data_mem_if
  );
      inner_memory_if inner_mem_if_instance();

      pipeline pipeline_instance(
          .clk(clk),
          .reset(reset),

          .instr_mem_if(instr_mem_if),
          .inner_mem_if(inner_mem_if_instance.user)
      );

      memory_handler memory_handler_instance(
          .cpu(inner_mem_if_instance.handler),
          .mem(data_mem_if)
      );
  endmodule
  ```

  === 变量命名约定
  <变量命名约定>
  - #strong[Datapath数据];: 使用 `lower_case_with_underscores`.
  - #strong[控制信号];: 使用 `CamelCase`.
  - #strong[Structs];: 使用 `_t` 后缀 (e.g., `mem_wb_flow_t`).
  - #strong[枚举];: 使用 `UPPER_CASE_WITH_UNDERSCORES`.

  == Pipeline Design
  <pipeline-design>
  === Overview
  <overview>
  以下是pipeline的大致实现。pipeline模块包含了各个阶段的实现，以及各个阶段之间的寄存器的实现。pipeline模块还包含了forwarding和hazard
  detection模块。详细代码见#link("../src/cpu/pipeline/pipeline.sv")[pipeline.sv];。

  ```systemverilog
  module pipeline(
      input logic clk,
      input logic reset,

      instr_memory_if.user instr_mem_if,
      inner_memory_if.user inner_mem_if
  );
      // flows
      if_id_flow_t if_flowout, id_flowin;
      id_ex_flow_t id_flowout, ex_flowin;
      ex_mem_flow_t ex_flowout, mem_flowin;
      mem_wb_flow_t mem_flowout, wb_flowin;
      ex_if_backflow_t ex_if_backflow;
      wb_id_backflow_t wb_id_backflow;

      // forwarding interface & unit
      forwarding_if fd();
      forwarding_unit forwarding_instance(
          .c(fd.control)
      );

      // hazard detection interface & unit
      hazard_if hd();
      hazard_unit hazard_instance(
          .c(hd.control)
      );

      if_stage if_stage_instance (
          ...
      );

      if_id_reg if_id_reg_instance (
          ...
      );

      id_stage id_stage_instance (
          ...
      );

      id_ex_reg id_ex_reg_instance (
          ...
      );

      ex_stage ex_stage_instance (
          ...
      );

      ex_mem_reg ex_mem_reg_instance (
          ...
      );

      mem_stage mem_stage_instance (
          ...
      );

      mem_wb_reg mem_wb_reg_instance (
          ...
      );

      wb_stage wb_stage_instance (
          ...
      );
  endmodule
  ```

  === Flows
  <flows>
  上面代码中先定义了一系列flow。为了使代码清爽，我把各个阶段传递的数据和控制信号打包成数据结构，起了个名字叫flow。这些flow定义在#link("../src/include/pipeline_flow_types.sv")[pipeline\_flow\_types.sv];中。下面详细说明一下：

  ==== Forward Flows
  <forward-flows>
  前向流将数据从一个流水线阶段传递到下一个阶段。总共有4个前向流：

  - #strong[if\_id\_flow\_t];: 将程序计数器 (`pc`) 和指令 (`instr`)
    从指令获取 (IF) 阶段传递到指令解码 (ID) 阶段。
  - #strong[id\_ex\_flow\_t];: 将数据从 ID 阶段传递到执行 (EX)
    阶段，包括寄存器数据 (`rs1_data`, `rs2_data`)、地址 (`rs1_addr`,
    `rs2_addr`, `rd_addr`)、立即数值和控制信号 (`ex_ctrl`, `mem_ctrl`,
    `wb_ctrl`)。
  - #strong[ex\_mem\_flow\_t];: 将数据从 EX 阶段传递到内存 (MEM)
    阶段，包括 ALU 结果、寄存器地址和控制信号。
  - #strong[mem\_wb\_flow\_t];: 将数据从 MEM 阶段传递到写回 (WB)
    阶段，包括内存读取数据、ALU 结果和控制信号。

  ==== Backward Flows
  <backward-flows>
  后向流将数据从后面的阶段传递回前面的阶段，以支持分支和寄存器写回两个操作。

  - #strong[ex\_if\_backflow\_t];: 将分支决策信息从 EX 阶段传递回 IF
    阶段，包括分支目标地址 (`pc_target`)。
  - #strong[wb\_id\_backflow\_t];: 将寄存器写回信息从 WB 阶段传递回 ID
    阶段，包括寄存器地址 (`rd_addr`) 和数据 (`rd_data`)。

  === Control Signals
  <control-signals>
  #link("../src/include/control_signal_types.sv")[control\_signal\_types.sv]
  文件定义了 CPU
  各个阶段使用的控制信号类型。这些控制信号用于控制流水线各个阶段的操作。以下是各个控制信号类型的详细说明：

  ==== 具体控制信号
  <具体控制信号>
  ===== ALU 控制信号 (`alu_t`)
  <alu-控制信号-alu_t>
  `alu_t` 枚举类型定义了 ALU
  的操作类型，包括加法、减法、逻辑移位、比较等操作。

  ```systemverilog
  typedef enum logic [3:0] {
      ALU_ADD = 4'b0_000,
      ALU_SUB = 4'b1_000,
      ALU_SLL = 4'b0_001,
      ALU_SLT = 4'b0_010,
      ALU_SLTU = 4'b0_011,
      ALU_XOR = 4'b0_100,
      ALU_SRL = 4'b0_101,
      ALU_SRA = 4'b1_101,
      ALU_OR = 4'b0_110,
      ALU_AND = 4'b0_111
  } alu_t;
  ```

  ===== 立即数生成控制信号 (`immgen_t`)
  <立即数生成控制信号-immgen_t>
  `immgen_t` 枚举类型定义了不同类型指令的立即数生成方式。

  ```systemverilog
  typedef enum logic [2:0] {
      IMMGEN_I = 3'b000, // i-type
      IMMGEN_S = 3'b001, // s-type
      IMMGEN_SB = 3'b010, // sb-type
      IMMGEN_UJ = 3'b011, // uj-type
      IMMGEN_U = 3'b100  // u-type
  } immgen_t;
  ```

  ===== 读写类型控制信号 (`rw_type_t`)
  <读写类型控制信号-rw_type_t>
  `rw_type_t`
  枚举类型定义了内存访问的读写类型，包括字节、半字和字的访问方式。load
  会用到全部，而 store 不会用到 BYTE\_U 和 HALF\_U。

  ```systemverilog
  typedef enum logic [2:0] {
      BYTE = FUN3_LB,
      BYTE_U = FUN3_LBU,
      HALF = FUN3_LH,
      HALF_U = FUN3_LHU,
      WORD = FUN3_LW
  } rw_type_t;
  ```

  ===== 内存到寄存器控制信号 (`memtoreg_t`)
  <内存到寄存器控制信号-memtoreg_t>
  `memtoreg_t`
  枚举类型定义了不同的数据到寄存器的数据路径。事实上，这个信号应该被叫做
  `datatoreg_t`更合适。其中 `MEMTOREG_PC` 用于 jalr 和 auipc 指令，写入
  `PC + 4` 或 `PC + imm`，`MEMTOREG_IMM` 用于 lui 指令。

  ```systemverilog
  typedef enum logic [1:0] {
      MEMTOREG_ALU = 2'd0,  // alu result (R-type)
      MEMTOREG_MEM = 2'd1,  // memory data in (load)
      MEMTOREG_PC = 2'd2,   // pc related (jalr/auipc)
      MEMTOREG_IMM = 2'd3   // immediate (lui)
  } memtoreg_t;
  ```

  ===== 程序计数器跳转目标控制信号 (`pctarget_t`)
  <程序计数器跳转目标控制信号-pctarget_t>
  `pctarget_t` 枚举类型定义了程序计数器的跳转目标。

  ```systemverilog
  typedef enum logic {
      SET_ALU = 1'b1, // set PC to alu result (jalr)
      OFFSET_IMM = 1'b0 // offset PC by immediate value (others)
  } pctarget_t;
  ```

  ===== 分支控制信号 (`branch_t`)
  <分支控制信号-branch_t>
  `branch_t` 枚举类型定义了是否为分支指令。

  ```systemverilog
  typedef enum logic {
      BRANCH = 1'b1, // is a branch instruction
      NO_BRANCH = 1'b0  // not a branch instruction
  } branch_t;
  ```

  ===== 逆分支控制信号 (`inversebranch_t`)
  <逆分支控制信号-inversebranch_t>
  `inversebranch_t` 枚举类型定义了分支指令的类型。

  ```systemverilog
  typedef enum logic {
      INVERSE_BRANCH = 1'b1,  // bne, bge, bgeu
      NORMAL_BRANCH = 1'b0    // beq, blt, bltu
  } inversebranch_t;
  ```

  ===== 内存读写控制信号 (`memrw_t`)
  <内存读写控制信号-memrw_t>
  `memrw_t` 枚举类型定义了内存的读写操作。

  ```systemverilog
  typedef enum logic {
      MEM_WRITE = 1'b1,  // write to memory
      MEM_READ = 1'b0    // read from memory
  } memrw_t;
  ```

  ===== ALU 源选择控制信号 (`alusrcb_t`)
  <alu-源选择控制信号-alusrcb_t>
  `alusrcb_t` 枚举类型定义了 ALU 的第二操作数来源。

  ```systemverilog
  typedef enum logic {
      ALU_RS2 = 1'b0,   // use rs2 as ALU input b
      ALU_IMM = 1'b1    // use immediate as ALU input b
  } alusrcb_t;
  ```

  ===== 跳转控制信号 (`jump_t`)
  <跳转控制信号-jump_t>
  `jump_t` 枚举类型定义了是否为跳转指令。

  ```systemverilog
  typedef enum logic {
      JUMP = 1'b1,    // is a jump instruction
      NO_JUMP = 1'b0  // not a jump instruction
  } jump_t;
  ```

  ===== 寄存器写控制信号 (`regwrite_t`)
  <寄存器写控制信号-regwrite_t>
  `regwrite_t` 枚举类型定义了是否写寄存器。

  ```systemverilog
  typedef enum logic {
      REG_WRITE = 1'b1,   // write to register
      NO_REG_WRITE = 1'b0 // not write to register
  } regwrite_t;
  ```

  ==== 控制信号结构体
  <控制信号结构体>
  每个阶段的控制信号都被打包成结构体，便于传递和使用。#strong[注意控制信号结构体可以在xx
stage之前的任意阶段使用，不仅仅是xx
stage。];这样规定主要是因为forwarding和hazard detection模块的需要。

  ```systemverilog
  typedef struct packed{
      immgen_t ImmSel;
  } id_control_t;

  typedef struct packed{
      alu_t ALUControl;
      alusrcb_t ALUSrcB;
      pctarget_t PCTarget;
      branch_t Branch;
      inversebranch_t InverseBranch;
  } ex_control_t;

  typedef struct packed{
      memrw_t MemRW;
      rw_type_t RWType;
      jump_t Jump; // mainly used in ex stage, but mem stage also need it
  } mem_control_t;

  typedef struct packed{
      memtoreg_t MemtoReg;
      regwrite_t RegWrite;
  } wb_control_t;
  ```

  === Forwarding & Hazard Detection
  <forwarding-hazard-detection>
  为了向流水线中注入bubble，需要先定义什么也不干（do-nothing,
  nop）的流水线寄存器状态，并适时向流水线寄存器中写入这些状态。这些NOP状态就是一些特定的控制信号和上面定义的流。

  ==== NOP 控制信号
  <nop-控制信号>
  定义了一些 NOP 控制信号。这些信号除了组成 NOP
  流外，还作为id阶段控制器case语句的default值。选择的原则是尽量不会对流水线的状态产生副作用。例如
  MemRW, Jump, Branch, RegWrite 都设置为
  0，以避免任何副作用。剩下的值则是或根据 `addi zero, zero, 0`
  来选择，或任意指定。

  ```systemverilog
  const id_control_t NOP_ID_CTRL = '{
      ImmSel: IMMGEN_I
  };
  const ex_control_t NOP_EX_CTRL = '{
      ALUControl: ALU_ADD,
      ALUSrcB: ALU_RS2,
      PCTarget: OFFSET_IMM,
      Branch: NO_BRANCH,
      InverseBranch: NORMAL_BRANCH
  };
  const mem_control_t NOP_MEM_CTRL = '{
      MemRW: MEM_READ,
      RWType: WORD,
      Jump: NO_JUMP
  };
  const wb_control_t NOP_WB_CTRL = '{
      MemtoReg: MEMTOREG_ALU,
      RegWrite: NO_REG_WRITE
  };
  ```

  ==== NOP 流
  <nop-流>
  定义在#link("../src/include/pipeline_flow_types.sv")[pipeline\_flow\_types.sv];中。

  NOP (No Operation) 流用于初始化或重置 CPU
  状态，并处理流水线Stall或Flush。这些流被定义为常量：

  ```systemverilog
  const if_id_flow_t NOP_IF_ID_FLOW = '{32'h0, NOP_INSTR};
  const id_ex_flow_t NOP_ID_EX_FLOW = '{32'h0, 32'h0, 32'h0, 5'h0, 5'h0, 5'h0, 32'h0, NOP_EX_CTRL, NOP_MEM_CTRL, NOP_WB_CTRL};
  const ex_mem_flow_t NOP_EX_MEM_FLOW = '{32'h0, 5'h0, 32'h0, 32'h0, 32'h0, 32'h0, NOP_MEM_CTRL, NOP_WB_CTRL};
  const mem_wb_flow_t NOP_MEM_WB_FLOW = '{5'h0, 32'h0, 32'h0, 32'h0, 32'h0, NOP_WB_CTRL};
  ```

  ==== Hazard Detection 具体实现
  <hazard-detection-具体实现>
  Hazard
  detection分为两部分，#link("../src/cpu/pipeline/hazard/hazard_if.sv")[第一部分];是一个interface，定义了用到的信号；#link("../src/cpu/pipeline/hazard/hazard_unit.sv")[第二部分];是一个module，实现了具体的Stall
  & Flush逻辑，如下代码所示：

  ```systemverilog
  ...

  in_use_t Rs1InUse, Rs2InUse;
  always_comb begin
      if (c.id.rs1_addr != 5'b0 &&
          (c.id.opcode == OPCODE_R_TYPE
          || c.id.opcode == OPCODE_IMMEDIATE_CALCULATION
          || c.id.opcode == OPCODE_LOAD
          || c.id.opcode == OPCODE_S_TYPE
          || c.id.opcode == OPCODE_SB_TYPE)
      ) begin
          Rs1InUse = IN_USE;
      end else begin
          Rs1InUse = NOT_IN_USE;
      end

      if (c.id.rs2_addr != 5'b0 &&
          (c.id.opcode == OPCODE_R_TYPE
          || c.id.opcode == OPCODE_S_TYPE
          || c.id.opcode == OPCODE_SB_TYPE)
      ) begin
          Rs2InUse = IN_USE;
      end else begin
          Rs2InUse = NOT_IN_USE;
      end
  end

  always_comb begin
      if (c.ex.Load && (
          (c.id.rs1_addr == c.ex.rd_addr && Rs1InUse == IN_USE)
          ||
          (c.id.rs2_addr == c.ex.rd_addr && Rs2InUse == IN_USE)
      )) begin
          c.Stall = 1'b1;
      end else begin
          c.Stall = 1'b0;
      end
  end

  always_comb begin
      if (c.ex.PCSrc) begin
          c.Flush = 1'b1;
      end else begin
          c.Flush = 1'b0;
      end
  end
  ```

  stall部分，首先通过opcode判断rs1,
  rs2是否是垃圾值，然后判断是否有load-use
  hazard。flush逻辑较简单，有分支Taken即Flush。

  ==== Forwarding 具体实现
  <forwarding-具体实现>
  Forwarding同样分为两部分，#link("../src/cpu/pipeline/hazard/forwarding_if.sv")[第一部分];是一个interface，定义了用到的信号；#link("../src/cpu/pipeline/hazard/forwarding_unit.sv")[第二部分];是一个module，实现了具体的Forwarding逻辑，如下代码所示：

  ```systemverilog
  ...

  // Forwarding for rs1
  if (c.mem.RegWrite && c.mem.rd_addr != 0 &&
      c.mem.rd_addr == c.ex.rs1_addr) begin
      c.rs1 = FORWARD_MEM;
  end else if (c.wb.RegWrite && c.wb.rd_addr != 0 &&
                  c.wb.rd_addr == c.ex.rs1_addr) begin
      c.rs1 = FORWARD_WB;
  end else begin
      c.rs1 = NO_FORWARD;
  end

  // Forwarding for rs2
  if (c.mem.RegWrite && c.mem.rd_addr != 0 &&
      c.mem.rd_addr == c.ex.rs2_addr) begin
      c.rs2 = FORWARD_MEM;
  end else if (c.wb.RegWrite && c.wb.rd_addr != 0 &&
                  c.wb.rd_addr == c.ex.rs2_addr) begin
      c.rs2 = FORWARD_WB;
  end else begin
      c.rs2 = NO_FORWARD;
  end

  ...
  ```

  ==== 流水线寄存器的写入
  <流水线寄存器的写入>
  在pipeline模块中，根据hazard
  detection和forwarding的结果，流水线寄存器选择是否写入NOP或者正常的值。这里以ID-EX寄存器为例，其他寄存器类似。见#link("../src/cpu/pipeline/stage_regs/id_ex_reg.sv")[id\_ex\_reg.sv];和#link("../src/cpu/pipeline/stage_regs/if_id_reg.sv")[if\_id\_reg.sv];。

  ```systemverilog
  module id_ex_reg (
      input logic clk,
      input logic reset,
      hazard_if.listener hd,

      input id_ex_flow_t id_flow,
      output id_ex_flow_t ex_flow
  );
      always_ff @(posedge clk or posedge reset) begin
          // if we need to stall or flush, discard the current flow
          // use do-nothing flow instead
          if (reset || hd.Stall || hd.Flush) begin
              ex_flow <= NOP_ID_EX_FLOW;
          end else begin
              ex_flow <= id_flow;
          end
      end
  endmodule
  ```

  === Datapath 数据流
  <datapath-数据流>
  简单列举一下源码文件名，这部分应该都比较相似，不多赘述了。也许可以看看那些有hazard或者forwarding的地方。

  - #strong[IF 阶段];: #link("../src/cpu/pipeline/if/if_stage.sv")[if.sv]
    - 负责从指令存储器中取指令和更新程序计数器（PC）。
    - 将当前PC值和取到的指令传递给下一个阶段。
    - Stall 时不更新PC。（Flush 时照常工作）
  - #strong[ID 阶段];: #link("../src/cpu/pipeline/id/id_stage.sv")[id.sv]
    - 负责寄存器文件读写和控制信号的生成。
    - 将译码后的操作数和控制信号传递给下一个阶段。
    - 向 hazard detection unit 提供信息。
  - #strong[EX 阶段];: #link("../src/cpu/pipeline/ex/ex_stage.sv")[ex.sv]
    - 负责执行算术逻辑运算（ALU操作）以及跳转。
    - 将ALU结果和其他数据传递给下一个阶段。
    - 告诉 forwarding unit 所使用的rs1, rs2并使用 forwarding unit
      提供的新鲜数据。
    - 向 hazard detection unit 提供信息。
  - #strong[MEM 阶段];:
    #link("../src/cpu/pipeline/mem/mem_stage.sv")[mem.sv]
    - 负责与数据存储器进行交互。
    - 将访存结果和其他数据传递给下一个阶段。
    - 向 forwarding unit 提供上一阶段 ALU 计算出的数据。
  - #strong[WB 阶段];: #link("../src/cpu/pipeline/wb/wb_stage.sv")[wb.sv]
    - 负责将计算结果或访存结果写回寄存器文件。
    - 将写回的数据传递给转发单元，以便后续指令使用。
    - 向 forwarding unit
      提供上一阶段访存或上上阶段ALU计算的数据得到的数据。（即将要写入的数据）

  === Control Signal Generation
  <control-signal-generation>
  这个模块是id\_stage的一部分。我在Lab4的基础上经过了多次重构，现在全部信号都成为enum了，可读性强，故删除了大部分的注释。得益于先在case前赋值默认信号的做法，代码行数从200多行的巨无霸减少到了仅95行。（虽然执行的mux逻辑量没有减少）

  ```systemverilog
  module controller(
      input wire opcode_t  opcode,
      input wire [2:0]     fun3,
      input wire           fun7,

      output id_control_t  id_ctrl,
      output ex_control_t  ex_ctrl,
      output mem_control_t mem_ctrl,
      output wb_control_t  wb_ctrl
  );
      always_comb begin
          id_ctrl = NOP_ID_CTRL;
          ex_ctrl = NOP_EX_CTRL;
          mem_ctrl = NOP_MEM_CTRL;
          wb_ctrl = NOP_WB_CTRL;

          case (opcode)
          OPCODE_R_TYPE: begin
              ex_ctrl.ALUSrcB = ALU_RS2;
              ex_ctrl.ALUControl = alu_t'({fun7, fun3});
              wb_ctrl.RegWrite = REG_WRITE;
              wb_ctrl.MemtoReg = MEMTOREG_ALU;
          end
          OPCODE_IMMEDIATE_CALCULATION: begin
              id_ctrl.ImmSel = IMMGEN_I;
              ex_ctrl.ALUSrcB = ALU_IMM;
              ex_ctrl.ALUControl = alu_t'({fun3 == FUN3_SR ? fun7 : 1'b0, fun3});
              wb_ctrl.RegWrite = REG_WRITE;
              wb_ctrl.MemtoReg = MEMTOREG_ALU;
          end
          OPCODE_LOAD: begin
              id_ctrl.ImmSel = IMMGEN_I;
              ex_ctrl.ALUSrcB = ALU_IMM;
              ex_ctrl.ALUControl = ALU_ADD;
              mem_ctrl.MemRW = MEM_READ;
              mem_ctrl.RWType = rw_type_t'(fun3);
              wb_ctrl.RegWrite = REG_WRITE;
              wb_ctrl.MemtoReg = MEMTOREG_MEM;
          end
          OPCODE_JALR: begin
              id_ctrl.ImmSel = IMMGEN_I;
              ex_ctrl.ALUSrcB = ALU_IMM;
              ex_ctrl.ALUControl = ALU_ADD;
              ex_ctrl.PCTarget = SET_ALU;
              mem_ctrl.Jump = JUMP;
              wb_ctrl.RegWrite = REG_WRITE;
              wb_ctrl.MemtoReg = MEMTOREG_PC; // PC + 4
          end
          OPCODE_S_TYPE: begin
              id_ctrl.ImmSel = IMMGEN_S;
              ex_ctrl.ALUSrcB = ALU_IMM;
              ex_ctrl.ALUControl = ALU_ADD;
              mem_ctrl.MemRW = MEM_WRITE;
              mem_ctrl.RWType = rw_type_t'(fun3);
          end
          OPCODE_SB_TYPE: begin
              id_ctrl.ImmSel = IMMGEN_SB;
              ex_ctrl.ALUSrcB = ALU_RS2;
              case (fun3)
                  FUN3_BEQ: ex_ctrl.ALUControl = ALU_EQ;
                  FUN3_BNE: ex_ctrl.ALUControl = ALU_NE;
                  FUN3_BLT: ex_ctrl.ALUControl = ALU_LT;
                  FUN3_BGE: ex_ctrl.ALUControl = ALU_GE;
                  FUN3_BLTU: ex_ctrl.ALUControl = ALU_LTU;
                  FUN3_BGEU: ex_ctrl.ALUControl = ALU_GEU;
              endcase
              ex_ctrl.Branch = BRANCH;
              ex_ctrl.InverseBranch = inversebranch_t'(fun3[0]); // BNE, BGE, BGEU
              ex_ctrl.PCTarget = OFFSET_IMM;
          end
          OPCODE_UJ_TYPE: begin
              id_ctrl.ImmSel = IMMGEN_UJ;
              ex_ctrl.PCTarget = OFFSET_IMM;
              mem_ctrl.Jump = JUMP;
              wb_ctrl.RegWrite = REG_WRITE;
              wb_ctrl.MemtoReg = MEMTOREG_PC; // PC + 4
          end
          OPCODE_LUI: begin
              id_ctrl.ImmSel = IMMGEN_U;
              wb_ctrl.RegWrite = REG_WRITE;
              wb_ctrl.MemtoReg = MEMTOREG_IMM;
          end
          OPCODE_AUIPC: begin
              id_ctrl.ImmSel = IMMGEN_U;
              ex_ctrl.PCTarget = OFFSET_IMM;
              wb_ctrl.RegWrite = REG_WRITE;
              wb_ctrl.MemtoReg = MEMTOREG_PC; // PC + imm
          end
          endcase
      end
  endmodule
  ```

  应该很一目了然，不解释了，信号相关说明参考上面#link(<control-signals>)[Control Signals];。

  == Memory Access Support
  <memory-access-support>
  为了处理多种内存读写长度及符号（例如字节、半字），在 `mem_control_t`
  结构体中使用了 `RWType` 信号。支持的访问模式如下：

  #figure(
    align(center)[#table(
        columns: 2,
        align: (auto, auto),
        table.header([RWType], [描述]),
        table.hline(),
        [`3'b000`], [字节（有符号）],
        [`3'b100`], [字节（无符号）],
        [`3'b001`], [半字（有符号）],
        [`3'b101`], [半字（无符号）],
        [`3'b010`], [字],
      )],
    kind: table,
  )

  Vivado block memory
  本身只支持和宽度（32位）相同的访问，并且地址按宽度索引，而不按字节索引。#link("../src/cpu/memory_control/memory_handler.sv")[`memory_handler`]
  模块将这些访问类型进行转换，代码如下，比较丑。

  ```systemverilog
  module memory_handler (
      inner_memory_if.handler cpu,
      data_memory_if.cpu mem
  );
      assign mem.addr_out = {cpu.addr_out[11:2]}; // Align address to 4 bytes
      wire [1:0] where = cpu.addr_out[1:0]; // word offset

      always_comb begin
          if (cpu.MemRW == MEM_READ) begin
              case (cpu.RWType)
                  BYTE: cpu.data_in = {
                      {24{mem.data_in[{where, 3'b0}]}},
                      mem.data_in[{where, 3'b0} +: 8]
                  };
                  BYTE_U: cpu.data_in = {
                      24'b0,
                      mem.data_in[{where, 3'b0} +: 8]
                  };
                  HALF: cpu.data_in = {
                      {16{mem.data_in[{where[1], 4'b0}]}},
                      mem.data_in[{where[1], 4'b0} +: 16]
                  };
                  HALF_U: cpu.data_in = {
                      16'b0,
                      mem.data_in[{where[1], 4'b0} +: 16]
                  };
                  WORD: cpu.data_in = mem.data_in;
                  default: cpu.data_in = 32'bx;
              endcase
              mem.data_out = 32'b0;
              mem.WriteEnable = 4'b0;
          end else begin // MEM_WRITE
              case (cpu.RWType)
                  BYTE: begin // sb
                      mem.data_out = {4{cpu.data_out[7:0]}};
                      mem.WriteEnable = 4'b0001 << where;
                  end
                  HALF: begin // sh
                      mem.data_out = {2{cpu.data_out[15:0]}};
                      mem.WriteEnable = 4'b0011 << where;
                  end
                  WORD: begin // sw
                      mem.data_out = cpu.data_out;
                      mem.WriteEnable = 4'b1111;
                  end
                  default: begin
                      mem.data_out = 32'bx;
                      mem.WriteEnable = 4'b0;
                  end
              endcase
              cpu.data_in = 32'b0;
          end
      end
  endmodule
  ```

]

== 实验结果与分析

下面第一页是没有实现hazard和forwarding时在`noHazard.S`测试得到的波形图，第二页是实现了hazard和forwarding后在`Hazard_NOP.S`测试得到的波形图，第三页是实现了hazard和forwarding后在`Hazard_Stall.S`测试的波形图。

采用enum的好处就是大大节约波形图阅读时间，不用看一堆0和1，直接看到对应的信号名字。

为了方便对照，附上第三个测试`Hazard_Stall.S`的汇编代码：

```yasm
main:
    addi  x1, x0, 1      # x1 = 0x1
    addi  x2, x0, 1      # x2 = 0x1
    addi  x3, x0, 1      # x3 = 0x1
    addi  x4, x0, 1      # x4 = 0x1
    lw    x5, 0x8(x0)    # x5 = 0x8000_0000   # mem
    # nop                                     # load-use hazard, stall
    add   x6, x5, x1     # x6 = 0x8000_0001   # mem->ex forwarding
    xor   x7, x1, x2     # x7 = 0             # wb
    beq   x5, x6, error  # 不跳转
    sub   x8, x1, x7     # x8 = 1             # wb->ex forwarding
    xori  x9, x3, -1     # x9 = 0xFFFF_FFFE
    sw    x6, 0x4(x0)    # mem[1] = 0x8000_0001
    bne   x5, x6, test1  # jump to test1
    jal   x30, error     # x30 = pc + 4 则出错 # flush

test1:
    lw    x10, 0x4(x0)   # x10 = 0x8000_0001  # wb
    srl   x11, x5, x8    # x11 = 0x4000_0000
    slt   x12, x10, x9   # x12 = 0x1          # wb->ex forwarding
    and   x13, x9, x10   # x13 = 0x8000_0000
    sltu  x14, x10, x9   # x14 = 0x1
    srl   x15, x11, x9   # x15 = 0x1          # mem
    beq   x15, x12, test2                     # mem->ex forwarding, flush
    jal   x30, error     # x30 = pc + 4 则出错

test2:
    ori   x16, x14, 0x666 # x16 = 0x0000_0667 # mem
    sub   x16, x16, x14   # x16 = 0x0000_0666 # mem->ex forwarding
    jal   x0, main                            # flush

error:
    addi  x30, x30, -4    # 定位出错点
loop:
    addi  x31, x0, -1
    jal   x0, loop
```

这里用注释标出了每个forwarding, stall 以及 flush 的位置。

#page(margin: (x: 0pt, y: 0pt))[
  #set align(center)
  #image("assets/lab5_2_waveform.png")
]
#page(margin: (x: 0pt, y: 0pt))[
  #set align(center)
  #image("assets/lab5_3_waveform_hazard_nop.png")
]
#page(margin: (x: 0pt, y: 0pt))[
  #set align(center)
  #image("assets/lab5_3_waveform_hazard_stall.png")
]

== 实验讨论、心得

=== 思考题

#quote(name: "思考题1")[
  本实验中指令跳转的预测发生在MEM阶段，这会向流水线中插入多个气泡从而影响流水线的性能。能否将指令跳转的预测提前？提前后相应的Stall机制又应该怎么设计？
]

可以，我这里提前到EX了，这样的话Flush就是填充两个bubble。如果提前到ID，那么Flush就是填充一个bubble，但是alu不在ID阶段，如果强行加一个ALU，结果就是ID阶段变长，导致所有指令变慢，可能还不如直接在EX阶段处理。Stall机制（应为Flush机制，前述文档中 Stall 仅指Load-Use stall）就是在EX阶段判断是否跳转，如果跳转就向ID-EX寄存器、IF-ID寄存器写入NOP。

#quote(
  name: "思考题2",
)[若流水线中加入了Forwarding机制，是不是就不需要Stall机制了？（向流水线中插入气泡）若不是请给出实例。]

不是，例如Load-Use hazard，隔了两个阶段，只有Forwarding是不够的，还需要Stall机制。详见上面的有关CPU设计的说明。

=== 心得感想

主要干活的也就4天时间，但是承包了许多激情与快乐。发现把自己干的活发朋友圈也是挺不错的，#strike[因为我也没有什么生活可以发九宫格]

#grid(columns: 2)[
  #image("assets/2024-12-20-18-23-08.png")
][
  #image("assets/2024-12-20-18-20-28.png")
]

截止写报告时，git commit graph如下
#image("assets/2024-12-20-18-35-55.png", width: 80%)

=== 遇到的报错与问题

==== 语法错误类
由于使用linter，基本不会出现语法错误，但是有时候verilator也不是很管用，会有没检测出来的情况，下面这几个感觉可以略微提一下

1. 实例化interface时没加括号。
```sv
inner memory_if inner mem if instance;
```
#image("assets/issue_if_init.png")

2. 不知道linter为什么认为这样用enum是合法的：（图片是修复这个问题的commit diff）
#image("assets/2024-12-20-18-15-42.png", width: 70%)

==== 逻辑错误类
1. 只在forward失败时才考虑`ALUSrcB`（图片是修复这个问题的commit diff）
#image("assets/2024-12-20-18-14-24.png", width: 70%)
2.书上是RV64I，ALU移位有6位有效位。但是RV32I指令集中只有5位，所以要注意这个细节。有一条汇编验收了这个edge case。
#image("assets/2024-12-20-18-18-07.png", width: 70%)
