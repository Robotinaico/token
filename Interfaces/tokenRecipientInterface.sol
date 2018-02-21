pragma solidity ^0.4.13;

contract tokenRecipientInterface {
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData);
}
