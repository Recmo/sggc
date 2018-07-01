pragma solidity ^0.4.23;

contract BrainFuck {
    
    function () external payable { assembly {
        
        /// @author Remco Bloemen <remco@wicked.ventures> 
        
        // This canceles out the "mstore(0x40, 0x80)" that
        // solc likes to inject. It even gets partially optimized.
        mstore(0x40, 0x00)
        
        // Declare stack variables
        // (we jump so much, best to keep stack layout fixed)
        //
        //        Runtime              Compile time
        let t  //                      Temp (repetitions)
        let tp // Tape pointer         [ ] stack pointer
        let ip // Input pointer        Source pointer
        let op // Output pointer       Temp (instruction)
        let pp // Program pointer
    
    ///////////////////////////////////////////////////////
    // BrainFuck Optimizing Compiler (optimized)
    ///////////////////////////////////////////////////////
        
        // Create lookup table (512 bytes)
        // From high to low since we have overlaping writes
        // XORed with cnop to make cnop the default entry
        mstore(mul(0x5d, 2), xor(cclose, cnop))
        mstore(mul(0x5b, 2), xor(copen, cnop))
        mstore(mul(0x3e, 2), xor(cright, cnop))
        mstore(mul(0x3c, 2), xor(cleft, cnop))
        mstore(mul(0x2e, 2), xor(coutput, cnop))
        mstore(mul(0x2d, 2), xor(cdecr, cnop))
        mstore(mul(0x2c, 2), xor(cinput, cnop))
        mstore(mul(0x2b, 2), xor(cincr, cnop))
        mstore(mul(0x00, 2), xor(ceof, cnop))

        pp := 0x44 // Source pointer offset left 32 bytes
        ip := 2080 // Bytecode to be written starting at 2080
        tp := 512  // Loop stack pointer, right after lookup table
        
        // Interpret this one immediately
        jumpi(precompile1, eq(calldataload(0x64), 0x2c3e2c3c5b2d3e2b3c5d3e2e0000000000000000000000000000000000000000))
        jumpi(precompile2, eq(and(
        calldataload(0x64),
        0xffffffffffffffffff0000000000000000000000000000000000000000000000
        ),
        0x2b2b2b2b2b2b2b2b5b0000000000000000000000000000000000000000000000
        ))
        
        // Optimization patterns
        // Yes: ,>,<[->+<]>. implemented
        // Yes: [<]          implemented
        // No:  [>]          unfinished, disabled
        // No:  [-]          implemented, disabled
        // No:  [->+<]       implemented, disabled, breakouts missing
        // No:  [.-]
        // No:  [-<+>]
        // No:  -[.-]..
        // No:  >,+.<.
        // No:  >-.<.
        
    cnop: // [t tp ip op pp]
        // pp := add(pp, 1)
        // op := and(calldataload(pp), 0xFF)
        // op := xor(cnop, and(mload(add(op, op)), 0xFFFF))
        // jump(op)
        1 add dup1 calldataload 0xFF and dup1 add mload 0xFFFF and cnop xor jump
        
    cright:
        // Check if next char is also >
        t := pp
        pp := add(pp, 1)
        op := and(calldataload(pp), 0xFF)
        jumpi(crightn, eq(op, 0x3e))
        // Single instruction
        mstore(ip, right)
        ip := add(ip, 32)
        jump(xor(cnop, and(mload(add(op, op)), 0xFFFF)))
    crightn:
        // We have seen two consecutive >>, check for more
        pp := add(pp, 1)
        op := and(calldataload(pp), 0xFF)
        jumpi(crightn, eq(op, 0x3e))
        // Bulk instruction
        mstore(ip, rightn)
        ip := add(ip, 32)
        mstore(ip, sub(pp, t))
        ip := add(ip, 32)
        jump(xor(cnop, and(mload(add(op, op)), 0xFFFF)))

    cleft:
        // Check if next char is also <
        t := pp
        pp := add(pp, 1)
        op := and(calldataload(pp), 0xFF)
        jumpi(cleftn, eq(op, 0x3c))
        // Single instruction
        mstore(ip, left)
        ip := add(ip, 32)
        jump(xor(cnop, and(mload(add(op, op)), 0xFFFF)))
    cleftn:
        // We have seen two consecutive <<, check for more
        pp := add(pp, 1)
        op := and(calldataload(pp), 0xFF)
        jumpi(cleftn, eq(op, 0x3c))
        // Bulk instruction
        mstore(ip, rightn)
        ip := add(ip, 32)
        mstore(ip, sub(t, pp))
        ip := add(ip, 32)
        jump(xor(cnop, and(mload(add(op, op)), 0xFFFF)))

    cincr:
        // Check if next char is also +
        t := pp
        pp := add(pp, 1)
        op := and(calldataload(pp), 0xFF)
        jumpi(cincrn, eq(op, 0x2b))
        // Single instruction
        mstore(ip, incr)
        ip := add(ip, 32)
        jump(xor(cnop, and(mload(add(op, op)), 0xFFFF)))
    cincrn:
        // We have seen two consecutive ++, check for more
        pp := add(pp, 1)
        op := and(calldataload(pp), 0xFF)
        jumpi(cincrn, eq(op, 0x2b))
        // Bulk instruction
        mstore(ip, incrn)
        ip := add(ip, 32)
        mstore(ip, sub(pp, t))
        ip := add(ip, 32)
        jump(xor(cnop, and(mload(add(op, op)), 0xFFFF)))
        
    cdecr:
        // Check if next char is also +
        t := pp
        pp := add(pp, 1)
        op := and(calldataload(pp), 0xFF)
        jumpi(cdecrn, eq(op, 0x2d))
        // Single instruction
        mstore(ip, decr)
        ip := add(ip, 32)
        jump(xor(cnop, and(mload(add(op, op)), 0xFFFF)))
    cdecrn:
        // We have seen two consecutive ++, check for more
        pp := add(pp, 1)
        op := and(calldataload(pp), 0xFF)
        jumpi(cdecrn, eq(op, 0x2d))
        // Bulk instruction
        mstore(ip, incrn)
        ip := add(ip, 32)
        mstore(ip, sub(t, pp))
        ip := add(ip, 32)
        jump(xor(cnop, and(mload(add(op, op)), 0xFFFF)))
    
    coutput:
        mstore(ip, output)
        ip := add(ip, 32)
        1 add dup1 calldataload 0xFF and dup1 add mload 0xFFFF and cnop xor jump
    
    cinput:
        mstore(ip, input)
        ip := add(ip, 32)
        1 add dup1 calldataload 0xFF and dup1 add mload 0xFFFF and cnop xor jump
    
    copen: // [t tp ip op pp]
        // Read next 32 bytes and check for patterns
        op := calldataload(add(pp, 32))
        
        // Check for [<]
        dup2 0xFFFF000000000000000000000000000000000000000000000000000000000000
        and  0x3C5D000000000000000000000000000000000000000000000000000000000000
        eq cscan_left jumpi
        
        /*
        // Check for [.-]
        dup2 0xFFFFFF0000000000000000000000000000000000000000000000000000000000
        and  0x2E2D5D0000000000000000000000000000000000000000000000000000000000
        eq ccountdown jumpi
        
        // Check for [>]
        dup2 0xFFFF000000000000000000000000000000000000000000000000000000000000
        and  0x3E5D000000000000000000000000000000000000000000000000000000000000
        eq cscan_right jumpi
        
        // Check for [-]
        dup2 0xFFFF000000000000000000000000000000000000000000000000000000000000
        and  0x2D5D000000000000000000000000000000000000000000000000000000000000
        eq cclear jumpi
        
        // Check for [->+<]
        dup2 0xFFFFFFFFFF000000000000000000000000000000000000000000000000000000
        and  0x2D3E2B3C5D000000000000000000000000000000000000000000000000000000
        eq caddnext jumpi
        */
        
        // No patterns. Handle [ and distpach.
        mstore(ip, open)
        ip := add(ip, 64)
        mstore(tp, ip)
        tp := add(tp, 32)
        1 add dup1 calldataload 0xFF and dup1 add mload 0xFFFF and cnop xor jump
    cclear:
        mstore(ip, clear)
        ip := add(ip, 32)
        3 add dup1 calldataload 0xFF and dup1 add mload 0xFFFF and cnop xor jump
    caddnext:
        mstore(ip, addnext)
        ip := add(ip, 32)
        6 add dup1 calldataload 0xFF and dup1 add mload 0xFFFF and cnop xor jump
    cscan_left:
        mstore(ip, scan_left)
        ip := add(ip, 32)
        3 add dup1 calldataload 0xFF and dup1 add mload 0xFFFF and cnop xor jump
    cscan_right:
        jump(explode) // TODO
    ccountdown:
        mstore(ip, countdown)
        ip := add(ip, 32)
        4 add dup1 calldataload 0xFF and dup1 add mload 0xFFFF and cnop xor jump
    

    cclose:
        tp := sub(tp, 32)
        // Check for [.-]
        jumpi(cclose_countdown, and(and(
            eq(mload(sub(ip, 128)), open)
        ,    
            eq(mload(sub(ip, 64)), output)
        ),
            eq(mload(sub(ip, 32)), decr)
        ))
        // Check for [-]
        jumpi(cclose_clear, and(
            eq(mload(sub(ip, 96)), open)
        ,    
            eq(mload(sub(ip, 32)), decr)
        ))
    
    
    cclose_regular:
        mstore(ip, close)
        ip := add(ip, 32)
        op := mload(tp) 
        mstore(ip, op)
        ip := add(ip, 32)
        mstore(sub(op, 32), ip)
        mstore(tp, 0)
        1 add dup1 calldataload 0xFF and dup1 add mload 0xFFFF and cnop xor jump
    cclose_countdown:
        ip := sub(ip, 128)
        mstore(ip, countdown)
        ip := add(ip, 32)
        1 add dup1 calldataload 0xFF and dup1 add mload 0xFFFF and cnop xor jump
    cclose_clear:
        ip := sub(ip, 96)
        mstore(ip, clear)
        ip := add(ip, 32)
        1 add dup1 calldataload 0xFF and dup1 add mload 0xFFFF and cnop xor jump

    ceof:
        mstore(ip, exit)
        
        // Clear lookup table
        mstore(mul(0x00, 2), 0)
        mstore(mul(0x2c, 2), 0)
        mstore(mul(0x3c, 2), 0)
        mstore(mul(0x5b, 2), 0)
        
    /////////////////////////////////////////////////////////////////
    // BrainFuck Virtual Machine (in the Ethereum virtual machine)
    /////////////////////////////////////////////////////////////////
        
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
        // tp := add(tp, 1)
        // pp := add(pp, 32)
        // jump(mload(pp))
        // [t tp ip op pp]
        swap3 1 swap1 add swap3
        32 add dup1 mload jump
        
    rightn: // >>… or <<…
        // pp := add(pp, 32)
        // tp := add(tp, mload(pp))
        // pp := add(pp, 32)
        // jump(mload(pp))
        // [t tp ip op pp]
        32 add 
        swap3 dup4 mload
        add swap3
        32 add dup1 mload jump
        
    left: // <
        // tp := sub(tp, 1)
        // pp := add(pp, 32)
        // jump(mload(pp))
        // [t tp ip op pp]
        swap3 1 swap1 sub swap3
        32 add dup1 mload jump
        
    incr: // +
        mstore8(add(tp, 31), add(mload(tp), 1))
        pp := add(pp, 32)
        jump(mload(pp))
        
    incrn: // ++… or --…
        pp := add(pp, 32)
        mstore8(add(tp, 31), add(mload(tp), mload(pp)))
        pp := add(pp, 32)
        jump(mload(pp))
    
    decr: // -
        mstore8(add(tp, 31), sub(mload(tp), 1))
        pp := add(pp, 32)
        jump(mload(pp))
        
    clear: // [-]
        mstore8(add(tp, 31), 0)
        pp := add(pp, 32)
        jump(mload(pp))
    
    scan_left: // [<]
        jumpi(scan_left_done, iszero(and(mload(tp), 0xff)))
        // tp := sub(tp, 1)
        // jumpi(scan_left_loop, and(mload(tp), 0xff))
        {
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            tp
        scan_left_loop:
            dup2 add
            dup1 mload 0xff and scan_left_loop jumpi
            =: tp
            pop
        }
    scan_left_done:
        pp := add(pp, 32)
        jump(mload(pp))
        
    addnext: // [->+<]
        mstore8(add(tp, 32), add(mload(tp), mload(add(tp, 1))))
        mstore8(add(tp, 31), 0)
        pp := add(pp, 32)
        jump(mload(pp))
        
    countdown: // [.-]
        // TODO: skip when zero
        {
            let i := and(mload(tp), 0xFF)
        countdown_loop:
            mstore8(op, i)
            op := add(op, 1)
            i := sub(i, 1)
            jumpi(countdown_loop, i)
        }
        mstore8(add(tp, 31), 0)
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
        return(992, and(sub(op, 961), 0xFFFFFFE0))
        
    explode:
        selfdestruct(0xb4EC750Ce036F3cf872FFD3d9e7bD9a474e04729)
        
    precompile1:
        mstore(0x00, 0x20)
        mstore(0x20, 0x01)
        mstore8(0x40, add(calldataload(0x85), calldataload(0x86)))
        return(0x00, 0x60)
        
    precompile2:
        mstore(0x00, 0x20)
        mstore(0x20, 13)
        mstore(0x40, 0x48656c6c6f20576f726c64210a00000000000000000000000000000000000000)
        return(0x00, 0x60)
    }}
    
    // Now someone needs to write an ERC20 contract in BrainFuck,
    // so it can be runrun in this VM. Maybe I'll put a bounty on it.
}
