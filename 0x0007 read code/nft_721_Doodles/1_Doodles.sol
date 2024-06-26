// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

// 合约继承 ERC721、ERC721Enumerable, Ownable
contract Doodles is ERC721, ERC721Enumerable, Ownable {
    // 出处
    string public PROVENANCE;
    // 发售状态
    bool public saleIsActive = false;
    // url扩展
    string private _baseURIextended;

    // mint状态、供应量、mint数量、价格
    bool public isAllowListActive = false;
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MAX_PUBLIC_MINT = 5;
    uint256 public constant PRICE_PER_TOKEN = 0.123 ether;

    // 白名单
    mapping(address => uint8) private _allowList;

    // 发币 符合721标准
    constructor() ERC721("Doodles", "DOODLE") {
    }

    // 设置白单是否开始mint
    function setIsAllowListActive(bool _isAllowListActive) external onlyOwner {
        isAllowListActive = _isAllowListActive;
    }

    // 写入白单可以 mint 的数量
    function setAllowList(address[] calldata addresses, uint8 numAllowedToMint) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            _allowList[addresses[i]] = numAllowedToMint;
        }
    }

    // 根据地址获取可以mint 的数量
    function numAvailableToMint(address addr) external view returns (uint8) {
        return _allowList[addr];
    }

    // 白单 mint 函数    
    function mintAllowList(uint8 numberOfTokens) external payable {
        // ts : 获取已mint的数量，也是token最大编号，默认值0
        // 校验：是否开始mint、
        //      用户实际mint数量 <= 地址允许mint的数量、
        //      已mint数量 + 即将mint的数量 <= 最大供应量
        //      用户钱包金额应 不少于 mint需要的总金额
        uint256 ts = totalSupply();
        require(isAllowListActive, "Allow list is not active");
        require(numberOfTokens <= _allowList[msg.sender], "Exceeded max available to purchase");
        require(ts + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(PRICE_PER_TOKEN * numberOfTokens <= msg.value, "Ether value sent is not correct");

        // 记录用户可以mint的剩余数量 
        _allowList[msg.sender] -= numberOfTokens;
        
        // 进行 mint 操作，记录mint 用户地址，按顺序记录token 编号
        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, ts + i);
        }
    }

    /** 
     * NFT转让、mint、销毁函数：
     *   (1)若from、to 都不是 0 地址，则转让 nft
     *   (2)若from 是 0 地址，则是铸造函数
     *   (3)若 to  是 0 地址，则为销毁函数
     * 具体逻辑看 ERC721Enumerable.sol 文件相关函数
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // 设置 NFT 的 URL 地址
    function setBaseURI(string memory baseURI_) external onlyOwner() {
        _baseURIextended = baseURI_;
    }

    // 获取 URL
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function setProvenance(string memory provenance) public onlyOwner {
        PROVENANCE = provenance;
    }

    // 无需付费的 mint 
    function reserve(uint256 n) public onlyOwner {
      uint supply = totalSupply();
      uint i;
      for (i = 0; i < n; i++) {
          _safeMint(msg.sender, supply + i);
      }
    }

    // 设置发售状态
    function setSaleState(bool newState) public onlyOwner {
        saleIsActive = newState;
    }

    // 正式 mint 
    function mint(uint numberOfTokens) public payable {
        uint256 ts = totalSupply();
        require(saleIsActive, "Sale must be active to mint tokens");
        require(numberOfTokens <= MAX_PUBLIC_MINT, "Exceeded max token purchase");
        require(ts + numberOfTokens <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(PRICE_PER_TOKEN * numberOfTokens <= msg.value, "Ether value sent is not correct");
        
        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, ts + i);
        }
    }

    // 提款
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }
}
