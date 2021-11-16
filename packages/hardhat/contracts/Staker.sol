pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

   // stacked balance
   mapping(address => uint256) public balances;

   // staking threshold
   uint256 public constant threshold = 0.003 ether;

   // staking event
   event Stake(address indexed sender, uint256 amount);
   event Withdraw(address indexed sender, uint256 amount);

   uint256 public deadline = now + 60 seconds;

   //staking function
   function stake() public payable {
     // update staked balance
     balances[msg.sender] += msg.value;

     // emit the event
     emit Stake(msg.sender, msg.value);
   }

   function timeLeft() public view returns (uint256 timeleft) {
    if( block.timestamp >= deadline ) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  function execute() public notCompleted {
      if(address(this).balance >= threshold){
        (bool sent,) = address(exampleExternalContract).call{value: address(this).balance}(abi.encodeWithSignature("complete()"));
        require(sent, "exampleExternalContract.complete failed");
      }
    }

    function withdraw(address _receiver) public notCompleted {

      require(_receiver==msg.sender, "Please connect the correct wallet to withdraw!");

      uint256 userBalance = balances[msg.sender];

      // check if the user has balance to withdraw
      require(userBalance > 0, "You don't have balance to withdraw");

      // reset the balance of the user
      balances[msg.sender] = 0;

      // Transfer balance back to the user
      msg.sender.transfer(userBalance);
      emit Withdraw(msg.sender, userBalance);
    }

    receive() external payable {
      stake();
    }

    modifier notCompleted() {
      bool completed = exampleExternalContract.completed();
      require(!completed, "staking completed");
      _;
    }
}
