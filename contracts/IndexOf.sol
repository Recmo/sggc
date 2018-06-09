pragma solidity ^0.4.23;

contract IndexOf {

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
            
            bool found = true;
            for(uint j = 0; j < nl; j++) {
                if(bytes(haystack)[i + j] != bytes(needle)[j]) {
                    found = false;
                    break;
                }
            }
            if(found) {
                return int(i);
            }
        }
        return -1;
    }
}
