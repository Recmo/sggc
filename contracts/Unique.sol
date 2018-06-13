pragma solidity ^0.4.23;

contract Unique {
    
    /// @author Remco Bloemen <remco@wicked.ventures>
    
    uint256 constant p1 = 0xed6d961a586550c76591d3943b3c6f76b621934aa7ffad3360fac1cf4aa0473f;
    uint256 constant p2 = 0xb7094513c3a0a2641751087acb3855f3c0a80be7260acdf01a49b4661672cb23;
    uint256 constant p3 = 0x1b6d296aa8b7284041b9f0e36895d18399d8026b57a51e5af0ed54c3e03bd3a1;
    
    uint256 constant HTL = 513;
    
    function uniquify(uint256[] input)
        external payable
        returns(uint256[] memory) 
    {
        uint256 l = input.length;
        if (l < 2) {
            return input;
        }
        uint256[] memory out = new uint256[](l);
        
        uint256[HTL] memory table;
        
        uint256 ptr = 0;
        uint256 last1 = p1;
        uint256 last2 = p1;
        for(uint256 i = 0; i < l; i++) {
            uint256 value = input[i];
            if (value == last1) {
                continue;
            }
            if (value == last2) {
                continue;
            }
            last2 = last1;
            last1 = value;
            
            uint256 vhash = value + p1;
            
            uint256 index1 = vhash % HTL;
            uint256 r = table[index1];
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
            
            revert();
            
        }

        // Construct return value
        uint256[] memory result = new uint256[](ptr);
        for(i = 0; i < ptr; i++) {
            result[i] = out[i];
        }
        return result;
    }
}
