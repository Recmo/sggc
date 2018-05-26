pragma solidity 0.4.24;

contract BrainFuck {
    
    function () external payable { assembly {
        
        let source
        let eof
        let tp // Tape pointer
        let ip // Input pointer
        let op // Output pointer
        let pp // Program pointer
        
        //
        // Compiler
        //
        source := 0x45
        eof := add(calldataload(0x44), 0x45)
        pp := 2080
        for {} lt(source, eof) {} {
            switch and(calldataload(source), 0xff)
            case 0x3e { // >
                mstore(pp, right)
                pp := add(pp, 32)
            }
            case 0x3c { // <
                mstore(pp, left)
                pp := add(pp, 32)
            }
            case 0x2b { // +
                mstore(pp, incr)
                pp := add(pp, 32)
            }
            case 0x2d { // -
                mstore(pp, decr)
                pp := add(pp, 32)
            }
            case 0x2e { // .
                mstore(pp, output)
                pp := add(pp, 32)
            }
            case 0x2c { // ,
                mstore(pp, input)
                pp := add(pp, 32)
            }
            case 0x5b { // [
                mstore(pp, open)
                pp := add(pp, 64)
            }
            case 0x5d { // ]
                mstore(pp, close)
                pp := add(pp, 64)
            }
            default {}
            source := add(source, 1)
        }
        mstore(pp, exit)
        
        //
        // BrainFuck virtual machine in the Ethereum virtual machine
        //
        
        // Tape is allocated 32...1055 in memory as bytes (use mstore8)
        // Output is allocatd 1056...2079 in memory as bytes (use mstore8)
        // Program is stored as 2080... as uint256 in direct threading
        // Input is kept in calldata. Input pointer is offset by -31 so
        // a byte can be read using and(calldataload(ip), 0xff)
        
    reset: // 0
        tp := 32
        ip := add(calldataload(36), 5) // offset left 31 bytes
        op := 1056
        pp := 2080
        jump(mload(pp))
        
    right: // 1
        tp := add(tp, 1)
        pp := add(pp, 32)
        jump(mload(pp))
    
    left: // 2
        tp := sub(tp, 1)
        pp := add(pp, 32)
        jump(mload(pp))
    
    incr: // 3
        mstore8(tp, add(mload(sub(tp, 31)), 1))
        pp := add(pp, 32)
        jump(mload(pp))
    
    decr: // 4
        mstore8(tp, sub(mload(sub(tp, 31)), 1))
        pp := add(pp, 32)
        jump(mload(pp))
    
    output: // 5
        mstore8(op, mload(sub(tp, 31)))
        op := add(op, 1)
        pp := add(pp, 32)
        jump(mload(pp))
    
    input: // 6
        mstore8(tp, calldataload(ip))
        ip := add(ip, 1)
        pp := add(pp, 32)
        jump(mload(pp))
    
    open: // 7
        jumpi(take, iszero(and(mload(sub(tp, 31)), 0xff))) 
        pp := add(pp, 64)
        jump(mload(pp))
    
    close: // 8
        jumpi(take, and(mload(sub(tp, 31)), 0xff)) 
        pp := add(pp, 64)
        jump(mload(pp))
    
    take:
        pp := mload(add(pp, 32))
        jump(mload(pp))
    
    exit: // 9
        mstore(992, 32)
        mstore(1024, sub(op, 1056))
        return(992, and(sub(op, 961), not(0x1F)))
    }}
}
