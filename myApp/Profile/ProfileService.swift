//
//  ProfileService.swift
//  myApp
//
//  Created by Konstantin on 01.10.2026.
//

import Foundation

final class ProfileService {

    static let shared = ProfileService()

    struct ProfileResult: Codable {
        let username: String
        let firstName: String
        let lastName: String
        let bio: String?

        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
        }
    }

    struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }

    struct ProfileImageResult: Codable {
        let profileImage: ProfileImage

        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }

    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String?
        let profileImageURL: String
    }

    private init() {}

    private var task: URLSessionTask?

    private(set) var profile: Profile?

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        return request
    }

    private func makeProfileImageRequest(
        username: String,
        token: String
    ) -> URLRequest? {

        let urlString = "https://api.unsplash.com/users/\(username)"

        guard let url = URL(string: urlString) else {
            print("[ProfileService]: Не удалось создать URL аватарки")
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        return request
    }

    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService]: Не удалось создать запрос профиля")
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        let task = URLSession.shared.objectTask(
            for: request
        ) { [weak self] (result: Result<ProfileResult, Error>) in

            switch result {

            case .success(let profileResult):

                guard let imageRequest = self?.makeProfileImageRequest(
                    username: profileResult.username,
                    token: token
                ) else {
                    print("[ProfileService]: Не удалось создать запрос аватарки")
                    completion(.failure(NetworkError.invalidRequest))
                    return
                }

                let imageTask = URLSession.shared.objectTask(
                    for: imageRequest
                ) { (result: Result<ProfileImageResult, Error>) in

                    switch result {

                    case .success(let profileImageResult):

                        let profile = Profile(
                            username: profileResult.username,
                            name: "\(profileResult.firstName) \(profileResult.lastName)",
                            loginName: "@\(profileResult.username)",
                            bio: profileResult.bio,
                            profileImageURL: profileImageResult.profileImage.large
                        )

                        self?.profile = profile
                        completion(.success(profile))

                    case .failure(let error):
                        print("[ProfileService]: Ошибка запроса аватарки: \(error)")
                        completion(.failure(error))
                    }
                }

                self?.task = imageTask
                imageTask.resume()

            case .failure(let error):
                print("[ProfileService]: Ошибка запроса профиля: \(error)")
                completion(.failure(error))
            }

            self?.task = nil
        }

        self.task = task
        task.resume()
    }
}
