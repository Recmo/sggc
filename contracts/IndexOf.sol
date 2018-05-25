/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity 0.4.24;

contract IndexOf {
    function equals(string haystack, uint i, string needle)
        private pure
        returns(bool)
    {
        uint256 nl = bytes(needle).length;
        for(uint j = 0; j < nl; j++) {
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
    function indexOf(string haystack, string needle)
        public pure
        returns(int)
    {
        uint256 hl = bytes(haystack).length;
        uint256 nl = bytes(needle).length;
        if(nl > hl) {
            return -1;
        }
        uint256 end = hl - nl;
        for(uint i = 0; i <= end; i++) {
            if(equals(haystack, i, needle)) {
                return int(i);
            }
        }
        return -1;
    }
}
