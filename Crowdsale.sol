pragma solidity >=0.6.0 <0.9.0;

import"./ZupaToken.sol";

contract CrowdSale {

    uint private etherToWeiExchangeRate = 10 ** 18;

    uint public deadline;
    uint public hardCap;
    uint public etherToTokenExchangeRate;
    address private owner;
    uint private totalSales;

    ZupaToken public token;

    constructor(uint _hardCap, uint _etherToTokenExchangeRate) {
        deadline = block.timestamp + 28 days;
        hardCap = _hardCap;
        etherToTokenExchangeRate = _etherToTokenExchangeRate;
        owner = msg.sender;
        totalSales = 0;
        token = new ZupaToken(address(this));
    }

    function sale() external payable saleInProgress {
        require(msg.sender != owner, "Can't sale ether by self!");
        require(totalSales + msg.value <= hardCap, "Hardcap overflow! Try again with less sum!");

        payable(owner).transfer(msg.value);
        token.mint(msg.sender, msg.value / etherToWeiExchangeRate * etherToTokenExchangeRate);

        totalSales += msg.value;

        if(totalSales == hardCap) {
            token.mint(owner, token.totalSupply() / 100 * 10);
        }
    }

    modifier saleInProgress() {
        require(block.timestamp < deadline 
                && totalSales <  hardCap, "Crowdsale ended!");
        _;
    }
}