import Foundation

var LOAD_DIR = ".";
print("* Beginning Server, Root Directory: \(LOAD_DIR)\n")
FileManager.default.changeCurrentDirectoryPath(LOAD_DIR)
let ServerSocket = ContructTCPSocket(portNumber: 1337)
runThreads()
