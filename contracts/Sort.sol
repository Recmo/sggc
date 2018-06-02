pragma solidity ^0.4.23;

contract Sort {
    
    function () external payable { assembly {
        
        // @author Remco Bloemen <remco@wicked.ventures>
        
        // Copy input to memory
        calldatacopy(0, 4, calldatasize)
        
        // Special case for zero or one value
        jumpi(done, lt(calldatasize, 0x84))
        
        // Recursively sort
        sort(0x40, sub(calldatasize, 0x24))
        function sort(lo, hi) {
            
            let lolo := lo
            let hihi := hi
            let d := sub(hi, lo)
            
            if lt(d, 96) {
                
                // Optimize for two
                if eq(d, 32) {
                    {
                        let a := mload(lo)
                        let b := mload(hi)
                        if lt(b, a) {
                            mstore(lo, b)
                            mstore(hi, a)
                        }
                    }
                    jump(ret)
                }
                
                // Optimize for three
                //if eq(sub(hi, lo), 64) {
                    {
                        let a := mload(lo)
                        let b := mload(add(lo, 32))
                        let c := mload(hi)
                        if lt(b, a) {
                            a
                            b
                            =: a
                            =: b
                        }
                        if lt(c, b) {
                            b
                            c
                            =: b
                            =: c
                            if lt(b, a) {
                                a
                                b
                                =: a
                                =: b
                            }
                        }
                        mstore(lo, a)
                        mstore(add(lo, 32), b)
                        mstore(hi, c)
                    }
                    jump(ret)
                //}
            }
            
            // Partition
            {
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
            if lt(lolo, lo) {
                sort(lolo, lo)
            }
            if lt(hi, hihi) {
                sort(hi, hihi)
            }
            
        ret:
        }
        
        
    done:
        return(0, sub(calldatasize, 4))
    }}
}
