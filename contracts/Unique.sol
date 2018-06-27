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
        // Competition gas: 202359
        
        // Clear all memory
        mstore(0x40, 0)
        
        let l := calldataload(36)
        jumpi(main, l)
        
        // Empty list
        mstore(0, 32)
        mstore(32, 0)
        return(0, 64)
        
    main:
        let ptr := 64
        let i := 68
        // 16 197746
        // 17 197561
        // 18 196644
        // 19 196804
        // 20 196451
        // 21 196735
        // 22 197306
        let htl := mul(add(l, l), 32) // div(mul(l, 20), 10)
        let scale := add(div(sub(0, htl), htl), 1)
        let last1 := 0xed6d961a586550c76591d3943b3c6f76b621934aa7ffad3360fac1cf4aa0473f
        let last2 := 0xed6d961a586550c76591d3943b3c6f76b621934aa7ffad3360fac1cf4aa0473f
        //let last3 := 0xed6d961a586550c76591d3943b3c6f76b621934aa7ffad3360fac1cf4aa0473f
        //let last4 := 0xed6d961a586550c76591d3943b3c6f76b621934aa7ffad3360fac1cf4aa0473f
        
        let value
        let vhash
        let index1
        let index2
        let iv
    oloop:
        {
            // Read value
            value := calldataload(i)
            
            // Check recent values
            jumpi(seen, or(eq(value, last1), eq(value, last2)))
            //jumpi(seen, eq(value, last2))
            //jumpi(seen, eq(value, last3))
            //jumpi(seen, eq(value, last4))
            //last4 := last3
            //last3 := last2
            last2 := last1
            last1 := value
            
            // Offset value so we don't get zeros
            vhash := add(value,
0xed6d961a586550c76591d3943b3c6f76b621934aa7ffad3360fac1cf4aa0473f
            )
            
            // Compute index 1
            index1 := add(and(div(mul(vhash,
0xb7094513c3a0a2641751087acb3855f3c0a80be7260acdf01a49b4661672cb23
            ), scale), 0xFFFFFFFFFFFFFE0), calldatasize)
            
            // Read index 1
            iv := mload(index1)
            jumpi(unique1, iszero(iv))
            jumpi(seen, eq(iv, vhash))
            
            // Increment and test index 1
            index1 := add(index1, 32)
            iv := mload(index1)
            jumpi(unique1, iszero(iv))
            jumpi(seen, eq(iv, vhash))
            
            // Compute index 2
            index2 := add(and(div(mul(vhash,
0x1b6d296aa8b7284041b9f0e36895d18399d8026b57a51e5af0ed54c3e03bd3a1
            ), scale), 0xFFFFFFFFFFFFFE0), calldatasize)
            
            // Read index 2
            iv := mload(index2)
            jumpi(unique2, iszero(iv))
            jumpi(seen, eq(iv, vhash))
            
        iloop:
            // Increment and test index 1
            index1 := add(index1, 32)
            iv := mload(index1)
            jumpi(unique1, iszero(iv))
            jumpi(seen, eq(iv, vhash))
            
            // Incerment and test index 2
            index2 := add(index2, 32)
            iv := mload(index2)
            jumpi(unique2, iszero(iv))
            jumpi(seen, eq(iv, vhash))
            
            // Increment and test index 1
            index1 := add(index1, 32)
            iv := mload(index1)
            jumpi(unique1, iszero(iv))
            jumpi(seen, eq(iv, vhash))
            
            // Incerment and test index 2
            index2 := add(index2, 32)
            iv := mload(index2)
            jumpi(unique2, iszero(iv))
            jumpi(seen, eq(iv, vhash))
            
            // Loop
            jump(iloop)
        
        unique2:
            // Add to the hash table
            mstore(index2, vhash)
            
            // Add to start of list
            mstore(ptr, value)
            ptr := add(ptr, 32)
            jump(seen)
            
        unique1:
            // Add to the hash table
            mstore(index1, vhash)
            
            // Add to start of list
            mstore(ptr, value)
            ptr := add(ptr, 32)
        
        seen:
        }
            
    // oloop_continue:
        i := add(i, 32)
        jumpi(oloop, lt(i, calldatasize))
        
    // oloop_end:
        mstore(0, 32)
        mstore(32, div(sub(ptr, 64), 32))
        return(0, ptr)
    }}
    
}
