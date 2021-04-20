//
//  SongOptionsViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 3/12/21.
//

import UIKit

struct SongPlaylistOptionsCellModel {
    let symbol: UIImage
    let title: String
    let handler: ((Int) -> Void)
}

protocol SongPlaylistOptionsViewControllerDelegate {
    func openAddToPlaylistViewController(song: Song)
}

class SongPlaylistOptionsViewController: UIViewController {

    private var data = [SongPlaylistOptionsCellModel]()
    
    var delegate : SongPlaylistOptionsViewControllerDelegate!
    
    private var song : Song!
    
    private var songPlaylistPos : Int!
    
    private var playlist : Playlist!

    private let albumCoverImageView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    let placeholder = UIImage(named: "placeholder")
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .lightGray
        return lbl
    }()
    private let artistLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .lightGray
        return lbl
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SongPlaylistOptionsCell.self, forCellReuseIdentifier: SongPlaylistOptionsCell.identifier)
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    private let blurView : UIVisualEffectView = {
        let vis = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        vis.translatesAutoresizingMaskIntoConstraints = false
        return vis
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.insertSubview(blurView, at: 0)
        view.backgroundColor = .clear
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        
        view.addSubview(albumCoverImageView)
        view.addSubview(titleLabel)
        view.addSubview(artistLabel)
        titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabelSize)
        artistLabel.font = UIFont.boldSystemFont(ofSize: artistLabelSize)
        
        view.addSubview(tableView)
        configureModels()
        reloadTableView()
        // Do any additional setup after loading the view.
    }
    let spacing = CGFloat(40)
    let albumSpacing = CGFloat(160)
    let titleLabelSize = CGFloat(20)
    let artistLabelSize = CGFloat(20)

    override func viewDidLayoutSubviews() {
        let albumSize = CGFloat(view.width - albumSpacing)
        blurView.frame = view.frame
        albumCoverImageView.frame = CGRect(
            x: albumSpacing/2, y: albumSpacing/2, width: albumSize, height: albumSize
        )
        titleLabel.frame = CGRect(
            x: albumCoverImageView.left, y: albumCoverImageView.bottom+spacing/4, width: albumCoverImageView.width, height: titleLabelSize
        )
        artistLabel.frame = CGRect(
            x: titleLabel.left, y: titleLabel.bottom+spacing/4, width: titleLabel.width, height: artistLabelSize
        )
        tableView.frame = CGRect(
            x: 0, y: view.height/2, width: view.width, height: view.height/2
        )
    }
    
    private func configureModels() {
        if song != nil {
            data.append(SongPlaylistOptionsCellModel(symbol: UIImage(systemName: "rectangle.stack.badge.plus")!, title: "Add to playlist") { _ in
                self.didTapAddToPlaylist()
            })
            data.append(SongPlaylistOptionsCellModel(symbol: UIImage(systemName: "text.badge.plus")!, title: "Add to queue") { _ in
                self.didTapAddToQueue()
            })
            if playlist.title != "library" {
                data.append(SongPlaylistOptionsCellModel(symbol: UIImage(systemName: "rectangle.stack.badge.minus")!, title: "Remove from playlist") { (songPos) in
                    self.didTapRemoveFromPlaylist(songPos: songPos)
                })
            }
            data.append(SongPlaylistOptionsCellModel(symbol: UIImage(systemName: "minus.circle")!, title: "Remove from library") { _ in
                self.didTapRemoveFromLibrary()
            })
        }
        else {
            data.append(SongPlaylistOptionsCellModel(symbol: UIImage(systemName: "text.badge.plus")!, title: "Add to queue") { _ in
                self.didTapAddToQueue()
            })
            data.append(SongPlaylistOptionsCellModel(symbol: UIImage(systemName: "minus.circle")!, title: "Remove playlist") { _ in
                self.didTapRemovePlaylist()
            })
        }
    }
    
    func setSong(song: Song, playlist: Playlist, index: Int) {
        self.songPlaylistPos = index
        self.playlist = playlist
        self.song = song
        let albumSize = CGFloat(view.width - albumSpacing)
        self.titleLabel.text = song.title
        self.artistLabel.text = NSArray(array: song.artists).componentsJoined(by: ", ")
        let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(song.id).jpg"))
        if let imgData = imageData {
            self.albumCoverImageView.image = UIImage(data: imgData)!.cropToSquare(sideLength: Double(albumSize))
        } else {
            self.albumCoverImageView.image = placeholder
        }
    }
    func setPlaylist(playlist: Playlist, index: Int) {
        self.songPlaylistPos = index
        self.playlist = playlist
        self.titleLabel.text = playlist.title
        self.artistLabel.text = ""
        self.albumCoverImageView.image = placeholder
    }
    
    @objc func didTapAddToPlaylist() {
        print("add to playlist pressed")
        delegate.openAddToPlaylistViewController(song: song!)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapAddToQueue() {
        print("add to queue pressed")
        if song != nil {
            QueueManager.shared.addToQueue(songDict: song)
        }
        else {
            QueueManager.shared.addToQueue(playlist: playlist)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapRemoveFromPlaylist(songPos: Int) {
        print("Removing Song: \(song!.title) Index: \(songPos) from Playlist: \(playlist.title)")
        PlaylistsManager.shared.removeFromPlaylist(playlist: playlist, index: songPos)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapRemoveFromLibrary() {
        print("remove from library pressed")
        _ = LibraryManager.shared.deleteSongFromLibrary(song: song)
        for i in 0..<playlist.songList.count {
            if playlist.songList[i] == song {
                didTapRemoveFromPlaylist(songPos: i)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    @objc func didTapRemovePlaylist() {
        print("remove playlist pressed")
        PlaylistsManager.shared.removePlaylist(playlist: playlist)
        dismiss(animated: true, completion: nil)
    }

}
extension SongPlaylistOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongPlaylistOptionsCell.identifier) as! SongPlaylistOptionsCell
        cell.model = data[indexPath.row]
        cell.refreshCell()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! SongPlaylistOptionsCell
        print("Selected cell number \(indexPath.row) -> \(cell.model.title)")
        data[indexPath.row].handler(songPlaylistPos)
    }
    
}
