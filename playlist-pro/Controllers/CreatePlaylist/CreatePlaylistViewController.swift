//
//  CreatePlaylistViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/18/21.
//

import UIKit
import WebKit
protocol CreatePlaylistDelegate: class {
    func reloadTableView()
}

class CreatePlaylistViewController: UIViewController {
    weak var delegate: CreatePlaylistDelegate?

    let spacing = CGFloat(60)
    let buttonHeight = CGFloat(50)
    let lineHeight = CGFloat(4)
    
    private let spotifyImportVC = SpotifyImportViewController()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        label.text = "Give your playlist a name"
        return label
    }()
    
    private let inputField: UITextField = {
        let inputField = UITextField()
        inputField.placeholder = "Playlist Name"
        inputField.textAlignment = .center
        inputField.font = .systemFont(ofSize: 32, weight: .heavy)
        inputField.textColor = .blackGray
        return inputField
    }()
    
    private let horizontalLine: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
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
        button.backgroundColor = .spotifyGreen
        button.setTitle("Import From Spotify", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(onImportButtonPressed), for: .touchUpInside)
        button.layer.cornerRadius = Constants.UI.cornerRadius
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .hardlyGray
        view.addSubview(titleLabel)
        view.addSubview(inputField)
        view.addSubview(horizontalLine)
        view.addSubview(createButton)
        view.addSubview(importButton)
        
        configureSpotifyImport()
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
        createButton.applyDiagonalButtonGradient(colors: [UIColor.orange.cgColor, UIColor.lightPink.cgColor])

        importButton.frame = CGRect(
            x: spacing,
            y: createButton.bottom+spacing/3,
            width: view.width-spacing*2,
            height: buttonHeight
        )
    }
    
    private func configureSpotifyImport() {
        spotifyImportVC.selectionHandler = { playlist in
            SpotifyAPICaller.shared.getPlaylistDetails(for: playlist) { [weak self] result in
                    switch result {
                    case .success(let model):
                        self?.buildPlaylistFromSpotifyPlaylist(spotifyPlaylist: playlist, tracks: model.tracks.items.compactMap({ $0.track }))
                        DispatchQueue.main.async {
                            self?.dismiss(animated: true, completion: nil)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        }
    }
    
    func buildPlaylistFromSpotifyPlaylist(spotifyPlaylist: SpotifyPlaylist, tracks: [AudioTrack]) {
        let playlist = Playlist(title: spotifyPlaylist.name, songList: [Song](), description: spotifyPlaylist.description)
        PlaylistsManager.shared.addPlaylist(playlist: Playlist(title: spotifyPlaylist.name, songList: [Song](), description: spotifyPlaylist.description))
        for track in tracks {
            let searchText = getSearchTextFromTrack(track: track)
            print("Searching with text \(searchText)")
            YoutubeManager.shared.search(searchText: searchText) { videos in
                if videos != nil {
                    YoutubeManager.shared.downloadVideoFromSearchList(videos: videos!) { song in
                        PlaylistsManager.shared.addSongToPlaylist(song: song, playlistName: playlist.title)
                        let playlistIndex = PlaylistsManager.shared.getPlaylistIndex(title: playlist.title)
                        if /*spotifyPlaylist.images.count == 0 && */ PlaylistsManager.shared.playlists[playlistIndex].songList.count == 1 {
                            let firstSong = PlaylistsManager.shared.playlists[playlistIndex].songList[0]
                            let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(firstSong.id).jpg"))
                            if let imgData = imageData {
                                PlaylistsManager.shared.setImageForPlaylist(playlistName: PlaylistsManager.shared.playlists[playlistIndex].title, image: UIImage(data: imgData) ?? UIImage())
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func getSearchTextFromTrack(track: AudioTrack) -> String {
        let artists = track.artists
        var searchText = "\(artists[0].name) - \(track.name)"
        if artists.count > 1 {
            searchText = searchText + " ft. "
            searchText = searchText + "\(artists[1].name)"
            for i in 2..<track.artists.count {
                searchText = searchText + ", \(artists[i].name)"
            }
        }
        return searchText
    }
    
    @objc func onCreateButtonPressed() {
        print("Create Button Pressed")
        let title = inputField.text ?? "My Playlist"
        PlaylistsManager.shared.addPlaylist(playlist: Playlist(title: title))
        dismiss(animated: true) {
            self.delegate?.reloadTableView()
        }
    }
    
    @objc func onImportButtonPressed() {
        print("Import Button Pressed")
        if SpotifyAuthManager.shared.isSignedIn {
            present(spotifyImportVC, animated: true, completion: nil)
        }
        else {
            let vc = SpotifyAuthViewController()
            vc.completionHandler = { [weak self] success in
                self?.onImportButtonPressed()
            }
            navigationItem.largeTitleDisplayMode = .never
            present(vc, animated: true, completion: nil)
        }
    }

}
