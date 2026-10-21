//
//  constants.swift
//  myApp
//
//  Created by Konstantin on 17.09.2026.
//

import Foundation

enum Constants {
    static let accessKey = "2MEh5QQE3RzxML0ef1cBPXrd-CJsbknHxi7bF_okbkE"
    static let secretKey = "a9s-OCvVM34IoPk3K8NlW_NbSwgzBAOYof0wGsIqm74"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let authURLString = "https://unsplash.com/oauth/authorize"
    static let defaultBaseURLString = "https://api.unsplash.com"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURLString: String
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURLString = defaultBaseURLString
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.authURLString,
                                 defaultBaseURLString: Constants.defaultBaseURLString)
    }
}


