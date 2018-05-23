pragma solidity ^0.4.23;

import "./TokenBase.sol";

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

    balances[msg.sender] = totalSupply_;
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
  mapping(address => address) delegateSaler;

  function delegateSale(address seller) external onlyOwner checkAddress(seller) returns (bool){
    delegateSaler[seller] = msg.sender;
  }

  function addProduct(string description, uint price) external onlyOwner returns(bool){
    uint id = products.push(Product(description, price, msg.sender))-1;
    productSeller[id] = msg.sender;
    return true;
  }

  function payment(address _from, uint productId) external checkAddress(_from) returns (bool){
    address delegateAddress = delegateSaler[msg.sender];
    require(delegateAddress != address(0x0) || msg.sender == owner);

    Product memory product = products[productId];

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

  function maxTotalSupply() public view returns(uint){
    return maxTotalSupply_;
  }

}
