import Foundation

class SyncQueue<T> {
  var queue = [T]()
  var mutex = pthread_mutex_t()
  var cv = pthread_cond_t()
  
  init() {
    pthread_mutex_init(&mutex, nil)
    pthread_cond_init(&cv, nil)
  }
  
  func enqueue(_ t : T) {
    pthread_mutex_lock(&mutex)
    queue.append(t)
    pthread_mutex_unlock(&mutex)
    pthread_cond_signal(&cv)
  }
  
  func dequeue() -> T {
    pthread_mutex_lock(&mutex)
    while queue.count == 0 {
      pthread_cond_wait(&cv, &mutex)
    }
    
    let result = queue.removeFirst()
    pthread_mutex_unlock(&mutex)
    return result
  }
}

var sQueue = SyncQueue<Int32>()

func Consumer(pointer: UnsafeMutableRawPointer) ->
              UnsafeMutableRawPointer? {
  while true {
    let S = sQueue.dequeue()
    if S < 0 {
      continue
    }
    print("[CONSUMER] Handling Socket \(S).\n")
    close(HttpProto(socket: S))
  }

  return nil
}

func runThreads() {
  var Consumers = [pthread_t]()
  for _ in 0..<1 {
    var ThreadOpt: pthread_t? = nil
    let Result = pthread_create(&ThreadOpt, nil, Consumer, nil)
    if Result != 0 {
      print("Error creating thread--")
      exit(EXIT_FAILURE)
    }
    
    if let Thread = ThreadOpt {
      Consumers.append(Thread)
    } else {
      print("Error creating thread--")
      exit(EXIT_FAILURE)
    }
  }
  
  while true {
    sQueue.enqueue(AcceptConnection(Socket: ServerSocket))
  }
}
