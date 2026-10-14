//
//  PhotoResult.swift
//  myApp
//
//  Created by Konstantin on 05.10.2026.
//

import Foundation

struct UrlsResult: Codable {
    let thumb: URL 
    let regular: URL
    let small: URL
    let full: URL
}

struct PhotoResult: Codable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at" 
        case width
        case height
        case description
        case likedByUser = "liked_by_user"
        case urls
    }
}
