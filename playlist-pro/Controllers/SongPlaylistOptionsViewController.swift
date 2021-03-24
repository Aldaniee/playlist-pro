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
    func openAddToPlaylistViewController(songDict: Song)
}

class SongPlaylistOptionsViewController: UIViewController {

    private var data = [SongPlaylistOptionsCellModel]()
    
    var delegate : SongPlaylistOptionsViewControllerDelegate!
    
    private var songDict : Song!
    
    private var songPlaylistPos : Int!
    
    private var isInLibrary = false
    
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
        tableView.reloadData()
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
        if songDict != nil {
            data.append(SongPlaylistOptionsCellModel(symbol: UIImage(systemName: "rectangle.stack.badge.plus")!, title: "Add to playlist") { _ in
                self.didTapAddToPlaylist()
            })
            data.append(SongPlaylistOptionsCellModel(symbol: UIImage(systemName: "text.badge.plus")!, title: "Add to queue") { _ in
                self.didTapAddToQueue()
            })
            if isInLibrary == false {
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
    
    func setSong(songDict: Song, isLibrary: Bool, index: Int) {
        self.isInLibrary = isLibrary
        self.songPlaylistPos = index
        self.songDict = songDict
        let albumSize = CGFloat(view.width - albumSpacing)
        self.titleLabel.text = songDict["title"] as? String
        self.artistLabel.text = (songDict["artists"] as? NSArray ?? NSArray())!.componentsJoined(by: ", ")
        let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(songDict["id"] as? String ?? "").jpg"))
        if let imgData = imageData {
            self.albumCoverImageView.image = UIImage(data: imgData)!.cropToSquare(sideLength: Double(albumSize))
        } else {
            self.albumCoverImageView.image = placeholder
        }
    }
    func setPlaylist(playlist: Playlist, index: Int) {
        self.playlist = playlist
        self.songPlaylistPos = index
        self.titleLabel.text = playlist.title
        self.artistLabel.text = ""
        self.albumCoverImageView.image = placeholder
    }
    
    @objc func didTapAddToPlaylist() {
        print("add to playlist pressed")
        delegate.openAddToPlaylistViewController(songDict: songDict!)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapAddToQueue() {
        print("add to queue pressed")
        if songDict != nil {
            QueueManager.shared.addToQueue(songDict: songDict)
        }
        else {
            QueueManager.shared.addToQueue(playlist: playlist!)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapRemoveFromPlaylist(songPos: Int) {
        print("Removing Song: \(songDict![SongValues.title] ?? "") Index: \(songPos) from Playlist: \(playlist?.title ?? "")")
        PlaylistsManager.shared.removeFromPlaylist(playlist: playlist, index: songPos)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapRemoveFromLibrary() {
        print("remove from library pressed")
        LibraryManager.shared.deleteSongDictFromLibrary(songID: songDict![SongValues.id] as! String)
        dismiss(animated: true, completion: nil)
    }
    @objc func didTapRemovePlaylist() {
        print("remove playlist pressed")
        PlaylistsManager.shared.removePlaylist(playlist: playlist!)
        dismiss(animated: true, completion: nil)
    }

}
extension SongPlaylistOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    
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
