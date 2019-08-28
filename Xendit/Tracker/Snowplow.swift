//
//  Snowplow.swift
//  Xendit
//
//  Created by trial on 19/08/19.
//
import Foundation
import SnowplowTracker

class SnowplowManager: NSObject {
    @objc var tracker: SPTracker?
    static var shared: SnowplowManager? = SnowplowManager.init()
    
    func setTracker() -> SPTracker? {
        let emitter = SPEmitter.build({builder in
            builder?.setUrlEndpoint("snowplow-collector.iluma.ai")
            builder?.setProtocol(.https)
            builder?.setHttpMethod(.post)
        })
        
        let subject = SPSubject.init()
        
        tracker = SPTracker.build({builder in
            builder?.setEmitter(emitter)
            builder?.setAppId("xendit-sdk-ios")
            builder?.setTrackerNamespace("TPI")
            builder?.setSubject(subject)
            builder?.setExceptionEvents(true)
        })
        
        return tracker
    }
}
