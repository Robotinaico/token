pragma solidity ^0.4.13;

import "./Interfaces/tokenRecipientInterface.sol";
import "./Interfaces/ERC20TokenInterface.sol";
import "./Utils/Owned.sol";
import "./Utils/SafeMath.sol";
import "./Utils/Lockable.sol";

contract ERC20Token is ERC20TokenInterface, SafeMath, Owned, Lockable {

    // Name of token
    string public name;
    // Abbreviation of tokens name
    string public symbol;
    // Number of decimals token has
    uint8 public decimals;
    // Maximum tokens that can be minted
    uint256 public totalSupplyLimit;

    // Current supply of tokens
    uint256 supply = 0;
    // Map of users balances
    mapping (address => uint256) balances;
    // Map of users allowances
    mapping (address => mapping (address => uint256)) allowances;

    // Event that shows that new tokens were created
    event Mint(address indexed _to, uint256 _value);
    // Event that shows that old tokens were destroyed
    event Burn(address indexed _from, uint _value);

    /**
    * @dev Returns number of tokens in circulation
    *
    * @return total number od tokens
    */
    function totalSupply() public constant returns (uint256) {
        return supply;
    }

    /**
    * @dev Returns the balance of specific account
    *
    * @param _owner The account that caller wants to querry
    * @return the balance on this account
    */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    /**
    * @dev User can transfer tokens with this method, method is disabled if emergencyLock is activated
    *
    * @param _to Reciever of tokens
    * @param _value The amount of tokens that will be sent 
    * @return if successful returns true
    */
    function transfer(address _to, uint256 _value) lockAffected public returns (bool success) {
        require(_to != 0x0 && _to != address(this));
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev This is used to allow some account to utilise transferFrom and sends tokens on your behalf, this method is disabled if emergencyLock is activated
    *
    * @param _spender Who can send tokens on your behalf
    * @param _value The amount of tokens that are allowed to be sent 
    * @return if successful returns true
    */
    function approve(address _spender, uint256 _value) lockAffected public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev This is used to send tokens and execute code on other smart contract, this method is disabled if emergencyLock is activated
    *
    * @param _spender Contract that is receiving tokens
    * @param _value The amount that msg.sender is sending
    * @param _extraData Additional params that can be used on reciving smart contract
    * @return if successful returns true
    */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) lockAffected public returns (bool success) {
        tokenRecipientInterface spender = tokenRecipientInterface(_spender);
        approve(_spender, _value);
        spender.receiveApproval(msg.sender, _value, this, _extraData);
        return true;
    }

    /**
    * @dev Sender can transfer tokens on others behalf, this method is disabled if emergencyLock is activated
    *
    * @param _from The account that will send tokens
    * @param _to Account that will recive the tokens
    * @param _value The amount that msg.sender is sending
    * @return if successful returns true
    */
    function transferFrom(address _from, address _to, uint256 _value) lockAffected public returns (bool success) {
        require(_to != 0x0 && _to != address(this));
        balances[_from] = safeSub(balanceOf(_from), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        allowances[_from][msg.sender] = safeSub(allowances[_from][msg.sender], _value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Returns the amount od tokens that can be sent from this addres by spender
    *
    * @param _owner Account that has tokens
    * @param _spender Account that can spend tokens
    * @return remaining balance to spend
    */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowances[_owner][_spender];
    }

    /**
    * @dev Creates new tokens as long as total supply does not reach limit
    *
    * @param _to Reciver od newly created tokens
    * @param _amount Amount of tokens to be created;
    */
    function mintTokens(address _to, uint256 _amount) onlyOwner public {
        require(supply + _amount <= totalSupplyLimit);
        supply = safeAdd(supply, _amount);
        balances[_to] = safeAdd(balances[_to], _amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
    }

    /**
    * @dev Destroys the amount of tokens and lowers total supply
    *
    * @param _amount Number of tokens user wants to destroy
    */
    function burn(uint _amount) public {
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _amount);
        supply = safeSub(supply, _amount);
        Burn(msg.sender, _amount);
        Transfer(msg.sender, 0x0, _amount);
    }

    /**
    * @dev Saves exidentaly sent tokens to this contract, can be used only by owner
    *
    * @param _tokenAddress Address of tokens smart contract
    * @param _to Where to send the tokens
    * @param _amount The amount of tokens that we are salvaging
    */
    function salvageTokensFromContract(address _tokenAddress, address _to, uint _amount) onlyOwner public {
        ERC20TokenInterface(_tokenAddress).transfer(_to, _amount);
    }

    /**
    * @dev Disables the contract and wipes all the balances, can be used only by owner
    */
    function killContract() public onlyOwner {
        selfdestruct(owner);
    }
}
