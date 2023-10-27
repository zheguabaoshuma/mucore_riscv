# 编译实验记录

### LAB1

##### `llvm`是干啥的

![image-20230914015158193](C:\Users\Tuuuu\Desktop\project\os\image-20230914015158193.png)

位于高级程序语言和低级机器语言中间的一个东西，负责完成前者到后者的转换。

- `gcc`和`clang`都是`c/c++`的编译器，但是`gcc`封闭了编译的过程，不能看到中间的词法分析和语法分析过程。

- 在`clang`中，可以使用如下指令获得单词表
  
  ```sh
  clang -E -Xclang -dump-tokens main.c
  ```
  
  使用如下指令获得语法分析树信息 
  
  ```sh
  clang -E -Xclang -ast-dump main.c
  ```

- 利用`clang`进行编译，生成`LLVM IR`中间代码
  
  ```sh
  clang -S -emit-llvm main.c
  ```
  
  *补充：使用`gcc`使用`-S`参数直接生成`.s`文件*
  
  ```sh
  gcc -S main.c
  ```
  
  执行完毕生成`.ll`文件。

- `.ll`文件是`LLVM IR`中间文件的文本格式，有时候也会需要用到`.bc`格式，这种格式是`LLVM IR`的二进制格式
  
  ```sh
  llvm-dis a.bc -o a.ll
  ```
  
  ```sh
  llvm-as a.ll -o a.bc
  ```
  
  这两个指令允许两种格式的文件相互转换。

- `.i`文件是`.c`文件经过预处理之后的文件，从编译流程来看，两者都可以直接被编译为`.s`文件，也就是汇编代码文件。
  
  预处理在生成汇编代码方面有一些重要的意义：
  
  1. **宏展开**：预处理阶段会展开源代码中的宏。宏是一种带有参数的代码模板，通过展开宏，可以将宏调用替换为实际的代码。这有助于提高代码的可读性和重用性。展开宏后的代码更容易被编译器优化，生成更高效的汇编代码。
  2. **头文件包含**：预处理器处理`#include`指令，将其他源代码文件的内容包含到主源文件中。这允许你模块化代码并重用代码块，同时确保在生成汇编代码时将所有必需的源代码合并在一起。
  3. **条件编译**：预处理器可以根据条件编译指令（如`#ifdef`、`#ifndef`、`#if`等）决定哪些部分的代码应该包含在生成的汇编代码中。这使得你可以在不同的条件下生成不同的汇编代码，以实现平台特定的优化或在不同的编译目标上使用不同的代码。
  4. **删除注释**：预处理器通常会删除源代码中的注释，这减小了最终生成的汇编代码的体积，使其更加精简。
  
  `gcc/clang`使用如下命令进行预编译
  
  ```sh
  clang/gcc -E source_file.c -o output_file.i
  ```
  
  **预编译的效果**
  
  源文件（注意这是`c++`文件，以上的指令要从`clang`变成`clang++`）
  
  ```c++
  #include <iostream>
  #define x 10
  
  #ifndef debug
  std::cout<<"in debugging"<<std::endl;
  #endif
  
  int main() {
      int i,n,f;
      std::cin>>n;
      i=2;
      f=1;
      while(i<=n){
          f=f+i;
          i=i+1;
      }
      std::cout<<f<<std::endl;
      std::cout<<x;//macro definition
  }
  ```
  
  经过`clang`预编译之后代码达到了30000+行，前面的`#include`部分被全部链接到库文件并展开，复制到了`.i`的文件中。
  
  ```c++
	namespace std
  {
    typedef long unsigned int size_t;
    typedef long int ptrdiff_t;
  
    typedef decltype(nullptr) nullptr_t;
  
  }
  
  namespace std
  {
    inline namespace __cxx11 __attribute__((__abi_tag__ ("cxx11"))) { }
  }
  ```

  而程序正文段位于末尾

  ```c++
  std::cout<<"in debugging"<<std::endl;
  
    int main() {
        int i,n,f;
        std::cin>>n;
        i=2;
        f=1;
        while(i<=n){
            f=f+i;
            i=i+1;
        }
        std::cout<<f<<std::endl;
        std::cout<<10;
    }
  ```

  可以看到注释部分被删除；条件编译对应展开。从某种意义来说，预编译并不能算编译器的一部分，只是一种代码优化。

- 如何将`.c`和`.i`变成汇编代码文件`.s`
  
  ```sh
  llc main.ll -o main.s
  ```

  如果要指定生成不同架构的汇编代码文件

  ```sh
  llc -march=arm main.ll -o main.s
  ```

- `.s`文件进行一次翻译得到可执行文件，**Linux中可执行文件没有后缀**。
  
  ```sh
  gcc/clang main.s -o main
  ```
  
  也可以先生成中间的`.o`目标文件
  
  ```sh
  llc main.s -filetype=obj -o main.o
  ```

