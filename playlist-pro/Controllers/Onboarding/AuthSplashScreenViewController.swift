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
        img.image = UIImage(named: "Background")
        return img
    }()
    private let logo: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "Logo")
        return img
    }()
    private let appTitle: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.text = "Playlist Pro"
        lbl.textAlignment = .center
        lbl.textColor = .white
        return lbl
    }()
    private let slogan: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.text = "Take Control Of Your Music"
        lbl.textAlignment = .center
        lbl.textColor = .white

        return lbl
    }()
    private let createAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create Account", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.backgroundColor = .white
        button.setTitleColor(.blackGray, for: .normal)
        button.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
        return button
    }()
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.backgroundColor = .white
        button.setTitleColor(.blackGray, for: .normal)
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        return button
    }()
    private let createAccountWithSpotifyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .spotifyGreen
        button.setTitle("Login with Spotify", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.blackGray, for: .normal)
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.addTarget(self, action: #selector(didTapLoginWithSpotifyButton), for: .touchUpInside)
        return button
    }()
    private let loginAnonymousButton: UIButton = {
        let button = UIButton()
        button.setTitle("CONTINUE AS GUEST", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapLoginAnonymousButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(background)
        view.addSubview(appTitle)
        view.addSubview(slogan)
        view.addSubview(logo)
        view.addSubview(createAccountButton)
        view.addSubview(loginButton)
        view.addSubview(createAccountWithSpotifyButton)
        view.addSubview(loginAnonymousButton)
        createAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        createAccountWithSpotifyButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        loginAnonymousButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        createAccountButton.alpha = 0
        loginButton.alpha = 0
        createAccountWithSpotifyButton.alpha = 0
        loginAnonymousButton.alpha = 0

        if AuthManager.shared.isSignedIn {
            SpotifyAuthManager.shared.refreshIfNeeded(completion: nil)
            let tabBarVC = TabBarViewController()
            tabBarVC.modalPresentationStyle = .fullScreen
            let secondsDelay = 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + secondsDelay) {
                self.present(tabBarVC, animated: false)
            }
        }
        else {
            self.createAccountButton.titleLabel?.alpha = 0
            self.loginButton.titleLabel?.alpha = 0
            self.createAccountWithSpotifyButton.titleLabel?.alpha = 0
            self.loginAnonymousButton.titleLabel?.alpha = 0
            
            createAccountButton.frame = CGRect(
                x: 40+animationOffset/2,
                y: view.height/2 + spacing+animationOffset/2,
                width: view.width - spacing*2-animationOffset,
                height: 52.0-animationOffset
            )
            loginButton.frame = CGRect(
                x: spacing+animationOffset/2,
                y: createAccountButton.bottom + 15+animationOffset/2,
                width: view.width - spacing*2-animationOffset,
                height: 52.0-animationOffset
            )
            createAccountWithSpotifyButton.frame = CGRect(
                x: spacing+animationOffset/2,
                y: loginButton.bottom + 15+animationOffset/2,
                width: view.width - spacing*2-animationOffset,
                height: 52.0-animationOffset
            )
            loginAnonymousButton.frame = CGRect(
                x: spacing+animationOffset/2,
                y: createAccountWithSpotifyButton.bottom + spacing/2+animationOffset/2,
                width: view.width - spacing*2-animationOffset,
                height: 32.0-animationOffset
            )
            UIView.animate(withDuration: 0.5) {
                self.createAccountButton.alpha = 1
                self.loginButton.alpha = 1
                self.createAccountWithSpotifyButton.alpha = 1
                self.loginAnonymousButton.alpha = 1
                self.createAccountButton.frame = CGRect(
                    x: 40,
                    y: self.view.height/2 + self.spacing,
                    width: self.view.width - self.spacing*2,
                    height: 52.0
                )
                self.loginButton.frame = CGRect(
                    x: self.spacing,
                    y: self.createAccountButton.bottom + 15,
                    width: self.view.width - self.spacing*2,
                    height: 52.0
                )
                self.createAccountWithSpotifyButton.frame = CGRect(
                    x: self.spacing,
                    y: self.loginButton.bottom + 15,
                    width: self.view.width - self.spacing*2,
                    height: 52.0
                )
                self.loginAnonymousButton.frame = CGRect(
                    x: self.spacing,
                    y: self.createAccountWithSpotifyButton.bottom + self.spacing/2,
                    width: self.view.width - self.spacing*2,
                    height: 32.0
                )
            }
            UIView.animate(withDuration: 0.5, delay: 0.5) {
                self.createAccountButton.titleLabel?.alpha = 1
                self.loginButton.titleLabel?.alpha = 1
                self.createAccountWithSpotifyButton.titleLabel?.alpha = 1
                self.loginAnonymousButton.titleLabel?.alpha = 1
            }
        }
    }
    let fontSize = CGFloat(16)
    let logoSize = CGFloat(80)
    let spacing = CGFloat(40)
    let animationOffset: CGFloat = 20
    override func viewDidLayoutSubviews() {
        background.frame = view.bounds
        logo.frame = CGRect(
            x: view.center.x-logoSize/2,
            y: view.height/3.5-logoSize/2,
            width: logoSize,
            height: logoSize
        )
        appTitle.frame = CGRect(
            x: spacing,
            y: logo.bottom + spacing/2,
            width: view.width-spacing*2,
            height: 52+3
        )
        appTitle.font = .systemFont(ofSize: 52, weight: .semibold)

        slogan.frame = CGRect(
            x: spacing,
            y: appTitle.bottom + spacing/4,
            width: view.width-spacing*2,
            height: 16+3
        )
        slogan.font = .systemFont(ofSize: 16, weight: .regular)
        
    }
    @objc private func didTapCreateAccountButton() {
        let vc = RegistrationViewController()
        present(vc, animated: true)
    }
    @objc private func didTapLoginButton() {
        let vc = LoginViewController()
        present(vc, animated: true)
    }
    @objc private func didTapLoginWithSpotifyButton() {
        let vc = SpotifyAuthViewController()
        vc.completionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handleSpotifySignIn(success: success)
            }
        }
        navigationItem.largeTitleDisplayMode = .never
        present(vc, animated: true, completion: nil)
    }
    @objc private func didTapLoginAnonymousButton() {
        Auth.auth().signInAnonymously { (authResult, error) in
            if (error == nil) {
                print("Signed in with Anonymous auth")
                // dismiss all view controllers down to the root
                self.dismiss(animated: true, completion: nil)
                let tabBarVC = TabBarViewController()
                tabBarVC.modalPresentationStyle = .fullScreen
                self.present(tabBarVC, animated: true)
            }
        }
    }
    private func handleSpotifySignIn(success: Bool) {
        guard success else {
            let alert = UIAlertController(title: "Oops",
                                          message: "Something went wrong when signing in to Spotify.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            return
        }
        self.dismiss(animated: true, completion: nil)
        let vc = RegistrationViewController()
        present(vc, animated: true)
    }
}
