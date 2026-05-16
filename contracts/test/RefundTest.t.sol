// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/core/GreenFixFactory.sol";
import "../contracts/core/GreenFixProject.sol";
import "../contracts/core/ProjectToken.sol";
import "../contracts/mocks/MockUSDC.sol";

contract RefundTest {
    MockUSDC usdc;
    GreenFixFactory factory;
    GreenFixProject project;
    ProjectToken token;
    
    uint256 constant FUNDING_GOAL = 1000 * 1e6;
    uint256 constant GUARANTEE = 50 * 1e6;

    function setUp() public {
        usdc = new MockUSDC();
        
        factory = new GreenFixFactory(
            address(usdc),
            1000,
            1,
            1,
            7,
            address(this)
        );
    }

    function ensureFunds(uint256 amount) internal {
        usdc.mint(address(this), amount);
    }

    function createProjectInDefault() internal returns (GreenFixProject) {
        ensureFunds(GUARANTEE + FUNDING_GOAL);
        
        usdc.approve(address(factory), GUARANTEE);
        uint256 projectId = factory.createProject(
            FUNDING_GOAL, 600, 30, 7 * 24 * 3600, "ipfs://metadata"
        );
        
        (address projectAddr,,,) = factory.getProject(projectId);
        project = GreenFixProject(projectAddr);
        token = ProjectToken(address(project.projectToken()));
        
        usdc.approve(projectAddr, GUARANTEE);
        project.depositGuarantee();
        
        usdc.approve(projectAddr, FUNDING_GOAL);
        project.invest(FUNDING_GOAL);
        project.finalizeFunding();
        
        // Doble rechazo → Defaulted
        project.requestMilestoneRelease("ipfs://QmTest1");
        project.vote(0, false);
        project.finalizeVoting(0);
        
        project.requestMilestoneRelease("ipfs://QmTest2");
        project.vote(0, false);
        project.finalizeVoting(0);
        
        assert(uint256(project.state()) == 6); // Defaulted
        return project;
    }

    function testActivateRefundsFromDefaulted() public {
        project = createProjectInDefault();
        
        project.activateRefunds();
        
        assert(uint256(project.state()) == 3); // Refunding
        assert(project.refundPool() > 0);
        assert(project.refundTotalSupplySnapshot() > 0);
    }

    function testGetRefundAmount() public {
        project = createProjectInDefault();
        project.activateRefunds();
        
        uint256 refundAmount = project.getRefundAmount(address(this));
        
        assert(refundAmount > 0);
        assert(refundAmount <= project.refundPool());
    }

    function testClaimRefund() public {
        project = createProjectInDefault();
        project.activateRefunds();
        
        uint256 balanceBefore = usdc.balanceOf(address(this));
        uint256 refundAmount = project.getRefundAmount(address(this));
        
        project.claimRefund();
        
        uint256 balanceAfter = usdc.balanceOf(address(this));
        assert(balanceAfter - balanceBefore == refundAmount);
        assert(token.balanceOf(address(this)) == 0); // Tokens quemados
    }

    function testCannotDoubleClaim() public {
        project = createProjectInDefault();
        project.activateRefunds();
        project.claimRefund();
        
        try project.claimRefund() {
            assert(false);
        } catch {
            assert(true);
        }
    }

    function testCannotClaimWithoutActivation() public {
        project = createProjectInDefault();
        
        try project.claimRefund() {
            assert(false);
        } catch {
            assert(true);
        }
    }

    function testCancelFundingFlow() public {
        ensureFunds(GUARANTEE + FUNDING_GOAL);
        
        usdc.approve(address(factory), GUARANTEE);
        uint256 projectId = factory.createProject(
            FUNDING_GOAL, 600, 30, 7 * 24 * 3600, "ipfs://metadata"
        );
        
        (address projectAddr,,,) = factory.getProject(projectId);
        project = GreenFixProject(projectAddr);
        token = ProjectToken(address(project.projectToken()));
        
        usdc.approve(projectAddr, GUARANTEE);
        project.depositGuarantee();
        
        uint256 investAmount = 200 * 1e6;
        usdc.approve(projectAddr, investAmount);
        project.invest(investAmount);
        
        // Cancelar → Cancelled (5)
        project.cancelFunding();
        assert(uint256(project.state()) == 5); // Cancelled
        
        // Activar refunds → Refunding (3)
        project.activateRefunds();
        assert(uint256(project.state()) == 3); // Refunding
        
        // Reclamar
        uint256 balanceBefore = usdc.balanceOf(address(this));
        project.claimRefund();
        uint256 balanceAfter = usdc.balanceOf(address(this));
        
        assert(balanceAfter > balanceBefore);
    }

    function testSnapshotPreventsManipulation() public {
        project = createProjectInDefault();
        project.activateRefunds();
        
        uint256 snapshotSupply = project.refundTotalSupplySnapshot();
        uint256 currentSupply = token.totalSupply();
        
        // El snapshot debe ser igual al supply actual (antes de quemar)
        assert(snapshotSupply == currentSupply);
        
        // Reclamar
        project.claimRefund();
        
        // El snapshot debe seguir igual
        assert(project.refundTotalSupplySnapshot() == snapshotSupply);
        
        // Pero el supply actual bajó
        assert(token.totalSupply() < currentSupply);
    }
}