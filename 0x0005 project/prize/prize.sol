//SPDX-License-Identifier: UNLICENSED

// Solidity files have to start with this pragma.
// It will be used by the Solidity compiler to validate its version.
 pragma solidity >=0.6.0;

//pragma solidity >=0.4.24 <0.7.0;

//import "@openzeppelin/upgrades/contracts/Initializable.sol";
import "@openzeppelin/upgrades-core/contracts/Initializable.sol";


contract Lottery is Initializable {
    
    address owner;
    
    // 一、二等奖最多领取数额
    uint public firstPrizeMaxAmount;
    uint public secondPrizeMaxAmount;
    
    //每次下注金额
    uint public betMinAmount;
    
    // 奖池
    uint public jackpot;
    
    // you win event
    event YouWin(address indexed user, uint indexed lotNumber, uint indexed level, uint amount);
    event YouLost(address indexed user, uint indexed lotNumber);
    
    function initialize() initializer public {
        // 初始化，一等奖最多500e, 二等奖最多5e
        // 每次下注金额1e
        firstPrizeMaxAmount = 500*10**18;
        secondPrizeMaxAmount = 5*10**18;
        betMinAmount = 1*10**18;
    }
    
    // 获取4位随机数
    function lotNumber() public view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % 10000;
    }
    
    //下注，输入4位数
    function placeBet(uint _placeNumber) public payable{
        require(msg.value == betMinAmount, "invalid bet amount!");
        require(_placeNumber > 0 && _placeNumber < 10000, "invalid place number!");
        jackpot += msg.value;
        uint _lotNumber = lotNumber();
        if(_placeNumber == _lotNumber){
            //一等奖
            uint _winAmount = jackpot > firstPrizeMaxAmount ? firstPrizeMaxAmount:jackpot;
            msg.sender.transfer(_winAmount);
            jackpot-=_winAmount;
            emit YouWin(msg.sender,_lotNumber,1,_winAmount);
        }else{
            uint[2] memory _placePatterns = [_placeNumber%1000, _placeNumber/10];
            uint[2] memory _lotPatterns = [_lotNumber%1000, _lotNumber/10];
            bool _isWin = false;
            for(uint i=0;i<_placePatterns.length;i++){
                if(_isWin)break;
                for(uint j=0;j<_lotPatterns.length;j++){
                    if(_isWin)break;
                    if(_placePatterns[i] == _lotPatterns[j])
                        _isWin = true;
                }
            }
            if(_isWin){
                //二等奖
                uint _winAmount = jackpot > secondPrizeMaxAmount ? secondPrizeMaxAmount:jackpot;
                msg.sender.transfer(_winAmount);
                jackpot-=_winAmount;
                emit YouWin(msg.sender,_lotNumber,2,_winAmount);
            
            }else{
                //没有中奖   
                emit YouLost(msg.sender,_lotNumber);
            }
        }
    }    
}