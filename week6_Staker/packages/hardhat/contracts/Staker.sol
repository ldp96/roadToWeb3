// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";
import "./Interest.sol";

contract Staker {
  uint constant withdrawTime = 240 seconds;
  uint constant claimTime = 480 seconds;

  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint256) public balances;
  mapping(address => uint256) public depositTimestamps;
  address owner;


  uint256 public withdrawalDeadline = block.timestamp + withdrawTime;
  uint256 public claimDeadline = block.timestamp + claimTime;
  uint256 public currentBlock = 0;

  // Events
  event Stake(address indexed sender, uint256 amount);
  event Received(address, uint);
  event Execute(address indexed sender, uint256 amount);

  // Modifiers
  /*
  Checks if the withdrawal period been reached or not
  */
  modifier withdrawalDeadlineReached( bool requireReached ) {
    uint256 timeRemaining = withdrawalTimeLeft();
    if( requireReached ) {
      require(timeRemaining == 0, "Withdrawal period is not reached yet");
    } else {
      require(timeRemaining > 0, "Withdrawal period has been reached");
    }
    _;
  }

  /*
  Checks if the claim period has ended or not
  */
  modifier claimDeadlineReached( bool requireReached ) {
    uint256 timeRemaining = claimPeriodLeft();
    if( requireReached ) {
      require(timeRemaining == 0, "Claim deadline is not reached yet");
    } else {
      require(timeRemaining > 0, "Claim deadline has been reached");
    }
    _;
  }

  /*
  Requires that contract only be completed once!
  */
  modifier notCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "Stake already completed!");
    _;
  }

  constructor(address exampleExternalContractAddress){
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
      owner = msg.sender;
      exampleExternalContract.setStaker();
  }

  //reset timers to restart to stake
  function resetStaker() public {
    bool completed = exampleExternalContract.completed();
    require(completed, "stake has to be completed first");
    
    withdrawalDeadline = block.timestamp + withdrawTime;
    claimDeadline = block.timestamp + claimTime;
    exampleExternalContract.setUncomplete();

  }
  // Stake function for a user to stake ETH in our contract
  function stake() public payable withdrawalDeadlineReached(false) claimDeadlineReached(false){
    balances[msg.sender] = balances[msg.sender] + msg.value;
    depositTimestamps[msg.sender] = block.timestamp;
    emit Stake(msg.sender, msg.value);
  }

  /*
  Withdraw function for a user to remove their staked ETH inclusive
  of both principle and any accured interest
  */
  function withdraw() public withdrawalDeadlineReached(true) claimDeadlineReached(false) notCompleted{
    require(balances[msg.sender] > 0, "You have no balance to withdraw!");
    uint256 individualBalance = balances[msg.sender];
    uint256 indBalanceRewards = individualBalance + rewardsAvailableForWithdraw(msg.sender);
    console.log ("indBalanceRewards", indBalanceRewards);
    require(indBalanceRewards <= address(this).balance, "not enough money in the staker");
    balances[msg.sender] = 0;

    // Transfer all ETH via call! (not transfer) cc: https://solidity-by-example.org/sending-ether
    (bool sent, ) = msg.sender.call{value: indBalanceRewards}("");
    require(sent, "RIP; withdrawal failed :( ");
  }
 function rewardsAvailableForWithdraw(address checkAddress) public returns (uint interest) {
    uint256 principal = balances[checkAddress];
    uint256 age = block.timestamp - depositTimestamps[checkAddress];

    // takes principal, rate, age
    Interest interestCalculator = new Interest();
    uint256 rate = interestCalculator.yearlyRateToRay(0.42 ether); //0.42 ETHER is 42% APR.
    interest = interestCalculator.accrueInterest(principal, rate, age);
    console.log("rewardsAvailableForWithdraw");
    console.log("principal ", principal); 
    console.log("rate ", rate); 
    console.log("time passed in seconds, ", age);
    console.log("time passed in days (roughly) ", age / 86400);
    console.log("interest ", interest);   
    return interest; 
  }
  /*
  Allows any user to repatriate "unproductive" funds that are left in the staking contract
  past the defined withdrawal period
  */
  function execute() public claimDeadlineReached(true) notCompleted {
    exampleExternalContract.complete{value: address(this).balance}();
  }

  /*
  READ-ONLY function to calculate time remaining before the minimum staking period has passed
  */
  function withdrawalTimeLeft() public view returns (uint256) {
    if( block.timestamp >= withdrawalDeadline) {
      return (0);
    } else {
      return (withdrawalDeadline - block.timestamp);
    }
  }

  function getEthBlocked() public {
    exampleExternalContract.withdrawEth();
  }
  /*
  READ-ONLY function to calculate time remaining before the minimum staking period has passed
  */
  function claimPeriodLeft() public view returns (uint256 ) {
    if( block.timestamp >= claimDeadline) {
      return (0);
    } else {
      return (claimDeadline - block.timestamp);
    }
  }

  /*
  Time to "kill-time" on our local testnet
  */
  function killTime() public {
    currentBlock = block.timestamp;
  }
  /**
   * @dev function to backdate the start-time (for testing interest calculations)
   */
  function backdateStartTimeOneMonth(address addressToBackdate) public {
    depositTimestamps[addressToBackdate] -= 4 weeks;
  }

  /**
   * @dev function to backdate the start-time (for testing interest calculations)
   */
  function backdateStartTimeOneYear(address addressToBackdate) public {
    depositTimestamps[addressToBackdate] -= 52 weeks;
  }
  /*
  \Function for our smart contract to receive ETH
  cc: https://docs.soliditylang.org/en/latest/contracts.html#receive-ether-function
  */
  receive() external payable {
      emit Received(msg.sender, msg.value);
  }

}
