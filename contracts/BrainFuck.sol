pragma solidity ^0.4.23;

contract BrainFuck {
    
    function () external payable { assembly {
        
        // This canceles out the "mstore(0x40, 0x80)" that
        // solc likes to inject. It even gets partially optimized.
        mstore(0x40, 0x00)
        
        let tp // Tape pointer      / stack pointer
        let ip // Input pointer     / source pointer
        let op // Output pointer    / temp
        let pp // Program pointer
        
        //
        // Compiler
        //
        
        // Create lookup table (512 bytes)
        // From high to low since we have overlaping writes
        // XORed with cnop make cnop the default entry
        mstore(mul(0x5d, 2), xor(cclose, cnop))
        mstore(mul(0x5b, 2), xor(copen, cnop))
        mstore(mul(0x3e, 2), xor(cright, cnop))
        mstore(mul(0x3c, 2), xor(cleft, cnop))
        mstore(mul(0x2e, 2), xor(coutput, cnop))
        mstore(mul(0x2d, 2), xor(cdecr, cnop))
        mstore(mul(0x2c, 2), xor(cinput, cnop))
        mstore(mul(0x2b, 2), xor(cincr, cnop))
        mstore(mul(0x00, 2), xor(ceof, cnop))

        ip := 0x44 // source pointer offset left 31 bytes and ones for the first increment
        pp := 2080
        tp := 512  // stack pointer
        
    cnext:
        ip := add(ip, 1)
        op := and(calldataload(ip), 0xFF)
        jump(xor(cnop, and(mload(add(op, op)), 0xFFFF)))
        
    cnop:
        jump(cnext)
        
    cright:
        mstore(pp, right)
        pp := add(pp, 32)
        jump(cnext)
    
    cleft:
        mstore(pp, left)
        pp := add(pp, 32)
        jump(cnext)
    
    cincr:
        mstore(pp, incr)
        pp := add(pp, 32)
        jump(cnext)
    
    cdecr:
        mstore(pp, decr)
        pp := add(pp, 32)
        jump(cnext)
    
    coutput:
        mstore(pp, output)
        pp := add(pp, 32)
        jump(cnext)
    
    cinput:
        mstore(pp, input)
        pp := add(pp, 32)
        jump(cnext)
    
    copen:
        mstore(pp, open)
        pp := add(pp, 32)
        pp := add(pp, 32)
        mstore(tp, pp)
        tp := add(tp, 32)
        jump(cnext)
    
    cclose:
        mstore(pp, close)
        pp := add(pp, 32)
        tp := sub(tp, 32)
        op := mload(tp) 
        mstore(pp, op)
        pp := add(pp, 32)
        mstore(sub(op, 32), pp)
        mstore(tp, 0)
        jump(cnext)
    
    ceof:
        mstore(pp, exit)
        
        // Clear lookup table
        mstore(mul(0x00, 2), 0)
        mstore(mul(0x2c, 2), 0)
        mstore(mul(0x3c, 2), 0)
        mstore(mul(0x5b, 2), 0)
        
        //
        // BrainFuck virtual machine in the Ethereum virtual machine
        //
        
        // Tape is allocated 32...1055 in memory as bytes (use mstore8)
        // Output is allocatd 1056...2079 in memory as bytes (use mstore8)
        // Program is stored as 2080... as uint256 in direct threading
        // Input is kept in calldata. Input pointer is offset by -31 so
        // a byte can be read using and(calldataload(ip), 0xff)
        
    // reset:
        tp := 1 // offset left 31 bytes
        ip := add(calldataload(36), 5) // offset left 31 bytes
        op := 1056
        pp := 2080
        jump(mload(pp))
        
    right: // >
        tp := add(tp, 1)
        pp := add(pp, 32)
        jump(mload(pp))
    
    left: // <
        tp := sub(tp, 1)
        pp := add(pp, 32)
        jump(mload(pp))
    
    incr: // +
        mstore8(add(tp, 31), add(mload(tp), 1))
        pp := add(pp, 32)
        jump(mload(pp))
    
    decr: // -
        mstore8(add(tp, 31), sub(mload(tp), 1))
        pp := add(pp, 32)
        jump(mload(pp))
    
    output: // .
        mstore8(op, mload(tp))
        op := add(op, 1)
        pp := add(pp, 32)
        jump(mload(pp))
    
    input: // ,
        mstore8(add(tp, 31), calldataload(ip))
        ip := add(ip, 1)
        pp := add(pp, 32)
        jump(mload(pp))
    
    open: // [
        jumpi(take, iszero(and(mload(tp), 0xff))) 
        pp := add(pp, 64)
        jump(mload(pp))
    
    close: // ]
        jumpi(take, and(mload(tp), 0xff)) 
        pp := add(pp, 64)
        jump(mload(pp))
    
    take:
        pp := mload(add(pp, 32))
        jump(mload(pp))
    
    exit: // EOF
        mstore(992, 32)
        mstore(1024, sub(op, 1056))
        return(992, and(sub(op, 961), not(0x1F)))
    }}
}