- `llvm`并不是一个特定的组件，而是一套工具，通常使用`llc`来调用相关功能
  
  ```sh
  llc --version
  ```

#### 一个程序完整的一生

![image-20230914010627073](C:\Users\Tuuuu\Desktop\project\os\image-20230914010416874.png)

#### 如何通过编辑`.ll`文件编写程序

正常来说，`.ll`本身应该是一个中间生成文件，并不是一个端语言，没有必要在`.ll`文件下修改然后又去编译喵。

`.ll`文件是一个介于汇编和高级程序语言的中间文件，是`LLVM`编译过程中的文件，风格与`C`类似。`LLVM`的官方文档https://llvm.org/docs/ProgrammersManual.html#the-core-llvm-class-hierarchy-reference。

这里实现一个阶乘的程序

```llvm
; ModuleID = 'test.cpp'
source_filename = "test.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1

define i32 @factorial(i32) {
entry:
  %eq = icmp eq i32 %0, 0   
  br i1 %eq, label %then, label %else

then:                                             ; preds = %entry
  br label %ifcont

else:                                             ; preds = %entry
  %sub = sub i32 %0, 1   
  %1 = call i32 @factorial(i32 %sub) 
  %mult = mul i32 %0, %1  
  br label %ifcont

ifcont:                                           ; preds = %else, %then
  %iftmp = phi i32 [ 1, %then ], [ %mult, %else ]
  ret i32 %iftmp
}

; Function Attrs: mustprogress noinline norecurse optnone uwtable
define dso_local noundef i32 @main() #0 {
  ;%1 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([3 x i8], [3 x i8]* @.str, i64 0, i64 0), i32 noundef 123)
  %1 = call i32 @factorial(i32 9)
  %2 = call i32 (i8*, ...) @printf(i8* noundef getelementptr inbounds ([3 x i8], [3 x i8]* @.str, i64 0, i64 0), i32 %1)
  ret i32 0
}

declare i32 @printf(i8* noundef, ...) #1

attributes #0 = { mustprogress noinline norecurse optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 1}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
```

**注意**：

1. 在`llvm`中，用`%`加一个数字表示一个虚拟寄存器，对应`c/c++`的局部变量

2. 代码中不是所有的东西都会被用于生成汇编语言。比如
   
   ```llvm
   ; ModuleID = 'test.cpp'
   source_filename = "test.cpp"
   target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
   target triple = "x86_64-pc-linux-gnu"
   ```
   
   指明了一些文件信息，数据存储信息等。这一部分的信息是由编译器生成的，可以在官网的`data layout`部分找到相关参考。
   
   还有这一部分
   
   ```llvm
   attributes #0 = { mustprogress noinline norecurse optnone uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
   attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
   
   !llvm.module.flags = !{!0, !1, !2, !3, !4}
   !llvm.ident = !{!5}
   
   !0 = !{i32 1, !"wchar_size", i32 4}
   !1 = !{i32 7, !"PIC Level", i32 2}
   !2 = !{i32 7, !"PIE Level", i32 2}
   !3 = !{i32 7, !"uwtable", i32 1}
   !4 = !{i32 7, !"frame-pointer", i32 2}
   !5 = !{!"Ubuntu clang version 14.0.0-1ubuntu1.1"}
   ```
   
   这一部分的数据是元数据metadata，这是一种描述数据信息的数据，对编译也没有用。

3. 在`llvm`中`@`之后的是一个**全局符号**，函数，全局变量都使用`@`开头。

4. 如果源文件包含对某些库的依赖例如使用`#include`，那么编译器会在链接过程将这些不属于本文件的符号链接到正确的位置。在这个例子中，由于我们使用的`stdlib`的`c`标准库函数，编译器会自动帮助链接，因为编译器本身就带有链接到标准库函数的`.so`文件，默认会帮我们自动解析来自标准库的符号
   
   为了查看链接信息，可以使用
   
   ```sh
   ldd your_program
   ```
   
   本例的输出结果
   
   ```sh
           linux-vdso.so.1 (0x00007ffd40bb5000)
           libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fd27bab8000)
           /lib64/ld-linux-x86-64.so.2 (0x00007fd27bcf4000)
   ```
   
   也可以在编译的时候指定选项`-v`输出编译器的编译过程信息。
   
   ```sh
   gcc -v your_program.c -o your_program
   ```
   
   

### Lab2

实验任务是自己设计一个`SysY`语言的文法，基于此文法写一个简单的程序，然后手工翻译成`arm`架构的汇编指令。

`SysY`语言设计这里就不再展开，设计出来基本与`C`类似。

```c
int factorial(int n){
    if(n<=1) return 1;
    return n*factorial(n-1);
}
int main(){
    int a=factorial(5);
    return a;
}
```

