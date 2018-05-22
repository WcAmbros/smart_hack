pragma solidity ^0.4.23;

import "./Pausable.sol";

contract TokenBase is Pausable{

  event Mint(address indexed to, uint amount, uint date);

  string public name;
  string public symbol;
  uint8 public decimals;
  uint public maxTotalSupply;

  function kill() public onlyOwner returns(bool){
    selfdestruct(owner);
    return true;
  }

  function mint(uint _amount) external onlyOwner returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    assert(totalSupply_ <= maxTotalSupply);

    balances[owner] = balances[owner].add(_amount);
    emit Mint(owner, _amount, now);
    emit Transfer(address(0), owner, _amount);
    return true;
  }
}
