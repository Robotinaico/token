pragma solidity ^0.4.13;

import "./ERC20Token.sol";
import "./Utils/Lockable.sol";

contract RoxToken is ERC20Token {

    /**
    * @dev Intialises token and all the necesary variable
    */
    function RoxToken() {
        name = "Robotina token";
        symbol = "ROX";
        decimals = 18;
        totalSupplyLimit = 815000000 * 10**18;
        lockFromSelf(0, "Lock before crowdsale starts");
    }
}