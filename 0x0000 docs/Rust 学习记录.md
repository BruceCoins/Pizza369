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
```rust   
    所有整型、bool、char、所有浮点型、Tuple(元组)要求其所有字段都是前面的类型   
```   
  
#### 【2】使用 Box 的集合（Heep操作）：不能直接赋值 b = a 操作，否则 a 的值将不再可用，要求a、b是如下同类型    
```rust
    Vec、String、HashMap...
```    
**Box 内存释放原则**：如果一个变量拥有一个 box ，当 Rust 释放该变量的 stack frame 时，Rust 同时释放该 box 的堆内存（Heep）  

- 移动堆（Heep）数据原则   
``如果变量 x 将堆（Heep）数据的所有权移动给另一个变量 y，那么在移动后，x 将不能在使用``

----------固定大小，数据小，存放在stack 中----------
```rust
fn main(){
    let a = 5;
    let b = a;
    println!("a = {a}, b = {b}");   //控制台输出 a = 5, b = 5
}
```
----------固定长度，数据太大，为减小内存占用，可放在Heep堆内存中---------
```rust
fn main(){
    //--------定义两个超大数组，要求都可以使用--------
    //具有1000000元素的数组，如果房在stack中，特别占内存
    let a = [0;1000000];

    //问题：赋值给b后，在stack中复制一个数组，导致内存占用的更多了
    let b = a;    
    println!("a = {a}, b = {b}");
}
```
------------解决：将数组放到 Heep 堆中，stack 放指针【与堆相关，涉及到所有权问题】-------------
```rust
fn main(){
    //通过Box::new()将数组数据放到堆中，a2有stack中存放指针的所有权
    let a2 = Box::new([0;1000000]);

    //问题：如下赋值，将a2 存放的指针 所有权 转让给 b2，a2失去了指向堆的指针，stack释放a2数据，a2成为未定义状态
    let b2 = a2;   

    //所以当输出 a2 时报错，b2 正常使用
    println!("a2 = {a2}, b2 = {b2}");
}
```
------------解决：使用close()方法克隆堆（Heep）数据------------
```rust
fn main(){
    //String 类型堆操作
    let a3 = String::from(“test”);

    // clone()方法，将堆复制，a3_clone的栈针指向新的堆，即创建新的所有权
    let a3_clone = a3.clone();
    let a4 = add_suffix(a3_clone);
    println!("{a3_clone}, originally {a3}");
}
fn add_suffix(mut name:String) -> String{
    name.push_str(" Dr. ");
    name
}
```    
-----------直接“字符串”和String::from("字符串区别")----------   
- **变量 = “字符串”**：变量固定长度，存放到stack中
- **变量 = String::from("字符串")**：使用String对象，数据存放到Heep堆中，stack存放指针  
```rust
fn main(){
    //"字符串"可以直接赋给其他 变量
    let b1 = "good rust";
    let b2 = b1;
    println!("b1 = {b1}, b2 = {b2}");

    // String 对象，使用clone()方法将Heep堆数据复制一份，新变量通过指针指向复制后的堆
    let mut c1 = String::from("Hello World");
    let c2 = c1.clone();

    // c1进行修改，所以需要mut修饰
    c1.push_str("-->rust");

    let c3 = c1.clone();
    println!("c1 = {c1}, c2 = {c2}, c3 = {c3}");
}
```
### 所有权--引用和借用  
#### 引用：是没有“所有权”的指针  
```rust
// String::from()定义字符串，变量作为参数传递给函数，随后输出变量。
fn main(){
    let m1 = String::from("Hello");
    let m2 = String::from("World");

    //调用函数后，m1、m2所有权转移给了参数g1、g2，stack内存释放
    //函数执行完后，g1、g2的stack也将被释放
    greet(m1, m2);
    let s = format!("{}, {}",m1, m2); //此处输出将报错，因为m1、m2已经转移说有权
}

fn greet(g1:String, g2:String){
    println!("g1 = {g1}, g2 = {g2}");
}
```
----------通过 **引用（符号 & ）** 解决 变量作为参数传递后 所有权转移 的问题-----------
```rust
fn main(){
    let m1 = String::from("Hello");
    let m2 = String::from("rust");

    // 调用函数后，将创建指针指向 m1、m2所在的stack，再通过m1 m2指向 Heep
    // 函数执行结束后，两个指针使用内存被释放，m1、m2所有权不受影响
    greet(&m1, &m2);
    let s = format("m1 = {}, m2 = {}", m1, m2);
}

//函数参数为指针，g1、g2获得的不是m1、m2的所有权，
fn greet(g1:&String, g2:&String){
    println!("{}, {}", g1, g2);
}
```
#### 解引用 指针来访问数据 （符号 *）   
```
//let mut x = Box::new(1) 在 栈(Stack) 和 堆(Heep) 中的存放

栈(Stack):
┌─────────────────────┐
│ 变量名: x            │ (编译期概念)
├─────────────────────┤
│ 栈地址: 0x7fffabcd   │ (&x 获取到的地址)
├─────────────────────┤
│ 值: 指针 0x123456    │ (x 的实际内容，指向堆)
└─────────────────────┘

堆(Heap):
┌─────────────────────┐
│ 地址: 0x123456       │ (x 指向的堆地址)
├─────────────────────┤
│ 值: 1                | (*x 获取到的值)
└─────────────────────┘

let mut x = Box::new(1);
println!("x 的值(指向的堆地址): {:p}", x);     // 打印 x 中存储的指针
println!("x 的地址(栈地址): {:p}", &x);         // 打印 x 变量在栈上的地址
println!("*x 的值: {}", *x); 
```

举例说明：
```rust
fn test(){
    let mut x = Box::new(1);   //定义可变指针变量x，数据存放在 Heep 上，x 在 stack 存放指针
    let a = *x;    //通过 *x 获取指针对应的 Heep 上存放的数据
    *x += 1;       //x为可变变量，加法操作
    println!("a = {a}, x = {x}");

    let r1 = &x;   // x为指针，&x 
    let b = **r1;
    println!("ri = {r1}, b = {b}");

    let r2 = &*x;
    let c = *r2;
    println!("r2 = {r2}, c = {c}");
}

```

