pragma solidity ^0.4.23;


contract ERC827Interface {
  function approveAndCall(address _spender, uint _value, bytes _data) public payable returns (bool);
  function transferAndCall(address _to, uint _value, bytes _data) public payable returns (bool);
  function transferFromAndCall(address _from, address _to, uint _value, bytes _data) public payable returns (bool);
}