在手工翻译成`arm`架构的代码之前，首先要明确几点：

- `arm`架构的机器中的通用寄存器一共有16个，用`r0`到`r15`指代。其中`r0`到`r12`是可供程序员随意使用的寄存器。`r13`是栈指针，可以用`sp`来指代；`r14`是链接寄存器，用来存放函数返回地址，可以用`lr`指代；`r15`是程序计数器，保存当前正在执行的指令的地址，可以用`sp`指代。

- 在讨论计算机体系底层设计中，“栈”指的是一段连续的内存空间，和FIFO、LIFO之类的没有任何关系，这段内存不一定要完全按照数据结构的定义运行（*可以有压栈弹栈等操作*，也可以直接定位存储），存储的方向不固定。（但是一般来说，随着程序的运行和函数的调用，数据应该是从栈顶向栈底增长的）

- 在栈中，规定高地址为栈顶，低地址为栈底，存放的单个数据是从栈顶向栈底增长，小端模式下呈现下面这样的排布

  | （高地址）     |
  | -------------- |
  | `0x14` 数据↓   |
  | `0x13` 是这↓   |
  | `0x12` 样子↓   |
  | `0x11` 放的    |
  | **（低地址）** |

  可以看到这条数据（"数据是这样子放的"）的高位("数据")放在了`0x14`的位置，低位（“放的”）放在了`0x11`的位置。

接下来就可以开始着手写代码了，首先是`factorial`的函数部分

```assembly
.global factorial
factorial:
@ r0 is praram. 
@ r12 is stack bottom
push {r12, lr}
sub sp,sp,#8
add r12,sp,#0
str r0, [r12,#4]
ldr r3, [r12,#4]  
cmp r3, #1
bgt br1
movs r3, #1
b br2

br1:
subs r3,r3,#1
mov r0,r3
bl factorial(PLT)
mov r4,r0
ldr r3,[r12,#4]
mul r3,r3,r4

br2:
mov r0,r3
adds r12,r12,#8
mov sp,r12

pop {r12,pc}
```

我们一段一段对照来看。首先是函数的声明`int factorial(int n)`。

```assembly
.global factorial
factorial:
@ r0 is praram. 
@ r12 is stack bottom
push {r12, lr}
sub sp,sp,#8
add r12,sp,#0
```

这一部分的代码只干了三件事：

1. 声明了符号`factorial`，然后将栈底指针`r12`和返回链接`lr`压栈。

   > 这里的`push`操作在`arm`汇编中的本质其实是`str r12, [sp,#-4]`，然后指针`sp`的位置向下移动4个字节。也就是说`r12`的数据会被存入`sp`向下偏移4个字节的位置
   >
   > 
   >
   > 同理`pop {r12}`的本质是`ldr r12,[sp,#4]`，然后指针`sp`向上移动4个字节。

2. `sp`向下移动8个字节的位置，开辟了一个8字节大小的栈空间。（意思就是栈底是一大片空内存，`sp`往下划了一段内存作为当前函数的栈内存）

3. 把当前的`sp`值赋给`r12`，用来记录函数栈底的指针。

```assembly
str r0, [r12,#4]
ldr r3, [r12,#4]  
cmp r3, #1
bgt br1
movs r3, #1
b br2
```

这一段代码首先是一个赋值，将函数入口的参数`r0`给到`r3`（`r0`可以理解作函数与外部的一个接口寄存器，函数传入的参数从这里进去，返回的值从这里出来），之后就不再使用`r0`而是`r3`来完成函数过程的运算（这也是为什么`c\c++`种函数调用传入的形参不会影响实参的原因）。

之后是一个分支跳转的实现。注意这里的`cmp`指令会比较寄存器`r3`和1的大小，比较的结果会设置在标志位寄存器`CPSR`。所以使用完`cmp`之后，通常会继续使用`beq`，`bne`，`bgt`等跳转操作，这些跳转指令选择跳转的方向就是这个标志寄存器。

```assembly
br1:
subs r3,r3,#1
mov r0,r3
bl factorial(PLT)
mov r4,r0
ldr r3,[r12,#4]
mul r3,r3,r4
```

`br1`是条件判断体外的代码，对应`return n*factorial(n-1);`。这里的函数调用就是将需要传入的参数放入`r0`，然后跳转回函数开头部分的代码。注意跳转用的是`bl`而不是`b`，`b`是无条件跳转，只是简单将`pc`的值变为对应位置指令的地址；`bl`是带链接跳转，除了有`b`的功能之外，还会将跳转前的地址存入`lr`寄存器中。

```assembly
br2:
mov r0,r3
adds r12,r12,#8
mov sp,r12
```

`br2`自然对应的就是`r3`小于等于1的时候。直接返回`r3`的值（就是1，参考上面的`mov r3,#1`）。

