// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter{
    /**
    * Network: Sepolia
    * Data Feed: ETH/USD
    * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    */
    
    function getPrice() internal view returns (uint256){
        // ABI
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // uint80 roundId, int256 price, uint256 startedAt, uint256 timeStamp, uint80 answeredInRound
        (,int256 price,,,)= priceFeed.latestRoundData(); 
        return uint256(price * 1e10);
    }

    function getVersion() internal view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version();
    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
        uint256 ethPrice = getPrice();
        // Solidity 中不能计算小数
        // 如ETH的价格如果是3000美元，则Price 是3000000000000000000000(3000e18)
        // 1美元也会变成 1000000000000000000(1e18)
        // 所以相乘后多出了1e18，需要除去
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
}