//
//  ImagesListService.swift
//  myApp
//
//  Created by Konstantin on 05.10.2026.
//

import Foundation
import CoreGraphics

final class ImagesListService {
    
    static let shared = ImagesListService()
    private var task: URLSessionTask?
    
    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange"
    )
    
    private(set) var photos: [Photo] = []
    
    private var currentPage = 0
    private var isLoading = false
    
    
    func changeLike(
        photoId: String,
        isLike: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.data(for: request) { result in 
            switch result {
            case .success:
                print("LIKE: запрос успешен")

                guard let index = self.photos.firstIndex(where: { $0.id == photoId }) else {
                    completion(.failure(NetworkError.invalidRequest))
                    return
                }

                let photo = self.photos[index]

                let updatedPhoto = Photo(
                    id: photo.id,
                    size: photo.size,
                    createdAt: photo.createdAt,
                    welcomeDescription: photo.welcomeDescription,
                    thumbImageURL: photo.thumbImageURL,
                    largeImageURL: photo.largeImageURL,
                    isLiked: isLike,
                    smallImageURL: photo.smallImageURL,
                    fullImageURL: photo.fullImageURL
                )

                self.photos[index] = updatedPhoto

                print("LIKE: состояние обновлено")
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
            
        }.resume()
    }
    
    func fetchPhotosNextPage() {
        print("fetchPhotosNextPage вызван")
        guard !isLoading else {
            return
        }
        
        isLoading = true
        
        let nextPage = currentPage + 1
        
        guard let url = URL(
            string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=10"
        ) else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        
        guard let token = OAuth2TokenStorage.shared.token else {
            isLoading = false
            return
        }
        
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )
        
        URLSession.shared.objectTask(for: request) {
            [weak self] (result: Result<[PhotoResult], Error>) in
            
            guard let self = self else {
                return
            }
            
            self.isLoading = false
            
            switch result {
            case .success(let photoResults):
                print("Пришло фото: \(photoResults.count)")
                let newPhotos = photoResults.map { photoResult in
                    Photo(
                        id: photoResult.id,
                        size: CGSize(
                            width: photoResult.width,
                            height: photoResult.height
                        ),
                        createdAt: photoResult.createdAt,
                        welcomeDescription: photoResult.description,
                        thumbImageURL: photoResult.urls.thumb.absoluteString,
                        largeImageURL: photoResult.urls.regular.absoluteString,
                        isLiked: photoResult.likedByUser, smallImageURL: photoResult.urls.small.absoluteString,
                        fullImageURL: photoResult.urls.full.absoluteString
                    )
                }
                
                self.photos.append(contentsOf: newPhotos)
                self.currentPage = nextPage
                
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self
                )
                
            case .failure(let error):
                print("[ImagesListService]: \(error)")
            }
        }.resume()
    }
    
    func cleanImageListService() {
        photos.removeAll()
        currentPage = 0
        isLoading = false
        task = nil
        task?.cancel()
    }
}
