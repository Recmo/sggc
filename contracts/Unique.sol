/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity 0.4.24;

contract Unique {
    
    function () external payable { assembly {
        
        // @author Remco Bloemen <remco.bloemen@gmail.com>
        
        // Clear all memory
        mstore(0x40, 0)
        
        let l := calldataload(36)
        jumpi(main, l)
        mstore(0, 32)
        mstore(32, 0)
        return(0, 64)
        
    main:
        let endi := add(68, mul(l, 32))
        let ptr := 64
        let i := 68
        let ht := endi
        let htl := mul(l, 2)
        let scale := add(div(sub(0, htl), htl), 1)
        
    oloop:
        {
            let value
            let vhash
            let index
            let iv
            
            // Read value
            value := calldataload(i)
            
            // Compute index and index value
            vhash := mul(xor(value,
0x3cb610f2f269903047b2e6af9f5940b3ae7a667c7a5bc30f0e02a1b323a7fee1
            ),
0x3cb610f2f269903047b2e6af9f5940b3ae7a667c7a5bc30f0e02a1b323a7fee1
            )
            index := add(ht, mul(div(vhash, scale), 32))
            iv := mload(index)
            
            jumpi(unique, iszero(iv))
        iloop:
            jumpi(iblock_end, eq(iv, vhash))
            index := add(index, 32) // TODO: overflow
            iv := mload(index)
            jumpi(iloop, iv)
            
        unique:
            // Add to the hash table
            mstore(index, vhash)
            
            // Add to start of list
            mstore(ptr, value)
            ptr := add(ptr, 32)
            
        iblock_end:
        }
            
    oloop_continue:
        i := add(i, 32)
        jumpi(oloop, lt(i, endi))
        
    // oloop_end:
        mstore(0, 32)
        mstore(32, div(sub(ptr, 64), 32))
        return(0, ptr)
    }}
    
}
