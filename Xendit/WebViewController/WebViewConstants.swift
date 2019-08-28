//
//  Constants.swift
//  Xendit
//
//  Created by Juan Gonzalez on 5/5/17.
//
//

import Foundation

@objcMembers
open class WebViewConstants: NSObject {

    public static var templateHTMLWithAuthenticateURL = "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" +
        "<style type=\"text/css\">html, body {margin: 0; padding:0}" +
        "iframe {border: none;width: 100%;height: 100%;}</style>" +
        "</head><body>" +
    "<iframe src='@xendit_src'></iframe></body></html>"

}
