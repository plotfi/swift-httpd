#include <thread>
#include <vector>

extern "C" void *Producer(void *);
extern "C" void *Consumer(void *);

extern "C" void runThreads(int s) {
  std::thread producerThread([&]() {
    return Producer(&s);
  });
  std::vector<std::thread> consumerThreads;
  for (unsigned i = 0; i < 8; ++i)
    consumerThreads.push_back(
        std::move(std::thread([&]() {
          return Consumer(nullptr);
        })));
  while (getchar() != 'q')
    printf("* Server Started, Enter q to Quit *\n\n");
}
