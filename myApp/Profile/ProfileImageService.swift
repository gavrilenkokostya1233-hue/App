//
//  ProfileImageService.swift
//  myApp
//
//  Created by Konstantin on 02.10.2026.
//

import Foundation

final class ProfileImageService {

    static let shared = ProfileImageService()

    private var task: URLSessionTask?

    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private init() {}

    struct UserResult: Codable {
        let profileImage: ProfileImage

        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }

    struct ProfileImage: Codable {
        let small: String
    }

    private(set) var avatarURL: String?

    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        task?.cancel()

        guard let token = OAuth2TokenStorage.shared.token else {
            let error = NetworkError.invalidRequest
            print("[ProfileImageService]: \(error)")
            completion(.failure(error))
            return
        }

        let urlString = "https://api.unsplash.com/users/\(username)"

        guard let url = URL(string: urlString) else {
            let error = NetworkError.invalidRequest
            print("[ProfileImageService]: \(error)")
            completion(.failure(error))
            return
        }

        var request = URLRequest(url: url)
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        let task = URLSession.shared.objectTask(
            for: request
        ) { [weak self] (result: Result<UserResult, Error>) in

            switch result {

            case .success(let userResult):
                let avatarURL = userResult.profileImage.small

                self?.avatarURL = avatarURL

                completion(.success(avatarURL))

                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL]
                    )

            case .failure(let error):
                print("[ProfileImageService]: \(error)")
                completion(.failure(error))
            }

            self?.task = nil
        }

        self.task = task
        task.resume()
    }
}
