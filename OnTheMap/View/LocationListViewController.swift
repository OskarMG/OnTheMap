//
//  LocationListViewController.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 9/2/22.
//

import UIKit

class LocationListViewController: OnTheMapNavControls {

    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureVC()
        OTMClient.getStudentLocations(completion: handleStudentResponse)
    }
    
    
    //MARK: - Private Methods
    private func configureVC() { }
    
    private func handleStudentResponse(result: Result<StudentResults, OTMError>) {
        animate(activityIndicator: activityIndicator, false)
        switch result {
            case .success(let studentResults):
                if !studentResults.results.isEmpty { StudentModel.locationList = studentResults.results
                    tableView.reloadData()
                }
            case .failure(let error): showAlert(title: OTMError.somethingWentWrong, message: error.rawValue)
        }
    }
    
    
    //MARK: - Events    
    override func handleRefreshTap() {
        animate(activityIndicator: activityIndicator, true)
        OTMClient.getStudentLocations(completion: handleStudentResponse)
    }

}


extension LocationListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentModel.locationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StudentLocationTableViewCell.reuseId, for: indexPath) as! StudentLocationTableViewCell
        
        let studentLocation = StudentModel.locationList[indexPath.row]
        cell.configureCell(with: studentLocation)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let studentLocation = StudentModel.locationList[indexPath.row]
        guard let url = URL(string: studentLocation.mediaURL), url.isValid() else {
            self.showAlert(title: "Invalid URL", message: OTMError.unableToOpenUrl.rawValue)
            return
        }
        
        self.presentSafariVC(width: url)
    }
    
}
