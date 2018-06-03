pragma solidity ^0.4.23;

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
        
        uint256[103] memory lookup;
        lookup[0x30] = 0;
        lookup[0x31] = 1;
        lookup[0x32] = 2;
        lookup[0x33] = 3;
        lookup[0x34] = 4;
        lookup[0x35] = 5;
        lookup[0x36] = 6;
        lookup[0x37] = 7;
        lookup[0x38] = 8;
        lookup[0x39] = 9;
        lookup[0x61] = 10;
        lookup[0x62] = 11;
        lookup[0x63] = 12;
        lookup[0x64] = 13;
        lookup[0x65] = 14;
        lookup[0x66] = 15;
        lookup[0x41] = 10;
        lookup[0x42] = 11;
        lookup[0x43] = 12;
        lookup[0x44] = 13;
        lookup[0x45] = 14;
        lookup[0x55] = 15;
        
        uint256 i = 0;
        uint256 j = 0;
        for (; i < ol; ) {
            uint256 a = lookup[uint8(bytes(input)[j++])];
            uint256 b = lookup[uint8(bytes(input)[j++])];
            output[i++] = byte(a * 16 | b);
        }
    }
}