不管是哪个分支，退出的时候都要执行返回的操作，继续之前调用函数之后的代码。也就是

```assembly
pop {r12,pc}
```

这个操作会将之前压入的栈指针（指向函数栈的栈底）和返回地址分别回退到`r12`和`pc`中，继续之前的任务。

至此阶乘的函数就结束了。接下来是主函数的实现

```assembly
.global main
main:
push {r12,lr}
sub sp,sp,#8
add r12,sp,#0
mov r0,#4
bl factorial(PLT)
str r0, [r12,#4]
ldr r3, [r12,#4]
mov r0,r3
adds r12, r12, #8
mov sp, r12

pop {r12,pc}
```

结构与`factorial`函数是一致的。开头是压栈开辟函数栈空间，结尾是将计算的结果挪入`r0`作为函数返回值，然后弹出栈指针和返回链接。



##### 怎么运行`arm`程序以及怎么调试

写完了代码还得要编译

```sh
arm-linux-gnueabihf-gcc factorial.s -o output
```

这样子就可以生成一个`arm`架构的程序了喵。但是如果直接在终端执行终端会告诉你它看不懂喵。

好不容易写完的程序还不能在`x86`上跑，总不能买一个`arm`架构的机器吧。这时候就要用到`qemu`喵。如果已经安装了`qemu`（并且有对应`arm`架构的`qemu`）。那么可以直接执行

```sh
qemu-arm output
```

就可以运行你已经编译好的`output`可执行程序了，同样可以用

```sh
echo $?
```

来获取主函数退出时返回的值。如果`qemu-arm`抽风提示

```sh
qemu-arm: Could not open '/lib/ld-linux-armhf.so.3': No such file or directory
```

首先检查`/usr/arm-linux-gnueabihf/`文件夹下有没有这个`.so.3`的链接文件，如果有，那么执行

```sh
qemu-arm -L /usr/arm-linux-gnueabihf/ output
```

> 这里补充一下，`qemu-arm`和`qemu-system-arm`都是模拟一个`arm`架构的机器。但是两者用起来是不一样的
>
> 1. **`qemu-arm`**：
>
>    - `qemu-arm` 是 QEMU 的一个简化命令，用于在用户空间中运行ARM二进制文件（不需要root权限）。
>    - 它通常用于在本地系统上运行ARM架构的可执行文件，类似于在ARM开发板上运行程序。
>    - 这个命令通常用于开发和调试阶段，例如在x86_64架构的Linux系统上运行ARM二进制文件进行调试。
>
>    示例：
>
>    ```bash
>    qemu-arm ./my_arm_binary
>    ```
>
> 2. **`qemu-system-arm`**：
>
>    - `qemu-system-arm` 是 QEMU 的一个完整的系统仿真命令，用于在虚拟机中模拟ARM架构的整个计算机系统。
>    - 它能够模拟整个ARM开发板，包括处理器、内存、设备等，并且可以加载一个完整的ARM操作系统（比如Linux），使你能够在虚拟环境中运行一个完整的ARM系统。
>    - 这个命令通常用于测试和验证ARM操作系统的运行，或者进行嵌入式系统的开发和调试。
>
>    示例（在QEMU虚拟机中运行ARM Linux系统）：
>
>    ```bash
>    qemu-system-arm -kernel kernel_image -dtb device_tree_blob -append "root=/dev/sda2" -driv
>    ```

其实本来到这就应该结束了，但是有bug喵。退出时候返回的是退出码，不是一个真正意义上的`int`值，所以算到5的阶乘都还是对的，6（及以上）的阶乘就错得很逆天了。那么到底是不是源代码有问题喵？答案是`gdb`，启动！

首先要重新编译一个带调试信息的可执行文件

```sh
arm-linux-gnueabihf-gcc factorial.s -g -o output
```

直接使用`qemu-arm`进行调试的参数与`qemu-system-arm`的参数稍有不同

```sh
qemu-arm -L /usr/arm-linux-gnueabihf/ -g 1234 output
```

注意参数`-g 1234`一定要放到可执行文件名字的前面，不然`qemu-arm`不知道是要调试直接就执行了喵。

然后在另一个窗口启动`gdb`，注意`gdb`必须要用`arm`架构的。或者也可以使用`gdb-multiarch`。

```sh
gdb-multiarch output
```

启动之后在`gdb`控制台中输入

```sh
(gdb) target remote :1234
```

然后就可以调试了喵，直接打断点过去查看`r0`寄存器的值就好了。

### Lab2.5

本节讨论如何使用`Flex`实现一个自定义功能的词法分析器以及如何使用`Bison`实现一个语法分析器。

在正式开始之前首先需要介绍一下正则表达式的规则

### 1. **文本字符**

- **字母和数字：** `[a-zA-Z0-9]` 匹配任意一个字母或数字。
- **单个字符：** `.` 匹配除换行符外的任意一个字符。

