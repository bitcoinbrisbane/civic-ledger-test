/**
@title Owned contract - Assigns ownership of contract to creator
@author Naveen Palaniswamy
@copyright Naveen Palaniswamy
*/

pragma solidity ^0.4.19;


contract Owned {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// Constructor function for Owned contract
    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    @notice Function that facilitates transfer of ownership from current owner to a new owner.
            Requires the current owner to be the function executor.
    @param _newOwner New Owner address
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

}
