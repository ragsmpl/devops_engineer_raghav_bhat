def check_sub_list_sum(A,K):
    # store all the sublists
    B = [[]]
    for i in range(len(A) + 1):
        for j in range(i + 1, len(A) + 1):
            # get the sub list
            sub = A[i:j]
            if sum(sub) == K:
               print(sub)
            B.append(sub)
    return B


# driver code
A = [1, 2, 3, 4, 5]
K=12
check_sub_list_sum(A,K)
