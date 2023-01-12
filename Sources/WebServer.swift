//
//  WebServer.swift
//
//
//  Created by Tomasz on 12/01/2023.
//

import Foundation
import Swifter

public class WebServer {
    private let logTag = "📟 WebServer"
    private let server: HttpServer
    private let workingDir: String

    public init(absoluteWorkingDir: String) {
        self.workingDir = "/" + absoluteWorkingDir.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/"
        self.server = HttpServer()
        self.initEndpoints()
    }

    public func start(port: UInt16) {
        do {
            try self.server.start(port, forceIPv4: true)
            Logger.v(self.logTag, "HttpServer has started on port = \(try self.server.port()), workDir = \(self.workingDir)")
            dispatchMain()
        } catch {
            Logger.e(self.logTag, "HttpServer start error: \(error)")
        }
    }

    private func initEndpoints() {
        // url: http://[server]:[port]/{filename}
        self.server.PUT["*"] = { request, _ in
            request.disableKeepAlive = true
            guard let filename = request.path.components(separatedBy: "/").last else {
                return .badRequest(.text("Missing filename"))
            }
            let path = self.workingDir + filename
            Logger.v(self.logTag, "Saved file \(filename) as \(path)")
            if FileManager.default.createFile(atPath: path, contents: Data(request.body)) {
                return .accepted
            }
            return .internalServerError
        }

        // url: http://[server]:[port]/{filename}
        self.server.GET["*"] = { request, responseHeaders in
            request.disableKeepAlive = true
            guard let filename = request.path.components(separatedBy: "/").last else {
                return .badRequest(.text("Missing filename"))
            }
            let filePath = self.workingDir + filename
            if FileManager.default.fileExists(atPath: filePath) {
                guard let file = try? filePath.openForReading() else {
                    Logger.e(self.logTag, "Could not open `\(filePath)`")
                    return .notFound
                }
                let mimeType = filePath.mimeType()
                responseHeaders.addHeader("Content-Type", mimeType)

                if let attr = try? FileManager.default.attributesOfItem(atPath: filePath),
                   let fileSize = attr[FileAttributeKey.size] as? UInt64 {
                    responseHeaders.addHeader("Content-Length", String(fileSize))
                }

                return .raw(200, "OK", { writer in
                    try writer.write(file)
                    file.close()
                })
            }
            Logger.e(self.logTag, "File `\(filePath)` doesn't exist")
            return .notFound
        }

        self.server.DELETE["*"] = { request, responseHeaders in
            request.disableKeepAlive = true
            guard let filename = request.path.components(separatedBy: "/").last else {
                return .badRequest(.text("Missing filename"))
            }
            let filePath = self.workingDir + filename
            if FileManager.default.fileExists(atPath: filePath) {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                    Logger.v(self.logTag, "Removed file \(filePath)")
                    return .accepted
                } catch {
                    Logger.e(self.logTag, "Delete error: \(error)")
                    return .internalServerError
                }
            }
            Logger.e(self.logTag, "File `\(filePath)` doesn't exist")
            return .notFound
        }

        self.server.middleware.append { [weak self] request, _ in
            Logger.v(self?.logTag, "Incoming request \(request.method) \(request.path)")
            return nil
        }
    }
}
