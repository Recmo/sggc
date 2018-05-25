/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity ^0.4.23;

contract Unique {
    
    function uniquify(uint[] input)
        public pure
        returns(uint[])
    {
        assembly {
            
            let prev1 := 97277402779417326246569501968090644759112326288932996378773065725448860767777
            let prev2 := prev1
            let prev3 := prev1
            let prev4 := prev1
            let prev5 := prev1
            let filter := 0
            
            let i := add(input, 32)
            let ptr := i
            let endi := add(i, mul(mload(input), 32))
            for {} lt(i, endi) {} {
                
                // Read value
                let value := mload(i)
                
                // Skip if we saw it recently
                // value != prev <=> value - prev
                if sub(value, prev1) {
                if sub(value, prev2) {
                if sub(value, prev3) {
                if sub(value, prev4) {
                if sub(value, prev5) {
                
                let unique := 1
                
                // Check filter
                let mask := exp(2, and(value, 0xff))
                if and(filter, mask) {
                    
                    // We *may* have seen it before
                    
                    // Check if we saw it before
                    let j := add(input, 32)
                    let endj := ptr
                    for {} lt(j, endj) {} {
                        if eq(mload(j), value) {
                            unique := 0
                            j := endj // break is not supported :(
                                     // in fact, we want to continue the outer
                                     // loop.
                        }
                        j := add(j, 32)
                    }
                }
                
                if unique {
                    // Add to start of list
                    mstore(ptr, value)
                    ptr := add(ptr, 32)
                    
                    // Update filter
                    filter := or(filter, mask)
                    
                    // Push recent adds
                    prev5 := prev4
                    prev4 := prev3
                    prev3 := prev2
                    prev2 := prev1
                    prev1 := value
                }
                
                // end of prev checks
                }}}}}
                
                i := add(i, 32)
            }
            
            // In-place return
            let start := sub(input, 32)
            mstore(start, 32)
            let length := sub(div(sub(ptr, input), 32), 1)
            mstore(input, length)
            return(start, sub(ptr, start))
        }
    }
    
}
