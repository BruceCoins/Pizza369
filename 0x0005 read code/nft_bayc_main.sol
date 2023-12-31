    // SPDX-License-Identifier: GPL-3.0
    pragma solidity ^0.7.0;
    
    contract BoredApeYachtClub is ERC721, Ownable{

        using SafeMath for uni256;
        //BAYC起源地
        string public BAYC_PROVENANCE = "";

        //起始区块位置,用于记录合约起始的区块值 block.number
        uint256 public startingIndexBlock;

        //起始编号 
        uint256 public startingIndex;

        // 铸造每个APE 最小单位费用
        uint256 public constant apePrice = 80000000000000000; //0.08 ETH

        //每次最大铸造数量20
        uint public constant maxApePurchase = 20;

        //最大的数量
        uint256 public MAX_APES;

        //是否可出售状态
        bool public saleIsActive = false;

        //可铸造的时间
        uint256 public REVEAL_TIMESTAMP;
        
        //构造函数，智能合约创建时，进行初始化。由于本合约继承了ERC721 所以初始化ERC721的构造函数  Ownable是抽象类abstract 则不需要
        constructor(string memory name, string memory symbol, uint256 maxNftSupply, uint256 saleStart) ERC721(name, symbol) {
            //设置最大供应量
            MAX_APES = maxNftSupply;

            //设置可mint时间，mint时间必须大于等于REVEAL_TIMESTAMP
            REVEAL_TIMESTAMP = saleStart + (86400 * 9);
        }

        // withdraw函数 返还地址的以太坊
        // onlyOwner 只允许合约部署地址调用该方法
        // payable 表示该方法能够使用transfer 和 send 发送以太坊 
        function withdraw() public onlyOwner payable {
            //获取当前合约账户余额 
            uint balance = address(this).balance;
            //发送wei 到 msg.sender地址
            msg.sender.transfer(balance);
        }

        /**
        * Set some Bored Apes aside
        * 获取一些新的ape NFT 这里给定该方法每次生成30个新BAYC
        */
        function reserveApes() public onlyOwner {        
            //获取当前总供给量
            uint supply = totalSupply();
            //mint 30个新的BAYC
            uint i;
            for (i = 0; i < 30; i++) {
                _safeMint(msg.sender, supply + i);
            }
        }

        /**
        * DM Gargamel in Discord that you're standing right behind him.
        * 设置可铸造时间  
        * onlyOwner 只允许合约部署地址调用该方法
        */
        function setRevealTimestamp(uint256 revealTimeStamp) public onlyOwner {
            REVEAL_TIMESTAMP = revealTimeStamp;
        } 

        /*     
        * Set provenance once it's calculated
        * 设置起源地HASH值
        */
        function setProvenanceHash(string memory provenanceHash) public onlyOwner {
            BAYC_PROVENANCE = provenanceHash;
        }
        /**设置URL */
        function setBaseURI(string memory baseURI) public onlyOwner {
            _setBaseURI(baseURI);
        }

        /*
        * Pause sale if active, make active if paused
        * 改变可售卖状态  
        * onlyOwner 只允许合约部署地址调用该方法
        */
        function flipSaleState() public onlyOwner {
            saleIsActive = !saleIsActive;
        }

        /**
        * Mints Bored Apes
        * 铸造 APE NFT
        */
        function mintApe(uint numberOfTokens) public payable {
            // 售卖状态需要开启
            require(saleIsActive, "Sale must be active to mint Ape");
            
            // 铸造数量必须小于等于20
            require(numberOfTokens <= maxApePurchase, "Can only mint 20 tokens at a time");
            
            // 增加铸造的数量必须小于 MAX_APEs
            require(totalSupply().add(numberOfTokens) <= MAX_APES, "Purchase would exceed max supply of Apes");
            
            // 发送的以太坊 >= numberOfTokens * 0.08ETH
            require(apePrice.mul(numberOfTokens) <= msg.value, "Ether value sent is not correct");
            
            //铸造对应数量的APE
            for(uint i = 0; i < numberOfTokens; i++) {
            //获取总供应量 该方法继承于 ERC721 合约
                uint mintIndex = totalSupply();
            
                if (totalSupply() < MAX_APES) {
            //铸造BAYC msg.sender铸造者地址，mintIndex 铸造的BAYC的tokenId 该方法继承于 ERC721 合约
                    _safeMint(msg.sender, mintIndex);
                }
            }

            // If we haven't set the starting index and this is either 1) the last saleable token or 2) the first token to be sold after
            // the end of pre-sale, set the starting index block
            if (startingIndexBlock == 0 && (totalSupply() == MAX_APES || block.timestamp >= REVEAL_TIMESTAMP)) {
                startingIndexBlock = block.number;
            } 
        }

        /**
        * Set the starting index for the collection
        * 设置对应的起始编号
        */
        function setStartingIndex() public {
            //起始编号为0  表示还没有被设置过
            require(startingIndex == 0, "Starting index is already set");
            // 起始区块的位置需要已经被设置
            require(startingIndexBlock != 0, "Starting index block must be set");
            
            //计算起始编号的值
            startingIndex = uint(blockhash(startingIndexBlock)) % MAX_APES;
            // Just a sanity case in the worst case if this function is called late (EVM only stores last 256 block hashes)
            // 最坏的情况下如果这个函数调用的太晚了  就用下面的方式计算起始编号的值
            if (block.number.sub(startingIndexBlock) > 255) {
                startingIndex = uint(blockhash(block.number - 1)) % MAX_APES;
            }
            // Prevent default sequence
            if (startingIndex == 0) {
                startingIndex = startingIndex.add(1);
            }
        }

        /**
        * Set the starting index block for the collection, essentially unblocking
        * setting starting index
        *设置起始块值
        */
        function emergencySetStartingIndexBlock() public onlyOwner {
            require(startingIndex == 0, "Starting index is already set");
            
            startingIndexBlock = block.number;
        }
    }

