// SPDX-License-Identifier: UNLICENSED

// Written by: Riley Desrochers
pragma solidity =0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


import "hardhat/console.sol";

contract DaoLiquidityPool is Ownable {
    uint32 public fee; //fraction out of 100000
    uint32 public maxSupplyInPool; //fraction out of 100000
    //address token;
    ERC20Burnable token;
    address public factory;

    constructor(uint32 _fee, uint32 _maxSupplyInPool, address _token, address _owner) {
        require(_fee < 10001, 'fee to high');
        require(_maxSupplyInPool < 10001, 'maxSupplyInPool to high');
        fee = _fee;
        maxSupplyInPool = _maxSupplyInPool;
        token = ERC20Burnable(_token);
        transferOwnership(_owner);
        factory = msg.sender;
    }

    function buyToken() external payable {
        uint256 amtOut = getAmtOut(msg.value, address(this).balance, token.balanceOf(address(this)));//FIX address(this).balance may be wrong after payment
        require(token.transfer(msg.sender, amtOut), 'token transfer failed');
        /*
        uint256 amtImAfterFee = msg.value*(100000 - fee);
        uint256 amtOut = amtImAfterFee*token.balanceOf(address(this))/(address(this).balance*100000+amtImAfterFee);
        require(token.transfer(msg.sender, amtOut), 'token transfer failed');
        */
    }

    function sellToken(uint256 amtIn, address to) external {
        require(token.transferFrom(msg.sender, address(this), amtIn), 'token transfer failed');
        uint256 amtOut = getAmtOut(amtIn, token.balanceOf(address(this)), address(this).balance);
        payable(to).transfer(amtOut);
        checkAndBurn();
    }

    function getReserve() public view returns(uint256 ethReserve, uint256 tokenReserve){
        ethReserve = address(this).balance;
        tokenReserve = token.balanceOf(address(this));
    }

    function getAmtOut(uint256 amtIn, uint256 reserveIn, uint256 reserveOut) public view returns(uint256 amtOut) {
        uint256 amtAfterFee = amtIn*(100000 - fee);
        amtOut = amtAfterFee*reserveOut/(reserveIn*100000+amtAfterFee);

        /*
            uint amountInWithFee = amountIn.mul(997);
            uint numerator = amountInWithFee.mul(reserveOut);
            uint denominator = reserveIn.mul(1000).add(amountInWithFee);
            amountOut = numerator / denominator;
        */
    }
    function changeFee(uint32 _fee) public onlyOwner {
        require(_fee < 10001, 'fee to high');
        fee = _fee;
    }
    function changeMaxSupplyInPool(uint32 _maxSupplyInPool) public {
        require(_maxSupplyInPool < 10001, 'maxSupplyInPool to high');
        maxSupplyInPool = _maxSupplyInPool;

    }
    function deposit(uint256 amount) external payable onlyOwner{
        require(token.transferFrom(msg.sender, address(this), amount), 'token transfer failed');
        checkAndBurn();
    }
    function withdrawal(uint256 share) public onlyOwner{
        address payable receiver = payable(owner());
        token.transfer(receiver, token.balanceOf(address(this))*share/100000);//FIX?
        receiver.transfer(address(this).balance*share/100000);
    }

    function checkAndBurn() internal {
        uint256 total = token.totalSupply();
        uint256 thisBal = token.balanceOf(address(this));
        if(thisBal < total*maxSupplyInPool/100000){
            return;
        }
        uint256 burnAmt = (100000*thisBal-maxSupplyInPool*total)/(100000-maxSupplyInPool);
        token.burn(burnAmt);
        //f= changeMaxSupplyInPool/100000
        //b = burn
        //f = (thisBal-b)/(total-b)
        //total-b = (thisBal-b)/f
        //-b = ((thisBal-b)/f)-total
        //b = total-((thisBal-b)/f)
        //b = total+((b-thisBal)/f)
        //b = total+(b/f)-(thisBal/f)
        //b-(b/f) = total-(thisBal/f)
        //(f*b/f)-(b/f) = total-(thisBal/f)
        //(f*b-b)/f = total-(thisBal/f)
        //(f-1)*b)f = total-(thisBal/f)
        //b = (total-(thisBal/f))*f/(f-1)
        //b = ((total*f)-thisBal)/(f-1)

        //total = 1000000
        //f = 0.05
        //thisBal = 60000

        //b = ((1000000*0.05)-60000)/0.95
        //b = (50000-60000)/0.95
        //b = -10000/0.95
        //b = 9500
    }


}
