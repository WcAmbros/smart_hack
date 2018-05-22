pragma solidity ^0.4.23;

import "./ERC827Interface.sol";
import "./ERC20.sol";


contract ERC827 is ERC827Interface, ERC20 {


  function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool) {
    require(_spender != address(this));
    super.approve(_spender, _value);

    require(_spender.call.value(msg.value)(_data));
    return true;
  }

  function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool) {
    require(_to != address(this));
    super.transfer(_to, _value);

    require(_to.call.value(msg.value)(_data));
    return true;
  }

  function transferFromAndCall(address _from, address _to, uint256 _value, bytes _data) public payable returns (bool){
    require(_to != address(this));
    super.transferFrom(_from, _to, _value);

    require(_to.call.value(msg.value)(_data));
    return true;
  }


  function increaseApprovalAndCall(address _spender, uint _value, bytes _data) public payable returns (bool) {
    require(_spender != address(this));
    super.increaseApproval(_spender, _value);

    require(_spender.call.value(msg.value)(_data));

    return true;
  }

  function decreaseApprovalAndCall(address _spender, uint _value, bytes _data) public payable returns (bool) {
    require(_spender != address(this));
    super.decreaseApproval(_spender, _value);

    require(_spender.call.value(msg.value)(_data));
    return true;
  }

}
