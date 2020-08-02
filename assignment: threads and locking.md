######
# in-class assignment: Threads and locking

## explanation:
**main** function create thread through **pthread_create**
**thread** function puts key and value in thread table through **put**
**thread** function identifies thread by getting the thread key.

**k** is the number of the key which is missing.

## Questions.
### Why are there missing keys with 2 or more threads, but not with 1 thread? 
I think the problem is happend in the **insert** function. if two threads run almost at the same time. when they run at the line ** *p = e **; 
the table can only record the node in the last thread, which means that it would lose the node in the first thread.
To solve this problem, it is needed to add lock.
