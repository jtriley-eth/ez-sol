// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {Contract} from "src/Contract.sol";
import {Storage} from "test/mock/Storage.sol";

uint256 constant initValue = 1;
uint256 constant updateValue = 2;

contract ContractTest is Test {

    Contract store;

    function setUp() public {
        store = Contract.wrap(address(new Storage(initValue)));
    }

    function testStaticcall() public {
        bytes memory callData = abi.encodeCall(Storage.getValue, ());

        uint256 value = abi.decode(store.staticcall(callData).expect("value() fail"), (uint256));

        assertEq(value, initValue);
    }

    function testCall() public {
        store.call(abi.encodeCall(Storage.setValue, (updateValue))).expect("setvalue(2) fail");

        bytes memory staticcallData = abi.encodeCall(Storage.getValue, ());

        assertEq(
            abi.decode(store.staticcall(staticcallData).expect("value() fail"), (uint256)),
            updateValue
        );
    }

    function testCallWithReturn() public {
        bytes memory returnData = store.call(
            abi.encodeCall(Storage.setValueReturnOld, (updateValue))
        ).expect("setvalue(2) fail");

        assertEq(abi.decode(returnData, (uint256)), initValue);
    }

    function testPayableCall() public {
        store.callWithValue(
            updateValue,
            abi.encodeCall(Storage.setValuePayable, ())
        ).expect("setvalue(2) fail");

        bytes memory staticcallData = abi.encodeCall(Storage.getValue, ());

        assertEq(
            abi.decode(store.staticcall(staticcallData).expect("value() fail"), (uint256)),
            updateValue
        );
    }
}
