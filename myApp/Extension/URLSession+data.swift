//
//  URLSession+data.swift
//  myApp
//
//  Created by Konstantin on 23.09.2026.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {

    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {

        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request, completionHandler: { data, response, error in

            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode {

                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    let error = NetworkError.httpStatusCode(statusCode)
                    print("[data(for:)]: \(error)")
                    fulfillCompletionOnTheMainThread(.failure(error))
                }

            } else if let error = error {

                let networkError = NetworkError.urlRequestError(error)
                print("[data(for:)]: \(networkError)")
                fulfillCompletionOnTheMainThread(.failure(networkError))

            } else {

                let error = NetworkError.urlSessionError
                print("[data(for:)]: \(error)")
                fulfillCompletionOnTheMainThread(.failure(error))
            }
        })

        return task
    }

    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {

        let decoder = JSONDecoder()

        let task = data(for: request) { result in

            switch result {

            case .success(let data):
                do {
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))

                } catch {
                    print(
                        "[objectTask(for:)]: Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")"
                    )
                    completion(.failure(error))
                }

            case .failure(let error):
                print("[objectTask(for:)]: \(error)")
                completion(.failure(error))
            }
        }

        return task
    }
}
