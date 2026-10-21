//
//  ImageListCell.swift
//  myApp
//
//  Created by Konstantin on 03.08.2026.
//
import UIKit
import Kingfisher

final class ImageListCell: UITableViewCell {
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    weak var delegate: ImagesListCellDelegate?
    static let reuseIdentifier = "ImagesListCell"
    
    private let bottomGradient = CAGradientLayer()
    
    private var animationLayers = Set<CALayer>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImage.isUserInteractionEnabled = false
        setupBottomGradient()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        
        removeLoadingAnimation()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bottomGradient.frame = gradientView.bounds
        
        animationLayers.forEach { layer in
            layer.frame = cellImage.bounds
        }
    }
    
    // MARK: - Bottom Gradient
    
    private func setupBottomGradient() {
        bottomGradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        gradientView.layer.addSublayer(bottomGradient)
    }
    
    // MARK: - Shimmer Animation
    
    func showLoadingAnimation() {
        layoutIfNeeded()
        
        let gradient = CAGradientLayer()
        gradient.frame = cellImage.bounds
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 16
        gradient.masksToBounds = true
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        
        gradient.add(animation, forKey: "locationsChange")
        
        cellImage.layer.addSublayer(gradient)
        animationLayers.insert(gradient)
    }
    
    func removeLoadingAnimation() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
    
    // MARK: - Actions
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        if isLiked {
            likeButton.tintColor = .ypRed
            likeButton.accessibilityIdentifier = "like button on"
        } else {
            likeButton.tintColor = .noActive
            likeButton.accessibilityIdentifier = "like button off"
        }
    }
}
