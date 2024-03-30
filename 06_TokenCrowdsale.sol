// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract TokenCrowdsale is Ownable {
    using SafeMath for uint256;
    address public tokenAddress;
    IERC20 private token;
    uint256 public tokenPrice;
    uint256 public tokenSold;
    uint256 public maxTokensToSell;
    uint256 public totalEtherRaised;
    bool public crowdsaleClosed;

    mapping(address => uint256) public contributions;

    event TokensPurchased(address indexed buyer, uint256 amount, uint256 totalContribution);

    constructor(
        address _tokenAddress,
        uint256 _initialTokenSupply,
        uint256 _tokenPrice,
        uint256 _maxTokenToSell
    ) {
        tokenAddress = _tokenAddress;
        token = IERC20(_tokenAddress);
        tokenPrice = _tokenPrice;
        maxTokensToSell = _maxTokenToSell;
        tokenSold = 0;
        crowdsaleClosed = false;
        //mint initial tokens to the owner
        token.transferFrom(owner(), address(this), _initialTokenSupply);
    }

    modifier onlyWhileOpen() {
        require(!crowdsaleClosed, "Crowdsale is closed");
        _;
    }

    function purchaseTokens(uint256 _numTokens) external payable onlyWhileOpen {
        require(_numTokens > 0, "Must purchase at least one token");
        require(tokensSold.add(_numTokens) <= maxTokensToSell, "Not enough tokens left to sell");
        uint256 totalCost = _numTokens.mul(tokenPrice);
        require(msg.value >= totalCost, "Insufficient ether supply");
        token.transfer(msg.sender, _numTokens);
        contributions[msg.sender] = contributions[msg.sender].add(msg.value);
        tokensSold = tokensSold.add(_numTokens);
        totalEtherRaised = totalEtherRaised.add(msg.value);
        emit TokensPurchased(msg.sender, _numTokens, contributions[msg.sender]);
    }

    function withdrawEther() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function closeCrowdsale() external onlyOwner {
        crowdsaleClosed = true;
    }
}