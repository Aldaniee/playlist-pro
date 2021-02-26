//
//  PlaylistViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/12/20.
//

import Foundation
import UIKit
import FirebaseAuth

class PlaylistViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PlaylistCell.self, forCellReuseIdentifier: PlaylistCell.identifier)
        return tableView
    }()
    
    // Called every time view appears
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNotAuthenticated()
        tableView.reloadData()
    }
    // Called only when view instatiated
	override func viewDidLoad() {
		super.viewDidLoad()
        title = "Playlists"
        view.backgroundColor = .systemBackground
        tableView.frame = view.frame
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
	
    func handleNotAuthenticated() {
        // Check auth status and if the user is not logged in, put the auth splash screen in front with this as the root view controller
        if Auth.auth().currentUser == nil {
            // Show log in
            print("No user logged in, presenting authentication splash screen")
            let loginVC = AuthSplashScreenViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: false)
        }
    }
}
extension PlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LibraryManager.shared.playlists.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistCell.identifier, for: indexPath) as! PlaylistCell
        print("here")
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
            present(createPlaylistViewController, animated: true) {
                tableView.reloadData()
            }
        }
        else {
            let playlistDetailViewController = PlaylistContentsViewController()
            playlistDetailViewController.setPlaylist(withPlaylist: LibraryManager.shared.playlists[indexPath.row - 1])
            playlistDetailViewController.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(playlistDetailViewController, animated: true)
        }
    }
    
}
