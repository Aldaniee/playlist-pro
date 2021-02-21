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
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PlaylistCell.self, forCellReuseIdentifier: PlaylistCell.identifier)
        return tableView
    }()
    
    // Called everytime view appears
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNotAuthenticated()

    }
    // Called only when view instatiated
	override func viewDidLoad() {
		super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        tableView.frame = view.frame
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @objc private func importSpotify() {
        let vc = SpotifyImportViewController()
        vc.title = "Spotify Import"
        navigationController?.pushViewController(vc, animated: true)
    }
	
    func handleNotAuthenticated() {
        // Check auth status
        if Auth.auth().currentUser == nil {
            // Show log in
            print("No user logged in, presenting authentication splash screen")
            let loginVC = SplashScreenViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: false)
        }
    }
}
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LibraryManager.shared.playlists.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistCell.identifier, for: indexPath) as! PlaylistCell
        if indexPath.row == 0 {
            cell.playlist = Playlist(songList: NSMutableArray(), title: "Create Playlist")
        }
        else {
            cell.playlist = LibraryManager.shared.playlists[indexPath.row - 1]
        }
        cell.refreshCell()

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PlaylistCell.rowHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PlaylistCell

        print("Selected cell number \(indexPath.row) -> \(cell.playlist.title ?? "")")
        
        if indexPath.row == 0 {
            let createPlaylistViewController = CreatePlaylistViewController()
            present(createPlaylistViewController, animated: true, completion: nil)
        }
        else {
            let playlistViewController = PlaylistViewController()
            playlistViewController.setPlaylist(withPlaylist: LibraryManager.shared.playlists[indexPath.row - 1])
            playlistViewController.modalPresentationStyle = .fullScreen
            present(playlistViewController, animated: false, completion: nil)
        }
    }
    
}
