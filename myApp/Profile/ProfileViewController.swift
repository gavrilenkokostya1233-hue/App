//
//  ProfileViewController.swift
//  myApp
//
//  Created by Konstantin on 06.08.2026.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfileImage()
        setupButton()
        setupLabels()
        setupStackView()
    }
    
    private let profileImage = UIImageView(image: UIImage(named: "Profile"))
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
        
        labelNameAndSurname.text = "Екатерина Новикова"
        
        
        view.addSubview(username)
        username.translatesAutoresizingMaskIntoConstraints = false
        username.textColor = .ypGray
        username.text = "@ekaterina_nov"
        
        view.addSubview(status)
        status.translatesAutoresizingMaskIntoConstraints = false
        status.textColor = .white
        status.text = "Hello, world!"
        
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
        // TODO
    }
    
    
}
