pragma solidity ^0.4.23;

contract BrainFuck {
    
    function () external payable { assembly {
        
        // This canceles out the "mstore(0x40, 0x80)" that
        // solc likes to inject. It even gets partially optimized.
        mstore(0x40, 0x00)
        
        let source
        let eof
        let stack
        let tp // Tape pointer
        let ip // Input pointer
        let op // Output pointer
        let pp // Program pointer
        
        //
        // Compiler
        //
        
        // Create lookup table (256 bytes)
        // From high to low since we have overlaping writes
        mstore(mul(0x5d, 2), close)
        mstore(mul(0x5b, 2), open)
        mstore(mul(0x3e, 2), right)
        mstore(mul(0x3c, 2), left)
        mstore(mul(0x2e, 2), output)
        mstore(mul(0x2d, 2), decr)
        mstore(mul(0x2c, 2), input)
        mstore(mul(0x2b, 2), incr)

        source := 0x45 // offset left 31 bytes
        eof := add(calldataload(0x44), 0x45)
        pp := 2080
        stack := 256
        {
            let c
            let inst
            // If input is empty we will see one zero byte
        cloop:
            c := and(calldataload(source), 0xFF)
            inst := and(mload(add(c, c)), 0xFFFF)
            
            if inst {
            
                mstore(pp, inst)
                pp := add(pp, 32)
                
                if eq(inst, open) {
                    pp := add(pp, 32)
                    mstore(stack, pp)
                    stack := add(stack, 32)
                }
                if eq(inst, close) {
                    stack := sub(stack, 32)
                    let back := mload(stack) 
                    mstore(pp, back)
                    pp := add(pp, 32)
                    mstore(sub(back, 32), pp)
                    mstore(stack, 0)
                }
            }
            
            source := add(source, 1)
            jumpi(cloop, lt(source, eof))
        cend:
        }
        mstore(pp, exit)
    
        // Clear lookup table
        mstore(mul(0x3e, 2), 0)
        mstore(mul(0x3c, 2), 0)
        mstore(mul(0x2b, 2), 0)
        mstore(mul(0x2d, 2), 0)
        mstore(mul(0x2e, 2), 0)
        mstore(mul(0x2c, 2), 0)
        mstore(mul(0x5b, 2), 0)
        mstore(mul(0x5d, 2), 0)

        
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
