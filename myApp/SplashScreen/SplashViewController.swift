//
//  SplashViewController.swift
//  myApp
//
//  Created by Konstantin on 30.09.2026.
//
import UIKit

class SplashViewController: UIViewController, AuthViewControllerDelegate {
   

    
    let storage = OAuth2TokenStorage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if storage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: "ShowAuthenticationScreen", sender: nil)
        }
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        switchToTabBarController()
    }
    
    
    private func switchToTabBarController() {
        let window = view.window
        
        guard let window = window else {
            return 
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(
            identifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAuthenticationScreen" {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                return
            }

            viewController.delegate = self
        }
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
