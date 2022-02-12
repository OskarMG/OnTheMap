//
//  OTMPinAnnotationView.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 10/2/22.
//

import UIKit
import MapKit

class OTMPinAnnotationView: MKPinAnnotationView {

    //MARK: - Properties
    static let reuseId = "OTMPinAnnotationView"
    
    
    func configure(canShowCallout flag: Bool = false) {
        canShowCallout = flag
        pinTintColor = UIColor.orangeMap
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }

}
