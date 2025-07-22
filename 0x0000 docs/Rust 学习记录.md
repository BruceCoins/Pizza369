## Rust 学习记录  
本文主要记录 Rust 特色用法

### 语句、表达式  
``语句``：执行操作指令，不返回值  
``表达式``：计算并返回一个结果  
```rust
// y={} 大括号中的为表达式
// x + 1 没有分号，自动返回结果。如果加上分号，大括号中就不是表达式了
fn main(){
    let y = {
        let x = 3;
        x + 1
    };
    // 输出时使用的占位符 {}
    println!("The value of y is {}",y)  
}
```
### 函数返回值  
- 使用 ``->``声明函数返回类型
- 【1】使用return返回，
- 【2】函数最后一个表达式的值，不加分号会自动返回结果  
```rust
fn get_num() -> i32{
    6666
}
```

### 循环 loop | while | for    
#### loop 循环  
- **“break”**：停止 loop 循环  
- **“break 表达式”**：停止 loop 循环，并返回表达式值  
- **“continue”**：跳出本次循环
- ** '标签名：loop{}**：【单引号 + 标签名】

```rust
//loop简单使用
fn loop1(){
    //不停的输出 gogogo
    loop{
        println!{"gogogo"};
    }
}

// 【break 表达式】的使用
fn loop2(){
    let mut counter = 0;
    let result = loop{
        counter += 1;
        if counter == 10{
            break counter*2;  //【break 表达式】：结束循环，返回表达式的结果
        }
    };
    println!("the result is {result}");
}

// '标签名 ：loop{} 的使用
fn loop3(){
    let mut count = 0;

    //第一层loop循环，定义标签为【'counting_up】
    'counting_up:loop{
        println!("count = {count}");  //输出count
        let mut remaining = 10;

        //第二层loop循环
        loop{
            println!("remaining = {remaining}");
            if remaining == 9{
                break;  //跳出当前循环，即第二层循环
            }
            if count == 2{
                break 'counting_up;  //跳出【标签名】的循环，即第一层循环
            }
            remaining -= 1;
        }
        count += 1;
    }
    println!("End count = {count}");
}
```   
#### for循环  
- **“for 元素 in 集合”**：如果元素没有用到，可以用 ``"_”`` 代替
- **"range"**：循环特定次数
```rust
//循环整个数组
fn for_example(){
    let a = [10,20,30,40,50,60];
    for e in a{
        println!("the value is {e}");
    }
}

// 循环3次，每次 x 都是10
fn for_example2(){
    let a = [10;3];  //定义数组，3个10
    let mut sum = 0;
    for x in a{
        println!("x = {x}");
        sum += x;
    }
    print!("sum = {sum}");
}

// 遍历 [1,5) 即4次,同时输出 1，2，3，4 
// rev()方法为倒序输出，即 4，3，2，1
fn for_example3(){
    for number in (1..5).rev(){
        println!({number});
    }
    println!("END!");
}

// 循环时元素不使用，’_‘ 代替元素，遍历[1,5)，循环4次
fn for_example4(){ 
    let mut cc = 1;
    for _ in 1..5{
        println!("cc = {cc}");
        cc += 1;
    }
}

//循环时元素不使用，用 ‘_‘代替，则只是循环数组长度的次数
fn for_example5(){
    let mut dd = 1;
    let a = [10,20,30,40,50,60];
    //循环6次
    for _ in a{
        println!("the shuzu is {dd}");
        dd += 1;
    }
}
```

### 所有权( Stack | Heep 内存安全 )   
``stack frame(栈帧)``：存放函数 **局部变量、参数、返回值** 的内存空间。   
- 数据小时，stack栈内存中直接存放在数据，数据必须拥有已知的固定大小
- 数据大时，编译或运行时，数据可能发生变化必须放在Heep中。stack栈内存中存放指针地址指向Heep堆内存，数据实际位置在Heep堆内存中。  

#### 【1】拥有 Copy strait 属性的类型：可以直接赋值 b = a，要求a、b是如下同类型   
所有整型、bool、char、所有浮点型、Tuple(元组)要求其所有字段都是前面的类型    
  
#### 【2】使用 Box 的集合（Heep操作）：不能直接赋值 b = a 操作，否则 a 的值将不可用，要求a、b是如下同类型    
Vec、String、HashMap...   
**Box 内存释放原则**：如果一个变量拥有一个 box ，当 Rust 释放该变量的 stack frame 时，Rust 同时释放该 box 的堆内存（Heep）  

```rust
//固定大小，数据小，存放在stack 中
fun num(){
    let a = 5;
    let b = a;
    println!("a = {a}, b = {b}");   //控制台输出 a = 5, b = 5
}

//固定长度，数据太大，为减小内存占用，可放在Heep堆内存中
fun num2(){
    //--------定义两个超大数组，要求都可以使用--------
    //具有1000000元素的数组，如果房在stack中，特别占内存
    let a = [0;1000000];

    //赋值给b后，在stack中复制一个数组，导致内存占用的更多了
    let b = a;    
    println!("a = {a}, b = {b}");

    //------------解决：将数组放到 Heep 堆中，stack 放指针【与堆相关，涉及到所有权问题】-------------
    //通过Box::new()将数组数据放到堆中，a2有stack中存放指针的所有权
    let a2 = Box::new([0;1000000]);

    //如下赋值，将a2 存放的指针 所有权 转让给 b2，a2失去了指向堆的指针，stack释放a2数据，a2成为未定义状态
    let b2 = a2;   

    //所以当输出 a2 时报错，b2 正常使用
    println!("a2 = {a2}, b2 = {b2}");
}



```
