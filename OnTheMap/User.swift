//
//  User.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 13/2/22.
//

import Foundation

struct User: Codable {
    let key: String
    let firstName: String
    let lastName:  String
    let imageUrl:  String
    let nickname: String
}
