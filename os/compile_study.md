# 编译原理

### 词法分析

- 单词：源代码字符串集的分类例如`<identifier>`，`<num>`等
- 模式：描述字符串集如何分类为单词的规则，例如正则表达式`[A-Z]*`
- 词素：程序中实际出现的字符串，与模式匹配，分类为单词、

- 符号串：**字母表符号组成的有穷序列**，例如`0011`，`abbca`等，也成为句子，字

  > 设`s`为符号串，`|s|`表示`s`的长度。另外`ε`表示空符号串
  >
  > 前缀、后缀、子串、真子串、真后缀、真前缀、子序列

- 语言：一个给定字母表之上的任意符号串集合

  ![image-20230923171156174](C:\Users\Tuuuu\Desktop\project\os\image-20230923171156174.png)

  > 空语言`Φ`，`{ε}`只含空字

##### 符号串的运算

- 连接：符号串`x`和`y`的连接，写作`xy`，这里的`y`拼在`x`之后。

  > $s\epsilon=\epsilon s=s$

- 幂运算：同一个字符串重复连接

  > $s^0=\epsilon$
  >
  > $s^{i}=s^{i-1}s$
  >
  > $s^1=s$

- 并、Kleene闭包、正则闭包

  ![image-20230923171816088](C:\Users\Tuuuu\Desktop\project\os\image-20230923171816088.png)

##### 正则表达式

> 也叫正规式、正规表达式
>
> 正规集：一组特定的符号集合，用于构建正则式

正则式$r$是用正规集$L(r)$根据某个规则构造的符号串。

正则式到其表示语言之间有一些特性（设$r,s$为正则式，$L(s),L(r)$为对应的表示语言）

- $r|s\rightarrow L(r)\cup L(s)$
- $rs\rightarrow L(r)L(s)$
- $r^*=(L(r))^*$
- $r=s\leftrightarrow L(r)=L(s)$

正则式还有一些运算的特性

![image-20230923173200159](C:\Users\Tuuuu\Desktop\project\os\image-20230923173200159.png)

在`Pascal`语言中，一些特定的正则式有其特殊的名字。

![image-20230923173530880](C:\Users\Tuuuu\Desktop\project\os\image-20230923173530880.png)

此外还有一些特殊的运算如

$r^+=rr^*$一个或多个实例

$r?=(r|\epsilon)\rightarrow L(r)\cup\{\epsilon\}$0个或一个实例

常用的符号用字符集表示

> $[abc]\rightarrow a|b|c$
>
> $[a-z]\rightarrow a|b\dots|z$
>
> $[A-Za-z]$

正则表达式中的一些常见元字符包括：

- `.`：匹配任何单个字符，除了换行符。
- `*`：匹配前一个字符的零个或多个实例。
- `+`：匹配前一个字符的一个或多个实例。
- `?`：匹配前一个字符的零个或一个实例。
- `[]`：用于定义字符类，匹配其中任何一个字符。
- `()`：用于分组表达式。
- `|`：用于分隔多个可能的匹配。
- `^`：匹配字符串的开头。
- `$`：匹配字符串的结尾。

有些式子不能用正则式表达例如Hollerith字符串。平衡或者嵌套的结构不能用正则式表达。

> 如`12A45B3C`，数字表示字符的重复次数，字母表示要重复的字符。

##### 状态转换图

一个字符串一般要经过几个固定的步骤来被识别。不同的字符串有不同的模式，但是遵循相同的语言规则（例如`+`的前后一般是同类型的变量）。基于此使用状态转换图的方式来识别不同的字符串的词法信息。

状态转换图：一个根据**逐字读入的字符**来判断当前状态并识别的分析方式。

![image-20230923182407549](C:\Users\Tuuuu\Desktop\project\os\image-20230923182407549.png)

![image-20230923182756022](C:\Users\Tuuuu\Desktop\project\os\image-20230923182756022.png)

![image-20230923182816742](C:\Users\Tuuuu\Desktop\project\os\image-20230923182816742.png)

##### 有限自动机

其实就是状态转换图的数学抽象表达，一种正则表达式对应一个有限自动机。有限自动机又分为两种

- 非确定有限自动机NFA：一个状态对于一个输入符号有多个可能的动作
- 确定有限自动机DFA：一个状态对一个输入符号最多有一个动作

![image-20230923183628272](C:\Users\Tuuuu\Desktop\project\os\image-20230923183628272.png)

在数学上，用一个五元组来表示一个自动机

$$M=\{S,\sum,\delta,s_0,F\}$$

- $S$表示有限状态集
- $\sum$表示有穷字母表，也就是输入的字符。
- $\delta$表示$S\times\sum$到$S$子集的映射，$S\times \sum\rightarrow S$，状态转换函数。
- $s_0\in S$是唯一的初态。
- $F\subseteq S$是终态集，可以为空

举例

![image-20230923192033181](C:\Users\Tuuuu\Desktop\project\os\image-20230923192033181.png)

