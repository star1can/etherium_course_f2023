pragma solidity >=0.6.0 <0.9.0;

contract StartupWallet {
    fallback() external payable { }

    receive() external payable { }

    function balanceOf() external view returns(uint) {
        return address(this).balance;
    }
}