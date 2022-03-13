//
//  Log.swift
//  Xendit
//
//  Created by Vladimir Lyukov on 23/10/2018.
//

import Foundation
import WebKit


@objc(XENLogLevel) public enum XenditLogLevel: UInt {
    case verbose, info, warning, error
}


internal class Log {
    static let shared = Log()

    public var level: XenditLogLevel? = .info
    public var logDNALevel: ISHLogDNALevel? = .warn

    let sanitizer = LogSanitizer()

    init() {
        let LogDNAKey = ""
        if !LogDNAKey.isEmpty {
            ISHLogDNAService.setup(withIngestionKey: LogDNAKey, hostName: "xendit.co", appName: "iOS SDK")
        } else {
            ISHLogDNAService.enabled = false
        }
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

    func logUrlRequest(prefix: String, request: URLRequest, requestBody: [String: Any]?) {
        log(.verbose, "\(prefix) start request")
        log(.info, "request: \(request.httpMethod ?? "n/a") \(request.url?.absoluteString ?? "n/a")")
        if let requestBody = requestBody {
            log(.verbose, "request body: \(sanitizer.sanitizeRequestBody(requestBody))")
        }
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
            log(.info, "response: \(response.statusCode) \(request.httpMethod ?? "n/a") \(response.url?.absoluteString ?? "n/a")")
            log(.verbose, "headers: \(response.allHeaderFields as? [String: String] ?? [:])")

            let logDNAlevel: ISHLogDNALevel
            switch response.statusCode {
            case (500...): logDNAlevel = .error
            case (400...): logDNAlevel = .warn
            default: logDNAlevel = .info
            }
            logDNA(
                line: "\(response.statusCode): \(request.httpMethod ?? "n/a") \(request.url?.absoluteString ?? "n/a")",
                level: logDNAlevel,
                meta: [
                    "statusCode" : response.statusCode,
                    "requestURL": request.url?.absoluteString ?? "",
                    "requestBody": sanitizer.sanitizeRequestBody(requestBody ?? [:]),
                    "responseHeaders": (response.allHeaderFields as? [String: String]) ?? [:],
                    "responseBody": dataString ?? ""
                ]
            )
        }
        if let dataString = dataString {
            verbose("data: \(dataString)")
        }
        if let error = error {
            verbose("error: \(error)")
        }
    }

    func logUnexpectedWebScriptMessage(url: String, message: WKScriptMessage) {
        let messageBody: Any
        switch message.body {
        case is NSNumber, is NSString: messageBody = message.body
        case let date as NSDate: messageBody = date.description
        default:
            messageBody = JSONSerialization.isValidJSONObject(message.body) ? message.body : "<invalid JSON>"
        }
        logDNA(
            line: "Unexpected web script message",
            level: .error,
            meta: [
                "url": url,
                "name": message.name,
                "message": messageBody,
            ]
        )
    }

    fileprivate func logDNA(line: String, level: ISHLogDNALevel, meta: [String: Any]) {
        guard ISHLogDNAService.enabled else {
            return
        }
        guard let logDNALevel = logDNALevel, level.rawValue >= logDNALevel.rawValue else {
            return
        }
        let message = ISHLogDNAMessage(
            line: line,
            level: level,
            meta: meta.merging([
                "hostAppBundleId": Bundle.main.bundleIdentifier ?? "n/a",
                "frameworkVersion": Bundle(for: Xendit.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "n/a",
            ], uniquingKeysWith: { first, _ in first })
        )
        ISHLogDNAService.logMessages([message])
    }
}
