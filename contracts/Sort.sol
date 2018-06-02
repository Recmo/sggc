pragma solidity 0.4.24;

contract Sort {
    
    // @author Remco Bloemen <remco@wicked.ventures>
    
    function sort(uint[] input)
        public payable returns(uint[])
    {
        uint256 l = input.length;
        if (l < 2) return input;
        sort(input, 0, l - 1);
        return input;
    }

    function sort(uint[] memory input, uint256 lo, uint256 hi)
        internal view
    {
        if (hi - lo == 1) {
            uint256 lov = input[lo];
            uint256 hiv = input[hi];
            if (lov > hiv) {
                input[lo] = hiv;
                input[hi] = lov;
            }
            return;
        }
        
        // partition
        uint256 pivot = input[(lo + hi) / 2];
        uint256 i = lo;
        uint256 j = hi;
        while (true) {
            uint iv = input[i];
            uint jv = input[j];
            while (iv < pivot) {
                i++;
                iv = input[i];
            }
            while (jv > pivot) {
                j--;
                jv = input[j];
            }
            if (i >= j) {
                i = j + 1;
                break;
            }
            input[i] = jv;
            input[j] = iv;
            i += 1;
            j -= 1;
        }
                
        // Recurse
        if (lo < j) sort(input, lo, j);
        if (i < hi) sort(input, i, hi);
    }
}
