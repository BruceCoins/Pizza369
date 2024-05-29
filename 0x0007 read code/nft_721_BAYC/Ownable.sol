// File: @openzeppelin/contracts/access/Ownable.sol



pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 * Contract模块提供了基本的访问控制机制，其中有一个帐户（所有者）可以被授予独占访问权限具体功能。
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 * 默认情况下，所有者账户将是部署合约的账户，这可以在稍后调用 transferOwnership 函数进行更改
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 * 该模块通过继承使用，允许使用修改器 onlyOwner() , 可以应用到你的函数中来限制拥有者使用(即不是拥有者不能用)
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     *      构造函数：初始化合约，将部署者设置为合约最初拥有者
     */
    constructor () internal {
        address msgSender = _msgSender(); //_msgSender()为 Context合约内部函数，防止被合约攻击
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
            返回当前合约拥有者地址
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
            修改器：如果被合约拥有者以外的用户调用，则抛出异常
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     * 合约没有所有者，将无法再调用 onlyOwner 函数，只有当前合约的拥有者才可以调用
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     * 放弃所有权将合约失去所有者，从而删除仅拥有者才可以用的所有功能
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);    //将拥有者设置为 0 地址
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     * 将合约拥有权转让给其他账户（newOwner），只有当前的合约拥有者可以调用本方法
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }



// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.2;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    // 设置为内部函数，避免被其他合约攻击
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

}