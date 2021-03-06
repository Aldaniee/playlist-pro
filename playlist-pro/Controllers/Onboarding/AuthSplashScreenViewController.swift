//
//  SplashScreenViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/23/20.
//

import UIKit
import Foundation
import Firebase

class AuthSplashScreenViewController: UIViewController {

    private let background: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "scooby")
        return img
    }()
    private let overlay: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.75
        view.applyGradient(colors: Constants.UI.orangePinkPair)
        return view
    }()
    private let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create Account", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    private let loginAnonymousButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue as Guest", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(background)
        view.addSubview(overlay)
        view.addSubview(createAccountButton)
        view.addSubview(loginButton)
        view.addSubview(loginAnonymousButton)
        
        view.backgroundColor = .systemBackground
        
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        loginAnonymousButton.addTarget(self, action: #selector(didTapLoginAnonymousButton), for: .touchUpInside)
    }
    override func viewDidLayoutSubviews() {
        background.frame = view.bounds
        overlay.frame = view.bounds
        createAccountButton.frame = CGRect(
            x: 25,
            y: view.height/2 + 50,
            width: view.width - 50,
            height: 52.0
        )
        loginButton.frame = CGRect(
            x: 25,
            y: createAccountButton.bottom + 10,
            width: view.width - 50,
            height: 52.0
        )
        loginAnonymousButton.frame = CGRect(
            x: 25,
            y: loginButton.bottom + 10,
            width: view.width - 50,
            height: 52.0
        )
        
    }
    @objc private func didTapCreateAccountButton() {
        let vc = RegistrationViewController()
        present(vc, animated: true)
    }
    @objc private func didTapLoginButton() {
        let vc = LoginViewController()
        present(vc, animated: true)
    }
    @objc private func didTapLoginAnonymousButton() {
        Auth.auth().signInAnonymously { (authResult, error) in
            if (error == nil) {
                print("Signed in with Anonymous auth")
                // dismiss all view controllers down to the root
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}
