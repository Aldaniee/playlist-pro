//
//  HomeViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/12/20.
//

import FirebaseAuth
import Foundation
import UIKit

class HomeViewController: UIViewController {
	
	var playlistManager = PlaylistManager()
	var menuButton: UIButton = {
		let btn = UIButton()
		btn.imageView!.contentMode = .scaleAspectFit
		btn.setImage(UIImage(named: "list"), for: UIControl.State.normal)
		return btn
	}()
	let titleLabel: UILabel = {
		let lbl = UILabel()
		lbl.text = "YouTag"
		lbl.font = UIFont.init(name: "DINCondensed-Bold", size: 28)
		lbl.textAlignment = .left
		return lbl
	}()
	let logoImageView: UIImageView = {
		let imgView = UIImageView(image: UIImage(named: "logo"))
		imgView.contentMode = .scaleAspectFit
		return imgView
	}()
	let logoView: UIView = {
		let view = UIView()
		view.backgroundColor = .clear
		return view
	}()
    let addButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = GraphicColors.orange
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = .boldSystemFont(ofSize: 48)
        btn.setTitle("+", for: .normal)
        btn.contentVerticalAlignment = .top
        btn.titleEdgeInsets = UIEdgeInsets(top: -10.0, left: 0.0, bottom: 0.0, right: 0.0)
        btn.addBorder(side: .left, color: .darkGray, width: 1.0)
        return btn
    }()

    private func addLogo() {
        self.view.addSubview(logoView)
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        logoView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 44).isActive = true
        logoView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.29).isActive = true
        logoView.heightAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.09).isActive = true
        
        logoView.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.leadingAnchor.constraint(equalTo: logoView.leadingAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: logoView.centerYAnchor).isActive = true
        logoImageView.widthAnchor.constraint(equalTo: logoView.widthAnchor, multiplier: 0.4).isActive = true
        logoImageView.heightAnchor.constraint(equalTo: logoView.heightAnchor).isActive = true
        logoView.addSubview(titleLabel)

    }
    private func addTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.trailingAnchor.constraint(equalTo: logoView.trailingAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: logoView.centerYAnchor, constant: 3).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: logoView.widthAnchor, multiplier: 0.58).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: logoView.heightAnchor).isActive = true
    }
    private func addMenu() {
        menuButton.addTarget(self, action: #selector(menuButtonAction), for: .touchUpInside)
        self.view.addSubview(menuButton)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        menuButton.topAnchor.constraint(equalTo: self.logoView.topAnchor).isActive = true
        menuButton.widthAnchor.constraint(equalTo: self.logoView.heightAnchor, multiplier: 0.8).isActive = true
        menuButton.heightAnchor.constraint(equalTo: self.logoView.heightAnchor).isActive = true
    }
    private func addPlaylistManager() {
        playlistManager.nowPlayingView.backgroundColor = .clear
        playlistManager.nowPlayingView.addBorder(side: .top, color: .lightGray, width: 1.0)
        playlistManager.nowPlayingView.addBorder(side: .bottom, color: .lightGray, width: 1.0)
        self.view.addSubview(playlistManager.nowPlayingView)
        playlistManager.nowPlayingView.translatesAutoresizingMaskIntoConstraints = false
        playlistManager.nowPlayingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        playlistManager.nowPlayingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        playlistManager.nowPlayingView.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 15).isActive = true
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
        addLogo()
        addTitle()
        addMenu()
		addPlaylistManager()
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
	@objc func menuButtonAction(sender: UIButton!) {
		print("Menu Button tapped")
		let vc = LibraryViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
	}
	
}
