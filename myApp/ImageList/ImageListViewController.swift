//
//  ViewController.swift
//  myApp
//
//  Created by Konstantin on 24.07.2026.
//

import UIKit

class ImageListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet private var tableView: UITableView!
    private let photosName: [String] = Array(0..<20).map{"\($0)"}
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func configCell(for cell: ImageListCell, with indexPath: IndexPath) { 
        let imageName = photosName[indexPath.row]
        
        guard let image = UIImage(named: imageName) else {
            return 
        }
        
        cell.cellImage.image = image
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        if indexPath.row % 2 == 0 {
            cell.likeButton.tintColor = .systemRed
        } else {
            cell.likeButton.tintColor = .systemGray
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(
            withIdentifier: showSingleImageSegueIdentifier,
            sender: indexPath
        )
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImageListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageName = photosName[indexPath.row]
        guard let image = UIImage(named: imageName) else {
            return 200
        }
        let widthImage = image.size.width
        let heightImage = image.size.height
        let heigthView = (heightImage * tableView.bounds.width) / widthImage
        
        return heigthView 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let imageName = photosName[indexPath.row]
            let image = UIImage(named: imageName)
            
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}


