import Foundation

var LOAD_DIR = "/Users/plotfi/Desktop"
print("* Beginning Server, Root Directory: \(LOAD_DIR)\n")
FileManager.default.changeCurrentDirectoryPath(LOAD_DIR)

// Sets up networking sockets used by Producer thread to AcceptConnection
let ServerSocket = ContructTCPSocket(portNumber: 1337)
defer { close(ServerSocket); }

var requestId: uint = 0

// Grab the client socket requests and process them async
while true {
    if #available(macOS 10.15, *) {
        let ClientSocket = AcceptConnection(Socket: ServerSocket)
        print("await request \(requestId)")
        requestId += 1
        Task {
            await HandleRequest(ClientSocket, requestId)
        }
    } else {
        // Fallback on earlier versions
        print("swift-httpd uses swift async/await and requires macOS 10.15 or later.")
        print("Goodbye...")
        break
    } 
}

@available(macOS 10.15.0, *)
func HandleRequest(_ ClientSocket : CInt, _ ID: uint) async {
  let Buffer = ReadFromSocket(ClientSocket)

  let ClientSocketAsFile = fdopen(ClientSocket, "w")
  defer {
    fclose(ClientSocketAsFile)
    close(ClientSocket)
  }

  let status = http_proto(socketFile: ClientSocketAsFile, request: Buffer)

  print("Handled request \(ID) with status \(status)")
}
