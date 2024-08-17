// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 1 * 1e18;//常量 100000000000000000
    address public immutable i_owner; // 不可修改，仅在构造函数中

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    constructor(){
        i_owner = msg.sender;
    }

    function fund() public payable {
        // 校验发送金额的最小值
        // 1. 如何发送ETH到这个合约
        require(msg.value.getConversionRate() >= MINIMUM_USD, "At least 1USD");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    // 提取资金
    function withdraw() public onlyOwner{
        // 逐个清空
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // 重置数组
        funders = new address[](0);

        // 发送货币的三种方式 transfer、send、call
        // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call 推荐方式
        (bool callSuccess,) = payable(msg.sender).call{value:address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner{
        require(msg.sender == i_owner, "Sender is not owner.");
        //if(msg.sender == i_owner) { revert NotOwner();}
        _; // 这个指在何处执行剩余代码
    }

    receive() external payable { 
        fund();
    }

    fallback() external payable {
        fund();
     }

}
