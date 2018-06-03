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

    uint256 constant lowNibs = 0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F;
    uint256 constant bit1 = 0x0101010101010101010101010101010101010101010101010101010101010101;
    uint256 constant byten1 = 0x0FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF0;
    uint256 constant byten2 = 0x0FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF000;
    uint256 constant byten3 = 0x0FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF0000000;
    uint256 constant byten4 = 0x0FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF000000000000000;
    
    uint256 constant f1 = 0x11;
    uint256 constant f2 = 0x101;
    uint256 constant f3 = 0x10001;
    uint256 constant f4 = 0x100000001;
    uint256 constant f5 = 0x100000000000000010;

    function decode(string input)
        public pure
        returns(bytes output)
    {
        uint256 ol = bytes(input).length / 2;
        output = new bytes(ol);
        uint256 i = 0;
        uint256 j = 0;
        if (ol > 15) {
            for (; i < ol - 15; ) {
                
                // Load input block
                uint256 B;
                for(uint k = 0 ; k < 32; k++) {
                    B *= 256;
                    B |= uint8(bytes(input)[j++]);
                }
                
                // SWAR convert hex to nibbles
                B = (B & lowNibs) + (9 * ((B / 64) & bit1));
                
                // SWAR shuffle nibbles to left
                B = (B * f1) & byten1;
                B = (B * f2) & byten2;
                B = (B * f3) & byten3;
                B = (B * f4) & byten4;
                B = B * f5;
                
                // Write to output
                bytes16 out = bytes16(bytes32(B));
                for(k = 0 ; k < 16; k++) {
                    output[i++] = out[k];
                }
            }
        }
        for (; i < ol; ) {
            uint8 a = uint8(bytes(input)[j++]);
            uint8 b = uint8(bytes(input)[j++]);
            a = (a & 0xf) + ((a / 64) * 9);
            b = (b & 0xf) + ((b / 64) * 9);
            output[i++] = byte((a << 4) | b);
        }
    }
}
