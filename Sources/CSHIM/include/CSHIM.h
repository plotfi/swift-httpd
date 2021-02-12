#ifndef CSHIM_H
#define CSHIM_H
void *MakeSocketQueue();
void DestroySocketQueue(void *Queue);
void EnqueueSocket(int s, void *Queue);
int DequeueSocket(void *Queue);
void runThreads(int);
#endif
