//
//  WebViewViewController.swift
//  myApp
//
//  Created by Konstantin on 13.09.2026.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    weak var delegate: WebViewViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAuthView()
        
        webView.navigationDelegate = self
        
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil
        )
        
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else { 
                return
            }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accesKey), 
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)    
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        print(url.absoluteString)
        
        let request = URLRequest(url: url)
        webView.load(request)

    }
    
    override func observeValue(
        forKeyPath keyPath: String?, 
        of object: Any?, 
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    private func updateProgress() {
        let progress = Float(webView.estimatedProgress)

        progressView.setProgress(progress, animated: true)
        progressView.isHidden = abs(progress - 1.0) <= 0.0001
    }
    
    
}

extension WebViewViewController: WKNavigationDelegate {
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,                         
                let urlComponents = URLComponents(string: url.absoluteString),  
                urlComponents.path == "/oauth/authorize/native",                
                let items = urlComponents.queryItems,                           
                let codeItem = items.first(where: { $0.name == "code" })        
                {
            return codeItem.value                                           
        } else {
            return nil
        }
    }
    
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        
        print(navigationAction.request.url?.absoluteString ?? "URL отсутствует")
        
        if let code = code(from: navigationAction) {
            print("Код получен:", code)
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

