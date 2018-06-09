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
    
    uint256 constant p1 = 0xed6d961a586550c76591d3943b3c6f76b621934aa7ffad3360fac1cf4aa0473f;
    uint256 constant p2 = 0xb7094513c3a0a2641751087acb3855f3c0a80be7260acdf01a49b4661672cb23;
    uint256 constant p3 = 0x1b6d296aa8b7284041b9f0e36895d18399d8026b57a51e5af0ed54c3e03bd3a1;
    
    function uniquify(uint256[] input)
        external payable
        returns(uint256[] memory) 
    {
        uint256 l = input.length;
        if (l < 2) {
            return input;
        }
        uint256[] memory out = new uint256[](l);
        
        uint256 htl = (25 * l) / 10;
        uint256 scale = ((-htl) / htl) + 1;

        uint256[] memory table = new uint256[](htl*3);
        
        uint256 ptr = 0;
        for(uint256 i = 0; i < l; i++) {
            uint256 value = input[i];
            uint256 vhash = value + p1;
            
            uint256 index1 = (vhash * p2) / scale;
            uint256 r = table[index1];
            if (r == 0) {
                out[ptr++] = value;
                table[index1] = vhash;
                continue;
            }
            if (r == vhash) {
                continue;
            }
            
            uint256 index2 = (vhash * p3) / scale;
            r = table[index2];
            if (r == 0) {
                out[ptr++] = value;
                table[index2] = vhash;
                continue;
            }
            if (r == vhash) {
                continue;
            }
            
            index1 += htl;
            r = table[index1];
            if (r == 0) {
                out[ptr++] = value;
                table[index1] = vhash;
                continue;
            }
            if (r == vhash) {
                continue;
            }
            
            index2 += htl;
            r = table[index2];
            if (r == 0) {
                out[ptr++] = value;
                table[index1] = vhash;
                continue;
            }
            if (r == vhash) {
                continue;
            }
            
            index1 += htl;
            r = table[index1];
            if (r == 0) {
                out[ptr++] = value;
                table[index1] = vhash;
                continue;
            }
            if (r == vhash) {
                continue;
            }
            
            index2 += htl;
            r = table[index2];
            if (r == 0) {
                out[ptr++] = value;
                table[index1] = vhash;
                continue;
            }
            if (r == vhash) {
                continue;
            }
            
            index1 += 1;
            r = table[index1];
            if (r == 0) {
                out[ptr++] = value;
                table[index1] = vhash;
                continue;
            }
            if (r == vhash) {
                continue;
            }
            
            index2 += 1;
            r = table[index2];
            if (r == 0) {
                out[ptr++] = value;
                table[index1] = vhash;
                continue;
            }
            if (r == vhash) {
                continue;
            }
            
            index1 += 1;
            r = table[index1];
            if (r == 0) {
                out[ptr++] = value;
                table[index1] = vhash;
                continue;
            }
            if (r == vhash) {
                continue;
            }
            
            index2 += 1;
            r = table[index2];
            if (r == 0) {
                out[ptr++] = value;
                table[index1] = vhash;
                continue;
            }
            if (r == vhash) {
                continue;
            }
            
            index1 += 1;
            r = table[index1];
            if (r == 0) {
                out[ptr++] = value;
                table[index1] = vhash;
                continue;
            }
            if (r == vhash) {
                continue;
            }
            
            index2 += 1;
            r = table[index2];
            if (r == 0) {
                out[ptr++] = value;
                table[index1] = vhash;
                continue;
            }
            if (r == vhash) {
                continue;
            }
            
            index1 += 1;
            r = table[index1];
            if (r == 0) {
                out[ptr++] = value;
                table[index1] = vhash;
                continue;
            }
            if (r == vhash) {
                continue;
            }
            
            index2 += 1;
            r = table[index2];
            if (r == 0) {
                out[ptr++] = value;
                table[index1] = vhash;
                continue;
            }
            if (r == vhash) {
                continue;
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
