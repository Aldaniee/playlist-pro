//
//  CreatePlaylistViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/18/21.
//

import UIKit

protocol CreatePlaylistDelegate: class {
    func reloadTableView()
}

class CreatePlaylistViewController: UIViewController {
    weak var delegate: CreatePlaylistDelegate?

    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.text = "Give your playlist a name:"
        return label
    }()
    
    private let inputField: UITextField = {
        let inputField = UITextField()
        inputField.placeholder = "Playlist Name"
        inputField.textAlignment = .center
        inputField.font = .systemFont(ofSize: 16, weight: .semibold)
        inputField.textColor = .black
        inputField.backgroundColor = .white
        return inputField
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Create Playlist", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(onCreateButtonPressed), for: .touchUpInside)
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(overlayView)
        view.addSubview(titleLabel)
        view.addSubview(inputField)
        view.addSubview(createButton)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayView.frame = view.bounds
        titleLabel.frame = CGRect(
            x: 20,
            y: view.top+100,
            width: view.width-40,
            height: 50)
        inputField.frame = CGRect(
            x: 40,
            y: titleLabel.bottom+50,
            width: view.width-80,
            height: 50)
        createButton.frame = CGRect(
            x: 40,
            y: inputField.bottom+50,
            width: view.width-80,
            height: 50)
    }
    
    @objc func onCreateButtonPressed() {
        let title = inputField.text ?? "My Playlist"
        PlaylistsManager.shared.addPlaylist(playlist: Playlist(songList: LibraryManager.shared.songLibrary.getSongList(), title: title))
        dismiss(animated: true) {
            self.delegate?.reloadTableView()
        }
    }

}
