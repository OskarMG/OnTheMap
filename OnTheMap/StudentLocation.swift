//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 10/2/22.
//

import Foundation


struct StudentLocation: Codable, Equatable {
    
    let objectId:  String
    let uniqueKey: String
    
    let firstName: String
    let lastName:  String
    let latitude:  Double
    let longitude: Double
    let mapString: String
    let mediaURL:  String
    
    let createdAt: String
    let updatedAt: String
    
}
