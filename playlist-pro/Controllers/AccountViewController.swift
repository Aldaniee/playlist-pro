//
//  SettingsViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 1/6/21.
//

import UIKit
import FirebaseAuth

/// View Controller to show user settings
final class AccountViewController: UIViewController {
    
    private var data = [[AccountCellModel]]()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .grouped)
        tableView.register(AccountSettingsCell.self, forCellReuseIdentifier: AccountSettingsCell.identifier)
        return tableView
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        guard let user = Auth.auth().currentUser else {
            print("We should never get here!!!")
            print("No user logged in, presenting authentication splash screen")
            let vc = AuthSplashScreenViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
            return
        }
        if user.isAnonymous {
            // Show options for user to make an account
            title = "Guest User"
            
            let section = [
                AccountCellModel(title: "Create Account", subtitle: "This transfers your music to a new account") { [weak self] in
                    self?.didTapCreateAccountButton()
                },
                AccountCellModel(title: "Log Out", subtitle: "Loses any music you have saved") { [weak self] in
                    self?.didTapLogoutButton()
                }
            ]
            data.append(section)
        }
        else {
            let section = [
                AccountCellModel(title: "Log Out", subtitle: "") { [weak self] in
                    self?.didTapLogoutButton()
                }
            ]
            data.append(section)
            title = Auth.auth().currentUser?.email
        }
        view.addSubview(tableView)
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        tableView.frame = view.frame
    }

    private func didTapCreateAccountButton() {
        let registrationVC = RegistrationViewController()
        present(registrationVC, animated: true)
    }

    private func didTapLogoutButton() {
        let user = Auth.auth().currentUser
        var message = "Are you sure you want to log out?"
        if user!.isAnonymous {
            message = "Are you sure you want to log out of your guest account? You will lose your music!"
        }
        let actionSheet = UIAlertController(title: "Log Out",
                                            message: message,
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            AuthManager.shared.logOut(completion: { success in
                DispatchQueue.main.async {
                    if success {
                        
                        // Clean up View Controllers
                        YoutubeSearchManager.shared.searchVC = SearchViewController()
                        PlaylistsManager.shared.homeVC = HomeViewController()
                        LibraryManager.shared.libraryVC = LibraryViewController()
                        QueueManager.shared.reset()

                        
                        // Show log in
                        let loginVC = AuthSplashScreenViewController()
                        loginVC.modalPresentationStyle = .fullScreen
                        self.present(loginVC, animated: false) {
                            self.navigationController?.popToRootViewController(animated: false)
                            self.tabBarController?.selectedIndex = 0
                        }
                    }
                    else {
                        // error occurred
                        fatalError("Could not log out user")
                    }
                }
            })
        }))
        present(actionSheet, animated: true)
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return AccountSettingsCell.rowHeight
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountSettingsCell.identifier, for: indexPath) as! AccountSettingsCell
        cell.accountCellModel = data[indexPath.section][indexPath.row]
        cell.refreshCell()

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AccountSettingsCell
        cell.accountCellModel?.handler()
    }
    
    
}
