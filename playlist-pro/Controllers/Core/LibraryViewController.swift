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
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SongPlaylistCell.self, forCellReuseIdentifier: SongPlaylistCell.identifier)
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
        navigationItem.title = Auth.auth().currentUser?.email
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
        let cell = tableView.dequeueReusableCell(withIdentifier: SongPlaylistCell.identifier, for: indexPath) as! SongPlaylistCell
        cell.songDict = LibraryManager.shared.songLibrary.songList.object(at: indexPath.row) as? Dictionary<String, Any>
        cell.refreshCell()

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SongPlaylistCell.rowHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SongPlaylistCell

        print("Selected cell number \(indexPath.row) -> \(cell.songDict!["title"] ?? "")")
    }
}
