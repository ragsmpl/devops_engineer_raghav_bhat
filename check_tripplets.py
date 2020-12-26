#User function Template for python3
class Solution:
    def countTriplet(self, arr, n):
        count_tripplets = 0
        for i in range(n):
            for j in range(i+1,n):
                sum = arr[i]+arr[j]
                if sum in arr:
                    count_tripplets += 1
        return count_tripplets


#{ 
#  Driver Code Starts
#Initial Template for Python 3

if __name__ == '__main__':
	T=int(input())
	for i in range(T):
		n = int(input())
		arr = [int(x) for x in input().split()]

		ob = Solution()
		ans = ob.countTriplet(arr, n)
		print(ans)

# } Driver Code Ends
