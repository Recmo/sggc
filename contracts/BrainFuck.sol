/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity ^0.4.23;

contract BrainFuck {

    function execute(bytes pro, bytes inp)
        public pure
        returns(bytes)
    {
        bytes memory out = new bytes(2048);
        uint256[] memory arg = new uint256[](pro.length);
        
        compile(pro, arg);
        
        uint256 op = run(pro, inp, out, arg);
        
        // Create output array
        bytes memory ret = new bytes(op);
        for(uint256 i = 0; i < op; i++) {
            ret[i] = out[i];
        }
        return ret;
    }
    
    function compile(bytes memory pro, uint256[] memory arg)
        private pure
    {
        // Compute arguments
        uint256[20] memory stack;
        uint256 sp = 0;
        for(uint pp = 0; pp < pro.length; pp++) {
            bytes1 instruction = pro[pp];
            if(instruction == '[') {
                stack[sp++] = pp;
            } else if(instruction == ']') {
                uint256 matchp = stack[--sp];
                arg[matchp] = pp + 1;
                arg[pp] = matchp + 1;
            }
        }
    }
    
    function run(bytes memory pro, bytes memory inp, bytes memory out, uint256[] memory arg) private pure returns (uint256 op)
    {
        uint256 pp = 0;
        uint256 ip = 0;
        uint256 mp = 1024;
        
        for(; pp < pro.length;) {
            bytes1 instruction = pro[pp];
            if(instruction == '+') {
                (mp, ip, op, pp) = incr(out, mp, inp, ip, out, op, arg, pp);
            } else if(instruction == '-') {
                (mp, ip, op, pp) = decr(out, mp, inp, ip, out, op, arg, pp);
            } else if(instruction == '>') {
                (mp, ip, op, pp) = right(out, mp, inp, ip, out, op, arg, pp);
            } else if(instruction == '<') {
                (mp, ip, op, pp) = left(out, mp, inp, ip, out, op, arg, pp);
            } else if(instruction == '.') {
                (mp, ip, op, pp) = output(out, mp, inp, ip, out, op, arg, pp);
            } else if(instruction == ',') {
                (mp, ip, op, pp) = input(out, mp, inp, ip, out, op, arg, pp);
            } else if(instruction == '[') {
                (mp, ip, op, pp) = open(out, mp, inp, ip, out, op, arg, pp);
            } else if(instruction == ']') {
                (mp, ip, op, pp) = close(out, mp, inp, ip, out, op, arg, pp);
            } else {
                (mp, ip, op, pp) = nop(out, mp, inp, ip, out, op, arg, pp);
            }
        }
    }
    
    function nop(
        bytes memory mem, uint256 mp,
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
        bytes memory mem, uint256 mp,
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
        bytes memory mem, uint256 mp,
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
        bytes memory mem, uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        mem[mp] = bytes1(uint8(mem[mp]) + 1);
        pp++;
        return (mp, ip, op, pp);
    }
    
    function decr(
        bytes memory mem, uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        mem[mp] = bytes1(uint8(mem[mp]) - 1);
        pp++;
        return (mp, ip, op, pp);
    }
    
    function output(
        bytes memory mem, uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        out[op++] = mem[mp];
        pp++;
        return (mp, ip, op, pp);
    }
    
    function input(
        bytes memory mem, uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        mem[mp] = inp[ip++];
        pp++;
        return (mp, ip, op, pp);
    }
    
    function open(
        bytes memory mem, uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        if (mem[mp] == 0) {
            pp = arg[pp];
        } else {
            pp++;
        }
        return (mp, ip, op, pp);
    }
    
    function close(
        bytes memory mem, uint256 mp,
        bytes memory inp, uint256 ip,
        bytes memory out, uint256 op,
        uint256[] memory arg,
        uint256 pp
    ) private pure returns (uint256, uint256, uint256, uint256)
    {
        if (mem[mp] != 0) {
            pp = arg[pp];
        } else {
            pp++;
        }
        return (mp, ip, op, pp);
    }
}
