/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity 0.4.24;

contract Sort {
    /**
     * @dev Sorts a list of integers in ascending order.
     *
     * The input list may be of any length.
     *
     * @param input The list of integers to sort.
     * @return The sorted list.
     */
    function sort(uint[] input) public pure returns(uint[]) {
        sort(input, 0, int(input.length - 1));
        return input;
    }

    function sort(uint[] input, int lo, int hi) internal pure {
        if(lo < hi) {
            int p = partition(input, lo, hi);
            sort(input, lo, p - 1);
            sort(input, p + 1, hi);
        }
    }

    function partition(uint[] input, int lo, int hi) internal pure returns(int) {
        uint pivot = input[uint(hi)];
        int i = lo - 1;
        for(int j = lo; j < hi; j++) {
            if(input[uint(j)] < pivot) {
                i += 1;
                (input[uint(i)], input[uint(j)]) = (input[uint(j)], input[uint(i)]);
            }
        }
        (input[uint(i + 1)], input[uint(hi)]) = (input[uint(hi)], input[uint(i + 1)]);
        return i + 1;
    }
}
