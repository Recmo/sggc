pragma solidity 0.4.24;

contract BrainFuck {
    
    function execute(bytes program, bytes input)
        public view
        returns(bytes)
    {
        uint256[10] memory inst;
        uint256[] memory prog;
        
        assembly {
            //
            // BrainFuck virtual machine in the Ethereum virtual machine
            //
            
            // Tape is allocated 32...1055 in memory as bytes (use mstore8)
            // Output is allocatd 1056...2079 in memory as bytes (use mstore8)
            // Program is stored as 2080... as uint256 in direct threading
            // Input is kept in calldata. Input pointer is offset by -31 so
            // a byte can be read using and(calldataload(ip), 0xff)
            
            let tp // Tape pointer
            let ip // Input pointer
            let op // Output pointer
            let pp // Program pointer
            
            prog := sub(2080, 32)
            mstore(prog, 1024)
            mstore(2080, export)
            
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
            
        export:
            mstore(inst, reset)
            mstore(add(inst, 0x20), right)
            mstore(add(inst, 0x40), left)
            mstore(add(inst, 0x60), incr)
            mstore(add(inst, 0x80), decr)
            mstore(add(inst, 0xA0), output)
            mstore(add(inst, 0xC0), input)
            mstore(add(inst, 0xE0), open)
            mstore(add(inst, 0x100), close)
            mstore(add(inst, 0x120), exit)
        }
        
        uint256 progp = 0;
        for(uint ip = 0; ip < program.length; ip++) {
            byte instruction = program[ip];
            if(instruction == '+') {
                prog[progp++] = inst[3];
            } else if(instruction == '-') {
                prog[progp++] = inst[4];
            } else if(instruction == '>') {
                prog[progp++] = inst[1];
            } else if(instruction == '<') {
                prog[progp++] = inst[2];
            } else if(instruction == '.') {
                prog[progp++] = inst[5];
            } else if(instruction == ',') {
                prog[progp++] = inst[6];
            } else if(instruction == '[') {
                prog[progp++] = inst[7];
                prog[progp++] = inst[9];
                
                /*
                if(mem[dp] == 0) {
                    uint depth = 1;
                    for(uint i = ip + 1; i < pl; i++) {
                        if(program[i] == ']') {
                            depth--;
                            if(depth == 0) {
                                ip = i;
                                break;
                            }
                        } else if(program[i] == '[') {
                            depth++;
                        }
                    }
                }
                */
            } else if(instruction == ']') {
                prog[progp++] = inst[8];
                prog[progp++] = inst[9];
                
                /*
                if(mem[dp] != 0) {
                    depth = 1;
                    for(i = ip - 1; i > 0; i--) {
                        if(program[i] == '[') {
                            depth--;
                            if(depth == 0) {
                                ip = i;
                                break;
                            }
                        } else if(program[i] == ']') {
                            depth++;
                        }
                    }
                }
                */
            }
        }
        prog[progp++] = inst[9];
        
        assembly {
            jump(mload(inst)) // reset
        }
    }
}
