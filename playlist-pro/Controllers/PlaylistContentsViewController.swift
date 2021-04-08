//
//  PlaylistDetailViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/16/21.
//

import UIKit

class PlaylistContentsViewController: UIViewController, UISearchBarDelegate {
    
    private let songPlaylistOptionsViewController = SongPlaylistOptionsViewController()

    var playlist = Playlist(title: "Empty Playlist")
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        return searchBar
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.identifier)
        return tableView
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        songPlaylistOptionsViewController.delegate = self
        songPlaylistOptionsViewController.setPlaylist(playlist: playlist, index: PlaylistsManager.shared.getPlaylistIndex(title: playlist.title))

        if playlist.title == "library" {
            navigationItem.title = LibraryManager.LIBRARY_DISPLAY
        }
        else {
            navigationItem.title = playlist.title
        }
        searchBar.delegate = self

        tableView.tableHeaderView = searchBar
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.frame
    }

}
extension PlaylistContentsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.songList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.identifier, for: indexPath) as! SongCell
        cell.song = playlist.songList[indexPath.row]
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
        print("Selected cell number \(indexPath.row) -> \(cell.song!.title)")
        QueueManager.shared.setupQueue(with: playlist, startingAt: indexPath.row)
        tableView.reloadData()
    }
}

extension PlaylistContentsViewController: SongCellDelegate {
    func optionsButtonTapped(tag: Int) {
        let song = playlist.songList[tag]
        let isLibrary = playlist.title == "library"
        songPlaylistOptionsViewController.setSong(song: song, isLibrary: isLibrary, index: tag)
        present(songPlaylistOptionsViewController, animated: true, completion: nil)
    }
}

extension PlaylistContentsViewController: SongPlaylistOptionsViewControllerDelegate {
    
    func removeFromPlaylist(index: Int) {
        if playlist.title != "library" { // Should always be true
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
