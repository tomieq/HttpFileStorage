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

let server = WebServer(absoluteWorkingDir: workingDir)
server.start(port: port)

dispatchMain()