### 2. **字符类**

- **字符范围：** `[0-9]` 匹配任意一个数字。
- **否定字符类：** `[^0-9]` 匹配任意一个非数字字符。

### 3. **重复**

- **重复零次或更多次：** `*` 匹配前面的模式元素零次或更多次。
- **重复一次或更多次：** `+` 匹配前面的模式元素一次或更多次。
- **重复零次或一次：** `?` 匹配前面的模式元素零次或一次。
- **重复指定次数：** `{n}` 匹配前面的模式元素恰好 n 次。
- **重复指定次数范围：** `{n,m}` 匹配前面的模式元素至少 n 次，最多 m 次。

### 4. **位置和边界**

- **行的开头：** `^` 匹配字符串的开头。
- **行的结尾：** `$` 匹配字符串的结尾。
- **单词边界：** `\b` 匹配单词的边界。
- **非单词边界：** `\B` 匹配非单词的边界。

### 5. **分组和引用**

- **分组：** `(pattern)` 用括号将模式元素组合成一个单元，可以与量词一起使用。
- **引用：** `\n` （n 是数字）引用前面的第 n 个分组。

### 6. **特殊字符**

- **转义字符：** `\` 用于转义特殊字符，使其匹配文本而不是特殊含义。
- **或操作：** `|` 匹配两个或多个模式中的任意一个。

### 7. **预定义字符类**

- **数字：** `\d` 匹配任意一个数字，相当于 `[0-9]`。
- **非数字：** `\D` 匹配任意一个非数字字符，相当于 `[^0-9]`。
- **空白字符：** `\s` 匹配任意一个空白字符（空格、制表符、换行符等）。
- **非空白字符：** `\S` 匹配任意一个非空白字符。
- **字母和数字：** `\w` 匹配任意一个字母或数字字符，相当于 `[a-zA-Z0-9]`。
- **非字母和数字：** `\W` 匹配任意一个非字母和数字字符，相当于 `[^a-zA-Z0-9]`。

### Lab2.5

这一部分实验与`lab2`没有很大关系，主要任务是用`Bison`实现一个词法和语法分析器。

> 关于`Bison`
>
> `Bison`是一个生成语法分析器的工具，可以非常便捷地定义各种文法规则以及相关的操作。`Bison`是`yacc`的一个更加现代更加先进的版本。与之对应的是`Flex`，这是一个可以便捷自定义词法规则的工具。
>
> `Bison`的文件格式是`.y`，除了一些特别的文法定义格式之外，其他的各种函数实现直接使用的是`C`。`Bison`的源文件`.y`经过`yacc`分析可以生成一个`.c`的`C`源文件，`.c`的源文件再通过`gcc`即可编译成可执行文件，实现一个简单的编译器。

`Bison`源文件使用的实现是`C`，但是也有其一些特定的文法定义格式。

```yacas
%{
//include
%}
//定义(definations)
%%
//规则(rules)
%%
//代码(user code)
int main(int argc, char **argv)
{
  yylex()
  return 0;
}
int yywrap()
{
	return 1;
}
```

1. **定义部分**（Definitions Section）:

   - 在这一部分，用户可以定义宏（与C预处理器宏类似）和导入所需的头文件。

   - 这里也可以定义联合体（union）来指定yacc语义值的类型。后续实验可能会用到

   - `%token`指令用于声明词法符号。

   - `%start`可以用来声明开始符号。

   - 例如:

     ```yacas
     %{
       #include <stdio.h>
     %}
     %token NUMBER
     %token PLUS MINUS TIMES DIVIDE
     ```

2. **规则部分**（Rules Section）:

   - 在这里，用户定义文法规则，说明如何从一个或多个已知的符号组合生成新的符号。

   - 一个文法规则的左边是一个非终结符，右边是由终结符和/或非终结符组成的序列。右边和左边之间由冒号分隔，规则以分号结束。

   - 文法右侧可以设定**语法制导翻译的规则**，当识别到该规则时自动执行

   - 例如:

     ```yacas
     %%
     expression:
         NUMBER
       | expression PLUS expression
       | expression MINUS expression
       ;
     ```

3. **用户子程序部分**（User Subroutines Section）:

   - 通常这里会包括`yacc`调用的词法分析器（通常由`lex`生成，本次实验我们自行定义）。

   - 还可以包含其他需要的C函数和主函数`main()`.

   - 例如:

     ```yacas
     %%
     int yylex() {
       return getchar();
     }
     int main() {
       yyparse();
       return 0;
     }
     
     int yyerror(char *s) {
       fprintf(stderr, "Error: %s\n", s);
       return 0;
     }
     ```

当你运行`yacc`工具时，它会生成一个C源代码文件（通常命名为`y.tab.c`），该文件包含一个语法分析器。这个生成的文件还需要一个词法分析器，通常由`lex`或`flex`工具生成，然后一起编译。**但**在本次实验中，我们采用自行定义的方式提供`yylex`函数

> 关于`yylex`函数和`yyparse`函数
>
> `yyparse`函数是`Bison`生成的语法分析器的入口点。如果你想启动你已经定义好的语法分析器，那么就得在主函数中调用`yyparse()`函数。
>
> `yylex`函数是调用词法分析器的函数。与`yyparse()`类似。在我们的`Bison`调用`yyparse()`之后，程序会不断读取词法，自动对已有的词法按照特定的文法组合，每次需要读入新的词法时就会调用`yylex()`函数。

*注意：在`Bison`中，`token`可以看作是一个枚举变量，它是一个最基本的，不可分割的文法符号（可以理解成终结符），为了与文法中非终结符号区分，我们用全大写来命名*

#### 实验要求

1. 将所有的词法分析功能均放在` yylex` 函数内实现，为 `+`、`-`、`*`、`\`、`(`、` ) `每个运算符及整数分别定义一个单词类别，在 `yylex` 内实现代码，能识别这些单词，并将单词类别返回给词法分析程序。实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等空白符，能识别多位十进制整数。

2. 中缀表达式转后缀表达式。
3. 实现符号表，实现赋值计算操作。

由于所有功能的代码都整合到了一起，这里我们不按任务来分隔代码

预编译以及全局变量定义

```c
%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<stdbool.h>
    #include<ctype.h>
    #include<string.h>
    #define YYSTYPE double
    #define TABLE_SIZE 100
    #define INT_MIN -2147483648
    int yylex();
    extern int yyparse();
    FILE* yyin;
    void yyerror(const char* s);
    double ComputeValue=0;
    int LeftBrackets=0;
    char LastChar=' ';
    char DeclID[100]="";
    char LastID[100]="";
    int LastLength=0;
    char AssnID[100]="";
    struct KeyValue {
        char* key;
        double value;
        
        };
    struct HashTable {
        struct KeyValue table[TABLE_SIZE];
        };
    bool DeclFlag=false;
    struct HashTable ht;
    double get(struct HashTable* ht, const char* key);
