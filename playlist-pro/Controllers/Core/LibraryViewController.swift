//
//  AccountViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/12/20.
//

import Foundation
import UIKit
import FirebaseAuth

final class LibraryViewController: UIViewController {

    private let songPlaylistOptionsViewController = SongPlaylistOptionsViewController()
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Remove all subviews
        for view in view.subviews{
            view.removeFromSuperview()
        }
        guard let user = Auth.auth().currentUser else {
            print("No user logged in, presenting authentication splash screen")
            let vc = AuthSplashScreenViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
            return
        }
        if user.isAnonymous {
            // Show options for user to make an account
            addLoginSubViews()
            title = "Join us?"
            
            loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
            createAccountButton.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
        }
        else {
            configureNavigationBar()
            addTableView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    private let headerView: UIView = {
        let header = UIView()
        header.clipsToBounds = true
        header.backgroundColor = .systemGray
        return header
    }()
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.identifier)
        return tableView
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
    
    private func configureNavigationBar() {
        navigationItem.title = "Library"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.circle"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapSettingsButton))
    }
    private func addTableView() {
        tableView.frame = view.frame
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
    }
    @objc private func didTapSettingsButton() {
        let vc = AccountViewController()
        navigationController?.pushViewController(vc, animated: true)
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
    private func addLoginSubViews() {
        view.addSubview(headerView)
        view.addSubview(loginButton)
        view.addSubview(createAccountButton)
    }
    @objc private func didTapCreateAccountButton() {
        let registrationVC = RegistrationViewController()
        registrationVC.modalPresentationStyle = .fullScreen
        present(registrationVC, animated: true)
    }
    @objc private func didTapLoginButton() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
    }
}
extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LibraryManager.shared.songLibrary.songList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.identifier, for: indexPath) as! SongCell
        cell.songDict = LibraryManager.shared.songLibrary.songList.object(at: indexPath.row) as? Song
        cell.delegate = self

        cell.refreshCell()

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SongCell.rowHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SongCell

        print("Selected cell number \(indexPath.row) -> \(cell.songDict!["title"] ?? "")")
        QueueManager.shared.setupQueue(with: LibraryManager.shared.songLibrary, startingAt: indexPath.row)

    }
}
extension LibraryViewController: SongCellDelegate {
    func optionsButtonTapped(tag: Int) {
        let playlist = LibraryManager.shared.songLibrary
        let songDict = playlist.songList.object(at: tag) as! Song
        let isLibrary = playlist.title == LibraryManager.shared.LIBRARY_KEY
        songPlaylistOptionsViewController.setSong(songDict: songDict, isLibrary: isLibrary, index: tag)
        present(songPlaylistOptionsViewController, animated: true, completion: nil)
    }
}
extension LibraryViewController: SongPlaylistOptionsViewControllerDelegate {
    
    func removeFromPlaylist(index: Int) {
        let playlist = LibraryManager.shared.songLibrary
        if playlist.title != LibraryManager.shared.LIBRARY_KEY { // Should always be true
            PlaylistsManager.shared.removeFromPlaylist(playlist: playlist, index: index)
        }
        else {
            print("This should be inaccessible")
        }
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    func openAddToPlaylistViewController(songDict: Song) {
        let vc = AddToPlaylistViewController()
        vc.songDict = songDict
        let secondsDelay = 0.7
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsDelay) {
            self.present(vc, animated: true, completion: {
                self.reloadTableView()
            })
        }
    }

}
