import Foundation

var LOAD_DIR = "."
print("* Beginning Server, Root Directory: \(LOAD_DIR)\n")
FileManager.default.changeCurrentDirectoryPath(LOAD_DIR)

// Sets up networking sockets used by Producer thread to AcceptConnection
let ServerSocket = ContructTCPSocket(portNumber: 1337)
defer { close(ServerSocket); }

// Grab the client socket requests and process them async
while true {
  let ClientSocket = AcceptConnection(Socket: ServerSocket)

  Task {
    await HandleRequest(ClientSocket)
  } 
}

func HandleRequest(_ ClientSocket : CInt) async {
  let Buffer = ReadFromSocket(ClientSocket)
  let ClientSocketAsFile = fdopen(ClientSocket, "w")
  let _ = http_proto(socket: ClientSocketAsFile, request: Buffer)
  fclose(ClientSocketAsFile)
  close(ClientSocket)
}