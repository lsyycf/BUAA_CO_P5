# 一、需求分析

## 指令一：add

### 1.从GRF中读取rs,rt
- 操作：(rs)->RegRead1, (rt)->RegRead2
### 2.rs与rt通过ALU相加
- 操作：RegRead1->ALUIn1, RegRead2->ALUIn2, ALUIn1+ALUIn2->ALURes
### 3. 将结果写入rd
- 操作：rd->RegAddr, ALURes->RegData

## 指令二：sub

### 1.从GRF中读取rs,rt
- 操作：(rs)->RegRead1, (rt)->RegRead2
### 2.rs与rt通过ALU相减
- 操作：RegRead1->ALUIn1, RegRead2->ALUIn2, ALUIn1-ALUIn2->ALURes
### 3. 将结果写入rd
- 操作：rd->RegAddr, ALURes->RegData

## 指令三：ori

### 1.从GRF中读取rs,rt
- 操作：(rs)->RegRead1,(rt)->RegRead2
### 2.imm进行无符号拓展
- 操作：{16{0},imm}->extend
### 3.rs和imm通过ALU取或
- 操作：RegRead1->ALUIn1, extend->ALUIn2, ALUIn1|ALUIn2->ALURes
### 4.将结果写入rt
- 操作：rd->RegAddr, ALURes->RegData

## 指令四：lw

### 1.从GRF中读取base,rt
- 操作：(base)->RegRead1, (rt)->RegRead2
### 2.offest进行有符号拓展
- 操作：{16{offset[15]},offset}->extend
### 3.base和offest通过ALU相加
- 操作：RegRead1->ALUIn1, extend->ALUIn2, ALUIn1+ALUIn2->ALURes
### 4.将主存结果写入rt
- 操作：ALURes->MemAddr, rt->RegAddr, MemRead->RegData

## 指令五：sw

### 1.从GRF中读取base,rt
- 操作：(base)->RegRead1, (rt)->RegRead2
### 2.offest进行有符号拓展
- 操作：{16{offset[15]},offset}->extend
### 3.base和offest通过ALU相加
- 操作：RegRead1->ALUIn1, extend->ALUIn2, ALUIn1+ALUIn2->ALURes
### 4.将rt写入主存
- 操作：ALURes->MemAddr, RegRead2->MemData

## 指令六：beq

### 1.从GRF中读取rs,rt
- 操作：(rs)->RegRead1,(rt)->RegRead2
### 2.offest进行有符号拓展
- 操作：{16{offset[15]},offset}->extend
### 3.rs和rt通过ALU比较
- 操作：RegRead1->ALUIn1, RegRead2->ALUIn2, ALUIn1==ALUIn2->ALURes
### 4.修改pc值跳转
- 操作：pc+4+extend<<2->pc

## 指令七：lui

### 1.imm进行有符号拓展
- 操作：{16{imm[15]},imm}->extend
### 2.imm通过ALU加载到高位
- 操作：extend->ALUIn2, ALUIn2<<16->ALURes
### 3.将结果写入rt
- 操作：rt->RegAddr, ALURes->RegData

## 指令八：jal

### 1.index进行无符号转换
- 操作：{6{0},index}<<2->jump
### 2.将pc写入31号寄存器
- 操作：31->RegAddr, pc+4->RegData
### 3.修改pc值跳转
- 操作：jump->pc

## 指令九：jr

### 1.从GRF中读取rs
- 操作：(rs)->RegRead1
### 2.修改pc值跳转
- 操作：RegRead1->pc

# 二、模块设计

## 模块一：寄存器堆

- 功能同 P0 第三题 GRF

## 模块二：算术逻辑单元

- ALUOp 决定 ALU 进行的运算，0 为加，1 为减，2 为或，3 为加载到高位，4 为判断是否相等

## 模块三：取指令模块

- 每个时钟周期上升沿将pcNext赋值给pc
- 将pc的值减去初值0x00003000，作为ROM读取的地址addr
- 每个时钟周期上升沿从ROM读取指令instr
- pc若为0则将pc置为初始值0x00003000，地址置为0

## 模块四：主存单元

- 功能与ROM相同，大小为4096\*32bit

##  模块五：控制信号生成器

### （1）D段

