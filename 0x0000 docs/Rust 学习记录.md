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

// _ 代替元素
fn for_example2(){
    let a = [10,20,30,40,50,60];
    let cc = 0;
    for _ in a{
        
        print
    }
}

// 循环指定次数 [1,5) 即4次,同时输出[1,5) 
// rev()方法为倒序输出
fn for_example3(){
    for number in (1..5).rev(){
        println!({number});
    }
    println!("END!");
}

// 循环3次，每次 x 都是10
fn for_example5(){
    let a = [10;3];
    let mut sum = 0;
    for x in a{
        println!("x = {x}");
        sum += x;
    }
    print!("sum = {sum}");
}
```
