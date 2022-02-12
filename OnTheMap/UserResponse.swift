//
//  UserResponse.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 12/2/22.
//

import Foundation


struct User: Codable {
    let firstName: String
    let lastName:  String
    let imageUrl:  String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName  = "last_name"
        case imageUrl  = "_image_url"
    }
}

struct UserResponse: Codable {
    
    let user: User
    
}
