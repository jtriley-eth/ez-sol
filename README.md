# ez-sol

The Solidity Standard Library you never had or wanted.

---

## Bitmap

Bitmap custom type (aliased to uint256). This creates a high level interface for interacting with
bitmaps in a developer-friendly way.

```solidity
pragma solidity ^0.8.13;

import {Bitmap} from "ez-sol/Bitmap.sol";

contract MyCon {
    Bitmap internal map;
    uint8 constant firstBitIndex = 0;

    function setFirstBitToTrue() public {
        map = map.set(firstBitIndex);
    }
}
```

### Bitmap Operations

Where `b`, `b0`, and `b1` are of type `Bitmap`:

| code                  | operation                               |
| --------------------- | --------------------------------------- |
| `b = b.set(n)`        | set bit `n` of `b` to 1                 |
| `b = b.cleart(n)`     | set bit `n` of `b` to 0                 |
| `bool x = b.get(n)`   | true if bit `n` of `b` is 1, else false |
| `b0 = b0.and(b1)`     | bitwise `and` of `b0` and `b1`          |
| `b0 = b0.or(b1)`      | bitwise `or` of `b0` and `b1`           |
| `b0 = b0.xor(b1)`     | bitwise `xor` of `b0` and `b1`          |
| `b = b.not()`         | bitwise `not` of `b`                    |
| `bool x = b0.eq(b1)`  | true if `b0` equals `b1`, else false    |
| `bool x = b.iszero()` | true if `b` is empty, else false        |

---

## Contract

Contract custom type (aliased to address). This creates an alternative to the `address.*call`
interface for making external calls.

We declare a custom type, CallResult (aliased to uint256), which stores both the "success" boolean
_and_ the memory pointer to the returned data.

We roughly follow the `Result<T, E>` type in
[Rust](https://doc.rust-lang.org/std/result/enum.Result.html). This allows for a more ergonomic
alterantive to the external low-level call currently used in Solidity.

```solidity
pragma solidity ^0.8.13;

import {Contract} from "ez-sol/Contract.sol";

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
}

contract MyCon {

    address tokenAddress;
    Contract tokenContract;

    // -- snip --

    function usesOldApi() external view returns (uint256) {
        bytes memory callData = abi.encodeCall(IERC20.balanceOf, ());

        (bool success, bytes memory returnData) = tokenAddress.call(callData);

        require(success, "balance failed");

        return abi.decode(returnData, (uint256));
    }

    function useNewApi() external view returns (uint256) {
        bytes memory callData = abi.encodeCall(IERC20.balanceOf, ());

        bytes memory returnData = tokenContract
            .call(callData)
            .expect("balance failed");

        return abi.decode(returnData, (uint256));
    }
}
```

### Call Operations

Where `c` is of type `Contract` and `cd` is of type `bytes`.

| code                  | operation                |
| --------------------- | ------------------------ |
| `c.callWithValue(cd)` | external call with ether |
| `c.call(cd)`          | external call            |
| `c.staticcall(cd)`    | external staticcall      |

### CallResult Operations

Where `c` is of type `Contract` and `cd` is of type `bytes`.

| code                     | operation                                       |
| ------------------------ | ----------------------------------------------- |
| `c.call(cd).status()`    | Returns `ResultType.Ok` or `ResultType.Err`     |
| `c.call(cd).data()`      | Returns the returndata as bytes                 |
| `c.call(cd).isOk()`      | Returns true if the call succeeded              |
| `c.call(cd).isErr()`     | Returns true if the call failed                 |
| `c.call(cd).unwrap()`    | Reverts if call failed, bubbling up revert data |
| `c.call(cd).expect(msg)` | Reverts with custom string if call failed       |
