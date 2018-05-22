pragma solidity ^0.4.23;


import "./ERC827.sol";
import "./Ownable.sol";

contract Pausable is ERC827, Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() external onlyOwner whenNotPaused  {
    paused = true;
    emit Pause();
  }

  function unpause() external onlyOwner whenPaused  {
    paused = false;
    emit Unpause();
  }


  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }

  //For standart ERC827
  function approveAndCall(address _spender, uint256 _value, bytes _data) public payable whenNotPaused returns (bool) {
    return  super.approveAndCall(_spender, _value, _data);
  }

  function transferAndCall(address _to, uint256 _value, bytes _data) public payable whenNotPaused returns (bool) {
    return  super.transferAndCall(_to, _value, _data);
  }

  function transferFromAndCall(address _from, address _to, uint256 _value, bytes _data) public payable whenNotPaused returns (bool){
    return  super.transferFromAndCall( _from, _to, _value, _data);
  }

  function increaseApprovalAndCall(address _spender, uint _value, bytes _data) public payable whenNotPaused returns (bool) {
    return  super.increaseApprovalAndCall(_spender, _value, _data);
  }

  function decreaseApprovalAndCall(address _spender, uint _value, bytes _data) public payable whenNotPaused returns (bool) {
    return  super.decreaseApprovalAndCall(_spender, _value, _data);
  }
}
