// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../libraries/Errors.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ProjectToken is ERC20 {
    address public project;
    address public factory;

    constructor(
        string memory name_,
        string memory symbol_,
        address project_,
        address factory_
    ) ERC20(name_, symbol_) {
        project = project_;
        factory = factory_;
    }

    modifier onlyProject() {
        require(msg.sender == project, "Only project");
        _;
    }

    function mint(address to, uint256 amount) external onlyProject {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyProject {
        _burn(from, amount);
    }

    // Bloqueo completo de transferencias (solo se permite mint y burn)
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override {
        // Solo se permite si es mint (from == address(0)) o burn (to == address(0))
        if (!(from == address(0) || to == address(0))) {
            revert TransferNotAllowed();
        }
        super._update(from, to, value);
    }
}