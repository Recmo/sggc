pragma solidity 0.4.24;

contract Sort {
    
    // @author Remco Bloemen <remco@wicked.ventures>
    
    function sort(uint[] input) public view returns(uint[]) {
        heapSort(input, input.length);
        return input;
    }

    // To heapify a subtree rooted with node i which is
    // an index in arr[]. n is size of heap
    function heapify(uint[] arr, uint n, uint i)
        internal view
    {
        assembly {
            
            let top
            let iaddr // Root
            let ival
            let maddr // Maximum
            let mval
            let taddr // Temporary
            let tval
            
            arr := add(arr, 32)
            top := add(mul(n, 32), arr)
            iaddr := add(mul(i, 32), arr)
            ival := mload(iaddr)
            
        loop:
            
            // Start with the root as largest
            maddr := iaddr
            mval := ival
            
            // If left child is larger than root
            taddr := add(arr, mul(sub(iaddr, arr), 2))
            tval := mload(taddr)
            if and(lt(taddr, top), gt(tval, mval)) {
                maddr := taddr
                mval := tval
            }
            
            // If right child is larger than largest so far
            taddr := add(taddr, 32)
            tval := mload(taddr)
            if and(lt(taddr, top), gt(tval, mval)) {
                maddr := taddr
                mval := tval
            }
            
            // If root is largest we are done
            jumpi(end, eq(maddr, iaddr))
            
            // Swap largest with root
            mstore(iaddr, mval)
            mstore(maddr, ival)
            
            // Repeat for subtree starting at largest
            iaddr := maddr
            jump(loop)
            
        end:
        }
    }
    
    function heapSort(uint[] arr, uint n)
        internal view
    {
        int i;
        
        // Build heap (rearrange array)
        for (i = int(n) / 2 - 1; i >= 0; i--)
            heapify(arr, n, uint(i));
        
        // One by one extract an element from heap
        for (i = int(n) - 1; i >= 0; i--)
        {
            // Move current root to end
            (arr[0], arr[uint(i)]) = (arr[uint(i)], arr[0]);
     
            // call max heapify on the reduced heap
            heapify(arr, uint(i), 0);
        }
    }
}
