pragma solidity ^0.4.23;

contract HexDecoder {
    
    function () payable { assembly {

        jumpi(empty, eq(68, calldatasize))
        
        let o := 64
        let i := 68
        let a
        
    loop:
        a := calldataload(i)
        
        // Convert characters to nibbles
        a := add(and(a,
0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F
        ), mul(9, and(div(a, 64),
0x0101010101010101010101010101010101010101010101010101010101010101
        )))
        
        // Shuffle odd nibbles to consecutive bytes
        a := and(mul(a, 0x11),
0x0FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0
        )
        a := and(mul(a, 0x101),
0x0FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF000
        )
        a := and(mul(a, 0x10001),
0x0FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF0000000
        )
        a := and(mul(a, 0x100000001),
0x0FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF000000000000000
        )
        a := mul(a, 0x100000000000000010)
        
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
        return(0, and(add(ol, 95), 0xFFFFFFFFFFFFFFFE0))
        
    empty:
        mstore(0, 32)
        return(0, 64)
        
    }}
}
