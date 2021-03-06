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

    let spacing = CGFloat(60)
    let buttonHeight = CGFloat(50)
    let lineHeight = CGFloat(4)
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = Constants.UI.darkGray
        label.text = "Give your playlist a name"
        return label
    }()
    
    private let inputField: UITextField = {
        let inputField = UITextField()
        inputField.placeholder = "Playlist Name"
        inputField.textAlignment = .center
        inputField.font = .systemFont(ofSize: 32, weight: .heavy)
        inputField.textColor = Constants.UI.blackGray
        return inputField
    }()
    
    private let horizontalLine: UIView = {
        let view = UIView()
        view.backgroundColor = Constants.UI.lightGray
        return view
    }()
    
    private let createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.setTitle("Create Playlist", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onCreateButtonPressed), for: .touchUpInside)
        button.layer.cornerRadius = Constants.UI.cornerRadius
        return button
    }()
    private let importButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.UI.spotifyGreen
        button.setTitle("Import From Spotify", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(onCreateButtonPressed), for: .touchUpInside)
        button.layer.cornerRadius = Constants.UI.cornerRadius
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.UI.hardlyGray
        view.addSubview(titleLabel)
        view.addSubview(inputField)
        view.addSubview(horizontalLine)
        view.addSubview(createButton)
        view.addSubview(importButton)

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let edgePadding = spacing/2
        titleLabel.frame = CGRect(
            x: edgePadding,
            y: view.top+100,
            width: view.width-spacing,
            height: buttonHeight
        )
        inputField.frame = CGRect(
            x: spacing,
            y: titleLabel.bottom+spacing/2,
            width: view.width-spacing*2,
            height: buttonHeight
        )
        horizontalLine.frame = CGRect(
            x: inputField.left,
            y: inputField.bottom,
            width: inputField.width,
            height: lineHeight
        )
        createButton.frame = CGRect(
            x: spacing,
            y: inputField.bottom+spacing,
            width: view.width-spacing*2,
            height: buttonHeight
        )
        createButton.applyButtonGradient(colors: [Constants.UI.orange.cgColor, Constants.UI.lightPink.cgColor])

        importButton.frame = CGRect(
            x: spacing,
            y: createButton.bottom+spacing/3,
            width: view.width-spacing*2,
            height: buttonHeight
        )
    }
    
    @objc func onCreateButtonPressed() {
        let title = inputField.text ?? "My Playlist"
        PlaylistsManager.shared.addPlaylist(playlist: Playlist(songList: LibraryManager.shared.songLibrary.getSongList(), title: title))
        dismiss(animated: true) {
            self.delegate?.reloadTableView()
        }
    }

}
