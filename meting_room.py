#User function Template for python3

def maximumMeetings(n,start,end):
    '''
    :param n: number of activities
    :param start: start time of activities
    :param end: corresponding end time of activities
    :return: Integer, maximum number of activities
    '''

    tmp_end_time = [end[0]]
    for i in range(len(end)):
        for j in range(i+1,len(end)):
            if end[i] > end[j]:
                tmp_S = start[i]
                tmp_E = end[i]
                start[i] = start[j]
                end[i] = end[j]
                start[j] = tmp_S
                end[j] = tmp_E
    print(1, end=' ')
    for y in range(1,len(end)):
        if start[y] < tmp_end_time[0]:
            pass
        else:
            print(y+1, end=' ')
            tmp_end_time[0] = end[y]

        
            




#{ 
#  Driver Code Starts
#Initial Template for Python 3
import atexit
import io
import sys

#Contributed by : Nagendra Jha

if __name__ == '__main__':
    test_cases = int(input())
    for cases in range(test_cases) :
        n = int(input())
        start = list(map(int,input().strip().split()))
        end = list(map(int,input().strip().split()))
        maximumMeetings(n,start,end)
# } Driver Code Ends
