//
//  StudentLocationRequest.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 10/2/22.
//

import Foundation

struct StudentLocationRequest: Codable {
    
    let uniqueKey: String
    let firstName: String
    let lastName:  String
    var mapString: String
    var mediaURL:  String
    var latitude:  Double
    var longitude: Double
    
}
