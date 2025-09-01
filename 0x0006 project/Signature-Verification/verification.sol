// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract Verification{
    address owner;
    using ECDSA for bytes32;

    construct(){
        owner = msg.sender;
    }

    function isMessageValid(bytes memory _signature)
        public 
        view 
        returns (address, bool)
    {
        // 1、对签名进行 abi 编码
        bytes memory abiEncode = abi.encodePacked("HelloWorld");

        //2、再进行 k256 Hash 运算
        bytes32 messagehash = keccak256(abiEncode);

        //3、添加前缀，可以将计算出的以太坊特定的签名
        //   这可以防止恶意 DApp 签署任意数据（如交易）并使用签名来冒充受害者的滥用行为。
        bytes32 ethSignedMessageHash = ECDSA.toEthSignedMessageHash(messagehash);

        //4、从签名中恢复地址
        address signer = ECDSA.recover(ethSignedMessageHash, _signature);

        if(owner == signer){
            return(signer, true);
        }else{
            return(signer, false);
        }
    }
}
