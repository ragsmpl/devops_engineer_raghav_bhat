#User function Template for python3

# arr[]: Input Array
# N : Size of the Array arr[]

def inversionCount(a,n):
    # Your Code Here
    count_inversion = 0
    counter = 1
    while (counter):
        for i in range(n-1):
            if a[i] > a[i+1]:
                count_inversion += 1
                tmp = a[i+1]
                a[i+1] = a[i]
                a[i] = tmp
                break
        else:
            counter = 0

    return count_inversion
        


#{ 
#  Driver Code Starts
#Initial Template for Python 3

import atexit
import io
import sys

_INPUT_LINES = sys.stdin.read().splitlines()
input = iter(_INPUT_LINES).__next__
_OUTPUT_BUFFER = io.StringIO()
sys.stdout = _OUTPUT_BUFFER

@atexit.register

def write():
    sys.__stdout__.write(_OUTPUT_BUFFER.getvalue())

if __name__=='__main__':
    t = int(input())
    for tt in range(t):
        n = int(input())
        a = list(map(int, input().strip().split()))
        print(inversionCount(a,n))
# } Driver Code Ends
