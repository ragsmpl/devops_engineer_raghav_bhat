#https://pypi.org/project/dirsync/

from dirsync import sync
source_p = '/Source/Folder'
target_p = '/Target/Folder'

sync(source_p, target_p, 'sync') #for syncing one way
sync(target_p, source_p, 'sync') #for syncing the opposite way
