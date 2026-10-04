//
//  AuthViewController.swift
//  myApp
//
//  Created by Konstantin on 11.09.2026.
//

import ProgressHUD
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
        
        vc.dismiss(animated: true)
        
        UIBlockingProgressHUD.show()
        
        OAuth2Service.shared.fetchOAuthToken(code: code) { result in
            UIBlockingProgressHUD.dismiss()
    
            switch result {
            case .success(let token):
                print("TOKEN:", token)
                print("SAVED TOKEN:", OAuth2TokenStorage.shared.token as Any)
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                print(error)

                let alert = UIAlertController(
                    title: "Что-то пошло не так",
                    message: "Не удалось войти в систему",
                    preferredStyle: .alert
                )

                alert.addAction(
                    UIAlertAction(
                        title: "Ок",
                        style: .default
                    )
                )

                self.present(alert, animated: true)
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

