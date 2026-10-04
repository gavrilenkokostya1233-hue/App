//
//  ProfileViewController.swift
//  myApp
//
//  Created by Konstantin on 06.08.2026.
//
import Kingfisher
import UIKit

final class ProfileViewController: UIViewController {
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        setupProfileImage()
        setupButton()
        setupLabels()
        setupStackView()

        guard let profile = ProfileService.shared.profile else {
            return
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }

        updateAvatar()

        updateProfileDetails(profile: profile)
        loadProfileImage(from: profile.profileImageURL)
    }
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL else {
            return
        }

        profileImage.kf.setImage(
            with: URL(string: profileImageURL),
            placeholder: UIImage(named: "Profile")
        )
    }
    
    private func updateProfileDetails(profile: ProfileService.Profile) {
        labelNameAndSurname.text = profile.name
        username.text = profile.loginName
        status.text = profile.bio
    }
    
    private func loadProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Не удалось создать URL аватарки")
            return
        }

        profileImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Profile")
        )
    }
    
    private let profileImage = UIImageView()
    private let labelNameAndSurname = UILabel()
    private let username = UILabel()
    private let status = UILabel()
    private let button = UIButton.systemButton(
        with: UIImage(named: "arrow.forward") ?? UIImage(),
        target: ProfileViewController.self,
        action: #selector(logOut)
    )
    private var stackView: UIStackView!
    
    private func setupProfileImage() {
        view.addSubview(profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        profileImage.topAnchor
            .constraint(equalTo: view.topAnchor, constant: 76).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
    }
    
    private func setupButton() {
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .ypRed
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        button.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        
    }
    
    private func setupLabels() {
        view.addSubview(labelNameAndSurname)
        labelNameAndSurname.translatesAutoresizingMaskIntoConstraints = false
        labelNameAndSurname.textColor = .white
        labelNameAndSurname.font = UIFont.boldSystemFont(ofSize: 23)
        
        
        view.addSubview(username)
        username.translatesAutoresizingMaskIntoConstraints = false
        username.textColor = .ypGray
        
        view.addSubview(status)
        status.translatesAutoresizingMaskIntoConstraints = false
        status.textColor = .white
        
    }
    
    private func setupStackView() {
        
        stackView = UIStackView(
            arrangedSubviews: [labelNameAndSurname, username, status]
        )
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        stackView.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 10
            ).isActive = true
        stackView.trailingAnchor
            .constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    }
    
    @objc private func logOut() {
        
    }
    
    
}
