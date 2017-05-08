//
//  AuthenticationWebviewController.swift
//  Xendit
//
//  Created by Juan Gonzalez on 5/4/17.
//
//

import Foundation
import WebKit

class AuthenticationWebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {

    private var urlString : String!

    public var authentication : XenditAuthentication!

    var webView: WKWebView!

    var authenticateCompletion: (XenditAuthentication?, XenditError?) ->Void = {
        (authentication: XenditAuthentication?, error: XenditError?) -> Void in
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

        let HTMLString = WebViewConstants.templateHTMLWithAuthenticateURL.replacingOccurrences(of: "@xendit_src", with: urlString)
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
        let updatedAuthentication = XenditAuthentication(response: response)
        if updatedAuthentication != nil && authentication!.id == updatedAuthentication?.id {
            authenticateCompletion(updatedAuthentication, nil)
        } else {
            authenticateCompletion(nil, XenditError.serializationDataFailed(description: "Wrong authenticate post message format or not equal authentication id"))
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        authenticateCompletion(nil, XenditError.requestFailedWithError(error: error))
    }

}
