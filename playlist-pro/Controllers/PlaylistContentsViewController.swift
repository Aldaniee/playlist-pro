//
//  PlaylistDetailViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/16/21.
//

import UIKit

class PlaylistContentsViewController: UIViewController {

    var playlist = Playlist(songList: NSMutableArray(), title: "Create Playlist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = playlist.title
    }
    func setPlaylist(withPlaylist playlist: Playlist) {
        self.playlist = playlist
    }
    
}

