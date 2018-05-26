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
        
        // Create lookup table
        // From high to low since we have overlaping writes
        mstore(mul(0x5d, 16), sub(close, exit))
        mstore(mul(0x5b, 16), sub(open, exit))
        mstore(mul(0x3e, 16), sub(right, exit))
        mstore(mul(0x3c, 16), sub(left, exit))
        mstore(mul(0x2e, 16), sub(output, exit))
        mstore(mul(0x2d, 16), sub(decr, exit))
        mstore(mul(0x2c, 16), sub(input, exit))
        mstore(mul(0x2b, 16), sub(incr, exit))
        
        source := 0x45 // offset left 31 bytes
        eof := add(calldataload(0x44), 0x45)
        pp := 2080 // WARNING: Overlaps with lookup table for extended ascii
        stack := 0 // WARNING: Overlaps with lookup table
                   // If stack gets very deep or source has a very low
                   // character this will fail.
        
        // TODO: Instructions fit one byte if we subtract reset
        
        for {} lt(source, eof) {} {
            
            let c := and(calldataload(source), 0xff)
            let inst := and(mload(mul(c, 16)), 0xFFFF)
            
            if inst {
            
                mstore8(pp, inst)
                pp := add(pp, 1)
                
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
        }
        
        // Clear lookup table
        mstore(mul(0x3e, 16), 0)
        mstore(mul(0x3c, 16), 0)
        mstore(mul(0x2b, 16), 0)
        mstore(mul(0x2d, 16), 0)
        mstore(mul(0x2e, 16), 0)
        mstore(mul(0x2c, 16), 0)
        mstore(mul(0x5b, 16), 0)
        mstore(mul(0x5d, 16), 0)
        
        //
        // BrainFuck virtual machine in the Ethereum virtual machine
        //
        
        // Tape is allocated 32...1055 in memory as bytes (use mstore8)
        // Output is allocatd 1056...2079 in memory as bytes (use mstore8)
        // Program is stored as 2080... as uint256 in direct threading
        // Input is kept in calldata. Input pointer is offset by -31 so
        // a byte can be read using and(calldataload(ip), 0xff)
        
    // reset:
        tp := 32
        ip := add(calldataload(36), 5) // offset left 31 bytes
        op := 1056
        pp := 2080
        jump(add(mload(pp), exit))
        
    exit: // EOF
        mstore(992, 32)
        mstore(1024, sub(op, 1056))
        return(992, and(sub(op, 961), not(0x1F)))
        
    right: // >
        tp := add(tp, 1)
        pp := add(pp, 1)
        jump(add(and(mload(sub(pp, 31)), 0xff), exit))
    
    left: // <
        tp := sub(tp, 1)
        pp := add(pp, 1)
        jump(add(and(mload(sub(pp, 31)), 0xff), exit))
    
    incr: // +
        mstore8(tp, add(mload(sub(tp, 31)), 1))
        pp := add(pp, 1)
        jump(add(and(mload(sub(pp, 31)), 0xff), exit))
    
    decr: // -
        mstore8(tp, sub(mload(sub(tp, 31)), 1))
        pp := add(pp, 1)
        jump(add(and(mload(sub(pp, 31)), 0xff), exit))
    
    output: // .
        mstore8(op, mload(sub(tp, 31)))
        op := add(op, 1)
        pp := add(pp, 1)
        jump(add(and(mload(sub(pp, 31)), 0xff), exit))
    
    input: // ,
        mstore8(tp, calldataload(ip))
        ip := add(ip, 1)
        pp := add(pp, 1)
        jump(add(and(mload(sub(pp, 31)), 0xff), exit))
    
    open: // [
        jumpi(take, iszero(and(mload(sub(tp, 31)), 0xff))) 
        pp := add(pp, 33)
        jump(add(and(mload(sub(pp, 31)), 0xff), exit))
    
    close: // ]
        jumpi(take, and(mload(sub(tp, 31)), 0xff)) 
        pp := add(pp, 33)
        jump(add(and(mload(sub(pp, 31)), 0xff), exit))
    
    take:
        pp := mload(add(pp, 1))
        jump(add(and(mload(sub(pp, 31)), 0xff), exit))
    }}
}
