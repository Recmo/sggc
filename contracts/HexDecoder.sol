/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity 0.4.24;

contract HexDecoder {

    //function () payable
    function decode(string) external payable returns(bytes)
    {
        uint256 ol;
        assembly {
            ol := div(calldataload(36), 2)
        }
        bytes memory output = new bytes(ol);
        for(uint i = 0; i < ol; i++) {
            
            uint8 a;
            uint8 b;
            assembly {
                let iaddr := add(38, mul(i, 2))
                let ab := calldataload(iaddr)
                a := and(div(ab, 0x100), 0xFF)
                b := and(ab, 0xFF)
            }
            
            a = (a & 0xf) + ((a / 64) * 9);
            b = (b & 0xf) + ((b / 64) * 9);
            output[i] = byte((a << 4) | b);
        }
        assembly {
            mstore(sub(output, 32), 32)
            return(sub(output, 32), add(ol, 64))
        }
    }
}
