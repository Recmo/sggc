pragma solidity 0.4.24;

contract Sort {
    
    // @author Remco Bloemen <remco@wicked.ventures>
    
    function sort(uint[] input) public view returns(uint[]) {
        heapSort(input, input.length);
        return input;
    }
    
    function heapSort(uint[] arr, uint n)
        internal view
    {
        int i;
        
        // Build heap (rearrange array)
        for (i = int(n) / 2 - 1; i >= 0; i--) {
            assembly {
                
                let base
                let iaddr // Root
                let ival
                let maddr // Maximum
                let mval
                let taddr // Temporary
                let tval
                
                base := add(arr, 32)
                iaddr := add(mul(i, 32), base)
                ival := mload(iaddr)
                
            loop:
                
                // Start with the root as largest
                maddr := iaddr
                mval := ival
                
                // If left child is larger than root
                taddr := add(base, mul(sub(iaddr, base), 2))
                tval := mload(taddr)
                if gt(tval, mval) {
                    maddr := taddr
                    mval := tval
                }
                
                // If right child is larger than largest so far
                taddr := add(taddr, 32)
                tval := mload(taddr)
                if gt(tval, mval) {
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
        
        // One by one extract an element from heap
        for (i = int(n) - 1; i >= 0; i--)
        {
            // Move current root to end
            (arr[0], arr[uint(i)]) = (arr[uint(i)], arr[0]);
     
            // call max heapify on the reduced heap
            assembly {
                
                let base
                let top
                let iaddr // Root
                let ival
                let maddr // Maximum
                let mval
                let taddr // Temporary
                let tval
                
                base := add(arr, 32)
                top := add(mul(i, 32), base)
                iaddr := base
                ival := mload(iaddr)
                
            loop:
                
                // Start with the root as largest
                maddr := iaddr
                mval := ival
                
                // If left child is larger than root
                taddr := add(base, mul(sub(iaddr, base), 2))
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
    }
}
