import Foundation
import CSHIM

var LOAD_DIR = ".";
print("* Beginning Server, Root Directory: \(LOAD_DIR)\n")
FileManager.default.changeCurrentDirectoryPath(LOAD_DIR)
runThreads(ContructTCPSocket(portNumber: 1337))