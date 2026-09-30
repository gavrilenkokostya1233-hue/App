//
//  OAuth2TokenStorage.swift
//  myApp
//
//  Created by Konstantin on 26.09.2026.
//

import Foundation

class OAuth2TokenStorage {
    var token: String? { 
        get {
            UserDefaults.standard.string(forKey: "authToken")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "authToken")
        }
    }
}
