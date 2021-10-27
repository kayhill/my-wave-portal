// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message, string link);

    struct Wave {
        address waver; // The address of the user who waved.
        string message; // The message the user sent.
        string link; // The song link the user sent
        uint256 timestamp; // The timestamp when the user waved.
    }

    /*
     * an array of structs to hold waves
     */
    Wave[] waves;

    // prevent spamming - see when user last waved
    mapping(address => uint256) public lastWavedAt;


    constructor() payable {
        console.log("Hello, I am a smart contract.");
        // Initial seed
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message, string memory _link) public {
      // cool down time period 
      require(
            lastWavedAt[msg.sender] + 5 minutes < block.timestamp,
            "Please wait 5 minutes before you try again"
        );

      // Update the current timestamp we have for the user
      lastWavedAt[msg.sender] = block.timestamp;
      
      // update wave count 
      totalWaves += 1;

      // store the wave data in the array         
      waves.push(Wave(msg.sender, _message, _link, block.timestamp));

      // generate a new seed for each new wave
      seed = (block.difficulty + block.timestamp + seed) % 100;
        
      if (seed <= 25) {
          console.log("%s won!", msg.sender);

          uint256 prizeAmount = 0.0001 ether;

          require(
            prizeAmount <= address(this).balance,
            "Trying to withdraw more money than the contract has."
          );

          (bool success, ) = (msg.sender).call{value: prizeAmount}("");

          require(success, "Failed to withdraw money from contract.");
        }

      emit NewWave(msg.sender, block.timestamp, _message, _link);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
}