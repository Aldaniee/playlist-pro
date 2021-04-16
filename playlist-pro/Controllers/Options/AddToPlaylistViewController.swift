//
//  AddToPlaylistViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/16/21.
//

import UIKit

class AddToPlaylistViewController: UIViewController, PlaylistCellDelegate {

    var song : Song?
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Add to Playlist"
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 24, weight: .bold)
        return lbl
    }()
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
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.insertSubview(blurView, at: 0)
        title = "Add To Playlist"
        tableView.dataSource = self
        tableView.delegate = self
        view.backgroundColor = .clear

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        titleLabel.frame = CGRect(
            x: 10,
            y: 30,
            width: 400,
            height: 27
        )
        tableView.frame = CGRect(
            x: 0,
            y: titleLabel.bottom+20,
            width: view.width,
            height: view.height-titleLabel.height-20
        )
        blurView.frame = view.frame
        
    }
    override func viewDidAppear(_ animated: Bool) {
        reloadTableView()
    }

}

extension AddToPlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
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
