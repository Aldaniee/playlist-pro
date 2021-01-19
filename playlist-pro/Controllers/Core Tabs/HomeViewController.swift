//
//  HomeViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/12/20.
//

import Foundation
import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
	
	var playlistManager = PlaylistManager()
    
    private let headerView: UIView = {
        let header = UIView()
        header.clipsToBounds = true
        header.backgroundColor = .systemGray
        return header
    }()
    private let addButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.UI.orange
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = .boldSystemFont(ofSize: 48)
        button.setTitle("+", for: .normal)
        button.contentVerticalAlignment = .top
        button.titleEdgeInsets = UIEdgeInsets(top: -10.0, left: 0.0, bottom: 0.0, right: 0.0)
        button.addBorder(side: .left, color: .darkGray, width: 1.0)
        return button
    }()

    private func addPlaylistManager() {
        playlistManager.nowPlayingView.backgroundColor = .clear
        self.view.addSubview(playlistManager.nowPlayingView)
        
        playlistManager.nowPlayingView.translatesAutoresizingMaskIntoConstraints = false
        playlistManager.nowPlayingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        playlistManager.nowPlayingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        playlistManager.nowPlayingView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        playlistManager.nowPlayingView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.2).isActive = true
        
        playlistManager.playlistLibraryView.backgroundColor = .clear
        self.view.addSubview(playlistManager.playlistLibraryView)
        playlistManager.playlistLibraryView.translatesAutoresizingMaskIntoConstraints = false
        playlistManager.playlistLibraryView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        playlistManager.playlistLibraryView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        playlistManager.playlistLibraryView.topAnchor.constraint(equalTo: playlistManager.nowPlayingView.bottomAnchor, constant: 5).isActive = true
        playlistManager.playlistLibraryView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
	override func viewDidLoad() {
		super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureHeaderView()
		addPlaylistManager()
	}
    override func viewDidLayoutSubviews() {
        headerView.frame = CGRect(
            x: 0,
            y: 0.0,
            width: view.width,
            height: view.height/3.0)
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
	override func viewWillAppear(_ animated: Bool) {
		playlistManager.computePlaylist()
		playlistManager.playlistLibraryView.scrollToTop()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		playlistManager.audioPlayer.pause()
	}
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNotAuthenticated()

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
	
}
