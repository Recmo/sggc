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
        bytes32 needleHash = keccak256(needle);
        uint256 hl = bytes(haystack).length;
        uint256 nl = bytes(needle).length;
        if(nl > hl) {
            return -1;
        }
        uint256 end = hl - nl;
        for(uint i = 0; i <= end; i++) {
            
            bytes32 haydig;
            assembly {
                haydig := keccak256(add(haystack, add(32, i)), nl)
            }
            if(haydig == needleHash) {
                return int(i);
            }
        }
        return -1;
    }
}
