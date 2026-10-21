//
//  TabBarController.swift
//  myApp
//
//  Created by Konstantin on 04.10.2026.
//

import UIKit

final class TabBarViewController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as? ImageListViewController else {
            assertionFailure("Не удалось создать ImagesListViewController")
            return
        }
        
        let imageListPresenter = ImageListPresenter()
        imageListPresenter.view = imagesListViewController
        imagesListViewController.presenter = imageListPresenter
        
        let profileViewController = ProfileViewController()
        
        let profilePresenter = ProfilePresenter()
        profilePresenter.view = profileViewController
        profileViewController.presenter = profilePresenter
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "ProfileIconActive"),
            selectedImage: nil
        )
        
        viewControllers = [
            imagesListViewController,
            profileViewController
        ]
    }
}
