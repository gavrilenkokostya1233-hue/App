//
//  SplashViewController.swift
//  myApp
//
//  Created by Konstantin on 30.09.2026.
//
import UIKit

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
   
    private let profileService = ProfileService.shared
    let storage = OAuth2TokenStorage.shared
    private var didCompleteAuthentication = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let splashScreenLogo = UIImageView(image: UIImage(named: "Image"))
        view.addSubview(splashScreenLogo)
        splashScreenLogo.translatesAutoresizingMaskIntoConstraints = false
        
        splashScreenLogo.centerXAnchor
            .constraint(equalTo: view.centerXAnchor).isActive = true
        splashScreenLogo.centerYAnchor
            .constraint(equalTo: view.centerYAnchor ).isActive = true
        view.backgroundColor = .ypBlack
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if didCompleteAuthentication {
            return
        }
        
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            let viewController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
            viewController.delegate = self 
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
        }
    }    
    
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        guard let token = storage.token else {
            return
        }
        
        didCompleteAuthentication = true
        fetchProfile(token: token)
    }
    
    private func fetchProfile(token: String) {
        print("🔥 ПОКАЗЫВАЕМ HUD")
        UIBlockingProgressHUD.show()
        print("🔥 HUD ПОКАЗАН")

        profileService.fetchProfile(token) { [weak self] result in

            UIBlockingProgressHUD.dismiss()

            guard let self else { return }

            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(
                    username: profile.username
                ) { _ in }

                self.switchToTabBarController()

            case .failure(let error):
                print("Ошибка получения профиля:", error)
            }
        }
    }
    
    private func switchToTabBarController() {

        let window = view.window

        guard let window = window else {
            return
        }

        let tabBarController = UIStoryboard(
            name: "Main",
            bundle: .main
        ).instantiateViewController(
            identifier: "TabBarViewController"
        )

        window.rootViewController = tabBarController
    }
    
    
        private func switchNavigationController() {
        let window = view.window
        
        guard let window = window else {
            return
        }
        
        let navigationController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(
            identifier: "NavigationViewController")
        window.rootViewController = navigationController
    }
}
