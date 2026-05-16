// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/core/GreenFixFactory.sol";
import "../contracts/core/GreenFixProject.sol";
import "../contracts/mocks/MockUSDC.sol";

contract FundingTest {
    MockUSDC usdc;
    GreenFixFactory factory;
    
    uint256 constant FUNDING_GOAL = 1000 * 1e6;
    uint256 constant GUARANTEE = 50 * 1e6;

    function setUp() public {
        usdc = new MockUSDC();
        
        factory = new GreenFixFactory(
            address(usdc),
            1000,
            3 * 24 * 3600,
            1 * 24 * 3600,
            7 * 24 * 3600,
            address(this)
        );
    }

    // Helper para asegurar fondos
    function ensureFunds(uint256 amount) internal {
        usdc.mint(address(this), amount);
    }

    function createProjectWithGuarantee() internal returns (GreenFixProject) {
        ensureFunds(GUARANTEE * 2); // Asegurar fondos para garantía
        usdc.approve(address(factory), GUARANTEE);
        uint256 projectId = factory.createProject(
            FUNDING_GOAL, 600, 30, 7 * 24 * 3600, "ipfs://metadata"
        );
        
        (address projectAddr,,,) = factory.getProject(projectId);
        GreenFixProject project = GreenFixProject(projectAddr);
        
        usdc.approve(projectAddr, GUARANTEE);
        project.depositGuarantee();
        
        return project;
    }

    function testCreateProject() public {
        ensureFunds(GUARANTEE);
        usdc.approve(address(factory), GUARANTEE);
        uint256 projectId = factory.createProject(
            FUNDING_GOAL, 600, 30, 7 * 24 * 3600, "ipfs://metadata"
        );
        assert(projectId == 1);
    }

    function testDepositGuarantee() public {
        ensureFunds(GUARANTEE * 2);
        usdc.approve(address(factory), GUARANTEE);
        uint256 projectId = factory.createProject(
            FUNDING_GOAL, 600, 30, 7 * 24 * 3600, "ipfs://metadata"
        );
        (address projectAddr,,,) = factory.getProject(projectId);
        GreenFixProject project = GreenFixProject(projectAddr);
        
        usdc.approve(projectAddr, GUARANTEE);
        project.depositGuarantee();
        
        assert(project.guaranteeDeposited() == true);
    }

    function testInvest() public {
        GreenFixProject project = createProjectWithGuarantee();
        
        uint256 amount = 100 * 1e6;
        ensureFunds(amount);
        usdc.approve(address(project), amount);
        project.invest(amount);
        
        assert(project.totalRaised() == amount);
    }

    function testRevertIfBelowMinimum() public {
        GreenFixProject project = createProjectWithGuarantee();
        
        uint256 amount = 5 * 1e6;
        ensureFunds(amount);
        usdc.approve(address(project), amount);
        
        try project.invest(amount) {
            assert(false);
        } catch {
            assert(true);
        }
    }

    function testRevertWithoutGuarantee() public {
        ensureFunds(GUARANTEE + 100 * 1e6);
        usdc.approve(address(factory), GUARANTEE);
        uint256 projectId = factory.createProject(
            FUNDING_GOAL, 600, 30, 7 * 24 * 3600, "ipfs://metadata"
        );
        (address projectAddr,,,) = factory.getProject(projectId);
        GreenFixProject project = GreenFixProject(projectAddr);
        
        uint256 amount = 100 * 1e6;
        usdc.approve(address(project), amount);
        
        try project.invest(amount) {
            assert(false);
        } catch {
            assert(true);
        }
    }

    function testCancelFunding() public {
        GreenFixProject project = createProjectWithGuarantee();
        
        uint256 amount = 100 * 1e6;
        ensureFunds(amount);
        usdc.approve(address(project), amount);
        project.invest(amount);
        
        project.cancelFunding();
        
        assert(uint256(project.state()) == 5);
    }

    function testFinalizeFunding() public {
        GreenFixProject project = createProjectWithGuarantee();
        
        ensureFunds(FUNDING_GOAL);
        usdc.approve(address(project), FUNDING_GOAL);
        project.invest(FUNDING_GOAL);
        
        project.finalizeFunding();
        
        assert(uint256(project.state()) == 1);
        assert(project.fundingFinalized() == true);
        assert(project.getMilestoneCount() == 4);
    }

    function testRevertFinalizeIfGoalNotReached() public {
        GreenFixProject project = createProjectWithGuarantee();
        
        uint256 half = 500 * 1e6;
        ensureFunds(half);
        usdc.approve(address(project), half);
        project.invest(half);
        
        try project.finalizeFunding() {
            assert(false);
        } catch {
            assert(true);
        }
    }
}