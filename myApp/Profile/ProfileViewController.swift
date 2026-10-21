//
//  ProfileViewController.swift
//  myApp
//
//  Created by Konstantin on 06.08.2026.
//
import Kingfisher
import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileDetails(profile: ProfileResultModel) 
    func updateAvatar(with url: URL?)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    var presenter: ProfilePresenterProtocol?
    
    private var animationLayers = Set<CALayer>()
    private var isFirstLayout = true
    
    private let profileImage = UIImageView()
    private let labelNameAndSurname = UILabel()
    private let username = UILabel()
    private let status = UILabel()
    private lazy var button = UIButton.systemButton(
        with: UIImage(named: "ipad.and.arrow.forward") ?? UIImage(systemName: "ipad.and.arrow.forward") ?? UIImage(),
        target: self,
        action: #selector(logOut)
    )
    private var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        setupProfileImage()
        setupButton()
        setupLabels()
        setupStackView()

        presenter?.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isFirstLayout {
            showLoadingAnimation()
            isFirstLayout = false
        }
    }
    
    // MARK: - ProfileViewControllerProtocol
    
    func updateProfileDetails(profile: ProfileResultModel) {
        labelNameAndSurname.text = profile.name
        username.text = profile.loginName
        status.text = profile.bio
        
        removeLoadingAnimation()
        
        view.layoutIfNeeded()
    }
    
    func updateAvatar(with url: URL?) {
        guard let url = url else { return }
        
        profileImage.kf.indicatorType = .activity
        profileImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Profile")
        ) { [weak self] _ in
            self?.removeLoadingAnimation()
        }
    }
    
    @objc private func logOut() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            self?.presenter?.didTapLogoutButton()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Gradient & Shimmer Loading
    
    private func createGradientLayer(cornerRadius: CGFloat) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
        
        return gradient
    }
    
    private func showLoadingAnimation() {
        view.layoutIfNeeded()
        
        let avatarGradient = createGradientLayer(cornerRadius: 35)
        avatarGradient.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        profileImage.layer.addSublayer(avatarGradient)
        animationLayers.insert(avatarGradient)
        
        let nameGradient = createGradientLayer(cornerRadius: 9)
        nameGradient.frame = CGRect(x: 0, y: 0, width: 220, height: 26)
        labelNameAndSurname.layer.addSublayer(nameGradient)
        animationLayers.insert(nameGradient)
        
        let loginGradient = createGradientLayer(cornerRadius: 9)
        loginGradient.frame = CGRect(x: 0, y: 0, width: 150, height: 18)
        username.layer.addSublayer(loginGradient)
        animationLayers.insert(loginGradient)
        
        let descriptionGradient = createGradientLayer(cornerRadius: 9)
        descriptionGradient.frame = CGRect(x: 0, y: 0, width: 200, height: 18)
        status.layer.addSublayer(descriptionGradient)
        animationLayers.insert(descriptionGradient)
    }
    
    private func removeLoadingAnimation() {
        animationLayers.forEach { layer in
            layer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
    
    // MARK: - Setup UI
    
    private func setupProfileImage() {
        view.addSubview(profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        profileImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 76).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 70).isActive = true
        profileImage.layer.cornerRadius = 35
        profileImage.clipsToBounds = true
    }
    
    private func setupButton() {
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .ypRed
        button.widthAnchor.constraint(equalToConstant: 44).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        button.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor).isActive = true
        
        button.accessibilityIdentifier = "logout button"
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
        stackView.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 10).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    }
}
