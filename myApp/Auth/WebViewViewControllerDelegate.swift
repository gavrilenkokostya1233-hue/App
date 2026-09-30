//
//  WebViewViewControllerDelegate.swift
//  myApp
//
//  Created by Konstantin on 19.09.2026.
//

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
