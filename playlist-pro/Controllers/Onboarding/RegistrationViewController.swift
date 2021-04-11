//
//  RegistrationViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/12/20.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    private let logo: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "Login Logo")
        return img
    }()
    private let appTitle: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.text = "Playlist Pro"
        lbl.textAlignment = .center
        lbl.textColor = .black
        return lbl
    }()
    private let subTitle: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.text = "Create an Account"
        lbl.textAlignment = .center
        lbl.textColor = .blackGray
        return lbl
    }()
    private let emailTitle: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.text = "Email"
        lbl.textAlignment = .left
        lbl.textColor = .darkGray
        return lbl
    }()
    private let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email"
        field.returnKeyType = .next
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        field.autocapitalizationType = .none
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.UI.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        return field
    }()
    
    private let passwordTitle: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.text = "Password"
        lbl.textAlignment = .left
        lbl.textColor = .darkGray
        return lbl
    }()
    private let passwordField: UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.placeholder = "Password"
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        field.autocapitalizationType = .none
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.UI.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        return field
    }()
    private let repeatPasswordTitle: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.text = "Repeat Password"
        lbl.textAlignment = .left
        lbl.textColor = .darkGray
        return lbl
    }()
    private let repeatPasswordField: UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.placeholder = "Password"
        field.returnKeyType = .continue
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        field.autocapitalizationType = .none
        field.layer.masksToBounds = true
        field.layer.cornerRadius = Constants.UI.cornerRadius
        field.backgroundColor = .secondarySystemBackground
        return field
    }()
    private let createAccount: UIButton = {
        let button = UIButton()
        button.setTitle("Create Account", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Create Account"
        emailField.delegate = self
        passwordField.delegate = self
        repeatPasswordField.delegate = self

        addSubViews()

    }
    let fontSize = CGFloat(16)
    let logoSize = CGFloat(50)
    let spacing = CGFloat(40)
    let titleSize = CGFloat(36)
    let subTitleSize = CGFloat(14)
    let fieldSize = CGFloat(52)
    let fieldTitleSize = CGFloat(14)
    
    override func viewDidLayoutSubviews() {
        logo.frame = CGRect(
            x: view.center.x-logoSize/2,
            y: spacing*2,
            width: logoSize,
            height: logoSize
        )
        appTitle.frame = CGRect(
            x: spacing,
            y: logo.bottom + spacing/2,
            width: view.width-spacing*2,
            height: titleSize+3
        )
        appTitle.font = .systemFont(ofSize: titleSize, weight: .semibold)

        subTitle.frame = CGRect(
            x: spacing,
            y: appTitle.bottom + spacing,
            width: view.width-spacing*2,
            height: subTitleSize+3
        )
        subTitle.font = .systemFont(ofSize: subTitleSize, weight: .regular)

        let fieldWidth = view.width - spacing*2
        emailTitle.font = .systemFont(ofSize: fieldTitleSize, weight: .regular)
        emailTitle.frame = CGRect(
            x: spacing+5,
            y: subTitle.bottom + spacing,
            width: fieldWidth,
            height: fieldTitleSize+3)
        emailField.frame = CGRect(
            x: spacing,
            y: emailTitle.bottom + spacing/8,
            width: fieldWidth,
            height: fieldSize)
        passwordTitle.font = .systemFont(ofSize: fieldTitleSize, weight: .regular)
        passwordTitle.frame = CGRect(
            x: spacing+5,
            y: emailField.bottom + spacing/2,
            width: fieldWidth,
            height: fieldTitleSize+3)
        passwordField.frame = CGRect(
            x: spacing,
            y: passwordTitle.bottom + spacing/8,
            width: fieldWidth,
            height: fieldSize)
        repeatPasswordTitle.font = .systemFont(ofSize: fieldTitleSize, weight: .regular)
        repeatPasswordTitle.frame = CGRect(
            x: spacing+5,
            y: passwordField.bottom + spacing/2,
            width: fieldWidth,
            height: fieldTitleSize+3)
        repeatPasswordField.frame = CGRect(
            x: spacing,
            y: repeatPasswordTitle.bottom + spacing/8,
            width: fieldWidth,
            height: fieldSize)

        createAccount.frame = CGRect(
            x: spacing,
            y: repeatPasswordField.bottom + spacing/2,
            width: fieldWidth,
            height: fieldSize)
        createAccount.applyButtonGradient(colors: [UIColor.orange.cgColor, UIColor.darkPink.cgColor])

        
    }

    
    private func addSubViews() {
        view.addSubview(logo)
        view.addSubview(appTitle)
        view.addSubview(subTitle)
        view.addSubview(emailTitle)
        view.addSubview(emailField)
        view.addSubview(passwordTitle)
        view.addSubview(repeatPasswordTitle)
        view.addSubview(passwordField)
        view.addSubview(repeatPasswordField)

        view.addSubview(createAccount)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if SpotifyAuthManager.shared.isSignedIn {
            APICaller.shared.getCurrentUserProfile { (result) in
                switch result {
                case .success(let model):
                    print("Fetched Spotify User Profile Success")
                    DispatchQueue.main.async {
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

        createAccount.addTarget(self,
                                 action: #selector(didTapCreateAccount),
                                 for: .touchUpInside)
        emailField.becomeFirstResponder()

    }
    
    @objc private func didTapCreateAccount() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        repeatPasswordField.resignFirstResponder()

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
            print("Password must be 8 characters long")
            // error occurred
            let alert = UIAlertController(title: "Password Error",
                                          message: "Password must be 8 or more characters.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss",
                                          style: .cancel,
                                          handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard let repeatPassword = repeatPasswordField.text, repeatPassword == password else {
            print("Passwords do not match")
            // error occurred
            let alert = UIAlertController(title: "Password Error",
                                          message: "Passwords do not match",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss",
                                          style: .cancel,
                                          handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        AuthManager.shared.registerNewUser(email: email, password: password) { registered in
            DispatchQueue.main.async {
                if registered {
                    // dismiss all view controllers down to the root
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    let tabBarVC = TabBarViewController()
                    tabBarVC.modalPresentationStyle = .fullScreen
                    self.view.window?.rootViewController?.present(tabBarVC, animated: true)
                    
                    print("Registration successful")
                    let alert = UIAlertController(title: "Registration Successful",
                                                  message: "Welcome to Playlist Pro!",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss",
                                                  style: .cancel,
                                                  handler: nil))
                    tabBarVC.present(alert, animated: true)
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
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            repeatPasswordField.becomeFirstResponder()
        }
        else {
            didTapCreateAccount()
        }
        return true
    }
}

