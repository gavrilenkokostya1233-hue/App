//
//  ProfilePresenter.swift
//  myApp
//
//  Created by Konstantin on 18.10.2026.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogoutButton()
}

import Foundation

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        
        if let profile = ProfileService.shared.profile {
            let profileModel = ProfileResultModel(
                name: profile.name,
                loginName: profile.loginName,
                bio: profile.bio,
                profileImageURL: profile.profileImageURL
            )
            view?.updateProfileDetails(profile: profileModel)
            updateAvatar()
        }
    }
    
    func didTapLogoutButton() {
        ProfileLogoutService.shared.logout()
    }
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL) else {
            return
        }
        view?.updateAvatar(with: url)
    }
}

struct ProfileResultModel {
    let name: String
    let loginName: String
    let bio: String?
    let profileImageURL: String
}
