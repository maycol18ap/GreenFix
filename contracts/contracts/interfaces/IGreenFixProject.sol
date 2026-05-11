// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IGreenFixProject {
    // Funding
    function invest(uint256 amount) external;
    function cancelFunding() external;
    function finalizeFunding() external;

    // Milestones & Voting
    function requestMilestoneRelease(string calldata evidenceURI) external;
    function vote(uint256 milestoneId, bool support) external;
    function finalizeVoting(uint256 milestoneId) external;

    // Repayments
    function makeRepayment(uint256 repaymentIndex) external;
    function triggerDefaultVote() external;

    // Refunds & Rewards
    function activateRefunds() external;
    function claimRefund() external;
    function claimRewards() external;

    // View helpers
    function getMilestoneCount() external view returns (uint256);
    function getRepaymentCount() external view returns (uint256);
    function getRefundAmount(address investor) external view returns (uint256);
    function getPendingReward(address investor) external view returns (uint256);
}
