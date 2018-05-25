/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity 0.4.24;

contract IndexOf {
    function equals(string haystack, uint i, string needle) private pure returns(bool) {
        for(uint j = 0; j < bytes(needle).length; j++) {
            if(bytes(haystack)[i + j] != bytes(needle)[j]) {
                return false;
            }
        }
        return true;
    }

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
    function indexOf(string haystack, string needle) public pure returns(int) {
        if(bytes(needle).length > bytes(haystack).length) {
            return -1;
        }
        for(uint i = 0; i <= bytes(haystack).length - bytes(needle).length; i++) {
            if(equals(haystack, i, needle)) {
                return int(i);
            }
        }
        return -1;
    }
}
