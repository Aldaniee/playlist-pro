//
//  PlaylistDetailViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/16/21.
//

import UIKit

class PlaylistContentsViewController: UIViewController, UISearchBarDelegate {
    
    private let songPlaylistOptionsViewController = SongPlaylistOptionsViewController()

    var playlist = Playlist(title: "Empty Playlist")
    
    private let headerView : UIView = {
        let navBarView = UIView()
        navBarView.backgroundColor = .white
        return navBarView
    }()
    private let backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        btn.tintColor = .darkPink
        btn.contentMode = .scaleAspectFit
        return btn
    }()
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Playlist Name"
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 24, weight: .bold)
        return lbl
    }()
    private let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = .gray
        return lbl
    }()
    private let durationLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = .gray
        return lbl
    }()
    private let coverImageView: UIImageView = {
        let image = UIImageView()
        return image
    }()
    private let playlistPlayButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "playlist.play.button"), for: .normal)
        btn.tintColor = .darkPink
        btn.contentMode = .scaleAspectFit
        return btn
    }()
    private let optionsButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("···", for: UIControl.State.normal)
        btn.titleLabel!.font = .systemFont(ofSize: 20, weight: .bold)
        btn.setTitleColor(.black, for: UIControl.State.normal)
        btn.titleLabel!.numberOfLines = 0
        btn.contentMode = .scaleAspectFit
        return btn
    }()
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.identifier)
        return tableView
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    var statusBarBottom: CGFloat!
    let headerViewHeight: CGFloat = 200
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBarBottom = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 47
        view.backgroundColor = .systemBackground
        songPlaylistOptionsViewController.delegate = self

        tableView.dataSource = self
        tableView.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        view.addSubview(tableView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(descriptionLabel)
        headerView.addSubview(durationLabel)
        headerView.addSubview(backButton)
        headerView.addSubview(coverImageView)
        headerView.addSubview(playlistPlayButton)
        headerView.addSubview(optionsButton)
        view.addSubview(headerView)

        headerView.frame = CGRect(
            x: 0,
            y: statusBarBottom,
            width: view.width,
            height: headerViewHeight
        )
        backButton.frame = CGRect(
            x: 10,
            y: 10,
            width: 30,
            height: 30
        )
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)

        titleLabel.text = playlist.title == "library" ? LibraryManager.LIBRARY_DISPLAY : playlist.title
        titleLabel.frame = CGRect(
            x: 10,
            y: backButton.bottom,
            width: 400,
            height: 27
        )
        descriptionLabel.frame = CGRect(
            x: titleLabel.left,
            y: titleLabel.bottom + 10,
            width: view.width - 20,
            height: 15
        )
        durationLabel.frame = CGRect(
            x: descriptionLabel.left,
            y: descriptionLabel.bottom + 10,
            width: view.width - 20,
            height: 15
        )
        let coverArtSize = headerViewHeight/2
        coverImageView.frame = CGRect(
            x: view.width-coverArtSize-10,
            y: 10,
            width: coverArtSize,
            height: coverArtSize
        )
        playlistPlayButton.frame = CGRect(
            x: 10,
            y: durationLabel.bottom + 10,
            width: 60,
            height: 60
        )
        playlistPlayButton.addTarget(self, action: #selector(playlistPlayButtonAction), for: .touchUpInside)

        optionsButton.frame = CGRect(
            x: playlistPlayButton.right + 10,
            y: playlistPlayButton.top+playlistPlayButton.height/2-15,
            width: 40,
            height: 30
        )
        optionsButton.addTarget(self, action: #selector(playlistOptionsButtonPressed), for: .touchUpInside)
        tableView.frame = view.frame
        self.tableView.contentInset = UIEdgeInsets(
            top: headerViewHeight,
            left: 0,
            bottom: tableView.contentSize.height-statusBarBottom,
            right: 0
        )
        tableView.contentOffset.y = -headerViewHeight+statusBarBottom
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomHeader = headerViewHeight+statusBarBottom
        headerView.alpha = 1 - (scrollView.contentOffset.y+bottomHeader)/bottomHeader
        let offset = -(scrollView.contentOffset.y + bottomHeader)
        print(scrollView.contentOffset.y)

        headerView.transform = CGAffineTransform(translationX: 0, y: min(0, offset))
    }
    func reloadPlaylistData(playlist: Playlist) {
        self.playlist = playlist
        self.titleLabel.text = playlist.title == "library" ? LibraryManager.LIBRARY_DISPLAY : playlist.title
        self.durationLabel.text = "\(playlist.calcDuration()) minutes"
        self.descriptionLabel.text = playlist.description
        let firstSong = playlist.songList[0]
        let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(firstSong.id).jpg"))
        if let imgData = imageData {
            coverImageView.image = UIImage(data: imgData)!.cropToSquare(sideLength: 15.0)
        } else {
            coverImageView.image = UIImage(systemName: "list.bullet")
            coverImageView.tintColor = .gray
            coverImageView.contentMode = .scaleAspectFit
        }
        self.tableView.reloadData()
    }
    
    @objc func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    @objc func playlistPlayButtonAction() {
        QueueManager.shared.setupQueue(with: playlist, startingAt: 0)
    }
    @objc func playlistOptionsButtonPressed() {
        songPlaylistOptionsViewController.setPlaylist(playlist: playlist, index: PlaylistsManager.shared.getPlaylistIndex(title: playlist.title))
        present(songPlaylistOptionsViewController, animated: true, completion: nil)
    }
}
extension PlaylistContentsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlist.songList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.identifier, for: indexPath) as! SongCell
        cell.song = playlist.songList[indexPath.row]
        cell.refreshCell()
        cell.delegate = self
        cell.optionsButton.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SongCell.rowHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SongCell
        print("Selected cell number \(indexPath.row) -> \(cell.song!.title)")
        QueueManager.shared.setupQueue(with: playlist, startingAt: indexPath.row)
        tableView.reloadData()
    }
}

extension PlaylistContentsViewController: SongCellDelegate {
    func optionsButtonTapped(tag: Int) {
        let song = playlist.songList[tag]
        let isLibrary = playlist.title == "library"
        songPlaylistOptionsViewController.setSong(song: song, isLibrary: isLibrary, index: tag)
        present(songPlaylistOptionsViewController, animated: true, completion: nil)
    }
}

extension PlaylistContentsViewController: SongPlaylistOptionsViewControllerDelegate {
    
    func removeFromPlaylist(index: Int) {
        if playlist.title != "library" { // Should always be true
            PlaylistsManager.shared.removeFromPlaylist(playlist: playlist, index: index)
        }
        else {
            print("This should be inaccessible")
        }
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    func openAddToPlaylistViewController(song: Song) {
        let vc = AddToPlaylistViewController()
        vc.song = song
        let secondsDelay = 0.7
        DispatchQueue.main.asyncAfter(deadline: .now() + secondsDelay) {
            self.present(vc, animated: true, completion: {
                self.reloadTableView()
            })
        }
    }

}
