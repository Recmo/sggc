pragma solidity ^0.4.23;

contract Sort {
    
    function () external payable { assembly {
    
    // function sort(uint[] input) external payable returns(uint[]) { assembly {
        
        // @author Remco Bloemen <remco@wicked.ventures>
        
        // No  unrepeated sorted input
        // Yes repeated sorted input
        // No  unrepeated reverse sorted input
        // Yes repeated reverse sorted input
        // max(input size) = 299
        
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
        
        ////////////////////////////////////////////////////
        // First pass
        ////////////////////////////////////////////////////
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
        
        // Compute scaling factor (twice what it should be, we mask)
        scale := div(add(scale, 255), 256)
        
        ////////////////////////////////////////////////////
        // Second pass: count buckets
        ////////////////////////////////////////////////////
        0x44
    l2:
        // temp1 := sub(510, and(div(calldataload(i), scale), 0xFFFFFE))
        scale dup2 calldataload div 0xfffffe and 510 sub
        // mstore8(add(temp1, 31), add(mload(temp1), 1))
        dup1 mload 1 add swap1 31 add mstore8
        // i := add(i, 32)
        32 add
        // jumpi(l2, lt(i, calldatasize))
        dup1 calldatasize gt l2 jumpi
        pop
        
        ////////////////////////////////////////////////////
        // Bucket pass: compute running sum of the buckets
        ////////////////////////////////////////////////////
        
        0x0001000000000000000000000000000000000000000000000000000000000000
        0x0001000100010001000100010001000100010001000100010001000100010001
        0x220
        0x200 mload 32 mul add dup2 mul dup1 0x200 mstore dup3 swap1 div
        0x1e0 mload 32 mul add dup2 mul dup1 0x1e0 mstore dup3 swap1 div
        0x1c0 mload 32 mul add dup2 mul dup1 0x1c0 mstore dup3 swap1 div
        0x1a0 mload 32 mul add dup2 mul dup1 0x1a0 mstore dup3 swap1 div
        0x180 mload 32 mul add dup2 mul dup1 0x180 mstore dup3 swap1 div
        0x160 mload 32 mul add dup2 mul dup1 0x160 mstore dup3 swap1 div
        0x140 mload 32 mul add dup2 mul dup1 0x140 mstore dup3 swap1 div
        0x120 mload 32 mul add dup2 mul dup1 0x120 mstore dup3 swap1 div
        0x100 mload 32 mul add dup2 mul dup1 0x100 mstore dup3 swap1 div
        0xe0 mload 32 mul add dup2 mul dup1 0xe0 mstore dup3 swap1 div
        0xc0 mload 32 mul add dup2 mul dup1 0xc0 mstore dup3 swap1 div
        0xa0 mload 32 mul add dup2 mul dup1 0xa0 mstore dup3 swap1 div
        0x80 mload 32 mul add dup2 mul dup1 0x80 mstore dup3 swap1 div
        0x60 mload 32 mul add dup2 mul dup1 0x60 mstore dup3 swap1 div
        0x40 mload 32 mul add dup2 mul dup1 0x40 mstore dup3 swap1 div
        0x20 mload 32 mul add dup2 mul dup1 0x20 mstore dup3 swap1 div
        0x0 mload 32 mul add dup2 mul dup1 0x0 mstore dup3 swap1 div
        pop pop pop
        
        ////////////////////////////////////////////////////
        // Third pass: move to buckets
        ////////////////////////////////////////////////////
        temp1 := 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0000
        i := 0x44
    l4: {
        let value  := calldataload(i)
        let bucket := sub(510, and(div(value, scale), 0xFFFFFE))
        let bval   := mload(bucket)
        let addr   := sub(and(bval, 0xFFFF), 32)
        mstore(bucket, or(and(bval, temp1), addr))
        mstore(addr, value)
        i := add(i, 32)
        }
        jumpi(l4, lt(i, calldatasize))
        
        ////////////////////////////////////////////////////
        // Fourth pass (buckets): sort buckets
        ////////////////////////////////////////////////////
        
        // At this point unsorted groups have max 5 elements
        
        i := 510
        addr1 := 0x220
    l5:
        i := sub(i, 2)
        jumpi(last, slt(i, 0))
        addr2 := addr1
        addr1 := and(mload(i), 0xFFFF)
        temp1 := sub(addr1, addr2)
        jumpi(l5, lt(temp1, 64))
        jumpi(sort2, eq(temp1, 64))
        jumpi(sort3, eq(temp1, 96))
        jumpi(sort4, eq(temp1, 128))
        jumpi(sort5, eq(temp1, 160))
        jumpi(sort6, eq(temp1, 192))
        jumpi(sort7, eq(temp1, 224))
        jumpi(sort8, eq(temp1, 256))
        jump(explode)
        jump(l5)
        
    last:
        addr2 := addr1
        addr1 := add(sub(calldatasize, 0x44), 0x220)
        jumpi(done, eq(addr1, addr2))
        temp1 := sub(addr1, addr2)
        jumpi(done, eq(temp1, 32))
        jumpi(sort2, eq(temp1, 64))
        jumpi(sort3, eq(temp1, 96))
        jumpi(sort4, eq(temp1, 128))
        jumpi(sort5, eq(temp1, 160))
        jumpi(sort6, eq(temp1, 192))
        jumpi(sort7, eq(temp1, 224))
        jumpi(sort8, eq(temp1, 256))
        jump(explode)
        jump(l5)
        
    done:
        mstore(sub(0x220, 0x40), 0x20)
        mstore(sub(0x220, 0x20), calldataload(0x24))
        return(sub(0x220, 0x40), sub(calldatasize, 4))
        
    sort2: {
            let a := mload(addr2)
            let b := mload(add(addr2, 32))
            jumpi(end, gt(b, a))
            mstore(addr2, b)
            mstore(add(addr2, 32), a)
        end:
        }
        jump(l5)
    
    sort3: {
            let a := mload(addr2)
            let b := mload(add(addr2, 32))
            let c := mload(add(addr2, 64))
            jumpi(case1, gt(b, a))
            a b =: a =: b
        case1:
            jumpi(case3, gt(c, b))
            b c =: b =: c
            jumpi(case3, gt(b, a))
            a b =: a =: b
        case3:
            mstore(addr2, a)
            mstore(add(addr2, 32), b)
            mstore(add(addr2, 64), c)
        }
        jump(l5)
    
    sort4: // [[1 2][3 4][1 3][2 4][2 3]]
        addr2 96 add mload
        addr2 64 add mload
        addr2 32 add mload
        addr2 mload
        dup1 dup3 lt skip_4_1 jumpi swap1 skip_4_1:
        dup3 dup5 lt skip_4_2 jumpi swap2 swap3 swap2 skip_4_2:
        dup1 dup4 lt skip_4_3 jumpi swap2 skip_4_3:
        dup2 dup5 lt skip_4_4 jumpi swap1 swap3 swap1 skip_4_4:
        dup2 dup4 lt skip_4_5 jumpi swap1 swap2 swap1 skip_4_5:
        addr2 96 add mstore
        addr2 64 add mstore
        addr2 32 add mstore
        addr2 mstore
        jump(l5)

    sort5: // [[1 2][3 4][1 3][2 5][1 2][3 4][2 3][4 5][3 4]]
        addr2 128 add mload
        addr2 96 add mload
        addr2 64 add mload
        addr2 32 add mload
        addr2 mload
        dup1 dup3 lt skip_5_1 jumpi swap1 skip_5_1:
        dup3 dup5 lt skip_5_2 jumpi swap2 swap3 swap2 skip_5_2:
        dup1 dup4 lt skip_5_3 jumpi swap2 skip_5_3:
        dup2 dup6 lt skip_5_4 jumpi swap1 swap4 swap1 skip_5_4:
        dup1 dup3 lt skip_5_5 jumpi swap1 skip_5_5:
        dup3 dup5 lt skip_5_6 jumpi swap2 swap3 swap2 skip_5_6:
        dup2 dup4 lt skip_5_7 jumpi swap1 swap2 swap1 skip_5_7:
        dup4 dup6 lt skip_5_8 jumpi swap3 swap4 swap3 skip_5_8:
        dup3 dup5 lt skip_5_9 jumpi swap2 swap3 swap2 skip_5_9:
        addr2 128 add mstore
        addr2 96 add mstore
        addr2 64 add mstore
        addr2 32 add mstore
        addr2 mstore
        jump(l5)
        
    sort6: // [[1 2][3 4][5 6][1 3][2 5][4 6][1 2][3 4][5 6][2 3][4 5][3 4]]
        addr2 160 add mload
        addr2 128 add mload
        addr2 96 add mload
        addr2 64 add mload
        addr2 32 add mload
        addr2 mload
        dup1 dup3 lt skip_6_1 jumpi swap1 skip_6_1:
        dup3 dup5 lt skip_6_2 jumpi swap2 swap3 swap2 skip_6_2:
        dup5 dup7 lt skip_6_3 jumpi swap4 swap5 swap4 skip_6_3:
        dup1 dup4 lt skip_6_4 jumpi swap2 skip_6_4:
        dup2 dup6 lt skip_6_5 jumpi swap1 swap4 swap1 skip_6_5:
        dup4 dup7 lt skip_6_6 jumpi swap3 swap5 swap3 skip_6_6:
        dup1 dup3 lt skip_6_7 jumpi swap1 skip_6_7:
        dup3 dup5 lt skip_6_8 jumpi swap2 swap3 swap2 skip_6_8:
        dup5 dup7 lt skip_6_9 jumpi swap4 swap5 swap4 skip_6_9:
        dup2 dup4 lt skip_6_10 jumpi swap1 swap2 swap1 skip_6_10:
        dup4 dup6 lt skip_6_11 jumpi swap3 swap4 swap3 skip_6_11:
        dup3 dup5 lt skip_6_12 jumpi swap2 swap3 swap2 skip_6_12:
        addr2 160 add mstore
        addr2 128 add mstore
        addr2 96 add mstore
        addr2 64 add mstore
        addr2 32 add mstore
        addr2 mstore
        jump(l5)
        
    sort7: // [[1 2][0 2][0 1][3 4][5 6][3 5][4 6][4 5][0 4][0 3][1 5][2 6][2 5][1 3][2 4][2 3]]
        addr2 192 add mload
        addr2 160 add mload
        addr2 128 add mload
        addr2 96 add mload
        addr2 64 add mload
        addr2 32 add mload
        addr2 mload
        dup2 dup4 lt skip_7_1 jumpi swap1 swap2 swap1 skip_7_1:
        dup1 dup4 lt skip_7_2 jumpi swap2 skip_7_2:
        dup1 dup3 lt skip_7_3 jumpi swap1 skip_7_3:
        dup4 dup6 lt skip_7_4 jumpi swap3 swap4 swap3 skip_7_4:
        dup6 dup8 lt skip_7_5 jumpi swap5 swap6 swap5 skip_7_5:
        dup4 dup7 lt skip_7_6 jumpi swap3 swap5 swap3 skip_7_6:
        dup5 dup8 lt skip_7_7 jumpi swap4 swap6 swap4 skip_7_7:
        dup5 dup7 lt skip_7_8 jumpi swap4 swap5 swap4 skip_7_8:
        dup1 dup6 lt skip_7_9 jumpi swap4 skip_7_9:
        dup1 dup5 lt skip_7_10 jumpi swap3 skip_7_10:
        dup2 dup7 lt skip_7_11 jumpi swap1 swap5 swap1 skip_7_11:
        dup3 dup8 lt skip_7_12 jumpi swap2 swap6 swap2 skip_7_12:
        dup3 dup7 lt skip_7_13 jumpi swap2 swap5 swap2 skip_7_13:
        dup2 dup5 lt skip_7_14 jumpi swap1 swap3 swap1 skip_7_14:
        dup3 dup6 lt skip_7_15 jumpi swap2 swap4 swap2 skip_7_15:
        dup3 dup5 lt skip_7_16 jumpi swap2 swap3 swap2 skip_7_16:
        addr2 192 add mstore
        addr2 160 add mstore
        addr2 128 add mstore
        addr2 96 add mstore
        addr2 64 add mstore
        addr2 32 add mstore
        addr2 mstore
        jump(l5)
        
    sort8:
        addr2 224 add mload
        addr2 192 add mload
        addr2 160 add mload
        addr2 128 add mload
        addr2 96 add mload
        addr2 64 add mload
        addr2 32 add mload
        addr2 mload
        dup1 dup3 lt skip_8_1 jumpi swap1 skip_8_1:
        dup3 dup5 lt skip_8_2 jumpi swap2 swap3 swap2 skip_8_2:
        dup1 dup4 lt skip_8_3 jumpi swap2 skip_8_3:
        dup2 dup5 lt skip_8_4 jumpi swap1 swap3 swap1 skip_8_4:
        dup2 dup4 lt skip_8_5 jumpi swap1 swap2 swap1 skip_8_5:
        dup5 dup7 lt skip_8_6 jumpi swap4 swap5 swap4 skip_8_6:
        dup7 dup9 lt skip_8_7 jumpi swap6 swap7 swap6 skip_8_7:
        dup5 dup8 lt skip_8_8 jumpi swap4 swap6 swap4 skip_8_8:
        dup6 dup9 lt skip_8_9 jumpi swap5 swap7 swap5 skip_8_9:
        dup6 dup8 lt skip_8_10 jumpi swap5 swap6 swap5 skip_8_10:
        dup1 dup6 lt skip_8_11 jumpi swap4 skip_8_11:
        dup2 dup7 lt skip_8_12 jumpi swap1 swap5 swap1 skip_8_12:
        dup2 dup6 lt skip_8_13 jumpi swap1 swap4 swap1 skip_8_13:
        dup3 dup8 lt skip_8_14 jumpi swap2 swap6 swap2 skip_8_14:
        dup4 dup9 lt skip_8_15 jumpi swap3 swap7 swap3 skip_8_15:
        dup4 dup8 lt skip_8_16 jumpi swap3 swap6 swap3 skip_8_16:
        dup3 dup6 lt skip_8_17 jumpi swap2 swap4 swap2 skip_8_17:
        dup4 dup7 lt skip_8_18 jumpi swap3 swap5 swap3 skip_8_18:
        dup4 dup6 lt skip_8_19 jumpi swap3 swap4 swap3 skip_8_19:
        addr2 224 add mstore
        addr2 192 add mstore
        addr2 160 add mstore
        addr2 128 add mstore
        addr2 96 add mstore
        addr2 64 add mstore
        addr2 32 add mstore
        addr2 mstore
        jump(l5)
        
        
        ////////////////////////////////////////////////////
        ////////////////////////////////////////////////////
        ////////////////////////////////////////////////////
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
    }}
}
