//
//  StudentLocationTableViewCell.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 10/2/22.
//

import UIKit

class StudentLocationTableViewCell: UITableViewCell {
    
    //MARK: - Properties
    static let reuseId = "StudentLocationTableViewCell"
    
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var studentNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configureCell(with studentLocation: StudentLocation?) {
        DispatchQueue.main.async {
            if let studentLocation = studentLocation {
                self.studentNameLabel.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
            }
        }
    }

}
