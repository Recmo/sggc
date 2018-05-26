/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity 0.4.24;

contract IndexOf {

    uint256 constant firstBits = 0x0101010101010101010101010101010101010101010101010101010101010101;

    function indexOf(string haystack, string needle)
        public pure
        returns(int)
    {
        bytes memory n = bytes(needle);
        uint256 nl = n.length;
        if (nl == 0) {
            return 0;
        }
        bytes memory h = bytes(haystack);
        uint256 hl = h.length;
        if (nl > hl) {
            return -1;
        }
        bytes32 needleHash = keccak256(n);
        
        // Compute first byte vector
        uint256 fb = uint256(n[0]) * firstBits;
        
        uint256 end = hl - nl;
        uint256 i = 0;
        while (i <= end) {
            
            // Compare for equality
            bytes32 haydig;
            assembly {
                haydig := keccak256(add(h, add(32, i)), nl)
            }
            if(haydig == needleHash) {
                return int(i);
            }
            
            // Find next potential matching point
            uint256 value;
            assembly {
                value := mload(add(h, add(32, i)))
            }
            uint256 matchb = ~(value ^ fb);
            matchb &= matchb / 16;
            matchb &= matchb / 4;
            matchb &= matchb / 2;
            matchb &= firstBits;
            
            if (matchb == 0) {
                i += 32;
                continue;
            }
            if (matchb < 2**128) {
                i += 16;
            }
            matchb |= matchb / 2**128;
            matchb &= 2**128 - 1;
            if (matchb < 2**64) {
                i += 8;
            }
            matchb |= matchb / 2**64;
            matchb &= 2**64 - 1;
            if (matchb < 2**32) {
                i += 4;
            }
            matchb |= matchb / 2**32;
            matchb &= 2**32 - 1;
            if (matchb < 2**16) {
                i += 2;
            }
            matchb |= matchb / 2**8;
            matchb &= 2**8 - 1;
            if (matchb < 2**16) {
                i++;
            }
        }
        return -1;
    }
}
