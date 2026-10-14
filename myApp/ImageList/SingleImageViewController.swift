//
//  SingleImageViewController.swift
//  myApp
//
//  Created by Konstantin on 07.08.2026.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController, UIScrollViewDelegate {

    var imageURL: String? {
        didSet {
            guard isViewLoaded,
                  let imageURL = imageURL,
                  let url = URL(string: imageURL) else {
                return
            }

            loadImage(from: url)
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        imageView.translatesAutoresizingMaskIntoConstraints = true

        guard let imageURL = imageURL,
              let url = URL(string: imageURL) else { return }

        loadImage(from: url)
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }

        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )

        present(share, animated: true)
    }

    // MARK: - UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageInScrollView()
    }

    // MARK: - Private Methods

    private func loadImage(from url: URL) {
        // Явно гарантируем показ лоадера на главном потоке
        DispatchQueue.main.async {
            UIBlockingProgressHUD.show()
        }
        
        // Используем вариант загрузки с явным параметром
        imageView.kf.setImage(
            with: url,
            placeholder: nil,
            options: [.forceRefresh] 
        ) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
            }
            
            guard let self = self else { return }
            
            switch result {
            case .success(let imageResult):
                self.imageView.frame.size = imageResult.image.size
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showErrorAlert(for: url)
            }
        }
    }
    
    private func showErrorAlert(for url: URL) {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel)
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage(from: url)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        
        present(alert, animated: true)
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        view.layoutIfNeeded()

        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size

        guard visibleRectSize.width > 0, visibleRectSize.height > 0 else { return }

        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height

        let minScale = min(hScale, vScale)
        let maxScale = max(minScale * 3, 1.25)

        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = maxScale

        scrollView.setZoomScale(minScale, animated: false)
        scrollView.layoutIfNeeded()

        centerImageInScrollView()
    }

    private func centerImageInScrollView() {
        let visibleRectSize = scrollView.bounds.size
        let newContentSize = scrollView.contentSize

        let x = max(0, (visibleRectSize.width - newContentSize.width) / 2)
        let y = max(0, (visibleRectSize.height - newContentSize.height) / 2)

        scrollView.contentInset = UIEdgeInsets(
            top: y,
            left: x,
            bottom: y,
            right: x
        )
    }
}
