//
//  OAuth2Service.swift
//  myApp
//
//  Created by Konstantin on 20.09.2026.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {

    static let shared = OAuth2Service()

    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?

    let tokenStorage = OAuth2TokenStorage.shared

    private init() {}

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {

        guard var urlComponents = URLComponents(
            string: "https://unsplash.com/oauth/token"
        ) else {
            print("[OAuth2Service]: Не удалось создать URLComponents")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accesKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        guard let authTokenUrl = urlComponents.url else {
            print("[OAuth2Service]: Не удалось создать URL")
            return nil
        }

        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"

        return request
    }

    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        assert(Thread.isMainThread)

        // Если запрос уже выполняется
        if task != nil {

            // Пришёл новый code — отменяем старый запрос
            if lastCode != code {
                task?.cancel()
            } else {
                // Тот же code уже обрабатывается
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }

        } else {

            // Запроса сейчас нет, но такой code уже использовался
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }

        lastCode = code

        guard let urlRequest = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service]: Не удалось создать запрос")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(
            for: urlRequest
        ) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in

            DispatchQueue.main.async {

                switch result {

                case .success(let tokenResponse):
                    let token = tokenResponse.accessToken
                    self?.tokenStorage.token = token
                    completion(.success(token))

                case .failure(let error):
                    print("[OAuth2Service]: \(error)")
                    completion(.failure(error))
                }

                self?.task = nil
                self?.lastCode = nil
            }
        }

        self.task = task
        task.resume()
    }
}
