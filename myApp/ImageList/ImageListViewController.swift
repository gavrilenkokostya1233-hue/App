//
//  ViewController.swift
//  myApp
//
//  Created by Konstantin on 24.07.2026.
//

import UIKit
import Kingfisher




final class ImageListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private var tableView: UITableView!

    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []

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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: imagesListService
        )

        imagesListService.fetchPhotosNextPage()
    }

    // MARK: - UITableViewDataSource

    func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImageListCell.reuseIdentifier,
            for: indexPath
        )
        
        guard let imageListCell = cell as? ImageListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        configCell(
            for: imageListCell,
            with: indexPath
        )

        return imageListCell
    }

    // MARK: - Cell configuration

    private func configCell(for cell: ImageListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]

        cell.dateLabel.text = photo.createdAt.map {
            dateFormatter.string(from: $0)
        }

        cell.likeButton.tintColor = photo.isLiked ? .ypRed : .noActive

        cell.cellImage.image = nil

        // 1. ЗАПУСКАЕМ АНИМАЦИЮ ГРАДИЕНТА перед началом загрузки
        cell.showLoadingAnimation()

        cell.cellImage.kf.setImage(
            with: URL(string: photo.smallImageURL),
            placeholder: UIImage(named: "placeholder")
        ) { [weak self, weak cell] _ in
            guard let self = self else { return }

            // 2. СНИМАЕМ АНИМАЦИЮ ГРАДИЕНТА, когда загрузка картинки завершилась
            cell?.removeLoadingAnimation()

            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }

    // MARK: - UITableViewDelegate

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        print("Показывается ячейка: \(indexPath.row), всего фото: \(photos.count)")

        
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )

        performSegue(
            withIdentifier: showSingleImageSegueIdentifier,
            sender: indexPath
        )
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        let photo = photos[indexPath.row]
    
        
        let width = tableView.bounds.width
        let imageWidth = photo.size.width
        let imageHeight = photo.size.height

        return imageHeight * width / imageWidth
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }

    // MARK: - Notification

    @objc private func updateTableViewAnimated() {
        let oldCount = photos.count

        photos = imagesListService.photos

        let newCount = photos.count

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
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }

            let photo = photos[indexPath.row]

            viewController.imageURL = photo.fullImageURL

        } else {
            super.prepare(
                for: segue,
                sender: sender
            )
        }
    }
}

extension ImageListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImageListCell) {
        print("Кнопка нажата")
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked , completion: { result in
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                    UIBlockingProgressHUD.dismiss()
                case .failure(var error):
                    UIBlockingProgressHUD.dismiss()
                }
            }
        )
        
        
    }
}


