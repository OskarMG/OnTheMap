//
//  OnTheMapNavControls.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 10/2/22.
//

import UIKit
import SafariServices

class OnTheMapNavControls: UIViewController {
    
    //MARK: - Event Handle Methods
    private func handleAddTap() {
        if isAddedLocation() { showOverrideAlert(); return }
        addStudentLocation(action: .add)
    }
    
    func handleRefreshTap() { }
    func addStudentLocation(action: StudentLocationAction) {
        if let studentLocationVC = storyboard?.instantiateViewController(withIdentifier: StudentLocationViewController.identifier) as? StudentLocationViewController {
            studentLocationVC.delegate = self
            studentLocationVC.studentLocationAction = action
            if action == .override { studentLocationVC.cityName = (getMyLocation())?.mapString }
            DispatchQueue.main.async { self.present(studentLocationVC, animated: true, completion: nil) }
        }
    }
    
    func presentSafariVC(width url: URL) {
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredBarTintColor = UIColor.orangeMap
        DispatchQueue.main.async { self.present(safariVC, animated: true) }
    }
    
    func getMyLocation() -> StudentLocation? {
        return (StudentModel.locationList.filter { $0.objectId == OTMClient.Auth.objectId }).first
    }
    
    private func isAddedLocation() -> Bool {
        for studentLocation in StudentModel.locationList {
            if let objectId = OTMClient.getStudentObjectId() {
                return studentLocation.objectId == objectId
            }
        }
        return false
    }
    
    private func showOverrideAlert() {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: "", message: Message.existingLocation, preferredStyle: .alert)
            let override = UIAlertAction(title: "Override", style: .default) { _ in self.addStudentLocation(action: .override) }
            alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertVC.addAction(override)
            self.present(alertVC, animated: true)
        }
    }
    
    //MARK: - Events
    @IBAction func onLogoutTap(_ sender: UIBarButtonItem) {
        DispatchQueue.main.async { self.dismiss(animated: true, completion: nil) }
    }
    
    @IBAction func onAddButtonTapp(_ sender: UIBarButtonItem)    { handleAddTap() }
    @IBAction func onRefreshButtonTap(_ sender: UIBarButtonItem) { handleRefreshTap() }
}
