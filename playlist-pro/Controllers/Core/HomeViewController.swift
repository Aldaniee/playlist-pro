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
    
    private let createPlaylistViewController = CreatePlaylistViewController()

    private let songPlaylistOptionsViewController = SongPlaylistOptionsViewController()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SongPlaylistCell.self, forCellReuseIdentifier: SongPlaylistCell.identifier)
        return tableView
    }()
    private let addButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "plus.button"), for: .normal)
        return btn
    }()
    
    // Called every time view appears
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNotAuthenticated()
        PlaylistsManager.shared.fetchPlaylistsFromStorage()
        tableView.reloadData()
    }
    // Called only when view instatiated
	override func viewDidLoad() {
		super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        songPlaylistOptionsViewController.delegate = self
        tableView.frame = view.frame
        tableView.dataSource = self
        tableView.delegate = self
        createPlaylistViewController.delegate = self
        view.addSubview(tableView)
        view.addSubview(addButton)
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)

    }
    let addButtonSize = CGFloat(80)
    let spacing = CGFloat(40)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addButton.frame = CGRect(
            x: view.width - addButtonSize - spacing/2,
            y: spacing*2,
            width: addButtonSize,
            height: addButtonSize
        )

    }
    @objc func addButtonAction() {
        present(createPlaylistViewController, animated: true, completion: {
            self.reloadTableView()
        })
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
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlaylistsManager.shared.playlists.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongPlaylistCell.identifier, for: indexPath) as! SongPlaylistCell
        
        if indexPath.row == 0 {
            cell.playlist = LibraryManager.shared.songLibrary
        }
        else {
            cell.playlist = PlaylistsManager.shared.playlists[indexPath.row - 1]
        }
        cell.refreshCell()
        cell.delegate = self
        cell.optionsButton.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SongPlaylistCell.rowHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SongPlaylistCell

        print("Selected cell number \(indexPath.row) -> \(cell.playlist?.title ?? "no playlist found")")
        let playlistDetailViewController = PlaylistContentsViewController()
        if indexPath.row == 0 {
            playlistDetailViewController.playlist = LibraryManager.shared.songLibrary
        }
        else {
            playlistDetailViewController.playlist = PlaylistsManager.shared.playlists[indexPath.row - 1]
        }
        playlistDetailViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(playlistDetailViewController, animated: true)
    }
    
}

extension HomeViewController: SongPlaylistCellDelegate {
    func optionsButtonTapped(tag: Int) {
        if tag == 0 {
            songPlaylistOptionsViewController.setPlaylist(playlist: LibraryManager.shared.songLibrary)
        }
        else {
            songPlaylistOptionsViewController.setPlaylist(playlist: PlaylistsManager.shared.playlists[tag-1])
        }
        present(songPlaylistOptionsViewController, animated: true, completion: nil)
    }
}

extension HomeViewController: CreatePlaylistDelegate, SongOptionsViewControllerDelegate {
    func removeFromPlaylist(songDict: Dictionary<String, Any>) {
        print("This should be inaccessible")
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
}
