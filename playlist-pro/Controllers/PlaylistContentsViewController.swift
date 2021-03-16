//
//  PlaylistDetailViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/16/21.
//

import UIKit

class PlaylistContentsViewController: UIViewController, UISearchBarDelegate, SongOptionsViewControllerDelegate {
    
    func didTapRemoveFromLibrary() {
        tableView.reloadData()
    }
    let songOptionsViewController = SongOptionsViewController()

    var playlist = Playlist(songList: NSMutableArray(), title: "Empty Playlist")
    
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
        songOptionsViewController.delegate = self
        if playlist.title == LibraryManager.shared.LIBRARY_KEY {
            navigationItem.title = LibraryManager.shared.LIBRARY_DISPLAY
        }
        else {
            navigationItem.title = playlist.title
        }
        searchBar.delegate = self
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.hidesSearchBarWhenScrolling = true
        
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
        return playlist.count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.identifier, for: indexPath) as! SongCell
        cell.songDict = playlist.get(at: indexPath.row)
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
        print("Selected cell number \(indexPath.row) -> \(cell.songDict["title"] ?? "")")
        QueueManager.shared.setupQueue(with: playlist, startingAt: indexPath.row)
    }
}

extension PlaylistContentsViewController: SongCellDelegate {
    func optionsButtonTapped(tag: Int) {
        songOptionsViewController.setSong(songDict: playlist.get(at: tag))
        present(songOptionsViewController, animated: true, completion: nil)
    }
    
}
