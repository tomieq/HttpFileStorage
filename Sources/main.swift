import Foundation
import Dispatch

guard let workingDir = ArgumentParser.getValue(argument: "workingDir") else {
    Logger.e("main", "Missing lunch param `workingDir` whick is absolute path")
    exit(1)
}

var port: UInt16 = 8080
if let forcedPort = ArgumentParser.getValue(argument: "port"), let number = UInt16(forcedPort) {
    port = number
}

// by default server can save and read only from workingDir folder(without subdirectories)
var allowSubdirs = false
if let forcedAllowSubdirs = ArgumentParser.getValue(argument: "allowSubdirs") {
    allowSubdirs = forcedAllowSubdirs == "true"
}

let server = WebServer(absoluteWorkingDir: workingDir, allowSubdirs: allowSubdirs)
server.start(port: port)

dispatchMain()
