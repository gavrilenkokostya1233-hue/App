//
//  PhotoResult.swift
//  myApp
//
//  Created by Konstantin on 05.10.2026.
//

import Foundation

struct PhotoResult: Codable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let description: String?
    let likedByUser: Bool
    
}
