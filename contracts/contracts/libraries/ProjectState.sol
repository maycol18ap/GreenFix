// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

enum ProjectState {
    Funding,
    Active,
    Voting,
    Refunding,
    Completed,
    Cancelled,
    Defaulted
}