%}

%token NUMBER ADD MINUS DIVIDE MOD TIMES INT FLOAT ID

%left ADD MINUS
%left TIMES DIVIDE MOD
%right UMINUS
```

这一部分的代码定义了一些未来会用到的变量，后面会结核具体代码分析。此外，在这一段代码的末尾，我们定义了文法规则中的终结符`NUMBER`等以及运算符号计算的顺序。

```c
%token NUMBER ADD MINUS DIVIDE MOD TIMES INT FLOAT ID

%left ADD MINUS
%left TIMES DIVIDE MOD
%right UMINUS
```

这里的`left`表示左结合，`right`表示右结合。而定义的运算优先顺序位`+`、`-`<`*`、`\`<`Negtive`。也就是说越靠下的优先级越高。



文法规则定义

```c
%%

lines   :   lines stmt
        |   lines ';'
        |   
        ;

stmt    :   expr ';' {
        printf("Expression value is %f\n",$1);
        }
        |   decl ';' 
        |   assn ';'
        ;

expr    :   NUMBER {
                $$=ComputeValue;
                // printf("%f ",ComputeValue);
                }
        |   expr ADD expr {
                $$=$1+$3;
                // printf("+ ");
                } 
        |   expr MINUS expr {
                $$=$1-$3;
                // printf("- ");
                } 
        |   expr TIMES expr {
                $$=$1*$3;
                // printf("* ");
                } 
        |   expr DIVIDE expr {
                $$=$1/$3;
                // printf("/ ");
                } 
        |   expr MOD expr {
                $$=(int)$1%(int)$3;}
        |   '('expr')' {$$=$2;}
        |   '-' expr %prec UMINUS {$$=-$2;}
        |   ID{
                double value=get(&ht,LastID);
                if(value==INT_MIN)yyerror("varible not found");
                else $$=value;
                }
        ;

keyword :   INT
        |   FLOAT
        ;

decl    :   keyword ID  {printf("variable ");printf(DeclID);printf(" is added and set to %f\n",0);}
        |   keyword ID '=' expr {modify(&ht,DeclID,$4);printf("variable ");printf(DeclID);printf(" is added and set to %f\n",$4);}
        ;

assn    :   ID '=' expr {
        double last_value=get(&ht,AssnID);
        modify(&ht,AssnID,$3);
        printf("variable ");
        printf(AssnID);
        printf(" is set to %f from %f\n",$3,last_value);
        }
        ;


