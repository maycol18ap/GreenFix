// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./ProjectState.sol";

error InvalidState(ProjectState expected, ProjectState current);
error OnlyCreator();
error OnlyFactory();
error OnlyInvestor();
error NoActiveVoting();
error TransferNotAllowed();
error NotEnoughBalance();
error FundingNotComplete();
error MilestoneAlreadyReleased();
error VotingAlreadyStarted();
error VotingNotEnded();
error AlreadyVoted();
error QuorumNotMet();
error PaymentAlreadyMade();
error DefaultVoteActive();
error NotInDefault();
error RefundAlreadyClaimed();
// ... añade las que necesites