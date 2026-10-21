//
//  AuthViewController.swift
//  myApp
//
//  Created by Konstantin on 11.09.2026.
//

import ProgressHUD
import UIKit

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    private let showWebView = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebView {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebView)")
                return
            }
            let authHelper = AuthHelper()
            let webViewPresenter = WebViewPresenter(authHelper: authHelper)
            webViewViewController.presenter = webViewPresenter
            webViewPresenter.view = webViewViewController
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - WebViewViewControllerDelegate
    
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        vc.dismiss(animated: true)
        
        UIBlockingProgressHUD.show()
        
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success:
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
}
