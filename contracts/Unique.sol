/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity ^0.4.23;

contract Unique {
    
    function uniquify(uint[] input) public payable
    {
        assembly {
            
            input := add(input, 32)
            
            let prev1 := 97277402779417326246569501968090644759112326288932996378773065725448860767777
            let prev2 := prev1
            let prev3 := prev1
            let prev4 := prev1
            let filter := 0
            
            let i := input
            let ptr := i
            let endi := add(i, mul(mload(sub(input, 32)), 32))
            
            
            jumpi(oloop_end, eq(i, endi))
            
        oloop:
            {
                let value
                    
                // Read value
                value := mload(i)
                
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
                    j := input
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
        
        oloop_end:
            
            // In-place return
            {
                let start := sub(input, 64)
                mstore(start, 32)
                let length := div(sub(ptr, input), 32)
                mstore(sub(input, 32), length)
                return(start, sub(ptr, start))
            }
        }
    }
    
}
