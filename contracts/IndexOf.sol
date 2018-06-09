pragma solidity ^0.4.23;

contract IndexOf {
    
    /// @author Remco Bloemen <remco@wicked.ventures>

    function indexOf(string haystack, string needle)
        public payable
        returns(int256)
    {
        uint256 hl = bytes(haystack).length;
        uint256 nl = bytes(needle).length;
        if(nl > hl) {
            return -1;
        }
        if(nl == 0) {
            return 0;
        }
        
        // Boyer–Moore–Horspool
        
        // Bad character rule
        uint256[256] memory badChar;
        uint256[] memory needle32 = new uint256[](nl);
        
        for (uint256 i = 0; i < nl; i++) {
            // Needle lookup table
            uint256 s = read1(needle, i);
            needle32[i] = s;
            
            // Bad character table
            if (i != nl - 1) {
                badChar[s] = i + 1;
            }
        }
        
        s = 0;
        while (s <= (hl - nl)) {
            i = nl - 1;
            while (needle32[i] == read1(haystack, s + i)) {
                if(i == 0) {
                    return int256(s);
                } 
                i--;
            }
            uint256 skip = badChar[read1(haystack, s + nl - 1)] - 1;
            s += nl - skip - 1;
        }
        return -1;
    }
    
    function read1(string memory a, uint256 i)
        private pure
        returns (uint8)
    {
        return uint8(bytes(a)[i]);
    }
}
