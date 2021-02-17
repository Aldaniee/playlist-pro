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
    
    var miniPlayerView: MiniPlayerView!
    var queueManager = QueueManager()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(QueueSongCell.self, forCellReuseIdentifier: QueueSongCell.identifier)
        return tableView
    }()
    
	override func viewDidLoad() {
		super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self

        //addNowPlayingView()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.safeAreaLayoutGuide.layoutFrame
    }
    
    @objc private func importSpotify() {
        let vc = SpotifyImportViewController()
        vc.title = "Spotify Import"
        navigationController?.pushViewController(vc, animated: true)
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

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        queueManager.queue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QueueSongCell.identifier, for: indexPath) as! QueueSongCell
        cell.songDict = queueManager.queue[indexPath.row] as! Dictionary<String, Any>
        cell.refreshCell()
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return QueueSongCell.rowHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! QueueSongCell

        print("Selected cell number \(indexPath.row) -> \(cell.songDict["title"] ?? "")")
        
        QueueManager.shared.didSelectSong(songDict: cell.songDict)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            QueueManager.shared.queue.removeObject(at: (QueueManager.shared.queue.count - 2 - indexPath.row) % queueManager.queue.count)
            tableView.reloadData()
        }
    }
}
