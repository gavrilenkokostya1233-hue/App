//
//  ImageListPresenter.swift
//  myApp
//
//  Created by Konstantin on 18.10.2026.
//

import Foundation

protocol ImageListPresenterProtocol: AnyObject {
    var view: ImageListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func changeLike(for indexPath: IndexPath, completion: @escaping (Bool) -> Void)
    func calculateHeight(for indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat
}

import Foundation
import UIKit

final class ImageListPresenter: ImageListPresenterProtocol {
    weak var view: ImageListViewControllerProtocol?
    
    private let imagesListService = ImagesListService.shared
    private(set) var photos: [Photo] = []
    
    private var imagesListServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        print("ImageListPresenter: viewDidLoad")
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: imagesListService,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                
                print("Уведомление о фотографиях получено")
                
                let oldCount = self.photos.count
                let newCount = self.imagesListService.photos.count
                
                print("Фотографий в сервисе: \(newCount)")
                
                self.photos = self.imagesListService.photos
                self.view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
            }
        
        imagesListService.fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func changeLike(for indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                let isLiked = self.photos[indexPath.row].isLiked
                completion(isLiked)
            case .failure:
                break
            }
        }
    }
    
    func calculateHeight(for indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageWidth = photo.size.width
        let imageHeight = photo.size.height
        return imageHeight * tableViewWidth / imageWidth
    }
}
