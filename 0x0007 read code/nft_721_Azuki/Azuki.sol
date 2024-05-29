// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
  - 使用兼容ERC721的ERC721A接口实现
  - 支持指定开始时间的拍卖机制
  - 指定NFT数量的白名单机制
  - 使用区块时间戳指定公开发售时间
  - 使用OZ的ReentrancyGuard防止针对提现函数的可重入攻击
*/


contract Azuki is Ownable, ERC721A, ReentrancyGuard {
  uint256 public immutable maxPerAddressDuringMint;   //每个地址最多铸造数量
  uint256 public immutable amountForDevs;             //开发者金额
  uint256 public immutable amountForAuctionAndDev;    //用于拍卖和开发的金额

  // 安全配置参数
  struct SaleConfig {
    uint32 auctionSaleStartTime;
    uint32 publicSaleStartTime;
    uint64 mintlistPrice;
    uint64 publicPrice;
    uint32 publicSaleKey;
  }

  SaleConfig public saleConfig;

  // 白名单
  mapping(address => uint256) public allowlist;

  // 构造函数
  // 初始化 
  constructor(
    uint256 maxBatchSize_,
    uint256 collectionSize_,
    uint256 amountForAuctionAndDev_,
    uint256 amountForDevs_
  ) ERC721A("Azuki", "AZUKI", maxBatchSize_, collectionSize_) {
    maxPerAddressDuringMint = maxBatchSize_;
    amountForAuctionAndDev = amountForAuctionAndDev_;
    amountForDevs = amountForDevs_;
    require(
      amountForAuctionAndDev_ <= collectionSize_,
      "larger collection size needed"
    );
  }

  // 判断调用合约的是钱包地址，而不是其他合约地址，避免被其他合约攻击
  modifier callerIsUser() {
    require(tx.origin == msg.sender, "The caller is another contract");
    _;
  }

  // 铸造
  function auctionMint(uint256 quantity) external payable callerIsUser {
    // 开始时间
    uint256 _saleStartTime = uint256(saleConfig.auctionSaleStartTime);
    // 校验时间
    require(
      _saleStartTime != 0 && block.timestamp >= _saleStartTime,
      "sale has not started yet"
    );
    // 校验数量:为拍卖保留的余额不足以支持所需的铸币数量
    require(
      totalSupply() + quantity <= amountForAuctionAndDev,
      "not enough remaining reserved for auction to support desired mint amount"
    );
    // mint数量校验
    require(
      numberMinted(msg.sender) + quantity <= maxPerAddressDuringMint,
      "can not mint this many"
    );
    uint256 totalCost = getAuctionPrice(_saleStartTime) * quantity;
    _safeMint(msg.sender, quantity);
    refundIfOver(totalCost); //退款
  }

  // 允许铸造的用户列表
  function allowlistMint() external payable callerIsUser {
    // 铸造价格
    uint256 price = uint256(saleConfig.mintlistPrice);
    require(price != 0, "allowlist sale has not begun yet");
    require(allowlist[msg.sender] > 0, "not eligible for allowlist mint");
    require(totalSupply() + 1 <= collectionSize, "reached max supply");
    allowlist[msg.sender]--;
    _safeMint(msg.sender, 1);
    refundIfOver(price); //退款
  }

  // 公售铸造（数量、公售密钥）
  function publicSaleMint(uint256 quantity, uint256 callerPublicSaleKey)
    external
    payable
    callerIsUser
  {
    SaleConfig memory config = saleConfig;
    uint256 publicSaleKey = uint256(config.publicSaleKey);  //公售密钥
    uint256 publicPrice = uint256(config.publicPrice);      //公售价格
    uint256 publicSaleStartTime = uint256(config.publicSaleStartTime);    //公售时间
    //公售密钥错误
    require(
      publicSaleKey == callerPublicSaleKey,
      "called with incorrect public sale key"
    );
    //公售未开始
    require(
      isPublicSaleOn(publicPrice, publicSaleKey, publicSaleStartTime),
      "public sale has not begun yet"
    );
    //供应量检查
    require(totalSupply() + quantity <= collectionSize, "reached max supply");
    //每个地址最多铸造数量
    require(
      numberMinted(msg.sender) + quantity <= maxPerAddressDuringMint,
      "can not mint this many"
    );
    _safeMint(msg.sender, quantity);
    refundIfOver(publicPrice * quantity); //退钱
  }

  // 退钱
  function refundIfOver(uint256 price) private {
    require(msg.value >= price, "Need to send more ETH.");
    if (msg.value > price) {
      payable(msg.sender).transfer(msg.value - price);
    }
  }

  // 判断是否符合 开启公售 的条件
  function isPublicSaleOn(
    uint256 publicPriceWei,
    uint256 publicSaleKey,
    uint256 publicSaleStartTime
  ) public view returns (bool) {
    return
      publicPriceWei != 0 &&
      publicSaleKey != 0 &&
      block.timestamp >= publicSaleStartTime;
  }

  // 常量
  uint256 public constant AUCTION_START_PRICE = 1 ether;    // 拍卖开始时价格
  uint256 public constant AUCTION_END_PRICE = 0.15 ether;   // 拍卖结束时价格
  uint256 public constant AUCTION_PRICE_CURVE_LENGTH = 340 minutes;   // 拍卖周期
  uint256 public constant AUCTION_DROP_INTERVAL = 20 minutes;   // 每20分钟降价一次
  uint256 public constant AUCTION_DROP_PER_STEP =
    (AUCTION_START_PRICE - AUCTION_END_PRICE) /
      (AUCTION_PRICE_CURVE_LENGTH / AUCTION_DROP_INTERVAL);     // 计算拍卖每阶段降价幅度

  // 获取拍卖价格
  function getAuctionPrice(uint256 _saleStartTime)
    public
    view
    returns (uint256)
  {
    if (block.timestamp < _saleStartTime) {
      return AUCTION_START_PRICE;
    }
    if (block.timestamp - _saleStartTime >= AUCTION_PRICE_CURVE_LENGTH) {
      return AUCTION_END_PRICE;
    } else {
      uint256 steps = (block.timestamp - _saleStartTime) /
        AUCTION_DROP_INTERVAL;
      return AUCTION_START_PRICE - (steps * AUCTION_DROP_PER_STEP);
    }
  }

  // 结束拍卖，设置非拍卖信息
  // 参数：铸造价格、公售价格、公售开始时间
  function endAuctionAndSetupNonAuctionSaleInfo(
    uint64 mintlistPriceWei,
    uint64 publicPriceWei,
    uint32 publicSaleStartTime
  ) external onlyOwner {
    saleConfig = SaleConfig(
      0,
      publicSaleStartTime,
      mintlistPriceWei,
      publicPriceWei,
      saleConfig.publicSaleKey
    );
  }

  // 设置拍卖开始时间
  function setAuctionSaleStartTime(uint32 timestamp) external onlyOwner {
    saleConfig.auctionSaleStartTime = timestamp;
  }

  // 设置公售密钥
  function setPublicSaleKey(uint32 key) external onlyOwner {
    saleConfig.publicSaleKey = key;
  }

  // 设置白名单
  function seedAllowlist(address[] memory addresses, uint256[] memory numSlots)
    external
    onlyOwner
  {
    require(
      addresses.length == numSlots.length,
      "addresses does not match numSlots length"
    );
    for (uint256 i = 0; i < addresses.length; i++) {
      allowlist[addresses[i]] = numSlots[i];
    }
  }

  // For marketing etc.
  // 管理员 mint 函数
  function devMint(uint256 quantity) external onlyOwner {
    require(
      totalSupply() + quantity <= amountForDevs,
      "too many already minted before dev mint"
    );
    require(
      quantity % maxBatchSize == 0,
      "can only mint a multiple of the maxBatchSize"
    );
    uint256 numChunks = quantity / maxBatchSize;
    for (uint256 i = 0; i < numChunks; i++) {
      _safeMint(msg.sender, maxBatchSize);
    }
  }

  // // metadata URI
  string private _baseTokenURI;

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }
  
  function setBaseURI(string calldata baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }

  // 提款
  function withdrawMoney() external onlyOwner nonReentrant {
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "Transfer failed.");
  }

  // 设置所有者
  function setOwnersExplicit(uint256 quantity) external onlyOwner nonReentrant {
    _setOwnersExplicit(quantity);
  }

  // 获取已经mint的数量
  function numberMinted(address owner) public view returns (uint256) {
    return _numberMinted(owner);
  }

  // 获取 nft 拥有人
  function getOwnershipData(uint256 tokenId)
    external
    view
    returns (TokenOwnership memory)
  {
    return ownershipOf(tokenId);
  }
}