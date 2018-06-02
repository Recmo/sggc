pragma solidity 0.4.24;

contract Sort {
    
    // @author Remco Bloemen <remco@wicked.ventures>
    
    function sort(uint[] input) public view returns(uint[]) {
        sort(input, 0, int(input.length - 1));
        return input;
    }

    function sort(uint[] input, int lo, int hi)
        internal view
    {
        if(lo < hi) {
            if (hi - lo <= 2) {
                if (hi - lo == 1) {
                    uint lov = input[uint(lo)];
                    uint hiv = input[uint(hi)];
                    if (lov > hiv) {
                        input[uint(lo)] = hiv;
                        input[uint(hi)] = lov;
                    }
                } else /* if (hi - lo == 2) */ {
                    uint a = input[uint(lo)];
                    uint b = input[uint(lo + 1)];
                    uint c = input[uint(lo + 2)];
                    if (a < b) {
                        if (b < c) {
                            return;
                            // (a, b, c) = (a, b, c);
                        } else {
                            if (a < c) {
                                (a, b, c) = (a, c, b);
                            } else {
                                (a, b, c) = (c, a, b);
                            }
                        }
                    } else {
                        if (a < c) {
                            (a, b, c) = (b, a, c);
                        } else {
                            if (b < c) {
                                (a, b, c) = (b, c, a);
                            } else {
                                (a, b, c) = (c, b, a);
                            }
                        }
                    }
                    input[uint(lo)] = a;
                    input[uint(lo + 1)] = b;
                    input[uint(lo + 2)] = c;
                }
            } else {
                uint alo;
                uint ahi;
                uint slo;
                uint shi;
                assembly {
                    alo := add(add(input, 32), mul(lo, 32))
                    ahi := add(add(input, 32), mul(hi, 32))
                }
                (slo, shi) = partition(alo, ahi);
                assembly {
                    slo := div(sub(slo, add(input, 32)), 32)
                    shi := div(sub(shi, add(input, 32)), 32)
                }
                sort(input, lo, int(slo));
                sort(input, int(shi), hi);
            }
        }
    }
    
    function partition(uint256 lo, uint256 hi)
        internal view
        returns(uint256, uint256)
    {
        assembly {
            let pivot
            let lov
            let hiv
            
            // Compute pivot value
            pivot := and(div(add(lo, hi), 2), not(0x1F))
            pivot := mload(pivot)
            
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
            lo := hi
            hi := add(lo, 32)
        }
        return (lo, hi);
    }
}
