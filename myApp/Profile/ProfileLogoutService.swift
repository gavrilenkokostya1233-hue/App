//
//  ProfileLogoutService.swift
//  myApp
//
//  Created by Konstantin on 11.10.2026.
//

import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService() 
    
    private init() { }
    
    func logout() {
        cleanCookies()
        ProfileService.shared.cleanProfile()
        OAuth2TokenStorage.shared.cleanToken()
        ImagesListService.shared.cleanImageListService()
        
        guard let window = UIApplication.shared.windows.first else { return }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
        
    }
    
    private func cleanCookies() {
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    
}
    
