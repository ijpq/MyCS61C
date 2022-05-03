# proj2

## objects

1. 用riscv实现数值计算功能

2. 用riscv调用函数

3. 用riscv实现堆调用和文件操作

4. 写单元测试

## PartA

实现 dot product/matmul/relu/argmax

### advice

1. 注意函数定义方法
2. 实现参数检查，并返回正确的错误代码(注意`calling convention`)，检查错误代码时unittests需要使用execute(code=??)
3. 测试用例覆盖率100%不代表覆盖了所有的边界情况
4. 使用unittest见`Running Tests`
5. 使用venus见`Debugging Test with Venus Web Interface`
6. 多阅读utils.s，多使用utils.s中定义好的调用，最好别自己写

### task0 abs

### task1 relu

`python3 -m unittest unittests.TestRelu -v`

relu.s接受1维向量输入，对每个负数元素原地修改为0。

注意看relu.s的注释

### task2 argmax

`python3 -m unittest unittests.TestArgmax -v`

返回最大值元素的索引

### task3 .1 dot product

`python3 -m unittest unittests.TestDot -v`

 接收一个stride参数

不需要考虑乘法溢出，所以不需要使用mulh指令

如果array不改，只是把size参数改为3，并且arr`v1`的stride改为2，结果正确吗

### task3.2 matrix mul

`python3 -m unittest unittests.TestMatmul -v`

## PartB

**matrix file format**

这里提供了一个二进制格式来存储矩阵的大小和数值，便于riscv读取。在二进制格式和普通文本格式之间转换：

`python3 convert.py file.bin file.txt --to-ascii`

`python3 convert.py file.txt file.bin --to-binary`

最开始的8B表示两个int32，行列

后面每4B表示一个int32元素

小端表示法

**plaintext format**

第一行表示行数和列数

后面是矩阵的数值

**viewing binary**

推荐使用`xxd`，可以将文件的bit数据转换为16进制表示打印出来。打印结果如下所示：

