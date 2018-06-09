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
        uint256 pl = pro.length;
        
        uint256 pp = 0;
        uint256 ip = 0;
        uint256 op = 0;
        uint256 mp = 0;
        
        bytes memory mem = new bytes(1024);
        bytes memory out = new bytes(1024);
        uint256[] memory arg = new uint256[](pl);
        
        compile(pro, arg);
        
        for(pp = 0; pp < pl; pp++) {
            bytes1 instruction = pro[pp];
            if(instruction == '+') {
                mem[mp] = byte(uint(mem[mp]) + 1);
            } else if(instruction == '-') {
                mem[mp] = byte(uint(mem[mp]) - 1);
            } else if(instruction == '>') {
                mp++;
            } else if(instruction == '<') {
                mp--;
            } else if(instruction == '.') {
                out[op++] = mem[mp];
            } else if(instruction == ',') {
                mem[mp] = inp[ip++];
            } else if(instruction == '[') {
                if(mem[mp] == 0) {
                    pp = arg[pp];
                }
            } else if(instruction == ']') {
                if(mem[mp] != 0) {
                    pp = arg[pp];
                }
            }
        }
        
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
                arg[matchp] = pp;
                arg[pp] = matchp;
            }
        }
    }
}
