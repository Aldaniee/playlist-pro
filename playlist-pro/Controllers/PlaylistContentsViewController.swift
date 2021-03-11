//
//  PlaylistDetailViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/16/21.
//

import UIKit

class PlaylistContentsViewController: UIViewController {

    var playlist = Playlist(songList: NSMutableArray(), title: "Empty Playlist")
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        if playlist.title == LibraryManager.shared.LIBRARY_KEY {
            navigationItem.title = LibraryManager.shared.LIBRARY_DISPLAY
        }
        else {
            navigationItem.title = playlist.title
        }
        addTableView()
    }
    func setPlaylist(withPlaylist playlist: Playlist) {
        self.playlist = playlist
    }
    private func addTableView() {
        tableView.frame = view.frame
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self
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

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SongCell.rowHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SongCell

        print("Selected cell number \(indexPath.row) -> \(cell.songDict["title"] ?? "")")
    }
}
