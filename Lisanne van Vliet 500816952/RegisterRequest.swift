//
//  RegisterRequest.swift
//  Lisanne van Vliet 500816952
//
//  Created by Lisanne van Vliet on 16/11/2021.
//

import Foundation

struct RegisterRequest: Encodable {
    let username: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case username = "UserName"
        case password = "Password"
    }
}

struct RegisterResponse: Decodable {
    let success: Bool
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case success = "Success"
        case message = "Message"
    }
}
