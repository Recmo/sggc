/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity ^0.4.23;

contract Unique {
    
    uint256 constant prime = 97277402779417326246569501968090644759112326288932996378773065725448860767777;
    
    function uniquify(uint[] input)
        public pure
        returns(uint[])
    {
        uint256 prev1 = prime;
        uint256 prev2 = prime;
        uint256 prev3 = prime;
        uint256 prev4 = prime;
        uint256 prev5 = prime;
        uint256 filter = 0;
        uint ptr = 0;
        for(uint i = 0; i < input.length; i++) {
            
            uint256 value = input[i];
            
            assembly {
                
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
                    let end := add(j, mul(ptr, 32))
                    for {} lt(j, end) {} {
                        if eq(mload(j), value) {
                            unique := 0
                            j := end // break is not supported :(
                                     // in fact, we want to continue the outer
                                     // loop.
                        }
                        j := add(j, 32)
                    }
                }
                
                if unique {
                    // Add to start of list
                    let addr := add(mul(ptr, 32), add(input, 32))
                    mstore(addr, value)
                    ptr := add(ptr, 1)
                    
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

            }
        }

        // In-place return
        assembly {
            let start := sub(input, 32)
            mstore(start, 32)
            mstore(input, ptr)
            return(start, mul(add(ptr, 2), 32))
        }
    }
    
}
