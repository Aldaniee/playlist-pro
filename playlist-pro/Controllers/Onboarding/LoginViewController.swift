//
//  LoginViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/12/20.
//

import UIKit
import Foundation

class LoginViewController: UIViewController {

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
        lbl.text = "Login to your account"
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
    private let forgotPassword: UIButton = {
        let button = UIButton()
        button.setTitleColor(.darkGray, for: .normal)
        button.setTitle("Forgot Password?", for: .normal)
        button.contentHorizontalAlignment = .left
        button.contentVerticalAlignment = .center

        return button
    }()
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        
        addSubViews()
        
        view.backgroundColor = .systemBackground
        
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        forgotPassword.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
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
        forgotPassword.frame = CGRect(
            x: spacing+5,
            y: passwordField.bottom + spacing/3,
            width: fieldWidth,
            height: fieldTitleSize)
        forgotPassword.titleLabel?.font = .systemFont(ofSize: fieldTitleSize, weight: .regular)

        loginButton.frame = CGRect(
            x: spacing,
            y: forgotPassword.bottom + spacing/2,
            width: fieldWidth,
            height: fieldSize)
        loginButton.applyButtonGradient(colors: [UIColor.orange.cgColor, UIColor.darkPink.cgColor])

        
    }

    
    private func addSubViews() {
        view.addSubview(logo)
        view.addSubview(appTitle)
        view.addSubview(subTitle)
        view.addSubview(emailTitle)
        view.addSubview(emailField)
        view.addSubview(passwordTitle)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(forgotPassword)
    }
    
    @objc private func didTapLoginButton() {
        print("Login Tapped")
        // remove keyboards
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
        
        guard let email = emailField.text, !email.isEmpty else {
            print("Email Error")
            let alert = UIAlertController(title: "Email Error",
                                          message: "Email is empty.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss",
                                          style: .cancel,
                                          handler: nil))
            self.present(alert, animated: true)
            return
        }
        guard let password = passwordField.text, !password.isEmpty, password.count >= 8 else {
            print("Password Error")
            let alert = UIAlertController(title: "Login Error",
                                          message: "Password must be 8 or more characters.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss",
                                          style: .cancel,
                                          handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        AuthManager.shared.loginUser(username: nil, email: email, password: password) { success in
            DispatchQueue.main.async {
                if success {
                    // user logged in
                    print("Successfully Logged In")
                                        
                    // dismiss all view controllers down to the root
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    let tabBarVC = TabBarViewController()
                    tabBarVC.modalPresentationStyle = .fullScreen
                    self.view.window?.rootViewController?.present(tabBarVC, animated: true)
                }
                else {
                    print("Login Database Error")
                    // error occurred
                    let alert = UIAlertController(title: "Login Error",
                                                  message: "We were unable to log you in.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss",
                                                  style: .cancel,
                                                  handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    @objc private func didTapForgotPassword() {

    }
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            didTapLoginButton()
        }
        return true
    }
}
