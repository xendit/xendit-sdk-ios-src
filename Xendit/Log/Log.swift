//
//  Log.swift
//  Xendit
//
//  Created by Vladimir Lyukov on 23/10/2018.
//

import Foundation


@objc(XENLogLevel) public enum XenditLogLevel: UInt {
    case verbose, info, warning, error
}


internal class Log {
    static let shared = Log()

    public var level: XenditLogLevel? = .info
    public var logDNALevel: ISHLogDNALevel? = .warn

    let sanitizer = LogSanitizer()

    init() {
        ISHLogDNAService.setup(withIngestionKey: "db91ce0574a2ef343bd753485b81b0bd", hostName: "xendit.co", appName: "iOS SDK")
    }

    func log(_ level: XenditLogLevel = .info, _ message: String) {
        guard let lvl = self.level, level.rawValue >= lvl.rawValue else {
            return
        }
        print("[xendit] \(message)")
    }

    func verbose(_ message: String) {
        log(.verbose, message)
    }

    func logUrlResponse(prefix: String, request: URLRequest, requestBody: [String: Any]?, data: Data?, response: URLResponse?, error: Error?) {
        verbose("\(prefix) finished request")
        let dataString: String?
        if let data = data {
            dataString = String(data: data, encoding: .utf8)
        } else {
            dataString = nil
        }
        if let response = response as? HTTPURLResponse {
            log(.info, "response: \(response.statusCode) \(response.url?.absoluteString ?? "n/a")")
            log(.verbose, "headers: \(response.allHeaderFields as? [String: String] ?? [:])")

            let logDNAlevel: ISHLogDNALevel
            switch response.statusCode {
            case (500...): logDNAlevel = .error
            case (400...): logDNAlevel = .warn
            default: logDNAlevel = .info
            }
            let message = ISHLogDNAMessage(
                line: "\(response.statusCode): \(request.httpMethod ?? "n/a") \(request.url?.absoluteString ?? "n/a")",
                level: logDNAlevel,
                meta: [
                    "hostAppBundleId": Bundle.main.bundleIdentifier ?? "n/a",
                    "frameworkVersion": Bundle(for: Xendit.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "n/a",
                    "statusCode" : response.statusCode,
                    "requestURL": request.url?.absoluteString ?? "",
                    "requestBody": sanitizer.sanitizeRequestBody(requestBody ?? [:]),
                    "responseHeaders": (response.allHeaderFields as? [String: String]) ?? [:],
                    "responseBody": dataString ?? ""
                ]
            )
            logDNASend(message)
        }
        if let dataString = dataString {
            verbose("data: \(dataString)")
        }
        if let error = error {
            verbose("error: \(error)")
        }
    }

    func logDNASend(_ message: ISHLogDNAMessage) {
        guard let level = logDNALevel, message.level.rawValue >= level.rawValue else {
            return
        }
        ISHLogDNAService.logMessages([message])
    }
}
