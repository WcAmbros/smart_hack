pragma solidity ^0.4.23;

contract ERC20Interface {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);

  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);

  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


library SafeMath {

  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    return a / b;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}


contract ERC20 is ERC20Interface{
  using SafeMath for uint;

  mapping(address => uint) internal balances;
  mapping (address => mapping (address => uint)) internal allowed;

  uint internal totalSupply_;

  modifier beforeTransfer(address _from, address _to, uint _value){
    require(_to != address(0) && _to != address(this));
    require(_value <= balances[_from]);
    _;
  }

  modifier beforeApproval(address _spender, uint _value){
    require(_spender != address(0) && _spender != address(this));
    require(_value <= balances[msg.sender]);
    _;
  }

  function totalSupply() public view returns (uint) {
    return totalSupply_;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }

  function _transfer(address _from, address _to, uint _value) internal{
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);

    emit Transfer(_from, _to, _value);
  }

  function transfer(address _to, uint _value) public beforeTransfer(msg.sender, _to, _value) returns (bool) {
    _transfer(msg.sender, _to, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint) {
    return allowed[_owner][_spender];
  }

  function transferFrom(address _from, address _to, uint _value) public beforeTransfer(_from, _to, _value) returns (bool) {
    require(_value <= allowed[_from][msg.sender]);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    _transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint _value) public beforeApproval( _spender, _value) returns (bool) {
    allowed[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function increaseApproval(address _spender, uint _value) public beforeApproval( _spender, _value) returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_value);

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _value) public beforeApproval( _spender, _value) returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_value > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_value);
    }

    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}


contract ERC827Interface {
  function approveAndCall(address _spender, uint _value, bytes _data) public payable returns (bool);
  function transferAndCall(address _to, uint _value, bytes _data) public payable returns (bool);
  function transferFromAndCall(address _from, address _to, uint _value, bytes _data) public payable returns (bool);
}


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


contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

constructor() public {
owner = msg.sender;
}

modifier onlyOwner() {
require(msg.sender == owner);
_;
}

function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
owner = newOwner;

emit OwnershipTransferred(owner, newOwner);
}

}


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


contract TokenBase is Pausable{

event Mint(address indexed to, uint amount, uint date);

uint internal maxTotalSupply_;

function kill() public onlyOwner returns(bool){
selfdestruct(owner);
return true;
}

function mint(uint _amount) external onlyOwner returns (bool) {
totalSupply_ = totalSupply_.add(_amount);
assert(totalSupply_ <= maxTotalSupply_);

balances[owner] = balances[owner].add(_amount);
emit Mint(owner, _amount, now);
emit Transfer(address(0), owner, _amount);
return true;
}
}


contract TaxiToken  is TokenBase{


string internal name_;
string internal symbol_;
uint8 internal decimals_;

constructor() public{
name_ = "TaxiToken";
symbol_ = "TTC";
decimals_ = 18;
totalSupply_ = 1000 * 10**uint(decimals_);
maxTotalSupply_ = 1*10**uint(decimals_) + totalSupply_;
}

modifier checkAddress(address _from){
require(_from != address(0) && _from != address(this));
_;
}

event Payment(address indexed _from, address indexed _to, uint price, uint date, string description, address indexed seller);

struct Product{
string description;
uint price;
address seller;
}

Product[] public products;
mapping(uint=> address) productSeller;

function addProduct(string description, uint price) external onlyOwner returns(bool){
uint id = products.push(Product(description, price, msg.sender))-1;
productSeller[id] = msg.sender;
return true;
}

function payment(address _from, uint productId) external checkAddress(_from) returns (bool){

Product memory product = products[productId];

require(product.seller == msg.sender);
assert(super.transferFrom(_from, msg.sender, product.price));

emit Payment(_from, product.seller, product.price, now, product.description, msg.sender);
return true;
}

function name() public view returns(string){
return name_;
}

function symbol() public view returns(string){
return symbol_;
}

function decimals() public view returns(uint8){
return decimals_;
}

}
