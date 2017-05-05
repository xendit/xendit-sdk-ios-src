//
//  WebViewController.swift
//  Xendit
//
//  Created by Maxim Bolotov on 3/24/17.
//
//

import Foundation
import WebKit

let templateHTMLWithAuthenticateURL =
    "<html><head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" +
        "<style type=\"text/css\">html, body {margin: 0; padding: 0;}" +
        "iframe {border: none;width: 100%;height: 100%;position: fixed;left: 0;top: 0;}</style>" +
        "</head><body>" +
        "<script>addEventListener('message', function(e){ try { webkit.messageHandlers.callbackHandler.postMessage(e['data']);}" +
        "catch(err) {console.log('iOS call error');} }, false);</script>" +
    "<iframe src='@xendit_src'></iframe></body></html>"

class WebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    
    private var urlString : String!
    
    public var token : XenditCCToken!
    
    var webView: WKWebView!
    
    var authenticateCompletion: (XenditCCToken?, XenditError?) ->Void = {
        (token: XenditCCToken?, error: XenditError?) -> Void in
    }
    
    // MARK: - Initializer
    
    init(URL: String) {
        super.init(nibName: nil, bundle: nil)
        urlString = URL
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentController = WKUserContentController();
        contentController.add(
            self,
            name: "callbackHandler"
        )
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        
        webView = WKWebView(frame: view.frame, configuration: webConfiguration)
        webView.navigationDelegate = self
        view.backgroundColor = UIColor.white
        view.addSubview(webView)
        
        let HTMLString = templateHTMLWithAuthenticateURL.replacingOccurrences(of: "@xendit_src", with: urlString)
        webView.loadHTMLString(HTMLString, baseURL: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView.frame = CGRect(x: view.frame.origin.x, y: topLayoutGuide.length, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        do {
            let responseString = message.body as? String
            let data = responseString?.data(using: .utf8)
            let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            handlePostMessageResponse(response: parsedData!)
        } catch let error {
            authenticateCompletion(nil, XenditError.jsonEncodingFailed(error: error))
        }
    }
    
    func handlePostMessageResponse(response: [String:Any]) {
        let authenticatedToken = XenditCCToken(response: response)
        if authenticatedToken != nil && token.id == authenticatedToken?.id {
            authenticateCompletion(authenticatedToken, nil)
        } else {
            authenticateCompletion(nil, XenditError.serializationDataFailed(description: "Wrong authenticate post message format or not equal token id"))
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        authenticateCompletion(nil, XenditError.requestFailedWithError(error: error))
    }
    
}
