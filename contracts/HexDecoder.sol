/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity 0.4.24;

contract HexDecoder {
    function hexchr(byte input) private pure returns(uint8) {
        if(input >= 0x30 && input <= 0x39) {
            return uint8(input) - 0x30;
        } else if(input >= 0x41 && input <= 0x46) {
            return uint8(input) - 0x37;
        } else if(input >= 0x61 && input <= 0x67) {
            return uint8(input) - 0x57;
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
    function decode(string input) public pure returns(bytes output) {
        require(bytes(input).length % 2 == 0);
        output = new bytes(bytes(input).length / 2);
        for(uint i = 0; i < output.length; i++) {
            output[i] = byte((hexchr(bytes(input)[i * 2]) << 4) | hexchr(bytes(input)[i * 2 + 1]));
        }
    }
}
