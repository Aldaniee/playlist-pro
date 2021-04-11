//
//  SpotifyImportViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 1/19/21.
//

import UIKit

class SpotifyImportViewController: UIViewController {

    var playlists = [SpotifyPlaylist]()
    
    public var selectionHandler: ((SpotifyPlaylist) -> Void)?

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SpotifyPlaylistCell.self, forCellReuseIdentifier: SpotifyPlaylistCell.identifier)
        tableView.backgroundColor = .clear

        return tableView
    }()
    let blurView : UIVisualEffectView = {
        let vis = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        vis.translatesAutoresizingMaskIntoConstraints = false
        return vis
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.insertSubview(blurView, at: 0)
        title = "Add To Playlist"
        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = .clear
        fetchData()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.frame
        blurView.frame = view.frame
        
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    private func fetchData() {
        APICaller.shared.getCurrentUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.tableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension SpotifyImportViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SpotifyPlaylistCell.identifier,
            for: indexPath
        ) as? SpotifyPlaylistCell else {
            return UITableViewCell()
        }
        let spotifyPlaylist = playlists[indexPath.row]
        cell.configure(
            with: SpotifyPlaylistCellViewModel(
                title: spotifyPlaylist.name,
                subtitle: spotifyPlaylist.owner.display_name,
                imageURL: URL(string: spotifyPlaylist.images.first?.url ?? "")
            )
        )
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SpotifyPlaylistCell.rowHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected cell number \(indexPath.row) -> \(playlists[indexPath.row].name)")
        
        HapticsManager.shared.vibrateForSelection()

        let playlist = playlists[indexPath.row]
        guard selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true, completion: nil)
            return
        }
    }
}