%%
```

在文法定义中，

- `lines`表示的是一个抽象的行，这只是一个框架，用来承接`stmt`，也可以什么也不承接然后以`;`结束。

- `stmt`表示一个语句。在`C/C++`中，一个语句可以是一个表达式计算，也可以是一个定义操作，然后末尾加一个分号`;`。

- `expr`表示一个表达式，最简单的一个表达式可以直接是一个具体的值也就是`NUMBER`，这样就直接终结了，不再产生进一步的表达式。

  表达式和表达式之间可以使用`+`、`-`、`*`、`/`连接，并产生对应的一个表达式的部分。产生式可以概括为$expr \ \rightarrow\ expr\ OP\ expr$。

- `keyword`表示一个关键字。由于`Bison`的文法规则定义中通常不会使用一个字符串作为终结符，也就是说不能写成

  ```c
  keyword :   "int"
          |   "float"//error: cannot recognize string constant
          ;
  ```

  这个时候需要用一个抽象的`token`来代替这个字符串。也就是上面代码中的`INT`和`FLOAT`。

- `decl`是一个声明语句。在`C/C++`中，声明语句的写法一般是

  ```c
  Type _id_;//or
  Type _id_=value;
  ```

  这里我们同样采取这样的格式。

- `assn`表示的是赋值操作，之所以将这一步单曲取出是因为赋值操作与一般的表达式计算操作不太一样（虽然本质上是`=`运算符的计算），涉及到变量值的改变，遇到这种情况时具体的操作与表达式计算会有较大的不同之处，这里就单独列出。

上面两段代码就是整个文法规则的定义，以及遇到某种产生式时将要进行的操作。关于符号表，在全局变量定义的部分我们声明了一个哈希表用来存储符号的信息，下面给出哈希表操作所用到的辅助函数

```c
unsigned int hash(const char* key) {
    unsigned int hashValue = 0;
    for (int i = 0; key[i] != '\0'; i++) {
        hashValue += (key[i]);
    }

    return hashValue % TABLE_SIZE;
}

void insert(struct HashTable* ht, const char* key, double value) {
    unsigned int index = hash(key);
    ht->table[index].key = strdup(key);
    ht->table[index].value = value;
    
}

double get(struct HashTable* ht, const char* key) {
    unsigned int index = hash(key);
    
    if (ht->table[index].key != NULL && strcmp(ht->table[index].key, key) == 0) {
        return ht->table[index].value;
    } else {
        return INT_MIN; 
    }
}

void modify(struct HashTable* ht, const char* key, double newValue) {
    unsigned int index = hash(key);
    //printf("new value is %f\n",newValue);
    if (ht->table[index].key != NULL && strcmp(ht->table[index].key, key) == 0) {
        ht->table[index].value = newValue;
        
    } 
}

