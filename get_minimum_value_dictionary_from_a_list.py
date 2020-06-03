#this was asked in an interview. To print a row in a list of the format shown, where if given value has lowest value.
table1 = [{'a':2, 'b':-1, 'c': 0},
           {'a':2, 'b':1, 'c': 1},
           {'a':2, 'b':0, 'c': 2}]

def minimumfunction(tablename,value):
    count = 0
    dictresult = {}
    for n in globals()[tablename]:
        print(n)
        Keymin = min(n, key=n.get)
        if Keymin == value:
            dictresult[count] = n[Keymin]
        count +=1
    if dictresult:    
      Keymin = min(dictresult, key=dictresult.get)  
      print(table1[Keymin])
    else:
      print("none")  

if __name__=="__main__":
  minimumfunction("table1","c")
