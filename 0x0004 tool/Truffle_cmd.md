# Truffle 命令行：  

**所有命令均采用以下形式：**  
```
truffle <command> [options]
```
## 常用命令行

- 创建空项目。  
```
truffle init
```                  

- 使用Truffle Boxs下载项目模板。
```
truffle unbox <box-name>
```

-   编译合约，首次运行时将编译所有合约。后续仅编译有更改的合约，如果想覆盖此行为，可使用 `--all`运行上面的命令。  
```
truffle compile [--all]      
```

- 部署合约，将部署在项目 `migrateions` 目录中所有的文件。  
  - 如果之前已经成功运行，则 `truffle migrate` 将从上次运行开始执行，进运行新创建的迁移；若没有新的迁移，则不执行任何操作。
  - 如果想从头开始运行所有迁移，可以使用 `--rest` 。本地测试时，确保执行 `migrate` 前已安装、运行了 Ganache 等测试区块链。
```
truffle migrate [--reset]
```
 
