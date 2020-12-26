#User function Template for python3

##Complete this function
res = []
def rearrange(a,n):
    for i in range(len(a)):
        if a:
            i_max = max(a)
            i_min = min(a)
            res.append(i_max)
            res.append(i_min)
            a.remove(i_max)
            a.remove(i_min)

    print(res)



#{ 
#  Driver Code Starts
#Initial Template for Python 3

import math




def main():
        T=int(input())
        while(T>0):
            
            n=int(input())
            
            arr=[int(x) for x in input().strip().split()]
            
            rearrange(arr,n)
            
            for i in arr:
                print(i,end=" ")
            
            print()
            
            T-=1


if __name__ == "__main__":
    main()
# } Driver Code Ends
