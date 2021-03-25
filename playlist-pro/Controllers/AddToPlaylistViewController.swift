//
//  AddToPlaylistViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/16/21.
//

import UIKit

class AddToPlaylistViewController: UIViewController, PlaylistCellDelegate {

    var song : Song?

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PlaylistCell.self, forCellReuseIdentifier: PlaylistCell.identifier)
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

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = view.frame
        blurView.frame = view.frame
        
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

}

extension AddToPlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlaylistsManager.shared.playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistCell.identifier, for: indexPath) as! PlaylistCell
        cell.playlist = PlaylistsManager.shared.playlists[indexPath.row]
        cell.refreshCell()
        cell.setDarkStyle()
        cell.delegate = self
        cell.optionsButton.isHidden = true
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PlaylistCell.rowHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PlaylistCell
        var playlist = cell.playlist!
        print("Selected cell number \(indexPath.row) -> \(cell.playlist!.title)")
        playlist.songList.append(song!)
        PlaylistsManager.shared.savePlaylistsToStorage()
        dismiss(animated: true, completion: nil)
    }
    func optionsButtonTapped(tag: Int) {}

}
