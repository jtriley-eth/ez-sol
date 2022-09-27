// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Storage {
    uint256 internal _value;

    constructor(uint256 initValue) {
        _value = initValue;
    }

    function getValue() public view returns (uint256) {
        return _value;
    }

    function setValue(uint256 v) public {
        _value = v;
    }

    function setValueReturnOld(uint256 a) public returns (uint256 b) {
        b = _value;
        _value = a;
    }

    function setValuePayable() public payable {
        _value = msg.value;
    }
}
