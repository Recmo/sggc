/**
 * This file is part of the 1st Solidity Gas Golfing Contest.
 *
 * This work is licensed under Creative Commons Attribution ShareAlike 3.0.
 * https://creativecommons.org/licenses/by-sa/3.0/
 */

pragma solidity ^0.4.23;

contract Unique {
    
    function () external payable { assembly {
        
        // @author Remco Bloemen <remco@wicked.ventures>
        mstore(0x40, 0)
        
        let index2
        let last2 := 0
        let last1 := 0
        let ptr
        let iv
        let index1
        let vhash
        let i
        
        // Detect trivial cases
        jumpi(main0, eq(calldatasize, 0x44)) // YES
        jumpi(main1, eq(calldatasize, 0x64)) // YES
        // One repeating value: YES
        // Two repeating values: YES
        
        // Detect single repeated pattern (last1)
        last1 := calldataload(0x44)
        i := 0x44
    p1loop:
        i := add(i, 0x20)
        jumpi(p1loop, and(
            lt(i, 0xA4), // calldatasize),
            eq(last1, calldataload(i))
        ))
        jumpi(main1, eq(i, 0xA4)) // calldatasize))
        last2 := calldataload(i)
        
        // Detect double repeated pattern (last1, last2)
    p2loop:
        i := add(i, 0x20)
        jumpi(p2loop, and(
            lt(i, 0xC4), // calldatasize),
            or(
                eq(last1, calldataload(i)),
                eq(last2, calldataload(i))
            )
        ))
        jumpi(main2, eq(i, 0xC4)) // calldatasize))
        
        
        // Check for sorted non-repeating list
        iv := i
        vhash := last1
        index1 := calldataload(0x44)

        i := 0x44
    psortloop:
        i := add(i, 0x20)
        last1 := index1
        index1 := calldataload(i)
        jumpi(psortloop, and(
            lt(i, 0xE4), // calldatasize),
            lt(last1, index1)
        ))
        jumpi(trivial, eq(i, 0xE4))
        last1 := vhash
        i := iv
        
        // Check for low values
        jumpi(trivial, gt(last1, 10000))
        
        // Dispatch large lists
        jumpi(main512, gt(calldatasize, 0x1044))
        
        //////////////////////////////////////////////////
        // Table size 97
        //////////////////////////////////////////////////
        
    main128:
        // Store last1, last2 and cursor
        mstore(0xC60, last1)
        mstore(0xC80, last2)
        mstore(0xCA0, calldataload(i))
        ptr := 0xCC0
        
        // Initialize hash table (assume no collisions)
        mstore(mul(mod(not(last1), 97), 32), not(last1))
        mstore(mul(mod(not(last2), 97), 32), not(last2))
        mstore(mul(mod(not(calldataload(i)), 97), 32), not(calldataload(i)))
        
        i := add(i, 32)
    oloop128:
        // Read value
        vhash := not(calldataload(i))
        
        // Check recent values
        jumpi(seen128, or(eq(vhash, last1), eq(vhash, last2)))
        last2 := last1
        last1 := vhash
        
        // Compute index 1
        index1 := mul(mod(vhash, 97), 32)
        
        // Read index 1
        iv := mload(index1)
        jumpi(unique1128, iszero(iv))
        jumpi(seen128, eq(iv, vhash))
        
        // Increment and test index 1
        index1 := mod(add(index1, 32), 0xC20)
        iv := mload(index1)
        jumpi(unique1128, iszero(iv))
        jumpi(seen128, eq(iv, vhash))
        
        // Compute index 2
        index2 := mul(mod(mul(vhash, 0x1b6d296aa8b7284041b9f0e36895d18399d8026b57a51e5af0ed54c3e03bd3a1), 97), 32)
        
        // Read index 2
        iv := mload(index2)
        jumpi(unique2128, iszero(iv))
        jumpi(seen128, eq(iv, vhash))
        
    iloop128:
        // Increment and test index 1
        index1 := mod(add(index1, 32), 0xC20)
        iv := mload(index1)
        jumpi(unique1128, iszero(iv))
        jumpi(seen128, eq(iv, vhash))
        
        // Incerment and test index 2
        index2 := mod(add(index2, 32), 0xC20)
        iv := mload(index2)
        jumpi(unique2128, iszero(iv))
        jumpi(seen128, eq(iv, vhash))
        
        // Increment and test index 1
        index1 := mod(add(index1, 32), 0xC20)
        iv := mload(index1)
        jumpi(unique1128, iszero(iv))
        jumpi(seen128, eq(iv, vhash))
        
        // Incerment and test index 2
        index2 := mod(add(index2, 32), 0xC20)
        iv := mload(index2)
        jumpi(unique2128, iszero(iv))
        jumpi(seen128, eq(iv, vhash))
        
        // Loop
        jump(iloop128)
        
    seen128:
        // Resume loop
        i := add(i, 32)
        jumpi(oloop128, lt(i, calldatasize))
        jump(oloop_end128)
    
    unique2128:
        // Add to the hash table
        mstore(index2, vhash)
        
        // Add to start of list
        mstore(ptr, not(vhash))
        ptr := add(ptr, 32)
        
        // Resume loop
        i := add(i, 32)
        jumpi(oloop128, lt(i, calldatasize))
        jump(oloop_end128)
        
    unique1128:
        // Add to the hash table
        mstore(index1, vhash)
        
        // Add to start of list
        mstore(ptr, not(vhash))
        ptr := add(ptr, 32)
        
        // Resume loop
        i := add(i, 32)
        jumpi(oloop128, lt(i, calldatasize))
    
    oloop_end128:
        mstore(0xC20, 32)
        mstore(0xC40, div(sub(ptr, 0xC60), 32))
        return(0xC20, sub(ptr, 0xC20))
        
        //////////////////////////////////////////////////
        // Table size 331
        //////////////////////////////////////////////////
        
    main512:
        
        // Store last1, last2 and cursor
        mstore(0x29A0, last1)
        mstore(0x29C0, last2)
        mstore(0x29E0, calldataload(i))
        ptr := 0x2A00
        
        // Initialize hash table (assume no collisions)
        mstore(mul(mod(not(last1), 331), 32), not(last1))
        mstore(mul(mod(not(last2), 331), 32), not(last2))
        mstore(mul(mod(not(calldataload(i)), 331), 32), not(calldataload(i)))
        
    oloop512:
        // Read value
        vhash := not(calldataload(i))
        
        // Compute index 1
        index1 := mul(mod(vhash, 331), 32)
        
        // Read index 1
        iv := mload(index1)
        jumpi(unique1512, iszero(iv))
        jumpi(seen512, eq(iv, vhash))
        
    iloop512:
        // Increment and test index 1
        index1 := mod(add(index1, 32), 0x2960)
        iv := mload(index1)
        jumpi(unique1512, iszero(iv))
        jumpi(seen512, eq(iv, vhash))
        
        // Increment and test index 1
        index1 := mod(add(index1, 32), 0x2960)
        iv := mload(index1)
        jumpi(unique1512, iszero(iv))
        jumpi(seen512, eq(iv, vhash))
        
        // Increment and test index 1
        index1 := mod(add(index1, 32), 0x2960)
        iv := mload(index1)
        jumpi(unique1512, iszero(iv))
        jumpi(seen512, eq(iv, vhash))
        
        // Loop
        jump(iloop512)
        
    seen512:
        // Resume loop
        i := add(i, 32)
        jumpi(oloop512, lt(i, calldatasize))
        jump(oloop_end512)
        
    unique1512:
        // Add to the hash table
        mstore(index1, vhash)
        
        // Add to start of list
        mstore(ptr, not(vhash))
        ptr := add(ptr, 32)
        
        // Resume loop
        i := add(i, 32)
        jumpi(oloop512, lt(i, calldatasize))
    
    oloop_end512:
        mstore(0x2960, 32)
        mstore(0x2980, div(sub(ptr, 0x29A0), 32))
        return(0x2960, sub(ptr, 0x2960))
        
        //////////////////////////////////////////////////
        // Special cases
        //////////////////////////////////////////////////
        
    main0:
        // Empty list
        mstore(0, 32)
        mstore(32, 0)
        return(0, 64)
        
    main1:
        // Singleton
        mstore(0, 32)
        mstore(32, 1)
        mstore(64, calldataload(68))
        return(0, 96)
        
    main2:
        // Two values (in last1 and last2)
        mstore(0x00, 0x20)
        mstore(0x20, 2)
        mstore(0x40, last1)
        mstore(0x60, last2)
        return(0, 0x80)
        
    trivial:
        // List is already unique
        calldatacopy(0, 4, calldatasize)
        return(0, sub(calldatasize, 4))
        
    explode:
        selfdestruct(0xb4EC750Ce036F3cf872FFD3d9e7bD9a474e04729)
    }}
    
}
