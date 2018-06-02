pragma solidity ^0.4.23;

contract Sort {
    
    // @author Remco Bloemen <remco@wicked.ventures>
    
    function () external payable
    {
        assembly {
            mstore(0x40, 0)
        }
        uint256 lo;
        uint256 hi;
        assembly {
            calldatacopy(0, 4, calldatasize)
            lo := 0x40
            hi := add(lo, sub(calldatasize, 0x64))
        }
        sort(lo, hi);
        assembly {
            return(0, sub(calldatasize, 4))
        }
    }
    
    function sort(uint256 lo, uint256 hi)
        internal view
    {
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
