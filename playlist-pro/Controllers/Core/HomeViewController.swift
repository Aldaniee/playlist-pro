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
	
	var playlistManager = QueueManager()

	override func viewDidLoad() {
		super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        addNowPlayingView()
		addPlaylistManager()
	}

    @objc private func importSpotify() {
        let vc = SpotifyImportViewController()
        vc.title = "Spotify Import"
        navigationController?.pushViewController(vc, animated: true)
    }
	override func viewWillAppear(_ animated: Bool) {
		playlistManager.computeQueue()
		playlistManager.playlistLibraryView.scrollToTop()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		playlistManager.audioPlayer.pause()
	}
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNotAuthenticated()

    }
    private func addPlaylistManager() {
        playlistManager.playlistLibraryView.backgroundColor = .clear
        self.view.addSubview(playlistManager.playlistLibraryView)
        playlistManager.playlistLibraryView.translatesAutoresizingMaskIntoConstraints = false
        playlistManager.playlistLibraryView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        playlistManager.playlistLibraryView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        playlistManager.playlistLibraryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        playlistManager.playlistLibraryView.bottomAnchor.constraint(equalTo: playlistManager.playlistLibraryView.topAnchor).isActive = true
        playlistManager.playlistLibraryView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.85).isActive = true

        
    }
    private func addNowPlayingView() {
        playlistManager.nowPlayingView.backgroundColor = .clear
        self.view.addSubview(playlistManager.nowPlayingView)
        playlistManager.nowPlayingView.translatesAutoresizingMaskIntoConstraints = false
        playlistManager.nowPlayingView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        playlistManager.nowPlayingView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        playlistManager.nowPlayingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        playlistManager.nowPlayingView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.15).isActive = true

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
