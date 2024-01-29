// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Lesson_7 {
    address owner; 
    event Paid (address _from, uint _amount, uint _timestamp);

    constructor () {
        owner = msg.sender;
    }

    receive() external payable {
        pay();
    }

    function pay() public payable {
        emit Paid(msg.sender, msg.value, block.timestamp);
    }

    modifier onlyOwner(address _to) {
        require(msg.sender == owner, "you are not an owner");
        require(_to != address(0), "incorrect address!");
        _;
    }

    function withdraw (address payable _to) external onlyOwner(_to){
        _to.transfer(address(this).balance);
    }
 
}