//
//  WebViewController.swift
//  Xendit
//
//  Created by Maxim Bolotov on 3/24/17.
//
//

import Foundation
import WebKit

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

        let button   = UIButton(type: UIButtonType.system) as UIButton
        button.frame = CGRect(x: 10, y: 20, width: view.frame.maxX, height: view.frame.maxY)
        button.setTitle("Cancel", for: UIControlState.normal)
        button.addTarget(self, action: #selector(cancelAuthentication), for: UIControlEvents.touchUpInside)
        button.sizeToFit()

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        webView = WKWebView(frame: view.frame, configuration: webConfiguration)
        webView.navigationDelegate = self

        view.backgroundColor = UIColor.white
        view.addSubview(webView)
        view.addSubview(button)
        
        let HTMLString = WebViewConstants.templateHTMLWithAuthenticateURL.replacingOccurrences(of: "@xendit_src", with: urlString)
        webView.loadHTMLString(HTMLString, baseURL: nil)
    }

    func cancelAuthentication() {
        authenticateCompletion(nil, XenditError(errorCode: "AUTHENTICATION_ERROR", message: "Authentication was cancelled"))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView.frame = CGRect(x: view.frame.origin.x, y: topLayoutGuide.length + 20, width: view.frame.size.width, height: view.frame.size.height - 20)
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        do {
            let responseString = message.body as? String
            let data = responseString?.data(using: .utf8)
            let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any]
            handlePostMessageResponse(response: parsedData!)
        } catch {
            authenticateCompletion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Unable to parse server response"))
        }
    }
    
    func handlePostMessageResponse(response: [String:Any]) {
        let authenticatedToken = XenditCCToken(response: response)
        if authenticatedToken != nil && token.id == authenticatedToken?.id {
            authenticateCompletion(authenticatedToken, nil)
        } else {
            authenticateCompletion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Incorrect webview post message format or wrong authentication id"))
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        authenticateCompletion(nil, XenditError(errorCode: "WEBVIEW_ERROR", message: error.localizedDescription))
    }
    
}
