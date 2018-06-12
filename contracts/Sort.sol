pragma solidity ^0.4.23;

contract Sort {
    
    //function () external payable { assembly {
    
    function sort(uint[] input) external payable returns(uint[]) { assembly {
        
        // @author Remco Bloemen <remco@wicked.ventures>
        
        mstore(0x40, 0) // Set all memory to zero
        
        let temp
        let scale
        let i
        
        // Special case for zero or one value
        jumpi(trivial, lt(calldatasize, 0x84))
        
        // Radix sort
        // 80 * 32 = 2560  = size of bucket table
        
        // First pass: find upper bound to values and compute scaling factor
        scale := 0
        for {i := 0x44} lt(i, calldatasize) {i := add(i, 32)} {
            scale := or(scale, calldataload(i))
        }
        scale := div(add(scale, 79), 80)
        
        // Second pass: count buckets (in multipes of 32)
        for {i := 0x44} lt(i, calldatasize) {i := add(i, 32)} {
            let addr := mul(div(calldataload(i), scale), 32)
            mstore(addr, add(mload(addr), 32))
        }
        temp := 2560 // Include write offset
        for {i := 0x00} lt(i, 2560) {i := add(i, 32)} {
            temp := add(temp, mload(i))
            mstore(i, temp)
        }
        
        // Third pass: move to buckets
        for {i := 0x44} lt(i, calldatasize) {i := add(i, 32)} {
            temp := calldataload(i)
            let addr1 := mul(div(temp, scale), 32)
            let addr2 := sub(mload(addr1), 32)
            mstore(addr1, addr2)
            mstore(addr2, temp)
        }
        
        // Fourth pass: sort buckets
        temp := mload(0)
        for {i := 0x20} lt(i, 2560) {i := add(i, 32)} {
            let val := mload(i)
            if lt(temp, sub(val, 32)) {
                sort(temp, sub(val, 32))
            }
            temp := val
        }
        scale := add(sub(calldatasize, 0x44), sub(2560, 32))
        if lt(temp, scale) {
            sort(temp, scale)
        }
        
        //scale := add(sub(calldatasize, 0x44), sub(2560, 32))
        //calldatacopy(2560, 0x44, sub(calldatasize, 0x44))
        //sort(2560, scale)
        
        function sort(lo, hi) {
            
            let lolo := lo
            let hihi := hi
            let d := sub(hi, lo)
            
            if lt(d, 96) {
                
                // Optimize for two
                jumpi(three, gt(d, 32))
                {
                    let a := mload(lo)
                    let b := mload(hi)
                    jumpi(end, gt(b, a))
                    mstore(lo, b)
                    mstore(hi, a)
                end:
                }
                jump(ret)
                
                // Optimize for three
            three:
                {
                    let a := mload(lo)
                    let b := mload(add(lo, 32))
                    let c := mload(hi)
                    jumpi(case1, gt(b, a))
                    a
                    b
                    =: a
                    =: b
                case1:
                    jumpi(case3, gt(c, b))
                    b
                    c
                    =: b
                    =: c
                    jumpi(case3, gt(b, a))
                    a
                    b
                    =: a
                    =: b
                case3:
                    mstore(lo, a)
                    mstore(add(lo, 32), b)
                    mstore(hi, c)
                }
                jump(ret)
            }
            
            // Partition
            {
                let pivot
                let lov
                let hiv
                
                // Compute pivot value
                pivot := and(div(add(lo, hi), 2),
0x0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0
                )
                pivot := mload(pivot)
                
            loop:
                lov := mload(lo)
                hiv := mload(hi)
                jumpi(loend, iszero(lt(lov, pivot)))
            loloop:
                lo := add(lo, 32)
                lov := mload(lo)
                jumpi(loloop, lt(lov, pivot))
            loend:
                jumpi(hiend, iszero(gt(hiv, pivot)))
            hiloop:
                hi := sub(hi, 32)
                hiv := mload(hi)
                jumpi(hiloop, gt(hiv, pivot))
            hiend:
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
            jumpi(sorthi, eq(lolo, lo))
            sort(lolo, lo)
        sorthi:
            jumpi(ret, eq(hi, hihi))
            sort(hi, hihi)
        ret:
        }
        
        
    done:
        mstore(sub(2560, 0x40), 0x20)
        mstore(sub(2560, 0x20), calldataload(0x24))
        return(sub(2560, 0x40), sub(calldatasize, 4))
        
    trivial:
        calldatacopy(0, 4, calldatasize)
        return(0, sub(calldatasize, 4))
    }}
}
