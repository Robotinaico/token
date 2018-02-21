pragma solidity ^0.4.13;

contract OwnedInterface {
    address public owner;
    address public newOwner;

    modifier onlyOwner {
        _;
    }
}