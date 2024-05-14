// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/**
 *  ChainLink VRF 从 V2 迁移到 V2.5：
 *      【1】 引入合约 由 V2合约 ---> V2Pluse 合约，注释掉的是V2版本，下边3条是V2.5版本  
 *      【2】 新增一个 Client 合约，其方法嵌套在了 mintRandomVRF()获取随机数的函数里边，判断是否使用本地货币。
 *          其中 VRFV2PlusClient.RandomWordsRequest({参数}) 中 参数 必须是 key:value 形式
 *      【3】 订阅id (即subId) 的类型由 uint64 改为 uint256
 */

import "https://github.com/AmazingAng/WTFSolidity/blob/main/34_ERC721/ERC721.sol";
//import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
//import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

import "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";


contract  Random is ERC721, VRFConsumerBaseV2Plus{
    //NFT相关
    uint256 public totalSupply = 100;   //总供给
    uint256[100] public ids;    // 用于计算可供mint的tokenId
    uint256 public mintCount;   // 已 mint 数量

    // chainlink VRF参数
    IVRFCoordinatorV2Plus COORDINATOR;

    /**
     * 使用chainlink VRF，构造函数需要继承 VRFConsumerBaseV2
     * 不同链参数填的不一样
     * 网络: Sepolia测试网
     * Chainlink VRF Coordinator 地址: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
     * LINK 代币地址: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * 30 gwei Key Hash: 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c
     * Minimum Confirmations 最小确认块数 : 3 （数字大安全性高，一般填12）
     * callbackGasLimit gas限制 : 最大 2,500,000
     * Maximum Random Values 一次可以得到的随机数个数 : 最大 500          
     */
    address vrfCoordinator = 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625;
    bytes32 keyHash = 0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c;
    uint16 requestConfirmations = 3;
    uint32 callbackGasLimit = 1_000_000;
    uint32 numWords = 1;
    uint256 subId;
    uint256 public requestId;

    // 记录VRF申请标识对应的mint地址
    mapping(uint256 => address) public requestToSender;

    // 初始化
    constructor(uint256 s_subId)
        VRFConsumerBaseV2Plus(vrfCoordinator)
        ERC721("Broce Coin", "BCC"){
            COORDINATOR = IVRFCoordinatorV2Plus(vrfCoordinator);
            subId = s_subId;
    }

    /**
     * 输入 uint256 数字，返回一个可以mint的tokenId 
     */
    function pickRandomUniqueId(uint256 random) private returns(uint256 tokenId){
        //先计算减法，在计算++
        uint256 len = totalSupply - mintCount++; //计算可mint的数量
        require(len > 0, "nothing can be mint"); //判断mint完
        uint256 randomIndex = random % len;      //获取链上随机数

        // 随机取模，获得tokenId，作为数组的下标，同时记录 value 为 len-1,
        // 如果驱魔得到的值已存在，则 tokenId 取该数组下标的 value
        tokenId = ids[randomIndex] != 0 ? ids[randomIndex] : randomIndex;  //获取tokenId
        ids[randomIndex] = ids[len - 1] == 0 ? len - 1 : ids[len - 1];   // 更新ids列表 
        ids[len - 1] = 0; //删除最后一个元素，能返回gas
    }


    /**
     * 调用 VRF 获取随机数，并 mint NFT 
     * 要调用 requestRandomness() 函数获取，消耗随机数的逻辑写在 VRF 的回调函数 fulfillRandomWords()中
     * 调用前，需要在 Subscription 中 fund 足够的 Link
     */
    function mintRandomVRF() public{
        //调用 requestRandomWords 获取随机数
        requestId = COORDINATOR.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash:keyHash, 
                subId:subId, 
                requestConfirmations:requestConfirmations, 
                callbackGasLimit:callbackGasLimit, 
                numWords:numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
            
        );
        requestToSender[requestId] = msg.sender; 
    }

    /*
     * VRF 的回调函数，由 VRF Coordinator 调用
     * 消耗随机数的逻辑写在本函数中
     */
    function fulfillRandomWords(uint256 reqId, uint256[] memory s_randomWords) internal override{
        address sender = requestToSender[reqId];   //从 requestToSender中获取 minter 用户地址
        uint256 tokenId = pickRandomUniqueId(s_randomWords[0]);   //利用VRF返回的随机数生成 tokenId
        _mint(sender, tokenId); 
    }
}
