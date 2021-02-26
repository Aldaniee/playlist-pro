//
//  CreatePlaylistViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/18/21.
//

import UIKit

class CreatePlaylistViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        LibraryManager.shared.addPlaylist(playlist: Playlist(songList: LibraryManager.shared.songLibrary.getSongList(), title: "New Playlist"))
        view.addSubview(inputField)
        inputField.center = view.center
    }
    private let inputField: UITextField = {
        let inputField = UITextField()
        return inputField
    }()

}
