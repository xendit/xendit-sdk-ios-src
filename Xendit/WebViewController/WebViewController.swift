//
//  WebViewController.swift
//  Xendit
//
//  Created by Maxim Bolotov on 3/24/17.
//
//

import Foundation
import WebKit


protocol CardAuthenticationProviderProtocol {
    func authenticate(fromViewController: UIViewController, URL: String, token: XenditCCToken, completion: @escaping (XenditCCToken?, XenditError?) -> Void)
}


class CardAuthenticationProvider: CardAuthenticationProviderProtocol {
    func authenticate(fromViewController: UIViewController, URL: String, token: XenditCCToken, completion: @escaping (XenditCCToken?, XenditError?) -> Void) {
        let webViewController = WebViewController(URL: URL)

        webViewController.token = token
        webViewController.authenticateCompletion = { (token, error) -> Void in
            webViewController.dismiss(animated: true, completion: nil)
            completion(token, error)
        }

        DispatchQueue.main.async {
            let navigationController = UINavigationController(rootViewController: webViewController)
            fromViewController.present(navigationController, animated: true, completion: nil)
        }
    }
}


class WebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    
    private var urlString : String!
    
    public var token : XenditCCToken!
    
    var webView: WKWebView!
    
    var authenticateCompletion: (XenditCCToken?, XenditError?) ->Void = {
        (token: XenditCCToken?, error: XenditError?) -> Void in
    }
    
    // MARK: - Initializer
    
    init(URL: String) {
        Log.shared.log(.info, "web auth: \(URL)")
        super.init(nibName: nil, bundle: nil)
        urlString = URL
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .white
        
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=400,shrink-to-fit=YES'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAuthentication))

        let contentController = WKUserContentController();
        contentController.add(
            self,
            name: "callbackHandler"
        )
        contentController.addUserScript(userScript)

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        webView = WKWebView(frame: view.frame, configuration: webConfiguration)
        webView.navigationDelegate = self

        view.addSubview(webView)
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: webView!, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let HTMLString = WebViewConstants.templateHTMLWithAuthenticateURL.replacingOccurrences(of: "@xendit_src", with: urlString)
        webView.loadHTMLString(HTMLString, baseURL: nil)
    }

    @objc func cancelAuthentication() {
        authenticateCompletion(nil, XenditError(errorCode: "AUTHENTICATION_ERROR", message: "Authentication was cancelled"))
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        Log.shared.verbose("web auth: receive message \(message)")
        if let responseString = message.body as? String,
                let data = responseString.data(using: .utf8),
                let parsedData = try? JSONSerialization.jsonObject(with: data, options: []),
                let parsedDict = parsedData as? [String: Any]{
            handlePostMessageResponse(response: parsedDict)
        } else {
            Log.shared.logUnexpectedWebScriptMessage(url: urlString, message: message)
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
        Log.shared.verbose("web auth: navigation error \(error)")
        authenticateCompletion(nil, XenditError(errorCode: "WEBVIEW_ERROR", message: error.localizedDescription))
    }
}
