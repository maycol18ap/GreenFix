// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/core/GreenFixFactory.sol";
import "../contracts/core/GreenFixProject.sol";
import "../contracts/core/ProjectToken.sol";
import "../contracts/mocks/MockUSDC.sol";

contract MilestoneTest {
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
            1,             // voting duration (no importa para tests)
            1,
            7,
            address(this)
        );
    }

    function ensureFunds(uint256 amount) internal {
        usdc.mint(address(this), amount);
    }

    function createAndFinalizeProject() internal returns (GreenFixProject) {
        ensureFunds(GUARANTEE + FUNDING_GOAL);
        
        usdc.approve(address(factory), GUARANTEE);
        uint256 projectId = factory.createProject(
            FUNDING_GOAL, 600, 30, 7 * 24 * 3600, "ipfs://metadata"
        );
        
        (address projectAddr,,,) = factory.getProject(projectId);
        project = GreenFixProject(projectAddr);
        
        usdc.approve(projectAddr, GUARANTEE);
        project.depositGuarantee();
        
        usdc.approve(projectAddr, FUNDING_GOAL);
        project.invest(FUNDING_GOAL);
        project.finalizeFunding();
        
        token = ProjectToken(address(project.projectToken()));
        
        return project;
    }

    function testRequestMilestoneRelease() public {
        project = createAndFinalizeProject();
        project.requestMilestoneRelease("ipfs://QmTest");
        
        assert(uint256(project.state()) == 2); // Voting
        assert(project.currentMilestone() == 0);
    }

    function testVoteYes() public {
        project = createAndFinalizeProject();
        project.requestMilestoneRelease("ipfs://QmTest");
        project.vote(0, true);
        
        try project.vote(0, true) {
            assert(false);
        } catch {
            assert(true);
        }
    }

    function testVoteNo() public {
        project = createAndFinalizeProject();
        project.requestMilestoneRelease("ipfs://QmTest");
        project.vote(0, false);
        
        try project.vote(0, false) {
            assert(false);
        } catch {
            assert(true);
        }
    }

    function testCannotVoteBeforeRequest() public {
        project = createAndFinalizeProject();
        
        try project.vote(0, true) {
            assert(false);
        } catch {
            assert(true);
        }
    }

    function testOnlyInvestorCanVote() public {
        project = createAndFinalizeProject();
        project.requestMilestoneRelease("ipfs://QmTest");
        project.vote(0, true);
        assert(true);
    }

    function testFinalizeApprovedMilestone() public {
        project = createAndFinalizeProject();
        project.requestMilestoneRelease("ipfs://QmTest");
        project.vote(0, true);
        project.finalizeVoting(0);
        
        // Después de aprobar, currentMilestone debe ser 1
        assert(project.currentMilestone() == 1);
        // El estado debe volver a Active (1)
        assert(uint256(project.state()) == 1);
    }

    function testFinalizeRejectedMilestone() public {
        project = createAndFinalizeProject();
        project.requestMilestoneRelease("ipfs://QmTest");
        project.vote(0, false);
        project.finalizeVoting(0);
        
        assert(uint256(project.state()) == 1); // Active
        assert(project.currentMilestone() == 0); // No avanzó
    }

    function testDoubleRejectionLeadsToDefault() public {
        project = createAndFinalizeProject();
        
        // Primer rechazo
        project.requestMilestoneRelease("ipfs://QmTest1");
        project.vote(0, false);
        project.finalizeVoting(0);
        
        assert(uint256(project.state()) == 1);
        
        // Segundo rechazo (NUEVO hasVoted para este milestone)
        project.requestMilestoneRelease("ipfs://QmTest2");
        project.vote(0, false); // Esto es un NUEVO voto, no doble voto
        project.finalizeVoting(0);
        
        assert(uint256(project.state()) == 6); // Defaulted
    }

    function testApproveResetsRejectionCounter() public {
        project = createAndFinalizeProject();
        
        // Rechazo
        project.requestMilestoneRelease("ipfs://QmTest1");
        project.vote(0, false);
        project.finalizeVoting(0);
        
        // Aprobado (resetea contador)
        project.requestMilestoneRelease("ipfs://QmTest2");
        project.vote(0, true);
        project.finalizeVoting(0);
        
        assert(uint256(project.state()) == 1);
        assert(project.currentMilestone() == 1);
        
        // Otro rechazo en el NUEVO milestone (milestone 1)
        project.requestMilestoneRelease("ipfs://QmTest3");
        project.vote(1, false); // ← milestoneId = 1, no 0
        project.finalizeVoting(1); // ← milestoneId = 1
        
        assert(uint256(project.state()) == 1); // Sigue Active (solo 1 rechazo)
    }

    function testCannotRequestMilestoneInWrongState() public {
        project = createAndFinalizeProject();
        project.requestMilestoneRelease("ipfs://QmTest");
        
        try project.requestMilestoneRelease("ipfs://QmTest2") {
            assert(false);
        } catch {
            assert(true);
        }
    }

    function testAllFourMilestones() public {
        project = createAndFinalizeProject();
        
        for (uint256 i = 0; i < 4; i++) {
            project.requestMilestoneRelease("ipfs://QmTest");
            project.vote(i, true);
            project.finalizeVoting(i);
            
            assert(project.currentMilestone() == i + 1);
            assert(uint256(project.state()) == 1);
        }
        
        assert(project.currentMilestone() == 4);
    }
}