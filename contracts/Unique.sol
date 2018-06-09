/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity 0.4.24;

contract Unique {
    
    function isUnique(uint256[] memory arr, uint256 len, uint256 value)
        private pure
        returns(bool)
    {
        for(uint256 i = 0; i < len; i++) {
            if(arr[i] == value) return false;
        }
        return true;
    }

    function uniquify(uint256[] input)
        external payable
        returns(uint256[] memory) 
    {
        uint256[] memory out = new uint256[](input.length);
        
        uint256 ptr = 0;
        for(uint256 i = 0; i < input.length; i++) {
            if(isUnique(out, ptr, input[i])) {
                out[ptr++] = input[i];
            }
        }

        // Construct return value
        uint256[] memory ret = new uint256[](ptr);
        for(i = 0; i < ret.length; i++) {
            ret[i] = out[i];
        }
        return ret;
    }
}
