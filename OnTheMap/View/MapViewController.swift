//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 9/2/22.
//

import UIKit
import MapKit

class MapViewController: OnTheMapNavControls {
    
    //MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        OTMClient.getStudentLocations(completion: handleStudentResponse)
    }

    //MARK: Lock rotation
    override open var shouldAutorotate: Bool { return false }
    
    //MARK: - Private Methods
    private func configureVC() {
        mapView.register(OTMPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: OTMPinAnnotationView.reuseId)
    }
    
    private func handleStudentResponse(result: Result<StudentResults, OTMError>) {
        animate(activityIndicator: activityIndicator, false)
        switch result {
        case .success(let studentResults):
            if !studentResults.results.isEmpty {
                StudentModel.locationList = studentResults.results
                setPinAnnotations()
            }
            case .failure(let error): self.showAlert(title: OTMError.somethingWentWrong, message: error.rawValue)
        }
    }
    
    private func cleanPreviewsPinAnnotations() {
        let annotations = self.mapView.annotations
        self.mapView.removeAnnotations(annotations)
    }
    
    private func setPinAnnotations() {
        var annotations = [MKPointAnnotation]()
        for studentLocation in StudentModel.locationList {
            let lat  = CLLocationDegrees(studentLocation.latitude)
            let long = CLLocationDegrees(studentLocation.longitude)
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
            annotation.subtitle = studentLocation.mediaURL.isEmpty ? studentLocation.mapString : studentLocation.mediaURL
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            annotations.append(annotation)
        }
        
        cleanPreviewsPinAnnotations()
        mapView.addAnnotations(annotations)
    }
    
    
    //MARK: - Events
    override func callAnimate(_ flag: Bool) { animate(activityIndicator: activityIndicator, flag) }
    
    override func handleRefreshTap() {
        animate(activityIndicator: activityIndicator, true)
        OTMClient.getStudentLocations(completion: handleStudentResponse)
    }
}


//MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: OTMPinAnnotationView.reuseId, for: annotation) as! OTMPinAnnotationView
        pinView.configure(canShowCallout: true)
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            guard let annotation = view.annotation,
               let subtitle = annotation.subtitle,
               let strUrl = subtitle, let url = URL(string: strUrl), url.isValid() else {
                   self.showAlert(title: "Invalid URL", message: OTMError.unableToOpenUrl.rawValue)
                   return
            }
            self.presentSafariVC(width: url)
        }
    }
}
