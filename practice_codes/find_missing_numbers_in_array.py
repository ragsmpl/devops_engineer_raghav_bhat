

def MissingNumber(array,n):
    for i in range(1,n+1):
        if i not in array:
            return i



#{ 
#  Driver Code Starts
#Initial Template for Python 3




t=int(input())
for _ in range(0,t):
    n=int(input())
    a=list(map(int,input().split()))
    s=MissingNumber(a,n)
    print(s)
# } Driver Code Ends
