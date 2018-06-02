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
        while (true) {
            uint largest = i;    // Initialize largest as root
            uint l = 2 * i + 1;  // left = 2*i + 1
            uint r = 2 * i + 2;  // right = 2*i + 2
        
            // If left child is larger than root
            if (l < n && arr[l] > arr[largest])
                largest = l;

            // If right child is larger than largest so far
            if (r < n && arr[r] > arr[largest])
                largest = r;
                
            if (largest == i) {
                return;
            }

            // Swap largest with root
            (arr[i], arr[largest]) = (arr[largest], arr[i]);
            
            // Heapify the affected sub-tree
            i = largest;
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
