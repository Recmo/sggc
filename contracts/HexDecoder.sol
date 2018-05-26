pragma solidity ^0.4.23;

contract HexDecoder {
    
    function () payable { assembly {
        
        let o := 64
        let i := 68
        let a
        
        jumpi(empty, eq(i, calldatasize))
        
    loop:
        a := calldataload(i)
        
        // Convert characters to nibbles
        a := add(and(a,
0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F
        ), mul(9, and(div(a, 64),
0x0101010101010101010101010101010101010101010101010101010101010101
        )))
        
        // Shuffle odd nibbles to consecutive bytes
        a := and(div(mul(a, 0x11), 0x10),
0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF
        )
        a := and(div(mul(a, 0x101), 0x100),
0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
        )
        a := and(div(mul(a, 0x10001), 0x10000),
0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF
        )
        a := and(div(mul(a, 0x100000001), 0x100000000),
0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF
        )
        a := mul(a, 0x100000000000000010000000000000000)
        
        // Store
        mstore(o, a)
        o := add(o, 16)
        
        // Loop
        i := add(i, 32)
        jumpi(loop, lt(i, calldatasize))
        
    exit:
        let ol := div(calldataload(36), 2)
        mstore(0, 32)
        mstore(32, ol)
        
        // Add 64 to ol and round to the next multiple of 32
        return(0, and(add(ol, 95),
            0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE0
        ))
        
    empty:
        mstore(0, 32)
        return(0, 64)
    }}
}
