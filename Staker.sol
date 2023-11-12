pragma solidity >=0.6.0 <0.9.0;

import "./Owner.sol";
import "./StartupWallet.sol";
import "./StakeNFT.sol";

contract Staker is Owner {

    uint public threshold;
    uint public deadline;

    StartupWallet private receiver;

    bool private isCompleted;
    bool private isSuccessful;

    uint[] public nftTiersThresholdsAscend;

    StakeNFT[] public NFTs;

    mapping(address => uint) public userToInvestments;

    constructor(uint _threshold, 
        uint _deadline, 
        address _projectWallet,
        uint[] memory _nftTiersThresholdsAscend,
        string[] memory _nftNames,
        string[] memory _nftSymbols,
        string[] memory _nftURIs
    ) Owner() {
        require(_deadline >= block.timestamp, "Staking deadline can't be in past!");
        require(_nftNames.length == _nftSymbols.length, "Count of Names and Symbols for the NFT must be equal");
        require(_nftSymbols.length == _nftURIs.length, "Count of Names and URIs for the NFT must be equal");
        require(_nftURIs.length == _nftTiersThresholdsAscend.length, "Count of Names and TierThresholds for the NFT must be equal");

        threshold = _threshold;
        deadline = _deadline;
        receiver = StartupWallet(payable(_projectWallet));

        isCompleted = false;
        isSuccessful = false;

        nftTiersThresholdsAscend = _nftTiersThresholdsAscend;

        for(uint i = 0; i < _nftNames.length; ++i) {
            NFTs.push(new StakeNFT(address(this), _nftNames[i], _nftSymbols[i], _nftURIs[i]));
        }
    }


    function invest() external payable deadlineNotExceeded {
        userToInvestments[msg.sender] += msg.value;
    }

    function complete() external isOwner notCompleted deadlineExceeded {
        isCompleted = true;
        require(address(this).balance >= threshold, "Deadline excedeed. But not enough investments to start project :(");
        isSuccessful = true;
        transfer();
    }

    function withdraw() external deadlineExceeded failedStaking {
        require(userToInvestments[msg.sender] > 0, 
                "Not found any investments for user or they already withdrawed!");

        payable(msg.sender).transfer(userToInvestments[msg.sender]);
        userToInvestments[msg.sender] = 0;
    }

    /**
     * return ([nftAdress], [tokenId])
     * (address == 0) => no nft minted for tier
     */
    function getNft() external deadlineExceeded successfullStaking returns(address[] memory, uint[] memory) {
        uint investments = userToInvestments[msg.sender];

        uint nftCount = NFTs.length;

        address[] memory nftAddresses = new address[](nftCount);
        uint[] memory tokenIds = new uint[](nftCount);

        for(uint i = 0; i < nftCount; ++i) {
            if(investments >= nftTiersThresholdsAscend[i]) {
                nftAddresses[i] = address(NFTs[i]);
                tokenIds[i] = NFTs[i].safeMint(msg.sender);
            }
        }

        return (nftAddresses, tokenIds);
    }


    function transfer() private {
        payable(receiver).transfer(address(this).balance);
    }



    modifier notCompleted() {
        require(!isCompleted, "Staking already completed!");
        _;
    }

    modifier successfullStaking() {
        require(address(this).balance >= threshold
                || isSuccessful, "Staking not successful, goal is't reached!");
        _;
    }

    modifier failedStaking() {
        require(address(this).balance < threshold, "Staking successful, goal is reached!");
        _;
    }

    modifier deadlineNotExceeded() {
        require(block.timestamp < deadline, "Deadline for investments reached!");
        _;
    }

    modifier deadlineExceeded() {
        require(block.timestamp >= deadline, "Deadline for investments not reached!");
        _;
    }
}