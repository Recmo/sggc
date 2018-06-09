pragma solidity ^0.4.23;

contract BrainFuck {
    
    /// @author Remco Bloemen <remco@wicked.ventures>

    function execute(bytes pro, bytes inp)
        public pure
        returns(bytes)
    {
        bytes memory out = new bytes(2048);
        uint256[] memory arg = new uint256[](pro.length);
        
        // Stress test the parser. (It's a dynamic array of function pointers)
        function(uint256,bytes memory,uint256,bytes memory,uint256,uint256[] memory,uint256) internal pure returns(uint256,uint256,uint256,uint256)[] memory byt = new function(uint256,bytes memory,uint256,bytes memory,uint256,uint256[] memory,uint256) internal pure returns(uint256,uint256,uint256,uint256)[](pro.length + 1);
        
        compile(pro, arg, byt);
        
        uint256 op = run(byt, inp, out, arg);
        
        // Create output array
        bytes memory ret = new bytes(op);
        for(uint256 i = 0; i < op; i++) {
            ret[i] = out[i];
        }
        return ret;
    }
    
    function compile(bytes memory pro, uint256[] memory arg, function(uint256,bytes memory,uint256,bytes memory,uint256,uint256[] memory,uint256) internal pure returns(uint256,uint256,uint256,uint256)[] memory byt)
        private pure
    {
        // Compute arguments
        uint256[20] memory stack;
        uint256 sp = 0;
        uint256 bp = 0;
        uint256 amount;
        for(uint pp = 0; pp < pro.length; pp++) {
            bytes32 instruction = pro[pp];
            if (instruction == '>') {
                if (pro[pp + 1] == '>') {
                    amount = 1;
                    do {
                        amount += 1;
                        pp++;
                    } while (pro[pp + 1] == '>');
                    byt[bp] = right;
                    arg[bp] = amount;
                } else {
                    byt[bp] = right1;
                }
                bp++;
            } else if (instruction == '<') {
                if (pro[pp + 1] == '<') {
                    amount = 1;
                    do {
                        amount += 1;
                        pp++;
                    } while (pro[pp + 1] == '<');
                    byt[bp] = left;
                    arg[bp] = amount;
                } else {
                    byt[bp] = left1;
                }
                bp++;
            } else if (instruction == '+') {
                if (pro[pp + 1] == '+') {
                    amount = 1;
                    do {
                        amount += 1;
                        pp++;
                    } while (pro[pp + 1] == '+');
                    byt[bp] = incr;
                    arg[bp] = amount;
                } else {
                    byt[bp] = incr1;
                }
                bp++;
            } else if (instruction == '-') {
                if (pro[pp + 1] == '-') {
                    amount = 1;
                    do {
                        amount += 1;
                        pp++;
                    } while (pro[pp + 1] == '-');
                    byt[bp] = decr;
                    arg[bp] = amount;
                } else {
                    byt[bp] = decr1;
                }
                bp++;
            } else if (instruction == '.') {
                byt[bp] = output;
                bp++;
            } else if (instruction == ',') {
                byt[bp] = input;
                bp++;
            } else if(instruction == '[') {
                byt[bp] = open;
                stack[sp++] = bp;
                bp++;
            } else if(instruction == ']') {
                byt[bp] = close;
                amount = stack[--sp];
                arg[amount] = bp + 1;
                arg[bp] = amount + 1;
                bp++;
            }
        }
        byt[bp] = exit;
    }
    
    function run(function(uint256,bytes memory,uint256,bytes memory,uint256,uint256[] memory,uint256) internal pure returns(uint256,uint256,uint256,uint256)[] memory byt, bytes memory inp, bytes memory out, uint256[] memory arg) private pure returns (uint256 op)
    {
        uint256 pp = 0;
        uint256 ip = 0;
        uint256 mp = 1024;
        for(; pp < byt.length;) {
            (mp, ip, op, pp) = byt[pp](mp, inp, ip, out, op, arg, pp);
        }
    }
    
    function nop(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        pp++;
        return (mp, ip, op, pp);
    }
    
    function right1(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        mp += 1;
        pp++;
        return (mp, ip, op, pp);
    }
    
    function right(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        mp += arg[pp];
        pp++;
        return (mp, ip, op, pp);
    }
    
    function left1(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        mp -= 1;
        pp++;
        return (mp, ip, op, pp);
    }
    
    function left(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        mp -= arg[pp];
        pp++;
        return (mp, ip, op, pp);
    }
    
    function incr1(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        out[mp] = bytes1(read1(out, mp) + 1);
        pp++;
        return (mp, ip, op, pp);
    }
    
    function incr(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        out[mp] = bytes1(read1(out, mp) + arg[pp]);
        pp++;
        return (mp, ip, op, pp);
    }
    
    function decr1(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        out[mp] = bytes1(read1(out, mp) - 1);
        pp++;
        return (mp, ip, op, pp);
    }
    
    function decr(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        out[mp] = bytes1(read1(out, mp) - arg[pp]);
        pp++;
        return (mp, ip, op, pp);
    }
    
    function output(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        out[op] = out[mp];
        op++;
        pp++;
        return (mp, ip, op, pp);
    }
    
    function input(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        out[mp] = inp[ip];
        ip++;
        pp++;
        return (mp, ip, op, pp);
    }
    
    function open(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        if (out[mp] == 0) {
            pp = arg[pp];
        } else {
            pp++;
        }
        return (mp, ip, op, pp);
    }
    
    function close(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        if (out[mp] != 0) {
            pp = arg[pp];
        } else {
            pp++;
        }
        return (mp, ip, op, pp);
    }
    
    function exit(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        pp = 0x123456789ABCDEF;
        return (mp, ip, op, pp);
    }
    
    function read1(bytes memory inp, uint256 i)
        internal pure
        returns (uint256)
    {
        return uint256(inp[i]);
    }
}
