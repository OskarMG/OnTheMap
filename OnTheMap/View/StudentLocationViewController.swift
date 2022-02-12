//
//  StudentLocationViewController.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 11/2/22.
//

import UIKit
import MapKit
import CoreLocation

class StudentLocationViewController: UIViewController {
    
    //MARK: - Properties
    static let identifier = "StudentLocationViewController"
    var cityName: String?
    var studentRequest: StudentLocationRequest!
    var studentLocationAction: StudentLocationAction!
    weak var delegate: OnTheMapNavControls?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var onTheMapFindBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var locationContainerView: UIView!
    
    @IBOutlet weak var locationContViewYConstraints: NSLayoutConstraint!
    @IBOutlet weak var textFieldYConstraint: NSLayoutConstraint!
    
    var onNextSubmit = false
    var coordinate: CLLocationCoordinate2D!

    
    //MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureVC()
    }
    
    
    //MARK: - Private Methods
    private func configureVC() {
        DispatchQueue.main.async {
            self.mapView.register(OTMPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: OTMPinAnnotationView.reuseId)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
            tap.cancelsTouchesInView = false
            self.view.addGestureRecognizer(tap)
            
            if let cityName = self.cityName { self.textField.text = cityName }
            self.onTheMapFindBtn.layer.cornerRadius = 40 / 2
            self.submitBtn.layer.cornerRadius = 40 / 2
            self.view.backgroundColor = UIColor.lightBlueGray
            self.locationContainerView.backgroundColor = UIColor.faceBookBlue
        }
    }
    
    private func animateLocationContainer() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                self.locationContViewYConstraints = self.locationContViewYConstraints.changeMultiplier(multiplier: 0.333)
                self.textFieldYConstraint.constant = 0
                self.setupNextSubmit()
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func setupNextSubmit() {
        textField.text = Message.insertLink
        onTheMapFindBtn.isHidden = true
        submitBtn.isHidden = false
        onNextSubmit = true
    }
    
    private func adaptUIElement() {
        cancelBtn.tintColor = .white
        textField.placeholder = Message.shareLink
    }
    
    private func configureMapView() {
        mapView.isHidden = false
        let mkCoordSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let mkCoordRegion = MKCoordinateRegion(center: coordinate, span: mkCoordSpan)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        mapView.addAnnotations([annotation])
        mapView.setRegion(mkCoordRegion, animated: true)
    }
    
    private func showMap() {
        DispatchQueue.main.async {
            self.animateLocationContainer()
            self.adaptUIElement()
            self.configureMapView()
        }
    }
    
    private func handleStudentActionResponse(success: Bool, error: OTMError?) {
        if success { dismiss(animated: true) { self.delegate?.handleRefreshTap() } }
        else { if let error = error { showAlert(title: OTMError.somethingWentWrong, message: error.rawValue) } }
    }

    
    //MARK: - Events
    @objc func dismissKeyboard() { DispatchQueue.main.async { self.view.endEditing(true) } }
    
    @IBAction func onCancelButtonTap(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func onTheMapTap(_ sender: UIButton) {
        if let address = textField.text, address != Message.insertLocation, !address.isOnlyWhiteSpaces() {
            getCoordinateFrom(address: address, completion: handleCoordinateResponse)
        }
    }
    
    @IBAction func onSubmitTap(_ sender: UIButton) {
        if let text = textField.text, text != Message.insertLink, !text.isOnlyWhiteSpaces(), let url = URL(string: text), url.isValid() {
            studentRequest.mediaURL = textField.text ?? ""
            
            print("\n\n // Submitted StudentLocation Request: //", studentRequest, "\n\n")
            
            switch studentLocationAction {
                case .add: OTMClient.addStudentLocation(body: studentRequest, completion: handleStudentActionResponse)
                case .override: OTMClient.updateStudentLocation(body: studentRequest, completion: handleStudentActionResponse)
                default: showAlert(title: OTMError.somethingWentWrong)
            }
        } else { showAlert(title: OTMError.somethingWentWrong, message: OTMError.invalidUrl.rawValue) }
    }
}

//MARK: - CoreLocation Methods
extension StudentLocationViewController {
    
    func handleCoordinateResponse(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) {
        guard error == nil, let coordinate = coordinate else {
            self.showAlert(title: OTMError.somethingWentWrong, message: OTMError.unableToGetCoord.rawValue)
            return
        }
        
        self.coordinate = coordinate
        studentRequest = StudentLocationRequest(uniqueKey: OTMClient.Auth.sessionId, firstName: "Osukaru", lastName: "Martinesu", mapString: textField.text ?? "", mediaURL: "", latitude: coordinate.latitude, longitude: coordinate.longitude)
        showMap()
    }
    
    func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) ->Void) {
        CLGeocoder().geocodeAddressString(address) { completion($0?.first?.location?.coordinate, $1) }
    }
    
}

//MARK: - UITextFieldDelegate
extension StudentLocationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async { self.textField.text = "" }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            if let text = textField.text, text.isOnlyWhiteSpaces() {
                self.textField.text = self.onNextSubmit ? Message.insertLink : Message.insertLocation
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
}

//MARK: - MKMapViewDelegate
extension StudentLocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: OTMPinAnnotationView.reuseId, for: annotation) as! OTMPinAnnotationView
        pinView.configure()
        return pinView
    }
    
}
