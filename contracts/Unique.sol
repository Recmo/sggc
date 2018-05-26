/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity 0.4.24;

contract Unique {
    
    uint256 constant prime = 97277402779417326246569501968090644759112326288932996378773065725448860767777;
    
    function uniquify(uint[] input)
        public pure
        returns(uint[])
    {
        uint256 filter = 0;
        uint ptr = 0;
        for(uint i = 0; i < input.length; i++) {
            
            uint256 value = input[i];
            bool unique = true;
            
            // Hash value (high bytes of product with prime)
            uint256 h;
            assembly {
                // Better quality
                // h := byte(0, mul(value, 97277402779417326246569501968090644759112326288932996378773065725448860767777))
                
                // Faster
                h := and(value, 0xff)
            }
            
            // Check filter
            uint256 mask = 2**(value & 0xff);
            if (filter & mask != 0) {
                
                // We *may* have seen it before
                
                // Check if seen before
                for(uint j = 0; j < ptr; j++) {
                    if(input[j] == value) {
                        unique = false;
                        break;
                    }
                }
                
            }
            
            // Add to start of list
            if (unique) {
                input[ptr] = value;
                ptr++;
                filter |= mask;
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
