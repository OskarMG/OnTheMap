//
//  UIViewController+Extension.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 9/2/22.
//

import UIKit

extension UIViewController {

    func showAlert(title: String = "", message: String = "") {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertVC, animated: true)
        }
    }
    
    func setGradiantOn(view: UIView, top: UIColor, bottom: UIColor) {
        DispatchQueue.main.async {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [top.cgColor, bottom.cgColor]
            gradientLayer.locations = [0.0, 1.0]
            gradientLayer.frame = view.bounds
            view.layer.insertSublayer(gradientLayer, at:0)
        }
    }
    
    func animate(activityIndicator: UIActivityIndicatorView, _ flag: Bool) {
        DispatchQueue.main.async {
            if flag { activityIndicator.startAnimating() }
            else { activityIndicator.stopAnimating() }
        }
    }
    
    func isOnDarkMode() -> Bool {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        } else { return false }
    }
    
}
