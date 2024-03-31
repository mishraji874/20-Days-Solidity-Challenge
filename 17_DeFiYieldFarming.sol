// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract YiedlFarm is Ownable {
    IERC20 public rewardToken;
    IERC20 public token;
    uint256 public totalStaked;

    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public lastClaimed;

    uint256 public rewardRate = 100;
    uint256 public lastRewardBlock;
    uint256 public constant BLOCKS_PER_DAY = 5760;
    uint256 public rewardRateDecay = 1;

    constructor(address _token, address _rewardToken) {
        token = IERC(_token);
        rewardToken = IERC(_rewardToken);
        lastRewardBlock = block.number;
    }

    //stake tokens to earn rewards
    function stake(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        updateReward(msg.sender);
        token.transferFrom(msg.sender, address(this), amount);
        stakedBalance[msg.sender] += amount;
        totalStaked += amount;
    }

    //withdraw staked tokens
    function withdraw(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        updateReward(msg.sender);
        require(stakedBalance[msg.sender] >= amount, "Insufficient staked balance");
        stakedBalance[msg.sender] -= amount;
        totalStaked -= amount;
        token.transfer(msg.sender, amount);
    }

    //claim earned rewards
    function claim() external {
        updateReward(msg.sender);
        uint256 reward = getEarnedRewards(msg.sender);
        require(reward > 0, "No rewards to claim");
        lastClaimed[msg.sender] = block.number;
        rewardToken.transfer(msg.sender, reward);
    }

    //update tthe reward for a user
    function updateReward(address user) internal {
        uint256 currentBlock = block.number;
        uint256 blockPassed = currentBlock - lastRewardBlock;
        uint256 totalRewards = blockPassed * rewardRate;
        uint256 userReward = (stakedBalance[user] * totalRewards) / totalStaked;
        lastClaimed[user] = currentBlock;
        rewardToken.transfer(user, userReward);
        lastRewardBlock = currentBlock;
    }

    //calculate the rewards earned by a user
    function getEarnedRewards(address user) public view returns (uint256) {
        uint256 currentBlock = block.number;
        uint256 blockPassed = currentBlock - lastClaimed[user];
        uint256 totalRewards = blocksPassed * rewardRate;
        return (stakedBalance[user] * totalRewards) / totalStaked;
    }

    //update the reward ratte (onlyOwner)
    function updateRewardRate(uint256 newRate) external onlyOwner {
        require(newRate >= 0, "Rate must be non-negative");
        rewardRate = newRate;
    }

    //decay the reward rate over time(onlyOwner)
    function decayRewardRate(uint256 decayFactor) external onlyOwner {
        require(decayFactor >= 0 && decayFactor <= 100, "Decay factor must be between 0 and 100");
        uint256 currentBlock = block.number;
        uint256 daysPassed = (currentBlock - lastRewardBlock) / BLOCKS_PER_DAY;
        uint256 decayAmount = (rewardRate * decayFactor * daysPassed) / 100;
        rewardRate -= decayAmount;
    }
}