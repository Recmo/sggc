/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity ^0.4.23;

contract Unique {
    
    function () external payable
    {
        assembly {
            
            let l := calldataload(36)
            jumpi(main, l)
            mstore(0, 32)
            mstore(32, 0)
            return(0, 64)
            
        main:
            let prev1 := 97277402779417326246569501968090644759112326288932996378773065725448860767777
            let prev2 := prev1
            let prev3 := prev1
            let prev4 := prev1
            let filter := 0
            let endi := add(68, mul(l, 32))
            let ptr := 64
            let i := 68
            
        oloop:
            {
                let value
                    
                // Read value
                value := calldataload(i)
                
                // Skip if we saw it recently
                // value != prev <=> value - prev
                jumpi(oblock_end, eq(value, prev1))
                jumpi(oblock_end, or(or(
                    eq(value, prev2),
                    eq(value, prev3)),
                    eq(value, prev4)))
                {
                    let mask
                    let j
                    
                    // Check filter if we have not seen it before
                    mask := exp(2, and(value, 0xff))
                    jumpi(unique, iszero(and(filter, mask)))
                    
                    // We *may* have seen it before
                    
                    // Check if we saw it before
                    j := 64
                    jumpi(unique, eq(j, ptr))

                iloop:
                    jumpi(iblock_end, eq(mload(j), value))
                    j := add(j, 32)
                    jumpi(iloop, lt(j, ptr))
                
                unique:
                    // Add to start of list
                    mstore(ptr, value)
                    ptr := add(ptr, 32)
                    
                    // Update filter
                    filter := or(filter, mask)
                    
                    // Push recent adds
                    prev4 := prev3
                    prev3 := prev2
                    prev2 := prev1
                    prev1 := value
                
                iblock_end:
                }
            oblock_end:
            }
                
        oloop_continue:
            i := add(i, 32)
            jumpi(oloop, lt(i, endi))
            
        // oloop_end:
            mstore(0, 32)
            mstore(32, div(sub(ptr, 64), 32))
            return(0, ptr)
        }
    }
    
}
