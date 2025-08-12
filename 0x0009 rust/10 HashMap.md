## HashMap<Key, Value>  
- 数据放在 Heap 中  
- 所有 Key 类型必须相同，所有 Value 类型必须相同  

### 创建 HashMap  
```rust
fn create_map(){
    //方法1：使用new()方法
    let mut map = HashMap::new();
    map.insert(String::from("name"),"Jack");
    map.insert(String::from("age"),"11");
    println!("map:{:?}",map);

    //方法2：使用 from() 方法
    let map2 = HashMap::from([("k1","v1"),("k2","v2")]);
    println!("map2:{:?}",map2);

    //方法3：使用 迭代器 创建
    let vec = vec![("kk1","vv1"),("kk2","vv2")];
    let map3:HashMap<_, _>= vec.into_iter().collect();
    println!("map3:{:?}",map3);
}
```  

### 使用get()方法，根据key获取value   
```rust
fn get_value(){
    let mut map = HashMap::new();
    map.insert(String::from("name"),"Jack");
    map.insert(String::from("age"),"11");
    println!("get map:{:?}",map);

    //方法1：get()，通过.copy().unwrap_or()方法获取value
    let k_name = String::from("name");
    let result = map.get(&k_name).copied().unwrap_or("None");
    println!("result:{}",result);

    //方法2：get()，直接使用 name
    let result2 = map.get("name").copied().unwrap_or("None");
    println!("result2:{}",result2);

    //方法3：get()，通过 match 获取value
    match map.get(&String::from("name")){
        Some(value) => println!("value:{}",value),
        None => println!("None")
    }
}
``` 

### 遍历HashMap，分别获取 key 和 value 
```rust
fn iter_map(){
    let mut map = HashMap::new();
    map.insert(String::from("name"), "Jerry");
    map.insert(String::from("age"),"66");
    println!("iter map:{:?}", map);

    //方法1：for
    for(key, value) in &map{
        println!("{}:{}",key, value);
    }
}
```