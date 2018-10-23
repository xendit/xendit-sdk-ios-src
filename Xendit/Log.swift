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

    func log(_ level: Level = .info, _ message: String) {
        print("[xendit] \(message)")
    }

    func verbose(_ message: String) {
        log(.verbose, message)
    }

    func logUrlResponse(prefix: String, data: Data?, response: URLResponse?, error: Error?) {
        verbose("\(prefix) finished request")
        if let response = response {
            verbose("response: \(response)")
        }
        if let data = data {
            verbose("data: \(String(data: data, encoding: .utf8) ?? "non-string")")
        }
        if let error = error {
            verbose("error: \(error)")
        }
    }
}
