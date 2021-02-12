
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

namespace {
SyncQueue<int> Queue;
}

extern "C" void enqueue(int s) { Queue.enqueue(s); }
extern "C" int dequeue() { return Queue.dequeue(); }