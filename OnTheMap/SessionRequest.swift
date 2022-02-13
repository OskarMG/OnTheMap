//
//  SessionRequest.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 10/2/22.
//

import Foundation



struct SessionRequest: Codable {
    
    static let email = "username"
    static let pass  = "password"
    
    let udacity: [String : String]
}
