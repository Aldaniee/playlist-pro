//
//  PlaylistViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/16/21.
//

import UIKit

class PlaylistViewController: UIViewController {

    var playlist = Playlist(songList: NSMutableArray(), title: "Create Playlist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
    }
    

    func setPlaylist(withPlaylist playlist: Playlist) {
        self.playlist = playlist
    }
    
}
