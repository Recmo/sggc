/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity 0.4.24;

// 0  0011 0000 -> 0000
// 1  0011 0001 -> 0001
// 2  0011 0010 -> 0010
// 3  0011 0011 -> 0011
// 4  0011 0100 -> 0100
// 5  0011 0101 -> 0101
// 6  0011 0110 -> 0110
// 7  0011 0111 -> 0111
// 8  0011 1000 -> 1000
// 9  0011 1001 -> 1001
// a  0110 0001 -> 1010
// b  0110 0010 -> 1011
// c  0110 0011 -> 1100
// d  0110 0100 -> 1101
// e  0110 0101 -> 1110
// f  0110 0110 -> 1111
// A  0100 0001 -> 1010
// B  0100 0010 -> 1011
// C  0100 0011 -> 1100
// D  0100 0100 -> 1101
// E  0100 0101 -> 1110
// F  0100 0110 -> 1111

contract HexDecoder {
    
    function hexchr(byte input)
        private pure
        returns(uint8)
    {
        uint8 i = uint8(input);
        if (i & 0x40 != 0x0) {
            return 0x9 + (i & 0xf);
        } else {
            return i & 0xf;
        }
    }

    /**
     * @dev Decodes a hex-encoded input string, returning it in binary.
     *
     * Input strings may be of any length, but will always be a multiple of two
     * bytes long, and will not contain any non-hexadecimal characters.
     *
     * @param input The hex-encoded input.
     * @return The decoded output.
     */
    function decode(string input)
        public pure
        returns(bytes output)
    {
        require(bytes(input).length % 2 == 0);
        output = new bytes(bytes(input).length / 2);
        for(uint i = 0; i < output.length; i++) {
            output[i] = byte((hexchr(bytes(input)[i * 2]) << 4) | hexchr(bytes(input)[i * 2 + 1]));
        }
    }
}
