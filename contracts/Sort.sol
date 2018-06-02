pragma solidity ^0.4.23;

contract Sort {
    
    // @author Remco Bloemen <remco@wicked.ventures>
    
    function sort(uint[] input) public view returns(uint[]) {
        if (input.length == 0) {
            return input;
        }
        uint256 lo;
        uint256 hi;
        assembly {
            lo := add(input, 32)
            hi := add(lo, mul(mload(input), 32))
            hi := sub(hi, 32)
        }
        sort(lo, hi);
        return input;
    }

    function sort(uint256 lo, uint256 hi)
        internal view
    {
        if (hi - lo <= 32) {
            if (hi - lo == 32) {
                assembly {
                    let a := mload(lo)
                    let b := mload(hi)
                    if lt(b, a) {
                        mstore(lo, b)
                        mstore(hi, a)
                    }
                }
                return;
            } else  {
                uint256 a;
                uint256 b;
                uint256 c;
                assembly {
                    a := mload(lo)
                    b := mload(add(lo, 32))
                    c := mload(hi)
                }
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
                assembly {
                    mstore(lo, a)
                    mstore(add(lo, 32), b)
                    mstore(hi, c)
                }
                return;
            }
        }
        
        // Partition
        uint256 lolo = lo;
        uint256 hihi = hi;
        assembly {
            let pivot
            let lov
            let hiv
            let i
            let j
            
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
        
        // Recurse
        if (lolo < lo) sort(lolo, lo);
        if (hi < hihi) sort(hi, hihi);
    }
}
