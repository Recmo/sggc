/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity 0.4.24;

contract Unique {
    
    uint256 constant flag = 0x1e2f1f54a8ec52f1f611639f57a9e0157e21f98ff738f0ea8088d26157b00f1c;
    
    uint256 constant prime = 0x3cb610f2f269903047b2e6af9f5940b3ae7a667c7a5bc30f0e02a1b323a7fee1;
    
    function uniquify(uint[] input)
        public view
        returns(uint[])
    {
        uint256 htl = 2 * input.length;
        uint256[] memory ht = new uint256[](htl);
        
        uint ptr = 0;
        for(uint i = 0; i < input.length; i++) {
            
            uint256 value = input[i];
            uint256 h = (value ^ flag) * prime;
            uint256 index = h % ht.length;
            uint256 iv;
            
            bool found = false;
            assembly {
                iv := mload(add(mul(index, 32), add(32, ht)))
                
                jumpi(iend, iszero(iv))
                iloop:
                    jumpi(ibreak, eq(iv, h))
                    index := mod(add(index, 1), htl)
                    iv := mload(add(mul(index, 32), add(32, ht)))
                    jumpi(iloop, iv)
                    jump(iend)
                
                ibreak:
                    found := 1
                
                iend:
            }
            if (found) {
                continue;
            }
            
            // Insert
            ht[index] = h;
            input[ptr] = value;
            ptr++;
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
