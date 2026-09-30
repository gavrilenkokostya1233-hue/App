//
//  AuthViewController.swift
//  myApp
//
//  Created by Konstantin on 11.09.2026.
//

import UIKit

class AuthViewController: UIViewController, WebViewViewControllerDelegate {

    let showWebView = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
    }
    
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        print("1. Получили code:", code)
        
        vc.dismiss(animated: true)
        
        print("2. Вызываем fetchOAuthToken")
        
        OAuth2Service.shared.fetchOAuthToken(code: code) { result in
            
            print("3. Получили ответ от fetchOAuthToken")

    
            switch result {
            case .success(let token):
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                print(error)
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let webViewController = segue.destination as? WebViewViewController {
            webViewController.delegate = self
        }
    }
}

