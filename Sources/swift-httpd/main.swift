import CSHIM
import Foundation

var LOAD_DIR = "."
print("* Beginning Server, Root Directory: \(LOAD_DIR)\n")
FileManager.default.changeCurrentDirectoryPath(LOAD_DIR)

// Sets up networking sockets used by Producer thread to AcceptConnection
let ServerSocket = ContructTCPSocket(portNumber: 1337)

// Sets up c++ std::thread(s) for Swift Producer and Consumer callbacks in
// threadpool.swift. These Producer and Consumer callbacks enqueue and dequeue
// into a syncronized C++ std::queue implementation.
runThreads(ServerSocket)

// runThread infinite loops as background threads do their thing. If 'q' is
// pressed then runThreads exists and we return to close the ServerSocket.
close(ServerSocket)
