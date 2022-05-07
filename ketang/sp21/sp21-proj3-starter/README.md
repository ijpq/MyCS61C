# proj3

## objects

1. 实现alu和regfile, cpu数据通路用于执行addi指令

2. 实现一个完整的cpu

   

## tips

1. 只能使用logisim内建的元器件

​	:white_check_mark: Wiring( :heavy_multiplication_x:Transistor/Transmission Gate/POR/Pull Resistor/Power/Ground/Do not connect)

​	:white_check_mark:Gates( :heavy_multiplication_x: PLA )

​	:white_check_mark:Arithmetic( :heavy_multiplication_x: Divider )

​	:white_check_mark:Memory( :heavy_multiplication_x:RAM/Random Generator )

​	:white_check_mark:Plexers

2. **经常保存和commit logism**
3. .circ文件很难merge，所以不要merge就好了！
4. 不要移动locked input/output pins
5. 检查cpu.circ的同时检查harness circ，确保电路和testing harness是适配的
6. 不要新增.circ文件，电路图都应该画在已经给出的.circ中
7. 命名要全局唯一，给定代码中的名称不要动
8. **实现要高效**，测试太久不行

9. 写PartA前先完成lab05

10. 写PartB前先完成lab06

常见logism错误

![image-20220503175907105](https://tva1.sinaimg.cn/large/e6c9d24ely1h1vdccaxphj20gh08p0t3.jpg)

## Part A

### Task1 ALU

实现一个alu能够支持实验所需要运行的指令，**不处理溢出**。

在cpu/alu.circ中提供了一个alu的基本结构，三个输入和一个输出分别如下：

| Input Name | Bit Width | Description                                                  |
| ---------- | --------- | :----------------------------------------------------------- |
| A          | 32        | Data to use for Input A in the ALU operation                 |
| B          | 32        | Data to use for Input B in the ALU operation                 |
| ALUSel     | 4         | Selects which operation the ALU should perform (see the list of operations with corresponding switch values below) |

| Output Name | Bit Width | Description                 |
| ----------- | --------- | :-------------------------- |
| Result      | 32        | Result of the ALU operation |

**下面是需要实现的操作**

| ALUSel Value | Instruction                              |
| ------------ | :--------------------------------------- |
| 0            | add: `Result = A + B`                    |
| 1            | sll: `Result = A << B`                   |
| 2            | slt: `Result = (A < B (signed)) ? 1 : 0` |
| 3            | Unused                                   |
| 4            | xor: `Result = A ^ B`                    |
| 5            | srl: `Result = (unsigned) A >> B`        |
| 6            | or: `Result = A | B`                     |
| 7            | and: `Result = A & B`                    |
| 8            | mul: `Result = (signed) (A * B)[31:0]`   |
| 9            | mulh: `Result = (signed) (A * B)[63:32]` |
| 10           | Unused                                   |
| 11           | mulhu: `Result = (A * B)[63:32]`         |
| 12           | sub: `Result = A - B`                    |
| 13           | sra: `Result = (signed) A >> B`          |
| 14           | Unused                                   |
| 15           | bsel: `Result = B`                       |

在PartA的测试中，只使用ALUSel值和指定的一些指令，所以暂时不需要考虑其他的问题

可以对alu.circ做一些修改，但是必须遵守以上描述的要求。如果创建子电路，必须也放在alu.circ中。alu的实现必须能够适配alu-harness.circ，这表示输入和输出都不要改，以免对应不上harness。为了保证所实现的内容的正确性，可以打开harness看一下是否有logisim的报错。

### tips

* 实现移位操作的时候，注意使用splitter和extender
* 使用tunnel，可以让电路变得好看
* 当从多个输出中进行选择时，使用MUX。

### info:testing

在tests/路径下提供了一些测试

例如alu的测试放在了tests/part-a/alu中，测试结果放在student-output/中。

进行alu测试：

```bash
python3 test.py tests/part-a/alu/
```

也可以进行单一测试：

```bash
python3 test.py tests/part-a/alu/alu-add.circ
python3 test.py tests/part-a/
python3 test.py tests/
```

alu的测试完以后，输出放在tests/part-a/alu/student-output/中，并且带有-student.out后缀。与之相应的参考输出放在tests/part-a/alu/reference-output/并且带有-ref.out后缀

format-output.py会接受一个输出文件的路径，把输出文件展示了可阅读的格式，例如 把alu-add测试打印出可阅读的格式，使用：

```
python3 tools/format-output.py tests/part-a/alu/reference-output/alu-add-ref.out
```

如果为了对比不同点，可以使用diff

### inspecting tests

在logisim中可以使用类似gdb的功能

在logisim中打开tests/part-a/alu/alu-add.circ，有一些roms输入到`Input_A,Input_B,ALUSel`中，这些会输入到你的alu的右上角。每个时钟周期，左上角的加法器加一，将 ROM 的输出推进一个条目，并将一组新的输入提供给您的 ALU。

如果点击`File -> Tick Full Cycle`几次，可以看到测试电路接受了一个输入并产生了一些输出。

可以右键alu，点击`view alu`看一下你的alu电路，`poke tool`非常有用

### Task2 register file

这一个任务是实现所有的riscv寄存器

register file要根据给定的riscv指令对register进行读写，但是x0永远不要写。

时钟信号要直接连接register file

| Register Number | Register Name |
| --------------- | ------------- |
| x1              | ra            |
| x2              | sp            |
| x5              | t0            |
| x6              | t1            |
| x7              | t2            |
| x8              | s0            |
| x9              | s1            |
| x10             | a0            |

| Input Name                | Bit Width | Description                                                  |
| ------------------------- | --------- | :----------------------------------------------------------- |
| Clock                     | 1         | Input providing the clock. This signal can be sent into subcircuits or attached directly to the clock inputs of memory units in Logisim, but should not otherwise be gated (i.e., do not invert it, do not `AND` it with anything, etc.). |
| RegWEn                    | 1         | Determines whether data is written to the register file on the next rising edge of the clock. |
| rs1 (Source Register 1)   | 5         | Determines which register’s value is sent to the Read_Data_1 output, see below. |
| rs2 (Source Register 2)   | 5         | Determines which register’s value is sent to the Read_Data_2 output, see below. |
| rd (Destination Register) | 5         | Determines which register to write the value of Write Data to on the next rising edge of the clock, assuming that RegWEn is a 1. |
| wb (Write Data)           | 32        | Determines what data to write to the register identified by the Destination Register input on the next rising edge of the clock, assuming that RegWEn is 1. |

| Output Name | Bit Width | Description                                                  |
| ----------- | --------- | :----------------------------------------------------------- |
| Read_Data_1 | 32        | Driven with the value of the register identified by the Source Register 1 input. |
| Read_Data_2 | 32        | Driven with the value of the register identified by the Source Register 2 input. |
| `ra` Value  | 32        | Always driven with the value of `ra` (This is a DEBUG/TEST output.) |
| `sp` Value  | 32        | Always driven with the value of `sp` (This is a DEBUG/TEST output.) |
| `t0` Value  | 32        | Always driven with the value of `t0` (This is a DEBUG/TEST output.) |
| `t1` Value  | 32        | Always driven with the value of `t1` (This is a DEBUG/TEST output.) |
| `t2` Value  | 32        | Always driven with the value of `t2` (This is a DEBUG/TEST output.) |
| `s0` Value  | 32        | Always driven with the value of `s0` (This is a DEBUG/TEST output.) |
| `s1` Value  | 32        | Always driven with the value of `s1` (This is a DEBUG/TEST output.) |
| `a0` Value  | 32        | Always driven with the value of `a0` (This is a DEBUG/TEST output.) |

在regfile.circ顶部的test output是用来测试和debug的，实现真实register file时要忽略这些输出。不过，在本作业内，要包含这些输出，否则测试不能通过。

### tips

* 使用复制粘贴来节省工作量
* MUXes很有用，DeMUXes也用得上
* 建议不要使用MUXes的`Enable`信号线，建议把`Enable`和`Three state`关掉
* 想一下，在一条指令执行完后，register file会发生什么，值会变成什么，哪些值保持不变，寄存器是时钟触发的这意味着什么？

### testing

`python3 test.py tests/part-a/regfile/`

### task3 the `addi` instruction

### info:memory

mem.circ已经包含了实现好的内存单元，并且已经适配好了cpu-harness.circ

`addi`指令不使用memory，所以目前为止，可以忽略DMEM和I/O pins

memory单元的输入输出表如下

| Signal Name | Direction | Bit Width | Description                                                  |
| ----------- | --------- | --------- | :----------------------------------------------------------- |
| WriteAddr   | Input     | 32        | Address to read/write to in Memory                           |
| WriteData   | Input     | 32        | Value to be written to Memory                                |
| Write_En    | Input     | 4         | The write mask for instructions that write to Memory and zero otherwise |
| CLK         | Input     | 1         | Driven by the clock input to the CPU                         |
| ReadData    | Output    | 32        | Value of the data stored at the specified address            |

### info: branch comparator

分支单元放在了branch-comp.circ，但是没有实现完，`addi`指令不需要使用分支单元，所以可以暂时不管她

branch单元的输入输出表如下

| Signal Name | Direction | Bit Width | Description                                                  |
| ----------- | --------- | --------- | :----------------------------------------------------------- |
| rs1         | Input     | 32        | Value in the first register to be compared                   |
| rs2         | Input     | 32        | Value in the second register to be compared                  |
| BrUn        | Input     | 1         | Equal to one when an unsigned comparison is wanted, or zero when a signed comparison is wanted |
| BrEq        | Output    | 1         | Equal to one if the two values are equal                     |
| BrLt        | Output    | 1         | Equal to one if the value in rs1 is less than the value in rs2 |

### info: immediate generator

立即数生成单元放在了imm-gen.circ，没有实现，`addi`指令需要使用这个单元。对于目前的part来说，可以hard-wire来给`addi`指令生成立即数

编辑了imm-gen.circ以后，需要重新打开cpu.circ以加载所做的修改

| Signal Name | Direction | Bit Width | Description                                        |
| ----------- | --------- | --------- | :------------------------------------------------- |
| inst        | Input     | 32        | The instruction being executed                     |
| ImmSel      | Input     | 3         | Value determining how to reconstruct the immediate |
| imm         | Output    | 32        | Value of the immediate in the instruction          |

### info: processor

在partA，需要实现一个单指令周期（非流水线）且支持`addi`指令的数据通路。在partB，将会实现两级流水线。

进程会输出指令的地址，然后接受这个地址的指令作为输入。同时，要输出data mem address，data mem write enable，接受这个地址的数据作为输入。

仔细看一下run.circ和cpu-harness.circ，了解一下整个过程是怎么回事。

处理器接受三个输入，这三个输入来自harness

| Input Name  | Bit Width | Description                                                  |
| ----------- | --------- | :----------------------------------------------------------- |
| READ_DATA   | 32        | Driven with the data at the data memory address identified by the WRITE_ADDRESS (see below). |
| INSTRUCTION | 32        | Driven with the instruction at the instruction memory address identified by the FETCH_ADDRESS (see below). |
| CLOCK       | 1         | The input for the clock. As with the register file, this can be sent into subcircuits (e.g. the CLK input for your register file) or attached directly to the clock inputs of memory units in Logisim, but should not otherwise be gated (i.e., do not invert it, do not `AND` it with anything, etc.). |

处理器要给出以下输出

| Output Name     | Bit Width | Description                                                  |
| --------------- | --------- | :----------------------------------------------------------- |
| ra              | 32        | Driven with the contents of `ra` (FOR TESTING)               |
| sp              | 32        | Driven with the contents of `sp` (FOR TESTING)               |
| t0              | 32        | Driven with the contents of `t0` (FOR TESTING)               |
| t1              | 32        | Driven with the contents of `t1` (FOR TESTING)               |
| t2              | 32        | Driven with the contents of `t2` (FOR TESTING)               |
| s0              | 32        | Driven with the contents of `s0` (FOR TESTING)               |
| s1              | 32        | Driven with the contents of `s1` (FOR TESTING)               |
| a0              | 32        | Driven with the contents of `a0` (FOR TESTING)               |
| tohost          | 32        | Driven with the contents of CSR `0x51E` (FOR TESTING, for Part A leave it as-is) |
| WRITE_ADDRESS   | 32        | This output is used to select which address to read/write data from in data memory. |
| WRITE_DATA      | 32        | This output is used to provide write data to data memory.    |
| WRITE_ENABLE    | 4         | This output is used to provide the write enable mask to data memory. |
| PROGRAM_COUNTER | 32        | This output is used to select which instruction is presented to the processor on the INSTRUCTION input. |

### info:Control Logic

control-logic.circ还没有实现，这个内容的实现是partB中最难的

对于partA，可以为每一个控制信号设置一个常数，因为partA只要实现addi指令，对应的控制信号是固定的

**在这个文件中可以增加更多的input/output pin**，以实现控制逻辑

### 单级CPU: A Guide

回顾一下cpu的五个stage，下面每个stage提出一些问题，能够帮助理解问题！

**Stage1: IF**

主要的问题是，我们如何取得当前的指令？根据教材，指令是从指令内存中取出来的，每一条指令可以根据给定的内存地址来获取

1. 哪一个.circ包含了指令内存？如何连接到cpu.circ?

   `INSTRUCTION MEMORY`在run.circ中，把`PROGRAM_COUNTER`输入到`INSTRUCTION MEMORY`，并且输出到`INSTRCUTION`中

   输出`PROGRAM_COUNTER`到tunnel

   ![image-20220507150753619](https://tva1.sinaimg.cn/large/e6c9d24ely1h1zuvgf3a8j20jo08g755.jpg)

   `PROGRAM_COUNTER`输出到`INSTRUCTION MEMORY`

   ![image-20220507150833938](https://tva1.sinaimg.cn/large/e6c9d24ely1h1zuw4do1mj20si0ab40o.jpg)

   `INSTRUCTION MEMORY`输出`INSTRUCTION`到cpu

   ![image-20220507150915309](https://tva1.sinaimg.cn/large/e6c9d24ely1h1zuwu2o3sj20s90a7jti.jpg)

2. 在这个cpu中，更改了pc后，是如何影响指令输入的？

   更改pc后，从`INSTRUCTION MEMORY`取出不同的指令给cpu

3. 你怎么知道pc应该是什么值

   `答案`:`PROGRAM_COUNTER` is the address of the current instruction being executed, so it is saved in the PC register. For this project, your PC will start at 0, as that is the default value for a register.

4. 对于没有跳转和条件指令的程序，执行过程中pc是如何变化的

   直接+4

**Stage2: Instruction Decode**

