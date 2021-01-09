def find_long_palindrome(S):
    longest_palindrome = [""]
    for i in range(len(S)):
        for j in range(i+1, len(S)+1):
            sub = S[i:j]
            
            if sub == sub[::-1]:

                if len(sub) > len(longest_palindrome[0]):
                    longest_palindrome[0] = sub
    print(longest_palindrome[0])
    
if __name__ == '__main__':
	T=int(input())
	for i in range(T):
		S = input()
		find_long_palindrome(S)
