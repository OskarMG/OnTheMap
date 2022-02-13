//
//  OTMError.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 10/2/22.
//

import Foundation


enum OTMError: String, Error {
    //MARK: - Titles Error
    static let loginFailure = "Login failure"
    static let somethingWentWrong = "Something went wrong"
    
    //MARK: - Errors Body
    case invalidResponse  = "Invalid response from the server. Please try again."
    case unableToComplete = "Unable to complete your request. Please check your internet connection."
    case couldNotUpdate   = "Couldn't update your location, please try again."
    case invalidData      = "Data received from the server was invalid. Please try again."
    
    case unableToLogin    = "Unable to login, check your email or password. 😬"
    
    case unableToSubmitRequest = "Unable to submit request."
    case unableToOpenUrl = "Unable to open URL."
    case invalidUrl = "Invalid URL, please insert a valid URL."
    case missingUserCredential = "User credentials are missing."
    case failedToGetLocationList = "Failed to get student location list."
    
    case encodingFailure = "Unable to add location, please try again."
    case unableToGetCoord = "Unable to Pin location, insert a valid city name." 
}
