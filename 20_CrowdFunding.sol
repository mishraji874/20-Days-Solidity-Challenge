//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Crowdfunding {

    struct Campaign {
        address creator;
        uint256 goal;
        uint256 raised;
        bool completed;
    }

    Campaign[] public campaigns;

    function createCampaign(uint256 _goal) public {
        Campaign memory newCampaign = Campaign({
            creator: msg.sender,
            goal: _goal,
            raised: 0,
            completed: false
        });
        campaigns.push(newCampaign);
    }

    function contribute(uint256 _campaignIndex) public payable {
        Campaign storage campaign = campaigns[_campaignIndex];
        require(!campaign.completed, "Campaign is completed");
        campaign.raised += msg.value;
        if(campaign.raised >= campaign.goal) {
            campaign.completed = true;
        }
    }

    function getCampaignCount() public view returns (uint256) {
        return campaigns.length;
    }
}