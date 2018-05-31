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
            sort(input, lo, p);
            sort(input, p + 1, hi);
        }
    }

    function partition(uint[] input, int lo, int hi) internal pure returns(int) {
        uint pivot = input[uint((lo + hi) / 2)];
        int i = lo;
        int j = hi;
        while (true) {
            while (input[uint(i)] < pivot) {
                i += 1;
            }
            while (input[uint(j)] > pivot) {
                j -= 1;
            }
            if (i >= j) {
                return j;
            }
            (input[uint(i)], input[uint(j)]) = (input[uint(j)], input[uint(i)]);
        }
    }
    
    function insertionSort(uint[] input, int lo, int hi) internal pure {
        int i = lo + 1;
        while (i <= hi) {
            uint key = input[uint(i)];
            int j = i - 1;
            while(j >= lo && input[uint(j)] > key) {
                input[uint(j + 1)] = input[uint(j)];
                j -= 1;
            }
            input[uint(j + 1)] = key;
            i++;
        }
    }
}
