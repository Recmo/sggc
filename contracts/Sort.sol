pragma solidity 0.4.24;

contract Sort {
    
    // @author Remco Bloemen <remco@wicked.ventures>
    
    function sort(uint[] input)
        public payable returns(uint[])
    {
        uint256 l = input.length;
        if (l < 2) return input;
        sort(input, 0, int(l - 1));
        return input;
    }

    function sort(uint[] memory input, int lo, int hi)
        internal view
    {
        if (hi - lo == 1) {
            uint lov = input[uint(lo)];
            uint hiv = input[uint(hi)];
            if (lov > hiv) {
                input[uint(lo)] = hiv;
                input[uint(hi)] = lov;
            }
            return;
        }
        
        // partition
        uint pivot = input[uint((lo + hi) / 2)];
        int i = lo;
        int j = hi;
        while (true) {
            uint iv = input[uint(i)];
            uint jv = input[uint(j)];
            while (iv < pivot) {
                i++;
                iv = input[uint(i)];
            }
            while (jv > pivot) {
                j--;
                jv = input[uint(j)];
            }
            if (i >= j) {
                i = j + 1;
                break;
            }
            input[uint(i)] = jv;
            input[uint(j)] = iv;
            i += 1;
            j -= 1;
        }
                
        // Recurse
        if (lo < j) sort(input, lo, j);
        if (i < hi) sort(input, i, hi);
    }
}
