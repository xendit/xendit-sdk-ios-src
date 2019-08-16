//
//  Snowplow.swift
//  Xendit
//
//  Created by Aulia Hakiem on 15/08/19.
//

import Foundation
import SnowplowTracker

class SnowplowManager: NSObject {
    @objc var tracker: SPTracker?
    static var shared: SnowplowManager? = SnowplowManager.init()
    
    func setTracker() {
        let emitter = SPEmitter.build({ builder in
            builder?.setUrlEndpoint("snowplow-collector.iluma.ai") // Here is where you set the URL where you send the data
            builder?.setProtocol(.https) // you can either use http or https
        })
        tracker = SPTracker.build({ builder in
            builder?.setEmitter(emitter) // set the emitter of the tracker
            builder?.setAppId(Bundle.main.bundleIdentifier) // you can track the appId
            builder?.setAutotrackScreenViews(true) // these function autotracks all of the screen events with full detail
            builder?.setScreenContext(true) // get screen context like resolutions, width, height
            builder?.setInstallEvent(true) // get events about the first install of the app
            builder?.setApplicationContext(true) // get events about the device, app context
            builder?.setSessionContext(true) // get stats about the current session
            let subject = SPSubject.init(platformContext: true, andGeoContext: true) // You can set a subject where you can set several datas such as place, id and others
            subject?.setUserId("agent007")
            builder?.setSubject(subject) // add subject to the tracker
            builder?.setExceptionEvents(true) // also track exceptional events
            builder?.setLifecycleEvents(true) // these one is tracking the background/foreground stats of the sessions
        })
    }
}
