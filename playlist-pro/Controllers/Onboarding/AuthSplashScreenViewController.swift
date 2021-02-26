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

    private let headerView: UIView = {
        let header = UIView()
        header.clipsToBounds = true
        header.backgroundColor = .systemGray
        return header
    }()
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        return button
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
        title = "Playlist Pro"
        
        addSubViews()
        
        view.backgroundColor = .systemBackground
        
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
        loginAnonymousButton.addTarget(self, action: #selector(didTapLoginAnonymousButton), for: .touchUpInside)
    }
    override func viewDidLayoutSubviews() {
        headerView.frame = CGRect(
            x: 0,
            y: 0.0,
            width: view.width,
            height: view.height/3.0)
        loginButton.frame = CGRect(
            x: 25,
            y: headerView.bottom + 10,
            width: view.width - 50,
            height: 52.0)
        createAccountButton.frame = CGRect(
            x: 25,
            y: loginButton.bottom + 10,
            width: view.width - 50,
            height: 52.0)
        loginAnonymousButton.frame = CGRect(
            x: 25,
            y: createAccountButton.bottom + 10,
            width: view.width - 50,
            height: 52.0)
        
        configureHeaderView()
    }
    private func configureHeaderView() {
        guard headerView.subviews.count == 1 else {
            return
        }
        
        guard let backgroundView = headerView.subviews.first else {
            return
        }
        backgroundView.frame = headerView.bounds
    }
    private func addSubViews() {
        view.addSubview(headerView)
        view.addSubview(loginButton)
        view.addSubview(createAccountButton)
        view.addSubview(loginAnonymousButton)
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
