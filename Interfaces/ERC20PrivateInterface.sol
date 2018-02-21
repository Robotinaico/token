pragma solidity ^0.4.13;

contract ERC20PrivateInterface {
    uint256 supply;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