| 指令 | pcOp | cmpOp | extOp | regWE | rtTuse | rsTuse |
| ---- | ---- | ----- | ----- | ----- | ------ | ------ |
| add  | 00   | 001   | 0     | 1     | 01     | 01     |
| sub  | 00   | 001   | 0     | 1     | 01     | 01     |
| ori  | 00   | 001   | 0     | 1     | 01     | 01     |
| lw   | 00   | 001   | 1     | 1     | 10     | 01     |
| sw   | 00   | 001   | 1     | 0     | 10     | 01     |
| beq  | 01   | 010   | 1     | 0     | 00     | 00     |
| lui  | 00   | 001   | 0     | 1     | 11     | 01     |
| jal  | 10   | 001   | 0     | 1     | 11     | 01     |
| jr   | 11   | 001   | 0     | 0     | 00     | 00     |

- **pcOp**：设置程序计数器的操作。
- **cmpOp**：表示条件跳转比较。
- **extOp**：是否需要扩展符号。
- **regWE**：表示寄存器写使能。
- **rtTuse** 和 **rsTuse**：再过几个周期，该指令要使用  rs 或  rt 寄存器的值。

### （2）E段

| 指令 | ALUOp | ALUIn2Op | fwAddrOp | fwDataOp | Tnew |
| ---- | ---- | ---- | ---- | ---- | ---- |
| add  | 000 | 0 | 00 | 00 | 01 |
| sub  | 001 | 0 | 00 | 00 | 01 |
| ori  | 010 | 1 | 01 | 00 | 01 |
| lw   | 000 | 1 | 01 | 01 | 10 |
| sw   | 000 | 1 | 01 | 11 | 11 |
| lui  | 011 | 1 | 01 | 00 | 01 |
| jal  | 111 | 1 | 10 | 10 | 00 |
| jr   | 111 | 0 | 11 | 11 | 11 |

- **ALUOp**：决定 ALU 执行的操作。
- **ALUIn2Op**：确定 ALU 第二个输入。
- **fwAddrOp**：选择转发的地址。
- **fwDataOp**：选择转发的数据。
- **Tnew**：表示以D级为基准，再过几个周期，该指令产生所需的结果。

### （3）M段

| 指令 | fwAddrOp | fwDataOp | Tnew | memWE |
| ---- |  -------- | -------- | ---- | ---|
| add  |  00       | 00       | 00   | 0 |
| sub  |  00       | 00       | 00   | 0 |
| ori  |  01       | 00       | 00   | 0 |
| lw   |  01       | 01       | 01   | 0 |
| sw   |  01       | 11       | 11   | 1 |
| lui  |  01       | 00       | 00   | 0 |
| jal  |  10       | 10       | 00   | 0 |
| jr   |  11       | 11       | 11   | 0 |

- **memWE**：主存写使能信号。
- **fwAddrOp**：选择转发的地址。
- **fwDataOp**：选择转发的数据。
- **Tnew**：从结果产生到存入流水线寄存器需要几个周期。

### （4）W段

| 指令 | fwAddrOp | fwDataOp | Tnew |
| ---- | ---- | ---- | ---- |
| add  | 00 | 00 | 00 |
| sub  | 00 | 00 | 00 |
| ori  | 01 | 00 | 00 |
| lw   | 01 | 01 | 00 |
| sw   | 11 | 11 | 11 |
| lui  | 01 | 00 | 00 |
| jal  | 10 | 10 | 00 |
| jr   | 11 | 11 | 11 |

- **fwAddrOp**：选择转发的地址。
- **fwDataOp**：选择转发的数据。
- **Tnew**：从结果产生到存入流水线寄存器需要几个周期。

## 模块六：流水线寄存器

- **D段**：存储 pc、指令
- **E段**：存储 pc、指令、rs 和  rt 读出的数据、立即数、是否写入寄存器
- **M段**：存储 pc、指令、rs 和  rt 读出的数据、立即数、ALU 计算结果、是否写入寄存器
- **W段**：存储 pc、指令、rs 和  rt 读出的数据、立即数、ALU 计算结果、主存读出结果、是否写入寄存器

# 三、阻塞与转发

## 1.阻塞

### 条件：
- Tuse\<Tnew 
- 需要将后续数据写入寄存器
- 写入寄存器地址不为0
- 写入寄存器地址与后续转发地址相同

### 行为：
- 停止取下一条指令
- D级寄存器保持原值不变
- E级寄存器复位

## 2.转发

