//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Oscar Martínez Germán on 9/2/22.
//

import UIKit

class LoginViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet weak var emailTextField: LoginTextField!
    @IBOutlet weak var passwordTextField: LoginTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
    }
    
    
    //MARK: - Private Methods
    private func configureVC() {
        setGradiantOn(view: view, top: UIColor.skyeLightBlue, bottom: UIColor.marineDarkBlue)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    private func setLoggingIn(_ loggingIn: Bool) {
        animate(activityIndicator: self.activityIndicator, loggingIn)
        
        self.loginButton.isEnabled = !loggingIn
        self.emailTextField.isEnabled = !loggingIn
        self.passwordTextField.isEnabled = !loggingIn
    }
    
    private func isValidUserCredentials() -> Bool {
        if let email = emailTextField.text, !email.isOnlyWhiteSpaces(),
           let password = passwordTextField.text, !password.isOnlyWhiteSpaces() {
            return true
        }
        return false
    }
    
    private func handleUserResponse() {
        
    }
    
    private func handleLoginResponse(success: Bool, error: Error?) {
        setLoggingIn(false)
        if success { self.performSegue(withIdentifier: "Authenticated", sender: self) }
        else { showAlert(title: OTMError.loginFailure, message: OTMError.unableToLogin.rawValue) }
    }
    
    
    //MARK: - Events
    @objc func dismissKeyboard() { DispatchQueue.main.async { self.view.endEditing(true) } }
    
    @IBAction func onLoginTap(_ sender: UIButton) {
        if isValidUserCredentials() {
            setLoggingIn(true)
            OTMClient.createSession(username: emailTextField.text!, password: passwordTextField.text!, completion: handleLoginResponse)
        } else { self.showAlert(title: OTMError.loginFailure,message: OTMError.missingUserCredential.rawValue) }
    }
    
    @IBAction func onSignUpTap(_ sender: UIButton) {
        //TODO: - Go To Udacity.com
    }
}
