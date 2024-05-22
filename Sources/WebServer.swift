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
    private let allowSubdirs: Bool

    public init(absoluteWorkingDir: String, allowSubdirs: Bool) {
        self.workingDir = "/" + absoluteWorkingDir.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + "/"
        self.server = HttpServer()
        self.allowSubdirs = allowSubdirs
        self.initEndpoints()
    }

    public func start(port: UInt16) {
        do {
            try self.server.start(port, forceIPv4: true)
            Logger.v(self.logTag, "HttpServer has started on port = \(try self.server.port()), workDir = \(self.workingDir), allowSubdirs: \(self.allowSubdirs)")
            dispatchMain()
        } catch {
            Logger.e(self.logTag, "HttpServer start error: \(error)")
        }
    }

    private func getFilePath(request: HttpRequest) -> String? {
        if self.allowSubdirs {
            return request.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        } else {
            return request.path.components(separatedBy: "/").last
        }
    }

    private func saveFile(request: HttpRequest, responseHeaders: HttpResponseHeaders) -> HttpResponse {
        request.disableKeepAlive = true
        guard let filename = getFilePath(request: request) else {
            return .badRequest(.text("Missing filename"))
        }
        let path = self.workingDir + filename
        if self.allowSubdirs {
            let pathComponents = path.components(separatedBy: "/")
            let absoluteDir = pathComponents[0..<pathComponents.count - 1].joined(separator: "/")
            try? FileManager.default.createDirectory(atPath: absoluteDir, withIntermediateDirectories: true)
        }
        if FileManager.default.createFile(atPath: path, contents: Data(request.body)) {
            Logger.v(self.logTag, "Saved file \(filename) as \(path)")
            return .accepted()
        }
        return .internalServerError()
    }

    private func getFile(request: HttpRequest, responseHeaders: HttpResponseHeaders) -> HttpResponse {
        request.disableKeepAlive = true
        guard let filename = getFilePath(request: request) else {
            return .badRequest(.text("Missing filename"))
        }
        let filePath = self.workingDir + filename
        if FileManager.default.fileExists(atPath: filePath) {
            guard let file = try? filePath.openForReading() else {
                Logger.e(self.logTag, "Could not open `\(filePath)`")
                return .notFound()
            }
            let mimeType = filePath.mimeType
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
        return .notFound()
    }

    private func removeFile(request: HttpRequest, responseHeaders: HttpResponseHeaders) -> HttpResponse {
        request.disableKeepAlive = true
        guard let filename = getFilePath(request: request) else {
            return .badRequest(.text("Missing filename"))
        }
        let filePath = self.workingDir + filename
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                try FileManager.default.removeItem(atPath: filePath)
                Logger.v(self.logTag, "Removed file \(filePath)")
                return .accepted()
            } catch {
                Logger.e(self.logTag, "Delete error: \(error)")
                return .internalServerError()
            }
        }
        Logger.e(self.logTag, "File `\(filePath)` doesn't exist")
        return .notFound()
    }

    private func initEndpoints() {
        // url: http://[server]:[port]/{filename}

        self.server.middleware.append { [unowned self] request, responseHeaders in
            Logger.v(self.logTag, "Incoming request \(request.method) \(request.path) from \(request.peerName.readable)")
            switch request.method {
            case .GET:
                return self.getFile(request: request, responseHeaders: responseHeaders)
            case .PUT:
                return self.saveFile(request: request, responseHeaders: responseHeaders)
            case .DELETE:
                return self.removeFile(request: request, responseHeaders: responseHeaders)
            default:
                return .notFound()
            }
        }
    }
}
