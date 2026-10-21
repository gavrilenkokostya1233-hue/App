//
//  ViewController.swift
//  myApp
//
//  Created by Konstantin on 24.07.2026.
//

import UIKit
import Kingfisher

protocol ImageListViewControllerProtocol: AnyObject {
    var presenter: ImageListPresenterProtocol? { get set }
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
}


import UIKit
import Kingfisher

final class ImageListViewController: UIViewController, ImageListViewControllerProtocol {
    
    @IBOutlet private var tableView: UITableView!
    
    var presenter: ImageListPresenterProtocol?

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
        tableView.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 12,
            right: 0
        )

        presenter?.viewDidLoad()
    }
    
    // MARK: - ImageListViewControllerProtocol
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        let indexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }

        tableView.performBatchUpdates {
            tableView.insertRows(
                at: indexPaths,
                with: .automatic
            )
        }
    }

    // MARK: - Navigation

    override func prepare(
        for segue: UIStoryboardSegue,
        sender: Any?
    ) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let presenter = presenter
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let photo = presenter.photos[indexPath.row]
            viewController.imageURL = photo.fullImageURL

        } else {
            super.prepare(
                for: segue,
                sender: sender
            )
        }
    }
}

// MARK: - UITableViewDataSource

extension ImageListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photos.count ?? 0
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImageListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImageListCell,
              let presenter = presenter else {
            return UITableViewCell()
        }
        
        let photo = presenter.photos[indexPath.row]
        
        imageListCell.dateLabel.text = photo.createdAt.map {
            dateFormatter.string(from: $0)
        }

        imageListCell.setIsLiked(photo.isLiked)
        imageListCell.cellImage.image = nil
        imageListCell.showLoadingAnimation()

        imageListCell.cellImage.kf.setImage(
            with: URL(string: photo.smallImageURL),
            placeholder: UIImage(named: "placeholder")
        ) { [weak self, weak imageListCell] _ in
            guard let self = self else { return }
            imageListCell?.removeLoadingAnimation()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }

        imageListCell.delegate = self
        return imageListCell
    }
}

// MARK: - UITableViewDelegate

extension ImageListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return presenter?.calculateHeight(for: indexPath, tableViewWidth: tableView.bounds.width) ?? 0
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard let presenter = presenter else { return }
        if indexPath.row == presenter.photos.count - 1 {
            presenter.fetchPhotosNextPage()
        }
    }
}

// MARK: - ImagesListCellDelegate

extension ImageListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImageListCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let presenter = presenter else { return }
        
        presenter.changeLike(for: indexPath) { isLiked in
            cell.setIsLiked(isLiked)
        }
    }
}
