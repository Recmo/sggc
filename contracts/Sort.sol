pragma solidity ^0.4.23;

contract Sort {
    
    function () external payable { assembly {
    
    // function sort(uint[] input) external payable returns(uint[]) { assembly {
        
        // @author Remco Bloemen <remco@wicked.ventures>
        
        // No  unrepeated sorted input
        // Yes repeated sorted input
        // No  unrepeated reverse sorted input
        // Yes repeated reverse sorted input
        
        mstore(0x40, 0) // Set all memory to zero
        
        let temp1
        let temp2
        let addr1
        let addr2
        let scale
        let i
        
        // Special case for zero or one value
        jumpi(trivial, lt(calldatasize, 0x84))
        
        // Radix sort
        // Size of bucket table:
        //                                      Competition
        //  60 * 32 = 1920    gas: 337644        208971
        //  80 * 32 = 2560    gas: 323985        194330
        // 100 * 32 = 3200    gas: 321639        193251
        // 110 * 32 = 3520    gas: 318570        190720
        // 120 * 32 = 3840    gas: 315349        186302
        // 130 * 32 = 4160    gas: 314771        188363
        // 140 * 32 = 4480    gas: 314657        186329
        // 160 * 32 = 5120    gas: 317469        189141
        // 30 + 256 * 2 = 542
        // 64
        
        // First pass:
        // * find upper bound to values
        // * check for sorted input
        // * check for reverse sorted input
        temp1 := calldataload(0x44)
        scale := temp1
        i := 0x64
        addr1 := 1
        addr2 := 1
    l1:
        temp2 := calldataload(i)
        addr1 := and(addr1, slt(sub(temp1, 1), temp2))
        addr2 := and(addr2, gt(add(temp1, 1), temp2))
        scale := or(scale, temp2)
        temp1 := temp2
        i := add(i, 32)
        jumpi(l1, lt(i, calldatasize))
        jumpi(trivial, addr1)
        jumpi(reverse, addr2)
        
        // max(input size) = 299
        
        // Compute scaling factor (twice what it should be, we mask)
        scale := div(add(scale, 63), 64)
        
        // Second pass: count buckets (in multipes of 32)
        i := 0x44
    l2:
        temp1 := and(div(calldataload(i), scale), 0x1FE)
        mstore8(add(temp1, 31), add(mload(temp1), 32))
        i := add(i, 32)
        jumpi(l2, lt(i, calldatasize))
        
        // Bucket pass: compute running sum of the buckets
        // TODO: SWAR
        temp1 := 0x1000 // Add offset to write area
        i := 0x00
    l3:
        
        temp2 := mload(i)
        temp1 := and(add(temp1, temp2), 0xFFFF)
        temp2 := or(and(temp2, 
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
        ), temp1)
        mstore(i, temp2)
        i := add(i, 2)
        jumpi(l3, lt(i, 64))
        
        // Third pass: move to buckets
        i := 0x44
    l4:
        temp1 := calldataload(i)
        addr1 := and(div(temp1, scale), 0x1FE)
        temp2 := mload(addr1)
        addr2 := and(sub(temp2, 32), 0xFFFF)
        mstore(addr1, or(and(temp2,
        0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
        ), addr2))
        mstore(addr1, addr2)
        mstore(addr2, temp1)
        i := add(i, 32)
        jumpi(l4, lt(i, calldatasize))
        
        addr1 := 0x1000
        addr2 := add(sub(calldatasize, 0x44), sub(0x1000, 32))
        sort(addr1, addr2)
        jump(done)
        
        // Fourth pass (buckets): sort buckets
        addr2 := and(mload(0), 0xFFFF)
        i := 0x02
    l5:
        addr1 := and(mload(i), 0xFFFF)
        jumpi(l5n, lt(addr2, sub(addr1, 32)))
        addr2 := addr1
        i := add(i, 2)
        jumpi(l5, lt(i, 64))
        jump(l5e)
    l5n:
        sort(addr2, sub(addr1, 32))
        addr2 := addr1
        i := add(i, 32)
        jumpi(l5, lt(i, 64))
    l5e:
        addr1 := add(sub(calldatasize, 0x44), sub(542, 32))
        jumpi(l5s, lt(addr2, addr1))
        jump(done)
        
    l5s:
        sort(addr2, addr1)
        // jump(done)
        
    done:
        mstore(sub(0x1000, 0x40), 0x20)
        mstore(sub(0x1000, 0x20), calldataload(0x24))
        return(sub(0x1000, 0x40), sub(calldatasize, 4))
        
    trivial:
        calldatacopy(0, 4, calldatasize)
        return(0, sub(calldatasize, 4))
        
    reverse:
        calldatacopy(0, 4, 0x40)
        i := 0x44
        temp1 := sub(calldatasize, 36)
        
    lr:
        mstore(temp1, calldataload(i))
        i := add(i, 32)
        temp1 := sub(temp1, 32)
        jumpi(lr, lt(i, calldatasize))
        
        return(0, sub(calldatasize, 4))
        
    explode:
        selfdestruct(0)
        
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
        
    }}
}