###  条件：
- Tnew=0
- 需要将后续数据写入寄存器
- 写入寄存器地址不为0
- 写入寄存器地址与后续转发地址相同

### 通路：
- E段->D段
- M段->D段、E段
- W段->D段、E段、M段

### 内容：
- 转发地址：写入的寄存器
- 转发数据：写入寄存器的内容

# 四、思考题

## 问题一、
- Q：我们使用提前分支判断的方法尽早产生结果来减少因不确定而带来的开销，但实际上这种方法并非总能提高效率，请从流水线冒险的角度思考其原因并给出一个指令序列的例子。

- A：以beq指令为例，分支判断将比较操作提前到了D级，这导致beq指令的D_Tuse_rt和D_Tuse_rs为0，又因为Tuse < Tnew 时需阻塞流水线，所以beq指令被阻塞的概率较大，进而效率降低。

```assembly
beq $t1, $t2, label
nop
add $t1, $t2, $t3
label:
```

## 问题二、
- Q：因为延迟槽的存在，对于 jal 等需要将指令地址写入寄存器的指令，要写回 PC+8，请思考为什么这样设计？

- A：因为延迟槽的存在，在执行跳转指令后，先执行下一条指令，执行完毕后再根据条件跳转至目标指令，所以如果需要返回，应返回 pc + 8 ，否则位于 pc + 4 的指令会被再执行一次。

## 问题三、
- Q：我们要求所有转发数据都来源于流水寄存器而不能是功能部件（如 DM、ALU）：请思考为什么？

- A：从功能部件转发会导致流水段的执行总延迟增加，为了流水线的正常运行，则需要延长时钟周期，降低流水线的效率。

## 问题四、
- Q：我们为什么要使用 GPR 内部转发？该如何实现？

- A：W级和D级可能同时读写同一个寄存器，解决方法是将W级写入的数据作为D级读出的数据

```verilog
assign D_rsData = 
D_rs == E_fwAddr && D_rs && E_regWE && E_Tnew == 2'b00 ? E_fwData :
D_rs == M_fwAddr && D_rs && M_regWE && M_Tnew == 2'b00 ? M_fwData :
D_rs == W_fwAddr && D_rs && W_regWE && W_Tnew == 2'b00 ? W_fwData :
D_regRead1;

assign D_rtData = 
D_rt == E_fwAddr && D_rt && E_regWE && E_Tnew == 2'b00 ? E_fwData :
D_rt == M_fwAddr && D_rt && M_regWE && M_Tnew == 2'b00 ? M_fwData :
D_rt == W_fwAddr && D_rt && W_regWE && W_Tnew == 2'b00 ? W_fwData :
D_regRead2;
```

## 问题五、
- Q：我们转发时数据的需求者和供给者可能来源于哪些位置？共有哪些转发数据通路？

- 条件：
  - Tnew=0
  - 需要将后续数据写入寄存器
  - 写入寄存器地址不为0
  - 写入寄存器地址与后续转发地址相同
- 通路：
  - E段->D段
  - M段->D段、E段
  - W段->D段、E段、M段
- 内容：
  - 转发地址：写入的寄存器
  - 转发数据：写入寄存器的内容

## 问题六、
- Q：在课上测试时，我们需要你现场实现新的指令：对于这些新的指令，你可能需要在原有的数据通路上做哪些扩展或修改？提示：你可以对指令进行分类，思考每一类指令可能修改或扩展哪些位置。

- 明确扩展指令的所属类型，以此为依据，仿照已有指令，修改各个控制信号的输出
- 根据扩展指令需执行的操作，在各个操作模块中添加相应的操作
- 若扩展指令存在跨级的操作，还要添加相应的流水级寄存器中添加传递的数据和控制信号
- 考虑阻塞和转发信号是否需要修改

## 问题七、
- Q：简要描述你的译码器架构，并思考该架构的优势以及不足。

- 分布式译码：每一级有一个控制器，输出当前流水段所需控制信号。这种方法较为灵活，降低了流水级间传递的信号量，但是需要实例化多个控制器，增加了后续流水级的逻辑复杂度。

- 控制信号驱动型：每个指令定义一个 wire 型变量，使用或运算描述组合逻辑，对每个控制信号进行单独处理。这种方法易于管理和维护多条指令，灵活性高，便于扩展，缺点是实现复杂度较高，调试难度增加，需要仔细管理控制信号的组合。
