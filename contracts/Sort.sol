pragma solidity 0.4.24;

contract Sort {
    
    // @author Remco Bloemen <remco@wicked.ventures>
    
    function sort(uint[] input) public view returns(uint[]) {
        
        // 999377 in competition
        sort(input, 0, int(input.length - 1));
        return input;
    }

    function sort(uint[] input, int lo, int hi)
        internal view
    {
        if(lo < hi) {
            if (hi - lo == 1) {
                uint lov = input[uint(lo)];
                uint hiv = input[uint(hi)];
                if (lov > hiv) {
                    input[uint(lo)] = hiv;
                    input[uint(hi)] = lov;
                }
            } else {
                int slo;
                int shi;
                (slo, shi) = partition(input, lo, hi);
                sort(input, lo, slo);
                sort(input, shi, hi);
            }
        }
    }

    function partition(uint[] input, int lo, int hi)
        internal view
        returns(int, int)
    {
        assert(lo >= 0);
        assert(uint(lo) < input.length);
        assert(hi >= 0);
        assert(uint(hi) < input.length);
        assert(lo < hi);
        assembly {
            let pivot
            let lov
            let hiv
            
            // Compute pivot value
            pivot := div(add(lo, hi), 2)
            pivot := add(add(input, 32), mul(pivot, 32))
            pivot := mload(pivot)
            
            lo := add(add(input, 32), mul(lo, 32))
            hi := add(add(input, 32), mul(hi, 32))
            
        loop:
            lov := mload(lo)
            hiv := mload(hi)
            for {} lt(lov, pivot) {} {
                lo := add(lo, 32)
                lov := mload(lo)
            }
            for {} gt(hiv, pivot) {} {
                hi := sub(hi, 32)
                hiv := mload(hi)
            }
            jumpi(end, iszero(lt(lo, hi)))
            mstore(lo, hiv)
            mstore(hi, lov)
            lo := add(lo, 32)
            hi := sub(hi, 32)
            jump(loop)
            
        end:
            lo := div(sub(hi, add(input, 32)), 32)
            hi := add(lo, 1)
        }
        assert(lo >= 0);
        assert(uint(lo) < input.length);
        assert(hi >= 0);
        assert(uint(hi) < input.length);
        assert(lo < hi);
        return (lo, hi);
    }
    
    function insertionSort(uint[] input, int lo, int hi)
        internal view
    {
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
