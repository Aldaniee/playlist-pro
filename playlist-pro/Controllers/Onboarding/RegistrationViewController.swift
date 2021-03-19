//
//  RegistrationViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/12/20.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    private var isSpotifySignedIn = false
    
    private let displayNameField: UITextField = {
        let field = UITextField()
        field.placeholder = "Display Name"
        field.returnKeyType = .next
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.UI.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        return field
    }()
    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email Address"
        field.returnKeyType = .next
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.UI.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        return field
    }()
    private let passwordField: UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.placeholder = "Password"
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.UI.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        field.layer.borderWidth = 1.0
        field.layer.borderColor = UIColor.secondaryLabel.cgColor
        return field
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Account"
        view.addSubview(displayNameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(registerButton)
        view.backgroundColor = .systemBackground
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if SpotifyAuthManager.shared.isSignedIn {
            APICaller.shared.getCurrentUserProfile { (result) in
                switch result {
                case .success(let model):
                    print("Fetched Spotify User Profile Success")
                    DispatchQueue.main.async {
                        self.displayNameField.text = model.display_name
                        self.emailField.text = model.email
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            let alert = UIAlertController(title: "You're logged into your Spotify account",
                                          message: "Enter a password to create a Playlist Pro account.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        registerButton.addTarget(self,
                                 action: #selector(didTapRegister),
                                 for: .touchUpInside)
        displayNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        displayNameField.frame = CGRect(x: 20, y: view.safeAreaInsets.top+100, width: view.width-40, height: 52)
        emailField.frame = CGRect(x: 20, y: displayNameField.bottom+10, width: view.width-40, height: 52)
        passwordField.frame = CGRect(x: 20, y: emailField.bottom+10, width: view.width-40, height: 52)
        registerButton.frame = CGRect(x: 20, y: passwordField.bottom+10, width: view.width-40, height: 52)
    }
    @objc private func didTapRegister() {
        emailField.resignFirstResponder()
        displayNameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let displayName = displayNameField.text, !displayName.isEmpty else {
            print("Name Insufficient Error")
            // error occurred
            let alert = UIAlertController(title: "Name Empty",
                                          message: "Please enter a name",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss",
                                          style: .cancel,
                                          handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard let email = emailField.text, !email.isEmpty, email.contains("@"), email.contains(".") else {
            print("Email Insufficient Error")
            // error occurred
            let alert = UIAlertController(title: "Email Error",
                                          message: "Please enter a valid email address.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss",
                                          style: .cancel,
                                          handler: nil))
            self.present(alert, animated: true)
            return
        }
    
        guard let password = passwordField.text, !password.isEmpty, password.count >= 8 else {
            print("Password Insufficient Error")
            // error occurred
            let alert = UIAlertController(title: "Password Error",
                                          message: "Please enter a password of 8 or more characters.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss",
                                          style: .cancel,
                                          handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        AuthManager.shared.registerNewUser(displayName: displayName, email: email, password: password) { registered in
            DispatchQueue.main.async {
                if registered {
                    // dismiss all view controllers down to the root
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    
                    print("Registration successful")
                    let alert = UIAlertController(title: "Registration Successful",
                                                  message: "Welcome to Playlist Pro!",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss",
                                                  style: .cancel,
                                                  handler: nil))
                    self.present(alert, animated: true)
                }
                else {
                    print("Registration error")
                }
            }
        }

    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == displayNameField {
            emailField.becomeFirstResponder()
        }
        else if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else {
            didTapRegister()
        }
        return true
    }
}

