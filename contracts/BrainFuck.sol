/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity ^0.4.23;

contract BrainFuck {
    /**
     * @dev Executes a BrainFuck program, as described at https://en.wikipedia.org/wiki/Brainfuck.
     *
     * Memory cells, input, and output values are all expected to be 8 bit
     * integers. Incrementing past 255 should overflow to 0, and decrementing
     * below 0 should overflow to 255.
     *
     * Programs and input streams may be of any length. The memory tape starts
     * at cell 0, and will never be moved below 0 or above 1023. No program will
     * output more than 1024 values.
     *
     * @param program The BrainFuck program.
     * @param input The program's input stream.
     * @return The program's output stream. Should be exactly the length of the
     *          number of outputs produced by the program.
     */
    function execute(bytes program, bytes input) public pure returns(bytes) {
        uint256 pl = program.length;
        
        uint ipp = 0;
        uint opp = 0;
        uint dp = 0;
        bytes memory mem = new bytes(1024);
        bytes memory output = new bytes(1024);
        uint256[] memory arg = new uint256[](pl);
        compile(program, arg);
        
        for(uint ip = 0; ip < pl; ip++) {
            bytes1 instruction = program[ip];
            if(instruction == '+') {
                mem[dp] = byte(uint(mem[dp]) + 1);
            } else if(instruction == '-') {
                mem[dp] = byte(uint(mem[dp]) - 1);
            } else if(instruction == '>') {
                dp++;
            } else if(instruction == '<') {
                dp--;
            } else if(instruction == '.') {
                output[opp++] = mem[dp];
            } else if(instruction == ',') {
                mem[dp] = input[ipp++];
            } else if(instruction == '[') {
                if(mem[dp] == 0) {
                    ip = arg[ip];
                }
            } else if(instruction == ']') {
                if(mem[dp] != 0) {
                    ip = arg[ip];
                }
            }
        }

        // Create output array
        bytes memory ret = new bytes(opp);
        for(uint256 i = 0; i < opp; i++) {
            ret[i] = output[i];
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
