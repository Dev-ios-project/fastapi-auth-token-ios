//
//  TokenResponse.swift
//  LoginTest
//
//  Created by Mehdi Zahraei on 26.06.24.
//

import Foundation

struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
}

