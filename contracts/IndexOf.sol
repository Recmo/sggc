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
        
        // Boyer-Moore
        uint256[256] memory badChar;
        for(uint256 i = 0; i < 256; i++) {
            badChar[i] = uint256(-1);
        }
        for (i = 0; i < nl; i++) {
            badChar[read1(needle, i)] = i;
        }
        
        uint256 s = 0;
        while (s <= (hl - nl)) {
            i = nl - 1;
            while (i <= nl && read1(needle, i) == read1(haystack, s + i)) {
                i--;
            }
            if (i > nl) {
                return int256(s);
            } else {
                uint256 skip = i - badChar[read1(haystack, s + i)];
                
                if (skip > 1 && skip < hl) {
                    s += skip;
                } else {
                    s += 1;
                }
            }
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