bool isDigit(char c){
        if(c>='0'&&c<='9')return true;
        else return false;
}
```

> 这里使用的哈希函数算法是直接将字符串的各位`ascii`码相加然后取100的模得到一个`index`。这样做可能会出现碰撞。

接下来是`yylex()`函数。

```c
int yylex(){
    char t;
    while(true){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n'){continue;}
        else if(isDigit(t)){
                double value=(t-'0');
            	double resi=0;
                bool Havedot=false;
                t=getc(stdin);
                while(isDigit(t)||t=='.'||t==' '||t=='\n'||t=='\t'){
                        if(!Havedot&&t=='.'){
                                Havedot=true;
                                t=getc(stdin);
                                continue;
                        }
                        else if(t==' '||t=='\n'||t=='\t'){
                                t=getc(stdin);
                                continue;
                        }
                        if(Havedot){
                                //value+=0.1*(t-'0');
                           		resi=resi*10+t-'0';
                        }
                        else{
                                value=10*value+t-'0';
                        }

                        if((t=getc(stdin))==EOF){
                                break;       
                        }
                        
                }
                ungetc(t,stdin);
                while(resi>1)resi/=10;
                ComputeValue=value+resi;
                printf("NUMBER %f\n",ComputeValue);
                LastChar='0';
                return NUMBER;
        }
        else if(t=='+') {
                printf("ADD \'+\'\n");
                LastChar=t;return ADD;}
        else if(t=='-') {
                if(LastChar>='0'&&LastChar<='9'){
                        printf("MINUS \'-\'\n");
                        LastChar=t;
                        return MINUS; 
                }
                else{
                        printf("Negative Number\n");
                        return '-';
                }
                }
        else if(t=='/') {
                printf("DIVIDE \'/\'\n");
                LastChar=t;return DIVIDE;}
        else if(t=='*') {
                printf("TIMES \'*\'\n");
                LastChar=t;return TIMES;}
        else if(t=='%') {
                printf("MOD \'%\'\n");
                LastChar=t;return MOD;}
        else if(t=='(') {
                printf("Left Bracket \'(\'\n");
                LastChar=t;LeftBrackets++;return '(';}
        else if(t==')') {
                printf("Right Bracket \')\'\n");
                LastChar=t;LeftBrackets--;return ')';}
        else if(t==';') {
                printf("Semicolon \';\'\n");
                return ';';}
        else if((t>='a'&&t<='z')||(t>='A'&&t<='Z')||t=='_'){
                char identifier[100]="";
                identifier[0]=t;
                int ptr=1;

                t=getc(stdin);
                while((t>='a'&&t<='z')||(t>='A'&&t<='Z')||t=='_') {
                        identifier[ptr++]=t;
                        t=getc(stdin);
                }
                ungetc(t,stdin);

                if(strcmp(identifier,"int")==0){
                        printf("INT \'int\'\n");
                        DeclFlag=true;
                        LastChar='i';
                        return INT;
                }
                else if(strcmp(identifier,"float")==0){
                        printf("FLOAT \'float\'\n");
                        DeclFlag=true;
                        LastChar='f';
                        return FLOAT;
                }
                else {
                        if(DeclFlag){
                                insert(&ht,identifier,0);
                                memcpy(DeclID,identifier,(ptr+1)*sizeof(char));
                                DeclFlag=false;
                        }
                        memcpy(LastID,identifier,(100)*sizeof(char));
                        LastLength=ptr+1;
                        printf("Identifier \'");
                        printf(identifier);
                        printf("\'\n");
                        LastChar='0';//same reason as NUMBER condition
                        return ID;
                }

        }
        else if(t=='='){
                memcpy(AssnID,LastID,100*sizeof(char));
                printf("Assignment \'=\'\n");
                return '=';}
        else return t;
    }
}
```

在这个函数中，有几个注意的地方

- 每个分支返回的都是文法产生式中的一项终结符，可能是`token`，也可能是一个符号例如`(`等。

- 如何确定一个符号是不是`NUMBER`，以及如果是`NUMBER`那么怎么计算这个值？一位一位检查，如果是数字就右移然后相加。如果遇到小数点，那么将`Havedot`变量置位，开始计算小数位`resi`。最后返回一个`NUMBER`的`token`，告诉`yyparse()`函数当前遇到的文法项是一个`NUMBER`。

  `NUMBER`的计算值也需要传递给`expr`，但是`yylex()`函数并不能直接和`expr`交互，所以需要将计算值先保留在一个全局变量`ComputeValue`中，然后在文法规则定义的函数中将`ComputeValue`传递给`$$`（也就是`expr`）。

- 符号`ID`的确定与数字`NUMBER`的确定类似，首先一位一位检测是否为字母或者下划线，检测结束后返回一个`ID`的`token`。

  除此之外，为了实现符号记录的功能，我们还需要考虑将当前识别的符号加入到符号表中。这时必须要考虑

  1. 在声明`decl`的时候会有符号`ID`出现的情况，而`decl`又有两种产生式，一种是默认赋值，一种是指定赋值。这两种情况都是首先调用`insert(&ht,identifier,0)`，指定赋值后续再在文法操作函数的位置额外进行一次`modify()`即可。
  2. 在变量赋值`assn`时候也会出现符号`ID`，这时我们就不应该反复向符号表插入同样的符号项，而是直接调用`modify()`函数对当前识别到的`ID`对应的变量进行修改。

  为了区别这两种情况，使用了一个`DeclFlag`来判断当前遇到`ID`时是变量赋值操作还是变量声明操作。

  > 在文法规则的函数中，我们没法拿到变量`ID`的名字，为此我们设计了`LastID`、`DeclID`和`AssnID`来辅助在不同情况下的文法规则函数中可以找到当前操作的`ID`的名字是什么。

- 在识别到`-`时，同样有两种操作，一个是将这个符号看作是减号`MINUS`；另一个情况是看作符号`-`。区别这两种情况的依据就是上一次读取的字符

  1. 如果上一次读取的字符是数字`NUMBER`或者`ID`，那么这个符号应该看作是减号`MINUS`
  2. 否则，这个符号应该看作符号`-`

  为了实现这个功能，我们添加了维护了一个全局变量`LastChar`，并在每一个分支中都进行了更新，以便遇到上面这种情况的时候，可以判断当前符号应该是负号还是减号。

最后是主函数

```c
int main(){
        yyin=stdin;
        memset(&ht, 0, sizeof(struct HashTable));
        do{
                yyparse();

        }while(!feof(yyin));

        // Clean up allocated memory
        for (int i = 0; i < TABLE_SIZE; ++i) {
                if (ht.table[i].key != NULL) {
                        free(ht.table[i].key);
                }
        }
        return 0;
}
void yyerror(const char* s){
        fprintf(stderr,"parse error: %s\n",s);
        exit(1);
}
```

主函数首先初始化了符号哈希表`ht`，然后调用了`yyparse()`函数来启动文法分析。后面的`yyerror()`函数是当文法分析器遇到无法通过已有的文法产生式去匹配实际遇到的情况时调用的函数。
