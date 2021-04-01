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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        addTableView()
    }

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.identifier)
        return tableView
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
}
extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LibraryManager.shared.songLibrary.songList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.identifier, for: indexPath) as! SongCell
        cell.song = LibraryManager.shared.songLibrary.songList[indexPath.row]
        cell.refreshCell()
        cell.delegate = self
        cell.optionsButton.tag = indexPath.row

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SongCell.rowHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SongCell

        print("Selected cell number \(indexPath.row) -> \(cell.song?.title ?? "")")
        QueueManager.shared.setupQueue(with: LibraryManager.shared.songLibrary, startingAt: indexPath.row)
        tableView.reloadData()
    }
}
extension LibraryViewController: SongCellDelegate {
    func optionsButtonTapped(tag: Int) {
        let playlist = LibraryManager.shared.songLibrary
        let song = playlist.songList[tag]
        let isLibrary = playlist.title == LibraryManager.shared.LIBRARY_KEY
        songPlaylistOptionsViewController.setSong(song: song, isLibrary: isLibrary, index: tag)
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
    func openAddToPlaylistViewController(song: Song) {
        let vc = AddToPlaylistViewController()
        vc.song = song
        let secondsDelay = 0.7
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsDelay) {
            self.present(vc, animated: true, completion: {
                self.reloadTableView()
            })
        }
    }

}