NFA中并不是所有的路径都是可以被接受的。如果符号读取完毕，但是状态机不处于终态，那么这个路径就不能被接受。

![image-20230923193958346](C:\Users\Tuuuu\Desktop\project\os\image-20230923193958346.png)

除此之外，对于不符合正则式的字符串，我们也要为原来的自动机添加异常状态处理。

![image-20230923194420982](C:\Users\Tuuuu\Desktop\project\os\image-20230923194420982.png)

DFA和NFA的对比

![image-20230923194753525](C:\Users\Tuuuu\Desktop\project\os\image-20230923194753525.png)

NFA比DFA更加的简洁，在进行实际编译的过程中，我们可以先将正则式变为NFA，再转换成DFA提高性能。

##### 使用Thompson算法将正则式转换为NFA

关键：使用简单NFA片段替换形成完整的NFA

![image-20230923212351524](C:\Users\Tuuuu\Desktop\project\os\image-20230923212351524.png)

![image-20230923212408407](C:\Users\Tuuuu\Desktop\project\os\image-20230923212408407.png)

![image-20230923212424867](C:\Users\Tuuuu\Desktop\project\os\image-20230923212424867.png)

![image-20230923212438546](C:\Users\Tuuuu\Desktop\project\os\image-20230923212438546.png)

##### NFA转换为DFA，子集构造法

意义：NFA虽然简单，但是包含很多ε符号，计算机难以实现。



### LL文法和LR文法

During an LL parse, the parser continuously chooses between two actions:

1. **Predict**: Based on the leftmost nonterminal and some number of lookahead tokens, choose which production ought to be applied to get closer to the input string.
2. **Match**: Match the leftmost guessed terminal symbol with the leftmost unconsumed symbol of input.

As an example, given this grammar:

- S → E
- E → T + E
- E → T
- T → `int`

Then given the string `int + int + int`, an LL(2) parser (which uses two tokens of lookahead) would parse the string as follows:

```
Production       Input              Action
---------------------------------------------------------
S                int + int + int    Predict S -> E
E                int + int + int    Predict E -> T + E
T + E            int + int + int    Predict T -> int
int + E          int + int + int    Match int
+ E              + int + int        Match +
E                int + int          Predict E -> T + E
T + E            int + int          Predict T -> int
int + E          int + int          Match int
+ E              + int              Match +
E                int                Predict E -> T
T                int                Predict T -> int
int              int                Match int
                                    Accept
```

Notice that in each step we look at the leftmost symbol in our production. If it's a terminal, we match it, and if it's a nonterminal, we predict what it's going to be by choosing one of the rules.

In an LR parser, there are two actions:

1. **Shift**: Add the next token of input to a buffer for consideration.
2. **Reduce**: Reduce a collection of terminals and nonterminals in this buffer back to some nonterminal by reversing a production.

As an example, an LR(1) parser (with one token of lookahead) might parse that same string as follows:

```
Workspace        Input              Action
---------------------------------------------------------
                 int + int + int    Shift
int              + int + int        Reduce T -> int
T                + int + int        Shift
T +              int + int          Shift
T + int          + int              Reduce T -> int
T + T            + int              Shift
T + T +          int                Shift
T + T + int                         Reduce T -> int
T + T + T                           Reduce E -> T
T + T + E                           Reduce E -> T + E
T + E                               Reduce E -> T + E
E                                   Reduce S -> E
S                                   Accept
```



### 如何构建语法分析预测表

在语法分析中，预测分析表（Predictive Parsing Table）用于LL文法的自顶向下语法分析。为了构建预测分析表，我们通常需要计算两个集合：**First集合**（First Set）和**Follow集合**（Follow Set）。

### First集合：

First集合是一个非终结符或符号串能够推导出的所有可能的终结符的集合。计算First集合的目的是为了在LL文法的预测分析中确定每个非终结符的产生式应该如何选择。First集合的计算规则如下：

1. 如果X是一个终结符，那么First(X) = {X}。
2. 如果X是一个非终结符，并且有产生式X -> Y1Y2...Yk，那么将First(Y1)中的所有符号加入到First(X)中，如果Y1可以推导出空串（ε），那么将First(Y2)中的符号也加入到First(X)中，以此类推，直到最后一个符号Yk不再推导出空串或者k=0。
3. 如果所有产生式的右侧都可以推导出空串，那么将ε（空串）加入到First(X)中。

### Follow集合：

Follow集合是在文法中某个非终结符A的右边可能出现的所有终结符的集合。Follow集合的计算主要用于处理语法分析表中的“$”（输入串结束符）和进行错误恢复。Follow集合的计算规则如下：

1. 将$（输入串结束符）加入到Follow(S)中，其中S是文法的开始符号。
2. 对于文法的每个产生式A -> αBβ，将First(β)中的所有符号（除了ε）加入到Follow(B)中。
3. 如果文法中有产生式A -> αB，或者A -> αBβ并且ε ∈ First(β)，那么将Follow(A)中的所有符号加入到Follow(B)中。
