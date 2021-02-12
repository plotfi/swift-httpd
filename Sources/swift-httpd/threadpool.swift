import Foundation
import CSHIM

@_cdecl("Consumer")
func Consumer(pointer: UnsafeMutableRawPointer) ->
              UnsafeMutableRawPointer? {
  while true {
    let S = dequeue()
    if S < 0 {
      continue
    }
    print("[CONSUMER] Handling Socket \(S).\n")
    close(HttpProto(socket: S))
  }

  return nil
}

@_cdecl("Producer")
func Producer(pointer: UnsafeMutableRawPointer) ->
              UnsafeMutableRawPointer? {
  let Socket = pointer.load(as: Int32.self)
  while true {
    enqueue(AcceptConnection(Socket: Socket))
  }
  return nil
}
