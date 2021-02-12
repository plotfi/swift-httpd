import Foundation
import CSHIM

class SocketQueue {
  private var SocketQueue = MakeSocketQueue()

  deinit {
    DestroySocketQueue(SocketQueue)
    SocketQueue = nil
  }

  func enqueue(_ Socket : Int32) {
    EnqueueSocket(Socket, SocketQueue)
  }

  func dequeue() -> Int32 {
    return DequeueSocket(SocketQueue)
  }
}

let Sockets = SocketQueue()

@_cdecl("Consumer")
func Consumer(pointer: UnsafeMutableRawPointer) ->
              UnsafeMutableRawPointer? {
  while true {
    let ClientSocket = Sockets.dequeue()
    if ClientSocket < 0 {
      continue
    }
    print("[CONSUMER] Handling Socket \(ClientSocket).\n")
    close(HttpProto(socket: ClientSocket))
  }

  return nil
}

@_cdecl("Producer")
func Producer(pointer: UnsafeMutableRawPointer) ->
              UnsafeMutableRawPointer? {
  let ServerSocket = pointer.load(as: Int32.self)
  while true {
    let ClientSocket = AcceptConnection(Socket: ServerSocket)
    Sockets.enqueue(ClientSocket)
  }
  return nil
}
