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
            
            let largest
            let l
            let r
            let ival
            let lval
            let tval
            
        loop:
            
            l := add(mul(2, i), 1)
            r := add(mul(2, i), 2) // add(l, 1)
            
            // TODO: Move out of loop
            ival := mload(add(mul(i, 32), add(arr, 32)))
            
            // Start with the root as largest
            largest := i
            lval := ival
            
            // If left child is larger than root
            tval := mload(add(mul(l, 32), add(arr, 32)))
            if and(lt(l, n), gt(tval, lval)) {
                largest := l
                lval := tval
            }
            
            // If right child is larger than largest so far
            tval := mload(add(mul(r, 32), add(arr, 32)))
            if and(lt(r, n), gt(tval, lval)) {
                largest := r
                lval := tval
            }
            
            // If root is largest we are done
            jumpi(end, eq(largest, i))
            
            // Swap largest with root
            mstore(add(mul(i,       32), add(arr, 32)), lval)
            mstore(add(mul(largest, 32), add(arr, 32)), ival)
            
            // Repeat for subtree starting at largest
            i := largest
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
