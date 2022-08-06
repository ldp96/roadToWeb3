// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract ExampleExternalContract {

  bool public completed;
  address staker;

  modifier onlyStaker() {
    require(msg.sender == staker, "not staker");
    _;
  }
  function setStaker() public {
    staker = msg.sender;
  }
  function complete() public payable onlyStaker {
    completed = true;
  }

  function setUncomplete() public onlyStaker{
    completed = false;
  }

  function withdrawEth() public onlyStaker {
    (bool sent, ) = msg.sender.call{value: address(this).balance}("");
    require(sent);
  }

}
