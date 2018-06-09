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
        function(uint256,bytes memory,uint256,bytes memory,uint256,uint256[] memory,uint256) internal pure returns(uint256,uint256,uint256,uint256)[] memory byt = new function(uint256,bytes memory,uint256,bytes memory,uint256,uint256[] memory,uint256) internal pure returns(uint256,uint256,uint256,uint256)[](pro.length);
        
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
        for(uint pp = 0; pp < pro.length; pp++) {
            bytes1 instruction = pro[pp];
            if (instruction == '>') {
                byt[pp] = right;
            } else if (instruction == '<') {
                byt[pp] = left;
            } else if (instruction == '+') {
                byt[pp] = incr;
            } else if (instruction == '-') {
                byt[pp] = decr;
            } else if (instruction == '.') {
                byt[pp] = output;
            } else if (instruction == ',') {
                byt[pp] = input;
            } else if(instruction == '[') {
                byt[pp] = open;
                stack[sp++] = pp;
            } else if(instruction == ']') {
                byt[pp] = close;
                uint256 matchp = stack[--sp];
                arg[matchp] = pp + 1;
                arg[pp] = matchp + 1;
            } else {
                byt[pp] = nop;
            }
        }
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
    
    function right(
        uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        mp++;
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
        mp--;
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
        out[mp] = bytes1(uint8(out[mp]) + 1);
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
        out[mp] = bytes1(uint8(out[mp]) - 1);
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
        out[op++] = out[mp];
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
        out[mp] = inp[ip++];
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
}
