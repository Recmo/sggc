pragma solidity 0.4.24;

contract Sort {
    
    // @author Remco Bloemen <remco@wicked.ventures>
    
    uint256 constant RADIX = 80;
    
    function sort(uint[] input)
        external payable returns(uint[])
    {
        uint256 l = input.length;
        if (l < 2) return input;
        
        uint256[] memory counts = new uint256[](RADIX);
        uint256[] memory output = new uint256[](input.length);
        
        // First pass: find upper bound to values and compute scaling factor
        uint256 scale = RADIX;
        for(uint256 i = 0; i < input.length; i++) {
            scale |= input[i];
        }
        scale = (scale + RADIX - 1) / RADIX;
        
        // Second pass: count buckets
        for(i = 0; i < input.length; i++) {
            counts[input[i] / scale]++;
        }
        uint256 acc = counts[0];
        for(i = 1; i < RADIX; i++) {
            acc += counts[i];
            counts[i] = acc;
        }
        
        // Third pass: move to buckets
        for(i = 0; i < input.length; i++) {
            uint256 val = input[i];
            uint256 bucket = val / scale;
            uint256 idx = counts[bucket] - 1;
            counts[bucket] = idx;
            output[idx] = val;
        }
        
        // Fourth pass: sort buckets
        for(i = 0; i < RADIX - 1; i++) {
            sort(output, counts[i], counts[i + 1] - 1);
        }
        sort(output, counts[RADIX - 1], output.length - 1);
        
        return output;
    }
    
    function sort(uint[] memory input, uint256 lo, uint256 hi)
        internal view
    {
        if (hi <= lo) return;
        if (hi >= input.length) return;
        
        uint256 d = hi - lo;
        if (d < 3) {
            if (d == 0) {
                return;
            }
            // Optimize for two values
            if (d == 1) {
                uint256 a = input[lo];
                uint256 b = input[hi];
                if (b < a) {
                    input[lo] = b;
                    input[hi] = a;
                }
                return;
            }
            
            // Optimize for three values
            a = input[lo];
            b = input[lo + 1];
            uint256 c = input[hi];
            if (a < b) {
                if (b < c) {
                    return;
                } else {
                    if (c < a) {
                        input[lo] = c;
                        input[lo + 1] = a;
                        input[hi] = b;
                        return;
                    } else {
                        input[lo + 1] = c;
                        input[hi] = b;
                        return;
                    }
                }
            } else {
                if (a < c) {
                    input[lo] = b;
                    input[lo + 1] = a;
                    input[hi] = c;
                    return;
                } else {
                    if (b < c) {
                        input[lo] = b;
                        input[lo + 1] = c;
                        input[hi] = a;
                        return;
                    } else {
                        input[lo] = c;
                        input[lo + 1] = b;
                        input[hi] = a;
                        return;
                    }
                }
            }
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
