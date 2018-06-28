pragma solidity ^0.4.23;

contract BrainFuck {
    
    //function () external payable { assembly {
    function execute(bytes program, bytes input) external payable returns(bytes) { assembly {

        
        /// @author Remco Bloemen <remco@wicked.ventures> 
        
        // max(output size) = 257
        // max(tape) = 1024
        // Tape is very sparse and can be used modulo 11 or 16
        // max(loop stack) = 2
        // Assume input characters < 128
        // max(program) > 272 <= 276
        
        // This canceles out the "mstore(0x40, 0x80)" that
        // solc likes to inject. It even gets partially optimized.
        mstore(0x40, 0x00)
        
        // Declare stack variables
        // (we jump so much, best to keep stack layout fixed)
        //
        //        Runtime              Compile time
        let t  //                      Temp (repetitions)
        let t2
        let js // Jump stack
        let tp // Tape pointer         [ ] stack pointer
        let ip // Input pointer        Source pointer
        let op // Output pointer       Temp (instruction)
        let pp // Program pointer
    
    ///////////////////////////////////////////////////////
    // BrainFuck Interpreter
    ///////////////////////////////////////////////////////
        
        // Create lookup table (256 bytes)
        // From high to low since we have overlaping writes
        // XORed with cnop to make cnop the default entry
        mstore(0xBA, xor(cnop, cclose))
        mstore(0xB6, xor(cnop, copen))
        mstore(0x7C, xor(cnop, cright))
        mstore(0x78, xor(cnop, cleft))
        mstore(0x5C, xor(cnop, coutput))
        mstore(0x5A, xor(cnop, cdecr))
        mstore(0x58, xor(cnop, cinput))
        mstore(0x56, xor(cnop, cincr))
        mstore(0x00, xor(cnop, ceof))
        
        // 0x000 .. 0x100  instruction lookup table 
        // 0x110 .. 0x120  tape
        // 0x200 .. 0x341  output
        // 0x360 .. 0x588  cache of matching brackets
        // Program is kept in calldata. Program pointer offset by -31 bytes.
        // Input is kept in calldata. Input pointer is offset by -31 bytes.
        
    // reset:
        pp := add(calldataload(0x04), 4) // offset left 32 bytes
        ip := add(calldataload(0x24), 5) // offset left 31 bytes
        tp := 0x100
        op := 0x200
        
        jumpi(explode, gt(calldataload(pp), 263))
        
    cnop:
        pp := add(pp, 1)
        t := and(calldataload(pp), 0x7F)
        jump(xor(cnop, and(mload(add(t, t)), 0xFFFF)))
        
    cright:
        tp := add(and(add(tp, 1), 0xF), 0x100)
        jump(cnop)

    cleft:
        tp := add(and(sub(tp, 1), 0xF), 0x100)
        jump(cnop)

    cincr:
        mstore8(add(tp, 31), add(mload(tp), 1))
        jump(cnop)
        
    cdecr:
        mstore8(add(tp, 31), sub(mload(tp), 1))
        jump(cnop)
    
    coutput:
        mstore8(op, mload(tp))
        op := add(op, 1)
        jump(cnop)
    
    cinput:
        mstore8(add(tp, 31), calldataload(ip))
        ip := add(ip, 1)
        jump(cnop)
    
    copen:
        jumpi(cnop, and(mload(tp), 0xff))
        
        // Skip, try cache first
        t2 := pp
        pp := and(mload(add(add(pp, pp), 0x342)), 0xFFFF)
        jumpi(cnop, pp)
        
        // No cache, find bracket
        pp := t2
        js := 1
    copen_find:
        pp := add(pp, 1)
        t := and(calldataload(pp), 0x7F)
        js := add(js, eq(t, 0x5b)) // [
        js := sub(js, eq(t, 0x5d)) // ]
        jumpi(copen_find, js)
        
        // Cache brackets
        // cache[t2] = pp
        // cache[pp] = t2
        t := add(add(pp, pp), 0x342)
        mstore(t, or(and(mload(t), not(0xFFFF)), t2))
        t := add(add(t2, t2), 0x342)
        mstore(t, or(and(mload(t), not(0xFFFF)), pp))
        
        jump(cnop)
        
    cclose:
        jumpi(cclose_take, and(mload(tp), 0xff))
        jump(cnop)
        
    cclose_take:
        // Take, try cache first
        t2 := pp
        pp := and(mload(add(add(pp, pp), 0x342)), 0xFFFF)
        jumpi(cnop, pp)
        
        // No cache, find bracket
        pp := t2
        js := 1
    cclose_find_loop:
        pp := sub(pp, 1)
        t := and(calldataload(pp), 0x7F)
        js := sub(js, eq(t, 0x5b)) // [
        js := add(js, eq(t, 0x5d)) // ]
        jumpi(cclose_find_loop, js)
        
        // Cache brackets
        // cache[t2] = pp
        // cache[pp] = t2
        t := add(add(pp, pp), 0x342)
        mstore(t, or(and(mload(t), not(0xFFFF)), t2))
        t := add(add(t2, t2), 0x342)
        mstore(t, or(and(mload(t), not(0xFFFF)), pp))

        jump(cnop)
        
    ceof:
        mstore(0x1C0, 0x20)
        mstore(0x1E0, sub(op, 0x200))
        return(0x1C0, and(sub(op, 0x1A1), 0xFE0))
        
    explode:
        selfdestruct(0x0)
    }}
    
    // Now someone needs to write an ERC20 contract in BrainFuck,
    // so it can be runrun in this VM. Maybe I'll put a bounty on it.
}
