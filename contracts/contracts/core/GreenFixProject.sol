// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
//import "@openzeppelin/contracts/security/Pausable.sol";// or 
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./ProjectToken.sol";
import "../libraries/ProjectState.sol";
import "../libraries/Errors.sol";


contract GreenFixProject is ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // ────────────── STRUCTS ──────────────

    struct ProjectConfig {
        uint256 fundingGoal;
        uint256 interestBps;
        uint256 platformFeeBps;      // comisión plataforma sobre intereses
        uint256 fundingDeadline;
    }

    struct TimeConfig {
        uint256 votingDuration;
        uint256 repaymentInterval;
        uint256 gracePeriod;
        uint256 claimPeriod;
    }

    struct Milestone {
        uint8 percentage;
        uint256 amount;
        bool released;
        bool votingActive;
        uint256 voteStart;
        uint256 voteEnd;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 totalParticipation;
        string evidenceURI;
    }

    struct Repayment {
        uint256 dueDate;
        uint256 amount;
        bool paid;
    }

    // ────────────── STATE VARIABLES ──────────────

    // Immutables
    address public factory;
    IERC20 public usdc;
    ProjectToken public projectToken;

    // Configuraciones
    ProjectConfig public config;
    TimeConfig public timeConfig;

    // Estados
    ProjectState public state;

    // Creador del proyecto (depositó garantía)
    address public creator;

    // Financiamiento
    uint256 public totalRaised;
    uint256 public totalTokensMinted; // debe coincidir con totalRaised
    bool public fundingFinalized;

    // Registro de inversores
    address[] public investors;
    mapping(address => bool) public isInvestor;

    // Milestones
    Milestone[] public milestones;
    uint256 public currentMilestone;

    // Repayments
    Repayment[] public repayments;

    // Variables financieras separadas
    uint256 public totalPrincipalRepaid;
    uint256 public totalInterestRepaid;
    uint256 public totalReleased;       // fondos liberados al creador por milestones

    // Refunds
    uint256 public refundPool;          // capital restante + garantía
    mapping(address => bool) public hasClaimedRefund;

    // Rewards
    mapping(address => uint256) public claimedRewards;

    // Votaciones
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    // Votación de default activa
    bool public defaultVoteActive;

    // Fee recolectado
    uint256 public platformFeeCollected;

    // ────────────── MODIFIERS ──────────────

    modifier onlyState(ProjectState expected) {
        if (state != expected) revert InvalidState(expected, state);
        _;
    }

    modifier onlyCreator() {
        if (msg.sender != creator) revert OnlyCreator();
        _;
    }

    modifier onlyInvestor() {
        if (!isInvestor[msg.sender]) revert OnlyInvestor();
        _;
    }

    modifier onlyFactory() {
        if (msg.sender != factory) revert OnlyFactory();
        _;
    }

    modifier onlyActiveVoting() {
        // Verificar que hay una votación en curso en algún milestone
        // Implementación detallada en Fase 8
        _;
    }

    // ────────────── EVENTS ──────────────

    event Invested(address indexed investor, uint256 amount, uint256 tokensMinted);
    event MilestoneVotingStarted(uint256 indexed milestoneId, uint256 startTime, uint256 endTime);
    event Voted(address indexed investor, uint256 indexed milestoneId, bool support, uint256 weight);
    event MilestoneApproved(uint256 indexed milestoneId);
    event FundsReleased(uint256 indexed milestoneId, uint256 amount);
    event RefundActivated();
    event RefundClaimed(address indexed investor, uint256 amount);
    event RepaymentMade(address indexed creator, uint256 amount);
    event ProjectCompleted();
    event ProjectDefaulted();
    event FundingCancelled();

    // ────────────── CONSTRUCTOR ──────────────

    constructor(
        address _factory,
        address _usdc,
        uint256 _fundingGoal,
        uint256 _interestBps,
        uint256 _platformFeeBps,
        uint256 _votingDuration,
        uint256 _repaymentInterval,
        uint256 _gracePeriod,
        uint256 _claimPeriod,
        uint256 _fundingDeadline,
        address _creator,
        uint256 _guarantee
    ) {
        factory = _factory;
        usdc = IERC20(_usdc);
        config = ProjectConfig({
            fundingGoal: _fundingGoal,
            interestBps: _interestBps,
            platformFeeBps: _platformFeeBps,
            fundingDeadline: _fundingDeadline
        });
        timeConfig = TimeConfig({
            votingDuration: _votingDuration,
            repaymentInterval: _repaymentInterval,
            gracePeriod: _gracePeriod,
            claimPeriod: _claimPeriod
        });
        creator = _creator;
        state = ProjectState.Funding;

        // Desplegar token del proyecto (no transferible)
        projectToken = new ProjectToken("GreenFix Project", "GPFT", address(this), factory);

        // El creador deposita garantía (se hace en constructor o antes)
        // require(usdc.transferFrom(creator, address(this), _guarantee), "Guarantee failed");
        // refundPool += _guarantee;
    }

    // ────────────── FUNCIONES (esqueleto) ──────────────
    // Las implementaremos fase por fase.
    // Por ahora, solo declaraciones vacías o con revert para que compile.

    function invest(uint256 amount) external onlyState(ProjectState.Funding) nonReentrant whenNotPaused {
        revert("Not implemented");
    }

    function cancelFunding() external onlyState(ProjectState.Funding) onlyCreator whenNotPaused {
        revert("Not implemented");
    }

    function finalizeFunding() external onlyState(ProjectState.Funding) whenNotPaused {
        revert("Not implemented");
    }

    function requestMilestoneRelease(string calldata evidenceURI) external onlyState(ProjectState.Active) onlyCreator whenNotPaused {
        revert("Not implemented");
    }

    function vote(uint256 milestoneId, bool support) external onlyState(ProjectState.Voting) onlyInvestor whenNotPaused {
        revert("Not implemented");
    }

    function finalizeVoting(uint256 milestoneId) external onlyState(ProjectState.Voting) whenNotPaused {
        revert("Not implemented");
    }

    function makeRepayment(uint256 repaymentIndex) external onlyState(ProjectState.Active) onlyCreator whenNotPaused {
        revert("Not implemented");
    }

    function triggerDefaultVote() external onlyState(ProjectState.Active) whenNotPaused {
        revert("Not implemented");
    }

    function activateRefunds() external whenNotPaused {
        // permitido en Defaulted o Cancelled
        revert("Not implemented");
    }

    function claimRefund() external onlyInvestor nonReentrant whenNotPaused {
        // permitido en Refunding
        revert("Not implemented");
    }

    function claimRewards() external onlyInvestor nonReentrant whenNotPaused {
        // permitido en Completed
        revert("Not implemented");
    }

    // Funciones auxiliares (vistas)
    function getMilestoneCount() external view returns (uint256) {
        return milestones.length;
    }

    function getRepaymentCount() external view returns (uint256) {
        return repayments.length;
    }

    function getRefundAmount(address investor) external view returns (uint256) {
        revert("Not implemented");
    }

    function getPendingReward(address investor) external view returns (uint256) {
        revert("Not implemented");
    }
}