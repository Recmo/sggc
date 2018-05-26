pragma solidity ^0.4.23;

contract HexDecoder {
    
    function () payable {
        
        uint256 ol;
        assembly {
            ol := div(calldataload(36), 2)
        }
        bytes memory output = new bytes(ol);
        
        for(uint i = 0; i < ol; i += 16) {
            
            uint256 a;
            assembly {
                
                let iaddr := add(mul(i, 2), 68)
                a := calldataload(iaddr)
                
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
                let oaddr := add(i, add(output, 32))
                mstore(oaddr, a)
            }
        }
        assembly {
            mstore(sub(output, 32), 32)
            
            // Add 64 to ol and round to the next multiple of 32
            return(sub(output, 32), and(add(ol, 95),
                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE0
            ))
        }
    }
}
