/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity 0.4.24;

contract IndexOf {
    /**
     * @dev Returns the index of the first occurrence of `needle` in `haystack`,
     *      or -1 if `needle` is not found in `haystack`.
     *
     * Input strings may be of any length <2^255.
     *
     * @param haystack The string to search.
     * @param needle The string to search for.
     * @return The index of `needle` in `haystack`, or -1 if not found.
     */
    function indexOf(string haystack, string needle)
        public pure
        returns(int)
    {
        uint256 nl = bytes(needle).length;
        if (nl == 0) {
            return 0;
        }
        uint256 hl = bytes(haystack).length;
        if (nl > hl) {
            return -1;
        }
        
        uint256 selfptr;
        uint256 needleptr;
        assembly {
            selfptr := add(haystack, 32)
            needleptr := add(needle, 32)
        }
        
        bytes32 mask = bytes32(~(2 ** (8 * (32 - nl)) - 1));

        bytes32 needledata;
        assembly { needledata := and(mload(needleptr), mask) }
        
        bytes32 needleHash;
        if (nl > 32) {
            needleHash = keccak256(needle);
        }
        
        uint256 fb = 0x0101010101010101010101010101010101010101010101010101010101010101 * needle[0]
        
        uint256 h = ...;
        
        uint256 matchedBits = (fb & h) | (~fb ^ h);
        
        uint256 matchedBytes = matchedBits;
        matchedBytes &= matchedBytes / 16;
        matchedBytes &= matchedBytes / 8;
        matchedBytes &= matchedBytes / 4;
        matchedBytes &= matchedBytes / 2;
        matchedBytes &=  0x0101010101010101010101010101010101010101010101010101010101010101;
        
        // Count leading zero bytes
        uint256 firstBitSet = matchedBytes & (-matchedBytes);
        uint256 map = 0x000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F;
        uint256 index = (map / firstBitSet) & 0xFF;
        
        
        uint256 ptr = selfptr;
        uint256 end = selfptr + hl - nl;
        bytes32 ptrdata;
        assembly { ptrdata := and(mload(ptr), mask) }

        while (true) {
            while (ptrdata != needledata) {
                if (ptr >= end)
                    return int(-1);
                ptr++;
                assembly { ptrdata := and(mload(ptr), mask) }
            }
            if (nl > 32) {
                bytes32 haydig;
                assembly {
                    haydig := keccak256(ptr, nl)
                }
                if (haydig == needleHash) {
                    return int(ptr - selfptr);
                }
            } else {
                return int(ptr - selfptr);
            }
        }
        return -1;
    }
}
