//
//  XDTSentry.swift
//  Xendit
//
//  Created by xendit on 30/3/23.
//

import Foundation
import Sentry

class XDTSentry {
    static let shared = XDTSentry()
    
    private init() {
        SentrySDK.start { options in
            options.dsn = "https://0df5444e8c934cd282fe88f7634cff3a@o30316.ingest.sentry.io/6314582"
            options.debug = true
            
            options.beforeSend = { event in
                // modify event here or return NULL to discard the event
                if event.exceptions != nil {
                    if let thread = event.threads?[0] {
                        if let stacktrace = thread.stacktrace {
                            for frame in stacktrace.frames {
                                
                                if frame.function?.lowercased().range(of: "xendit") != nil {
                                    return event
                                }
                            }
                        }
                    }
                }
                
                return nil
            }
        }
        
        SentrySDK.configureScope { scope in
            let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
            // let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""
            
            let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "x.x"
            let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "x"
            
            scope.setTag(value: appName, key: "applicationName")
            scope.setTag(value: versionNumber, key: "applicationVersionName")
            scope.setTag(value: buildNumber, key: "applicationBuildNumber")
            scope.setTag(value: XDTApiClient.CLIENT_SDK_VERSION, key: "sdkVersionName")
        }
    }
    
    func configure() {
    }
}
