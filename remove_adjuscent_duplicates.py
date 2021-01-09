def remove_dup(S):
    S_lst = list(S)
    for i in range(len(S)-1):
        if S_lst[i] != "to_be_deleted":
            if S_lst[i] == S_lst[i+1]:
                S_lst[i] = "to_be_deleted"
                S_lst[i+1] = "to_be_deleted"
        else:
            continue
    for x in S_lst:
        if x != "to_be_deleted":
            print(x, end='')
    

    
if __name__ == '__main__':
	T=int(input())
	if T >= 1 and T <= 100:
	    
	    for i in range(T):
		    St = list(input().split())
		    for S in St:
		        if len(S) >= 1 and len(S) <= 50:
		            remove_dup(S)
