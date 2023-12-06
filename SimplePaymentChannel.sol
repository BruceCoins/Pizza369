// SPDX-License-Identifier: GPL03.0

pragma solidity >=0.7.0 <0.9.0;

contract SimplePaymentChannel{

    address payable public sender;      // 发送付款的账户
    address payable public recipient;   // 接收付款的账户
    uint256 public expiration;          // 超时时间，以防接收者永不关闭支付通道

    constructor (address payable recipientAddress, uint256 duration) payable{
        sender = payable (msg.sender);
        recipient = recipientAddress;
        expiration = block.timestamp + duration;
    }

    /// 接收者可以在任何时候通过提供发送者签名的金额来关闭通道
    /// 接收者将获得该金额，其余部分将返回给发送者，并销毁合约
    function close(uint256 amount, bytes memory signature) external
    {
        require(msg.sender == recipient);   // 验证当前登录用户事接收者
        require(isValidSignature(amount, signature));   //验证 金额、签名【1】

        recipient.transfer(amount);     //接收者获取金额
        selfdestruct(sender);   //销毁合约
    }

    /// 发送者 延长合约存在时间
    function extend(uint256 newExpiration) external
    {
        require(msg.sender == sender);
        require(newExpiration > expiration);
        expiration = newExpiration;
        
    }

    /// 合约自动销毁时间，
    /// 接收者 须在合约自动销毁前调用close()函数收取转账金额
    function claimTimeout() external {
        require(block.timestamp >= expiration);
        selfdestruct(sender);
    }

    /// 验证 转账金额、发送者签名信息
    function isValidSignature(uint256 amount, bytes memory signature) internal view returns (bool)
    {   
        // 对当前合约对象、转账金额进行加密，【2】
        bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));

        // 检查签名是否来自 发送方 【4】 
        // < 被签名的信息、签名信息(私钥) > 与 发送方地址(公钥)  进行验签
        return recoverSigner(message, signature) == sender;
    }


    /// 构建一个前缀哈希值，以模仿eth_sign的行为【3】
    function prefixed(bytes32 hash) internal pure returns(bytes32)
    {   
        // 进行二次哈希
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }


    /// 验证签名是否来自 发送方【5】
    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        // 
        return ecrecover(message, v, r, s);
    }


    /// 对发送方 私钥签名进行分割 
    function splitSignature(bytes memory sig) internal pure returns(uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65);

        assembly{
            // 前32字节，在长度前缀之后
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }
    
}