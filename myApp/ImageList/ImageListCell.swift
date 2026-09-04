//
//  ImageListCell.swift
//  myApp
//
//  Created by Konstantin on 03.08.2026.
//
import UIKit

final class ImageListCell: UITableViewCell {
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    static let reuseIdentifier = "ImagesListCell"
    
    let gradient = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImage.isUserInteractionEnabled = false
        setupGradient()
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradient.frame = gradientView.bounds
    }
    
    private func setupGradient() {
        gradient.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.8).cgColor
        ]
        
        gradientView.layer.addSublayer(gradient)
    }
}
