//
//  Fingerprint.swift
//  Xendit
//
//  Created by Vladimir Lyukov on 21/11/2018.
//

import Foundation
import UIKit
import SystemConfiguration.CaptiveNetwork


public class Fingerprint {
    var idfv: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    var idfa: String? {
        return XENweakGetIDFA()
    }
    var ipAddress: String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }

                let interface = ptr!.pointee
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    let name = String(cString: interface.ifa_name)
                    if name == "en0" {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
    var wiFiSsid: String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }
        let key = kCNNetworkInfoKeySSID as String
        for interface in interfaces {
            guard let interfaceInfo = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? else {
                continue
            }
            return interfaceInfo[key] as? String
        }
        return nil
    }
    var language: String {
        return NSLocale.current.identifier
    }
    var deviceModel: String? {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return simulatorModelIdentifier
        }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        let data = Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN))
        return String(bytes: data, encoding: .ascii)?.trimmingCharacters(in: .controlCharacters)
    }
    var osVersion: String {
        return UIDevice.current.systemVersion
    }
    var screenResolution: String {
        let bounds = UIScreen.main.bounds
        return String(format: "%.0fx%.0f@%.0f", bounds.width, bounds.height, UIScreen.main.scale)
    }
    var timeZoneName: String {
        return TimeZone.current.identifier
    }
    var timeZoneOffset: String {
        let seconds = TimeZone.current.secondsFromGMT()
        let hours = seconds/3600
        let minutes = abs(seconds/60) % 60
        return String(format: "%+.2d:%.2d", hours, minutes)
    }

    public var payload: [String: String] {
        var res = [
            "fp_language": language,
            "fp_os": "iOS \(osVersion)",
            "fp_resolution": screenResolution,
            "fp_tz_name": timeZoneName,
            "fp_tz_offset": timeZoneOffset
        ]
        if let deviceModel = deviceModel {
            res["fp_device"] = deviceModel
        }
        if let idfv = idfv {
            res["fp_idfv"] = idfv
        }
        if let idfa = idfa {
            res["fp_idfa"] = idfa
        }
        if let ipAddress = ipAddress {
            res["fp_ip"] = ipAddress
        }
        if let wiFiSsid = wiFiSsid {
            res["fp_ssid"] = wiFiSsid
        }
        return res
    }

    public init() {
    }
}
