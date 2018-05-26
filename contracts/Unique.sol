/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity 0.4.24;

contract Unique {
    
    function uniquify(uint[] input)
        public pure
        returns(uint[])
    {
        uint ptr = 0;
        for(uint i = 0; i < input.length; i++) {
            
            uint256 value = input[i];
            
            // Check if seen before
            bool unique = true;
            for(uint j = 0; j < ptr; j++) {
                if(input[j] == value) {
                    unique = false;
                    break;
                }
            }
            
            // Add to start of list
            if (unique) {
                input[ptr] = value;
                ptr++;
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
