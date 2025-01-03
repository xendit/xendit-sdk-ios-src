//
//  AuthenticationWebviewController.swift
//  Xendit
//
//  Created by Juan Gonzalez on 5/4/17.
//
//

import Foundation
import WebKit


protocol AuthenticationProviderProtocol {
    func authenticate(fromViewController: UIViewController, URL: String, authentication: XenditAuthentication, completion: @escaping (XenditAuthentication?, XenditError?) -> Void)
}


class AuthenticationProvider: AuthenticationProviderProtocol {
    func authenticate(fromViewController: UIViewController, URL: String, authentication: XenditAuthentication, completion: @escaping (XenditAuthentication?, XenditError?) -> Void) {
        let webViewController = AuthenticationWebViewController(URL: URL)
        webViewController.authentication = authentication
        webViewController.authenticateCompletion = { [weak webViewController] updatedAuthentication, error in
            webViewController?.dismiss(animated: true, completion: nil)
            completion(updatedAuthentication, error)
        }
        DispatchQueue.main.async {
            let navigationController = UINavigationController(rootViewController: webViewController)
            fromViewController.present(navigationController, animated: true, completion: nil)
        }
    }
}


class AuthenticationWebViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate, UIAdaptivePresentationControllerDelegate {

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

    override func loadView() {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .white
        
        // Script to scale the 3DS page
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=450,shrink-to-fit=YES'); document.getElementsByTagName('head')[0].appendChild(meta);"
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
        webView.translatesAutoresizingMaskIntoConstraints = false

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
        webView.load(URLRequest(url: URL(string: urlString)!))
    }

    @objc func cancelAuthentication() {
        authenticateCompletion(nil, XenditError(errorCode: "AUTHENTICATION_ERROR", message: "Authentication was cancelled"))
    }
    
    override func willMove(toParent parent: UIViewController?) {
        self.parent?.presentationController?.delegate = self
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.cancelAuthentication()
    }

    // MARK: - WKScriptMessageHandler

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        Log.shared.verbose("web auth: receive message \(message)")
        if let responseString = message.body as? String,
                let data = responseString.data(using: .utf8),
                let parsedData = try? JSONSerialization.jsonObject(with: data, options: []),
                let parsedDict = parsedData as? [String: Any] {
            handlePostMessageResponse(response: parsedDict)
        } else {
            Log.shared.logUnexpectedWebScriptMessage(url: urlString, message: message)
            authenticateCompletion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Unable to parse server response"))
        }
    }

    func handlePostMessageResponse(response: [String:Any]) {
        let updatedAuthentication = XenditAuthentication(response: response)
        if updatedAuthentication != nil && authentication!.id == updatedAuthentication?.id {
            authenticateCompletion(updatedAuthentication, nil)
        } else {
            authenticateCompletion(nil, XenditError(errorCode: "SERVER_ERROR", message: "Incorrect webview post message format or wrong authentication id"))
        }
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Log.shared.verbose("web auth: navigation error \(error)")
        authenticateCompletion(nil, XenditError(errorCode: "WEBVIEW_ERROR", message: error.localizedDescription))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove script message handler
        webView.configuration.userContentController.removeAllUserScripts()
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "callbackHandler")
        // Clear any other references
        webView.navigationDelegate = nil
        webView = nil
    }
}
