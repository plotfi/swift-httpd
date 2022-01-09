import Foundation

let MaxRequests: Int32 = 5
let RecvBufferLength = 100

func ContructTCPSocket(portNumber: UInt16) -> Int32 {
  var SocketAddress = sockaddr_in()
  bzero(&SocketAddress, MemoryLayout.size(ofValue: SocketAddress))
  SocketAddress.sin_family = sa_family_t(AF_INET)
  SocketAddress.sin_addr.s_addr = INADDR_ANY.bigEndian
  SocketAddress.sin_port = portNumber.bigEndian

  var SocketAddressGeneric = sockaddr()
  let SocketAddressGenericSize = MemoryLayout.size(ofValue: SocketAddressGeneric)
  memcpy(&SocketAddressGeneric, &SocketAddress, SocketAddressGenericSize)

  let Socket = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP)
  if Socket == -1 {
    print("Error opening socket: \(errno)")
    return -1
  }

  var SocketOptions: Int32 = 1
  setsockopt(Socket, SOL_SOCKET, SO_REUSEADDR, &SocketOptions, 4)

  let Bind = bind(
    Socket, &SocketAddressGeneric,
    socklen_t(SocketAddressGenericSize))
  if Bind == -1 {
    print("Error binding socket to address: \(errno)")
    return -1
  }

  listen(Socket, MaxRequests)
  return Socket
}

func ReadFromSocket(_ socket: Int32) -> [CChar] {
  let buffer = UnsafeMutablePointer<UInt8>
    .allocate(capacity: RecvBufferLength)
  defer { buffer.deallocate() }

  var TotalBuffer = [CChar]()
  var newBytes = 0

  repeat {
    bzero(buffer, RecvBufferLength)
    newBytes = read(socket, buffer, RecvBufferLength)

    for i in 0..<newBytes {
      TotalBuffer.append(CChar(buffer[i]))
    }
  } while newBytes >= RecvBufferLength

  return TotalBuffer
}

func AcceptConnection(Socket: Int32) -> Int32 {
  var SocketAddress = sockaddr()
  var len: socklen_t = socklen_t(MemoryLayout.size(ofValue: SocketAddress))
  let ClientSocket = accept(Socket, &SocketAddress, &len)
  print("Handling client \(ClientSocket)\n")
  return ClientSocket
}
