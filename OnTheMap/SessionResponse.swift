//
//  SessionResponse.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 10/2/22.
//

import Foundation


struct Account: Codable {
    let key: String
    let registered: Bool
}

struct Session: Codable {
    let id: String
    let expiration: String
}

struct SessionResponse: Codable {
    let account: Account
    let session: Session
}
