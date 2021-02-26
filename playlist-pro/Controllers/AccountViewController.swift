//
//  SettingsViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 1/6/21.
//

import UIKit
import FirebaseAuth

struct AccountCellModel {
    let title: String
    let handler: (() -> Void)
}

/// View Controller to show user settings
final class AccountViewController: UIViewController {
    
    private var data = [[AccountCellModel]]()
    static let cellReuseIdentifier = "AccountCell"
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero,
                                    style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        title = "Account"
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)

        view.addSubview(tableView)
        print(view.subviews)

        tableView.reloadData()
        print(tableView.dataSource?.numberOfSections?(in: tableView) ?? "none")
        // Do any additional setup after loading the view.
    }
    
    private func configureModels() {
        let section = [
            AccountCellModel(title: "Log Out") { [weak self] in
                self?.didTapLogoutButton()
            }
        ]
        data.append(section)
    }

    private func didTapLogoutButton() {
        let actionSheet = UIAlertController(title: "Log Out",
                                            message: "Are you sure you want to log out?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            AuthManager.shared.logOut(completion: { success in
                DispatchQueue.main.async {
                    if success {
                        // Show log in
                        let loginVC = AuthSplashScreenViewController()
                        loginVC.modalPresentationStyle = .fullScreen
                        QueueManager.shared.suspend()
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
        
        //iPad Layout
        actionSheet.popoverPresentationController?.sourceView = tableView
        actionSheet.popoverPresentationController?.sourceRect = tableView.bounds

        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountViewController.cellReuseIdentifier, for: indexPath)
        cell.textLabel!.text = data[indexPath.section][indexPath.row].title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.section][indexPath.row].handler()
    }
    
    
}
