#include <exception>
#include <iostream>
#include <thread>
#include <vector>

extern "C" void *Producer(void *);
extern "C" void *Consumer(void *);

extern "C" auto runThreads(int s) -> void {

  std::thread ProducerThread([&]() { return Producer(&s); });

  std::vector<std::thread> ConsumerThreads;
  for (unsigned i = 0; i < 1; ++i)
    ConsumerThreads.push_back(
        std::move(std::thread([&]() { return Consumer(nullptr); })));

  do {
    std::cout << "* Server Started, Enter q to Quit *\n";
  } while (getchar() != 'q');

#if defined(__linux__) || defined(__APPLE__)
  std::cout << "* Abruptly Attempting to Kill All Threads... Goodbye *\n";
  auto ProducerHandle = ProducerThread.native_handle();
  pthread_kill(ProducerHandle, 0);
  for (auto &ConsumerThread : ConsumerThreads) {
    auto ConsumerHandle = ConsumerThread.native_handle();
    pthread_kill(ConsumerHandle, 0);
  }
#endif
}
