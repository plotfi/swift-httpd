
#include <queue>
#include <thread>

template <class T> class SyncQueue {
private:
  std::mutex mutex;
  std::condition_variable cv;
  std::queue<T> syncQueue;

public:
  void enqueue(T t) {
    std::unique_lock<std::mutex> lock(mutex);
    syncQueue.push(t);
    cv.notify_all();
  }
  T dequeue() {
    std::unique_lock<std::mutex> lock(mutex);
    while (!syncQueue.size())
      cv.wait(lock);
    T t = syncQueue.front();
    syncQueue.pop();
    return t;
  }
};

extern "C"
void *MakeSocketQueue() {
  return new SyncQueue<int>();
}

extern "C"
void DestroySocketQueue(void *Queue) {
  delete(static_cast<SyncQueue<int>*>(Queue));
}

extern "C"
void EnqueueSocket(int s, void *Queue) {
  static_cast<SyncQueue<int>*>(Queue)->enqueue(s);
}

extern "C"
int DequeueSocket(void *Queue) {
  return static_cast<SyncQueue<int>*>(Queue)->dequeue();
}