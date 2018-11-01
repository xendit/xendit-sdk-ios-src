//
//  Log.swift
//  Xendit
//
//  Created by Vladimir Lyukov on 23/10/2018.
//

import Foundation


internal class Log {
    enum Level {
        case verbose, info, warning, error
    }
    static let shared = Log()

    var isEnabled = true

    init() {
        ISHLogDNAService.setup(withIngestionKey: "db91ce0574a2ef343bd753485b81b0bd", hostName: "xendit.co", appName: "iOS SDK")
    }

    func log(_ level: Level = .info, _ message: String) {
        print("[xendit] \(message)")
    }

    func verbose(_ message: String) {
        log(.verbose, message)
    }

    func logUrlResponse(prefix: String, request: URLRequest, data: Data?, response: URLResponse?, error: Error?) {
        verbose("\(prefix) finished request")
        let dataString: String?
        if let data = data {
            dataString = String(data: data, encoding: .utf8)
        } else {
            dataString = nil
        }
        if let response = response as? HTTPURLResponse {
            verbose("response: \(response)")
            if response.statusCode >= 400 {
                let level = response.statusCode >= 500 ? ISHLogDNALevel.error : ISHLogDNALevel.warn
                let message = ISHLogDNAMessage(
                    line: "Failed request: \(request.httpMethod ?? "n/a") \(request.url?.absoluteString ?? "n/a")",
                    level: level,
                    meta: [
                        "hostAppBundleId": Bundle.main.bundleIdentifier ?? "n/a",
                        "frameworkVersion": Bundle(for: Xendit.self).infoDictionary?["CFBundleShortVersionString"] as? String ?? "n/a",
                        "statusCode" : response.statusCode,
                        "requestURL": request.url?.absoluteString ?? "",
                        "responseHeaders": (response.allHeaderFields as? [String: String]) ?? [:],
                        "responseBody": dataString ?? ""
                    ]
                )
                ISHLogDNAService.logMessages([message]);
            }
        }
        if let dataString = dataString {
            verbose("data: \(dataString)")
        }
        if let error = error {
            verbose("error: \(error)")
        }
    }
}
