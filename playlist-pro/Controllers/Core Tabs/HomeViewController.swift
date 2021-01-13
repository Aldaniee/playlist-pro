//
//  HomeViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/12/20.
//

import FirebaseAuth
import UIKit
import Foundation

class HomeViewController: UIViewController {
    
    private let nowPlayingBackground: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.backgroundColor = .systemGray
        return button
    }()
    let thumbnail: UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = 5.0
        imgView.layer.borderWidth = 1.0
        imgView.layer.borderColor = UIColor.lightGray.cgColor
        imgView.layer.masksToBounds = true
        imgView.image = UIImage(named: "ico_placeholder")
        return imgView
    }()
    private let songTitle: UILabel = {
        let label = UILabel()
        label.text = "Song Name"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        addTargets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNotAuthenticated()
        view.backgroundColor = .systemBackground
    }
    override func viewDidLayoutSubviews() {
        nowPlayingBackground.frame = CGRect(
            x: 0.0,
            y: view.bottom - 140,
            width: view.width,
            height: 60)
        thumbnail.frame = CGRect(
            x: 60,
            y: view.bottom - 200,
            width: 60,
            height: 60)
        songTitle.frame = CGRect(
            x: thumbnail.right,
            y: nowPlayingBackground.top,
            width: 100,
            height: 60)
    }
    private func addSubViews() {
        view.addSubview(nowPlayingBackground)
    }
    private func addTargets() {
        nowPlayingBackground.addTarget(self, action: #selector(didTapNowPlaying), for: .touchUpInside)
    }
    
    func handleNotAuthenticated() {
        // Check auth status
        if Auth.auth().currentUser == nil {
            // Show log in
            let loginVC = SplashScreenViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: false)
            
        }
    }
    
    @objc private func didTapNowPlaying() {
        let vc = NowPlayingViewController()
        vc.title = "Now Playing"
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}