![image-20220425174350296](https://tva1.sinaimg.cn/large/e6c9d24egy1h1m3y0hcibj21bi06edgr.jpg)

这个输出结果4B一次，一次是8个16进制数，即两个小组。

看最左侧的地址，是16进制表示的，`00000000`到`00000010`是表示包含16个地址，所以包含16字节（字节寻址）。冒号右边有8个小组，所以每个小组对应2个字节，即16位，所以这里一个数字表示4位，一个数字表示4位正好就是一个16进制数的表示。其中`0300`是`0000 0000 0000 0011`

**file operations**

详细讲述了fopen/fread/fwrite/fclose的调用参数和返回值，具体见网站

### task1 read mat

riscv只能使用a0和a1作为返回值寄存器，但是很多函数需要3个返回值：指向矩阵的指针，矩阵行数，矩阵列数。**解决方法**是传入两个int指针作为调用的参数，把行列值写入这两个指针的内存，然后返回指向矩阵的指针。

`python3 -m unittest unittests.TestReadMatrix -v`

> 问题1：
>
> ```assembly
> fopen_error:
>  jal x1, error_epilogue
>  li a1, 117
>  j error_exit
> 
> malloc_error:
>  jal x1, error_epilogue
>  li a1, 116
>  j error_exit
> 
> fread_error:
>  jal x1, error_epilogue
>  li a1, 118
>  j error_exit
> 
> fclose_error:
>  jal x1, error_epilogue
>  li a1, 119
>  j error_exit
> ```
>
> 
>
> 先error_epilogue后`li x1, code`如上面代码，就不对，报exit code不正确，但是改为如下的顺序，就对了，为什么？
>
> ```assembly
> fopen_error:
>  li a1, 117
>  jal x1, error_epilogue
>  j error_exit
> 
> malloc_error:
>  li a1, 116
>  jal x1, error_epilogue
>  j error_exit
> 
> fread_error:
>  li a1, 118
>  jal x1, error_epilogue
>  j error_exit
> 
> fclose_error:
>  li a1, 119
>  jal x1, error_epilogue
>  j error_exit
> ```
>
> 怀疑是ra(x1)地址错误导致，在第一段code中，进入error_epilogue调用前设置了ra的值，但是调用中从stack设置了ra的值。因此从error_epilogue返回时，地址是错误的。尝试改为如下，从error_epilogue返回后，再设置一次ra
>
> ```assembly
> fopen_error:
>  jal x1, error_epilogue
>  li a1, 117
>  lw ra, 32(sp)
>  addi sp, sp, 44
>  j error_exit
> error_epilogue:
>  lw s0, 0(sp)
>  lw s1, 4(sp)
>  lw s2, 8(sp)
>  lw s3, 12(sp)
>  lw s4, 16(sp)
>  lw s5, 20(sp)
>  lw s6, 24(sp) 
>  lw s7, 28(sp)
>  lw ra, 32(sp)
>  # a1 and a2 should not be restore
>  # lw a1, 36(sp)
>  # lw a2, 40(sp)
> ```
>
> 结果仍然是fopen不对
>
> ![image-20220428223541172](https://tva1.sinaimg.cn/large/e6c9d24ely1h1pt8k68vqj20ky056752.jpg)
>
> 也是，如果ra错误的话，那么其他几种异常的调用顺序也应该错误。例如fclose，先设置ra位pc+4，再进入error_epilogue设置ra，也不应该能测试通过。所以这说明在调用中设置ra的值，不会影响`jal x1, label`中的ra(x1)，也就是说jal x1中的x1一定是pc+4，肯定能返回来。
>
> 换一个角度来看，jal进入一个调用过程以后，本来就应该save restore一遍，error_epilogue这个操作就不符合calling convention。
>
> 符合calling convention的error_epilogue如下(或者说，这没有jal，只是j 所以不需要calling convention了)
>
> **所以，如何写一个符合calling convention的epilogue给exception用，有待考虑**
>
> ```assembly
> fopen_error:
>  li a1, 117
>  j error_epilogue
> 
> malloc_error:
>  li a1, 116
>  j error_epilogue
> 
> fread_error:
>  li a1, 118
>  j error_epilogue
> 
> fclose_error:
>  li a1, 119
>  j error_epilogue
> 
> error_epilogue:
>  lw s0, 0(sp)
>  lw s1, 4(sp)
>  lw s2, 8(sp)
>  lw s3, 12(sp)
>  lw s4, 16(sp)
>  lw s5, 20(sp)
>  lw s6, 24(sp) 
>  lw s7, 28(sp)
>  lw ra, 32(sp)
>  # a1 and a2 should not be restore
>  # lw a1, 36(sp)
>  # lw a2, 40(sp)
>  j error_exit
> ```
>

> 问题2:
>
> 突然发现一个问题，《计算机组成与设计：硬件/软件接口》中写到riscv中的寄存器都是64bit，那么实现prologue和epilogue时，都使用的是sw/lw。虽然对高位进行了位拓展，但是感觉容易出问题，尤其是指针操作时，因为实验环境是64bit，指针地址是64bit，可能存在覆盖高32bit的问题。
>
> 根据https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf , **For RV32, the x registers are 32 bits wide, and for RV64, they are 64 bits wide. **因此，实验代码应该是使用的RV32指令集，


### task2 write mat

`python3 -m unittest unittests.TestWriteMatrix -v`

### task3 putting together

总目标：实现汇编代码，并且要返回正确的退出代码

具体：写函数来读入mnist输入数据，并做分类，参数矩阵是课程给的，训练好的。malloc一块内存，把读到的矩阵加载进去，计算network参数。自己实现的分类七会被多次调用，并实现分类功能，所以一定要注意calling convention和注释。

**command line args and filepath**

输出需要通过command line指定，riscv的命令行参数和c是相似的，a0/a1分别对应argc/argv，a2决定是否需要打印出分类结果，如果a2是0的话就打印一个新行。如果不是0，就不要打印任何东西。

调用的命令行： `./tools/venus <venus flags> src/main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>`，argv的索引是从`src/main.s`开始计算的。

**the network**

首先，使用read_matrix加载m0,m1,input。模型的计算过程是 输入*m0，然后relu，之后再乘m1。然后就使用分数最高的索引作为预测的输出(argmax)，可以参考伪代码:

```python3
hidden_layer = matmul(m0, input)
relu(hidden_layer) # Recall that relu is performed in-place
scores = matmul(m1, hidden_layer)
```

其次，最终输出的矩阵需要保存到特定的文件去。

**测试**

所有测试使用的输入都放在inputs文件夹中

`python3 -m unittest unittests.TestMain -v`

**Simple**

除了MNIST测试，先提供了一些示例去测试Main函数，这些示例比较容易debug

可以直接使用下面的命令来测试simple0的所有输入

```bash
./tools/venus src/main.s -ms -1 inputs/simple0/bin/m0.bin inputs/simple0/bin/m1.bin inputs/simple0/bin/inputs/input0.bin  outputs/test_basic_main/student_basic_output.bin
```

为了验证正确性，可以自己用numpy先算一下结果

在simple2的示例中，输出的score矩阵是大于1列的，但是argmax是将矩阵视为1D的行优先vector，输出一个整数表示argmax结果。

**MNIST**

输入位于inputs/mnist，包括9组inputs

用下面的命令来进行测试

```bash
./tools/venus src/main.s -ms -1 inputs/mnist/bin/m0.bin inputs/mnist/bin/m1.bin inputs/mnist/bin/inputs/mnist_input0.bin  outputs/test_mnist_main/student_mnist_outputs.bin
```

`-ms -1`是因为MNIST数据量大，需要增加venus能够运行的最大指令数

运行后将生成一个`student_mnist_outputs.bin`包括了对于每个手写数字的分数，同时打印出最大分数的识别数字。可以对比打印出来的数字和`inputs/mnist/txt/labels/label0.txt`

每一个输入的对比都可以在`mnist/txt/labels`找到

此外，`inputs/mnist/txt/print_mnist.py`脚本提供了可视化输入数据对应手写数字的功能

例如，可以在`inputs/mnist/txt`路径下，运行`python3 print_mnist.py 8`可以打印出来实际图像，展示的是ascii风格的mnist_input8

并不是所有的输入都被预测正确，mnist_input2和mnist_input7会被分类为9和8，其他的都能被分类正确。

> inputs中的文件名和实际数字对应关系如下：
>
> python3 print_mnist.py 0
>
>
> This is the MNIST input image:
>
>                   **
>                *****
>               *****
>             **** *
>            *****
>          ******
>         ******
>         ****
>        ***
>       *** *
>       ****
>       **            ******
>       ***      ***********
>       **     *************
>       **    ******* *****
>       ***   **** ** ****
>       ******** *******
>       **************
>        ***********
>          *****
>
> The classifier matches it to the number 6
>
> python3 print_mnist.py 1
>
>
> This is the MNIST input image:
>
>
>                **
>             *****
>           * *****
>            *  ****
>          *** ** **
>           ** *****
>             ******
>          ***** ***
>           ****  **
>                 **
>                 *
>                 **
>                 **
>                 **
>                 **
>                 ***
>                 ***
>                 ***
>                  *
>                  **
>
> The classifier matches it to the number 9
>
> python3 print_mnist.py 2
>
>
> This is the MNIST input image:
>
>              * *****
>             ********
>              *******
>                 **
>                 ***
>                ****
>                *******
>             **********
>            **********
>           *********
>            ******
>             ***
>            ****
>            ****
>           ****
>            ***
>          ***
>          ****
>         ****
>         ***
>
> The classifier matches it to the number 7
>
> python3 print_mnist.py 3
>
>
> This is the MNIST input image:
>
>                ***
>               *****
>             *******
>            ***** ***
>            ****    **
>           *****   ***
>            ***    ***
>                   ***
>                  ***
>                  ***
>                  ***
>            ***  ***
>           *********
>          *********
>         ****  ****
>        ****  ****
>        ***  *******
>        ******** ***
>        *******   *
>         *** *
>
> The classifier matches it to the number 2
>
>  python3 print_mnist.py 4
>
>
> This is the MNIST input image:
>
>
>            ******
>           *********
>         ****      *
>        ** *      ***
>        *         ***
>       ***       ***
>       ***      ****
>        ***   ******
>         ******** **
>          ****     *
>                  **
>                  **
>                  **
>                  **
>                  **
>                  ***
>                  ***
>                  ***
>                  **
>                  **
>
> The classifier matches it to the number 9
>
> python3 print_mnist.py 5
>
>
> This is the MNIST input image:
>
>            ***     **
>           ****   ***
>          ****    ***
>         ****     ***
>         ***       **
>        ***       ***
>        ***      ****
>        ***      **
>        ***      **
>         **   ** ***
>        ***  *******
>         ****** ****
>          ****  ***
>                ***
>                 **
>                ***
>                ***
>                **
>               ****
>               ***
>
> The classifier matches it to the number 4
>
> python3 print_mnist.py 6
>
>
> This is the MNIST input image:
>
>
>               *      **
>              ***   ****
>             ****   ****
>            *****   ****
>            ****   ***
>          *****    ****
>          ***     *****
>        ***************
>        ****************
>        ***************
>        ************
>          **  *****
>             ****
>            ******
>            *****
>           *****
>          *****
>          *****
>          ***
>           ***
>
> The classifier matches it to the number 4
>
> python3 print_mnist.py 7
>
>
> This is the MNIST input image:
>
>
>            ********
>           **********
>         ************
>       * *************
>      ********  * ****
>      ********   ****
>      *********  ****
>      ********   *****
>      **** *      ****
>      ****       *****
>                *****
>              *******    *
>             *************
>            **************
>           ***************
>         ***************
>        *********
>        ********
>        *******
>        *****
>
> The classifier matches it to the number 2
>
> python3 print_mnist.py 8
>
>
> This is the MNIST input image:
>
>                *****
>            **********
>         *************
>        **************
>      *********   ***
>      *******    ****
>     ******      ****
>     *****       ****
>     ****       *****
>                ****
>               *****
>               *****
>               ****
>              *****
>              *****
>             *****
>              ****
>             ****
>             ****
>              ***
>
>
> The classifier matches it to the number 7



> 问题：在write_matrix中读取行列的4B，使用sbrk就会报如下错误:
>
> ![image-20220503095634422](https://tva1.sinaimg.cn/large/e6c9d24ely1h1uze922xsj20dc03i0sr.jpg)
>
> ![image-20220503095557307](https://tva1.sinaimg.cn/large/e6c9d24ely1h1uzdnju2pj20t007275g.jpg)
>
> 而改为malloc，就不会报错
>
> ![image-20220503095617378](https://tva1.sinaimg.cn/large/e6c9d24ely1h1uzdyontvj20ss01zjrt.jpg)
>
> **究竟sbrk和malloc区别是?**

**Generating Your Own MNIST Inputs**

1. 在一个28*28像素点的图上画一个数字，并且存成bmp，放到inputs/mnist/student_inputs
2. 使用`bmp_to_bin.py`将bmp转成bin：`python3 bmp_to_bin.py example`
3. 使用m0和m1参数矩阵来进行预测:`./tools/venus src/main.s -ms -1 -it inputs/mnist/bin/m0.bin inputs/mnist/bin/m1.bin inputs/mnist/student_inputs/example.bin  outputs/test_mnist_main/student_input_mnist_output.bin`

## FAQ

**检查返回代码**

`t.execute(code=???)`

**coverage怎么测的**

计算指令执行的次数。一个单独的测试项目不需要cover代码中的所有指令。所以为了得到更高的coverage分数，需要将测试项目能够运行到代码中的所有指令。

**如何看没有cover到的指令**

使用`print_coverage`，verbose设置为True

**如何正确使用退出代码**

看一下`exit2`函数

**把一个temp register入栈，在函数调用结束后再从栈恢复是否可以**

根据calling convention，temp寄存器在经过函数调用后可能会包含任意值。

**malloc failed**

返回0

**fopen failed**

a0返回-1

## sp21-proj2-starter

```
.
├── inputs (test inputs)
├── outputs (some test outputs)
├── README.md
├── src
│   ├── argmax.s (partA)
│   ├── classify.s (partB)
│   ├── dot.s (partA)
│   ├── main.s (do not modify)
│   ├── matmul.s (partA)
│   ├── read_matrix.s (partB)
│   ├── relu.s (partA)
│   ├── utils.s (do not modify)
│   └── write_matrix.s (partB)
├── tools
│   ├── convert.py (convert matrix files for partB)
│   └── venus (RISC-V simulator)
└── unittests
    ├── assembly (contains outputs from unittests.py)
    ├── framework.py (do not modify)
    └── unittests.py (partA + partB)
```


## Here's what I did in project 2:

1. when debugging ReadMatirx, have to copy .bin used for read to assembly folder. And set filepath in unittest.py to ".bin"

2. [ref](https://cs61c.org/resources/venus-reference) would help if you have any question about Venus, such as "how to pass in commadline argument when debugging"