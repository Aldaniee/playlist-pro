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
    let handler: (() -> Void)
}

protocol SongOptionsViewControllerDelegate {
    func reloadTableView()
}

class SongPlaylistOptionsViewController: UIViewController {

    private var data = [SongPlaylistOptionsCellModel]()
    
    var delegate : SongOptionsViewControllerDelegate!
    
    private var songDict : Dictionary<String, Any>?
    
    private var playlist : Playlist?

    private let albumCoverImageView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = Constants.UI.lightGray
        return lbl
    }()
    private let artistLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = Constants.UI.lightGray
        return lbl
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SongOptionsCell.self, forCellReuseIdentifier: SongOptionsCell.identifier)
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
        let section = [
            SongPlaylistOptionsCellModel(symbol: UIImage(systemName: "rectangle.stack.badge.plus")!, title: "Add to playlist") { [weak self] in
                self?.didTapAddToPlaylist()
            },
            SongPlaylistOptionsCellModel(symbol: UIImage(systemName: "text.badge.plus")!, title: "Add to queue") { [weak self] in
                self?.didTapAddToQueue()
            },
            SongPlaylistOptionsCellModel(symbol: UIImage(systemName: "rectangle.stack.badge.minus")!, title: "Remove from playlist") { [weak self] in
                self?.didTapRemoveFromPlaylist()
            },
            SongPlaylistOptionsCellModel(symbol: UIImage(systemName: "minus.circle")!, title: "Remove from library") { [weak self] in
                self?.didTapRemoveFromLibrary()
            }
        ]
        data.append(contentsOf: section)
    }
    
    func setSong(songDict: Dictionary<String, Any>) {
        self.songDict = songDict
        let albumSize = CGFloat(view.width - albumSpacing)
        self.titleLabel.text = songDict["title"] as? String
        self.artistLabel.text = (songDict["artists"] as? NSArray ?? NSArray())!.componentsJoined(by: ", ")
        let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(songDict["id"] as? String ?? "").jpg"))
        if let imgData = imageData {
            self.albumCoverImageView.image = UIImage(data: imgData)!.cropToSquare(size: Double(albumSize))
        } else {
            self.albumCoverImageView.image = UIImage(named: "placeholder")
        }
    }
    func setPlaylist(playlist: Playlist) {
        self.playlist = playlist
        self.titleLabel.text = playlist.title
        self.artistLabel.text = ""
        self.albumCoverImageView.image = UIImage(named: "placeholder")
    }
    
    @objc func didTapAddToPlaylist() {
        print("add to playlist pressed")
    }
    
    @objc func didTapAddToQueue() {
        print("add to queue pressed")
    }
    
    @objc func didTapRemoveFromPlaylist() {
        print("remove from playlist pressed")
    }
    
    @objc func didTapRemoveFromLibrary() {
        print("remove from library pressed")
        LibraryManager.shared.deleteSongFromLibrary(songID: songDict![SongValues.id] as! String)
        QueueManager.shared.removeFromQueue(songId: songDict![SongValues.id] as! String)
        delegate.reloadTableView()
        dismiss(animated: true, completion: nil)
    }

}
extension SongPlaylistOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongOptionsCell.identifier, for: indexPath) as! SongOptionsCell
        cell.model = data[indexPath.row]
        cell.refreshCell()
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! SongOptionsCell
        print("Selected cell number \(indexPath.row) -> \(cell.model.title)")
        data[indexPath.row].handler()
    }
    
}
