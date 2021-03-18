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
        lbl.font = .systemFont(ofSize: 52, weight: .semibold)
        lbl.textAlignment = .center
        lbl.textColor = .white
        return lbl
    }()
    private let slogan: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.text = "For The Best Playlist In The Room"
        lbl.font = .systemFont(ofSize: 18, weight: .regular)
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
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
        return button
    }()
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = Constants.UI.cornerRadius
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        return button
    }()
    private let loginWithSpotifyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.UI.spotifyGreen
        button.setTitle("Login with Spotify", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.black, for: .normal)
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
        
        view.addSubview(background)
        view.addSubview(appTitle)
        view.addSubview(slogan)
        view.addSubview(logo)
        view.addSubview(createAccountButton)
        createAccountButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)

        view.addSubview(loginButton)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        view.addSubview(loginWithSpotifyButton)
        loginWithSpotifyButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)

        view.addSubview(loginAnonymousButton)
        loginAnonymousButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        

        view.backgroundColor = .systemBackground
    }
    
    let fontSize = CGFloat(16)
    let logoSize = CGFloat(80)
    let spacing = CGFloat(40)
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
            height: 52
        )
        slogan.frame = CGRect(
            x: spacing,
            y: appTitle.bottom + spacing/4,
            width: view.width-spacing*2,
            height: 18
        )

        createAccountButton.frame = CGRect(
            x: 40,
            y: view.height/2 + spacing,
            width: view.width - spacing*2,
            height: 52.0
        )
        loginButton.frame = CGRect(
            x: spacing,
            y: createAccountButton.bottom + 15,
            width: view.width - spacing*2,
            height: 52.0
        )
        loginWithSpotifyButton.frame = CGRect(
            x: spacing,
            y: loginButton.bottom + 15,
            width: view.width - spacing*2,
            height: 52.0
        )
        loginAnonymousButton.frame = CGRect(
            x: spacing,
            y: loginWithSpotifyButton.bottom + spacing/2,
            width: view.width - spacing*2,
            height: 32.0
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
                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
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
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        let vc = RegistrationViewController()
        present(vc, animated: true)
    }
}
