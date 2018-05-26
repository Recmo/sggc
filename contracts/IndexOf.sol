/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity ^0.4.23;

contract IndexOf {

    uint256 constant firstBits = 0x0101010101010101010101010101010101010101010101010101010101010101;
    
    uint256 constant firstByte = 0x0100000000000000000000000000000000000000000000000000000000000000;

    function indexOf(string haystack, string needle)
        public pure
        returns(int)
    {
        bytes memory n = bytes(needle);
        uint256 nl = n.length;
        if (nl == 0) {
            return 0;
        }
        bytes memory h = bytes(haystack);
        uint256 hl = h.length;
        if (nl > hl) {
            return -1;
        }
        bytes32 needleHash = keccak256(n);
        
        // Compute first byte vector
        uint256 fb = uint256(n[0]) * firstBits;
        
        uint256 end = hl - nl;
        uint256 i = 0;
        bytes32 haydig;
        while (i <= end) {
            
            // Find next potential matching point
            uint256 value;
            assembly {
                value := mload(add(h, add(32, i)))
            }
            uint256 matchb = ~(value ^ fb);
            matchb &= matchb / 16;
            matchb &= matchb / 4;
            matchb &= matchb / 2;
            matchb &= firstBits;
            
            if (matchb & firstByte != 0) {
                
                // Compare for equality
                assembly {
                    haydig := keccak256(add(h, add(32, i)), nl)
                }
                if(haydig == needleHash) {
                    return int(i);
                }
                i++;
                continue;
            }
            
            if (matchb < 2**128) {
                if (matchb < 2**64) {
                    if (matchb < 2**32) {
                        if (matchb < 2**16) {
                            if (matchb < 2**8) {
                                i += 1;
                            } else {
                                i += 2;
                            }
                        } else {
                            if (matchb < 2**(8 + 16)) {
                                i += 3;
                            } else {
                                i += 4;
                            }
                        }
                    } else {
                        if (matchb < 2**(16 + 32)) {
                            if (matchb < 2**(8 + 32)) {
                                i += 5;
                            } else {
                                i += 6;
                            }
                        } else {
                            if (matchb < 2**(8 + 32 + 16)) {
                                i += 7;
                            } else {
                                i += 8;
                            }
                        }
                    }
                } else {
                    if (matchb < 2**(32 + 64)) {
                        if (matchb < 2**(16 + 64)) {
                            if (matchb < 2**(8 + 64)) {
                                i += 9;
                            } else {
                                i += 10;
                            }
                        } else {
                            if (matchb < 2**(8 + 16 + 64)) {
                                i += 11;
                            } else {
                                i += 12;
                            }
                        }
                    } else {
                        if (matchb < 2**(16 + 32 + 64)) {
                            if (matchb < 2**(8 + 32 + 64)) {
                                i += 13;
                            } else {
                                i += 14;
                            }
                        } else {
                            if (matchb < 2**(8 + 32 + 16 + 64)) {
                                i += 15;
                            } else {
                                i += 16;
                            }
                        }
                    }
                }
            } else {
                if (matchb < 2**(64 + 128)) {
                    if (matchb < 2**(32 + 128)) {
                        if (matchb < 2**(16 + 128)) {
                            if (matchb < 2**(8 + 128)) {
                                i += 17;
                            } else {
                                i += 18;
                            }
                        } else {
                            if (matchb < 2**(8 + 16 + 128)) {
                                i += 19;
                            } else {
                                i += 20;
                            }
                        }
                    } else {
                        if (matchb < 2**(16 + 32 + 128)) {
                            if (matchb < 2**(8 + 32 + 128)) {
                                i += 21;
                            } else {
                                i += 22;
                            }
                        } else {
                            if (matchb < 2**(8 + 32 + 16 + 128)) {
                                i += 23;
                            } else {
                                i += 24;
                            }
                        }
                    }
                } else {
                    if (matchb < 2**(32 + 64 + 128)) {
                        if (matchb < 2**(16 + 64 + 128)) {
                            if (matchb < 2**(8 + 64 + 128)) {
                                i += 25;
                            } else {
                                i += 26;
                            }
                        } else {
                            if (matchb < 2**(8 + 16 + 64 + 128)) {
                                i += 27;
                            } else {
                                i += 28;
                            }
                        }
                    } else {
                        if (matchb < 2**(16 + 32 + 64 + 128)) {
                            if (matchb < 2**(8 + 32 + 64 + 128)) {
                                i += 29;
                            } else {
                                i += 30;
                            }
                        } else {
                            if (matchb < 2**(8 + 32 + 16 + 64 + 128)) {
                                i += 31;
                            } else {
                                i += 32;
                            }
                        }
                    }
                }
            }
            
            // Compare for equality
            assembly {
                haydig := keccak256(add(h, add(32, i)), nl)
            }
            if(haydig == needleHash) {
                return int(i);
            }
        }
        return -1;
    }
}
