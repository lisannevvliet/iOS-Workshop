//
//  LoginRequest.swift
//  Lisanne van Vliet 500816952
//
//  Created by Lisanne van Vliet on 16/11/2021.
//

import Foundation

struct LoginRequest: Encodable {
    let username: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case username = "UserName"
        case password = "Password"
    }
}

struct LoginResponse: Decodable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "AuthToken"
    }
}
