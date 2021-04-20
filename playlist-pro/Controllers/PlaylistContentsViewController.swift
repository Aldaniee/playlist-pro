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
        reloadTableView()
        reloadPlaylistData(playlist: playlist)
    }
    var statusBarBottom: CGFloat!
    let headerViewHeight: CGFloat = 200
    let coverArtSize: CGFloat = 200/2

    override func viewDidLoad() {
        super.viewDidLoad()
        statusBarBottom = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 47
        view.backgroundColor = .systemBackground
        songPlaylistOptionsViewController.delegate = self

        tableView.dataSource = self
        tableView.delegate = self
        
        // MARK: – Header View
        headerView.addSubview(titleLabel)
        headerView.addSubview(descriptionLabel)
        headerView.addSubview(durationLabel)
        headerView.addSubview(backButton)
        headerView.addSubview(coverImageView)
        headerView.addSubview(playlistPlayButton)
        headerView.addSubview(optionsButton)
        
        view.addSubview(tableView)
        view.addSubview(headerView)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        playlistPlayButton.addTarget(self, action: #selector(playlistPlayButtonAction), for: .touchUpInside)
        optionsButton.addTarget(self, action: #selector(playlistOptionsButtonPressed), for: .touchUpInside)
        
        self.headerView.frame = CGRect(
            x: 0,
            y: statusBarBottom,
            width: view.width,
            height: headerViewHeight
        )
        tableView.frame = view.frame
        backButton.frame = CGRect(
            x: 10,
            y: 5,
            width: 30,
            height: 30
        )

        titleLabel.frame = CGRect(
            x: 15,
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
        optionsButton.frame = CGRect(
            x: playlistPlayButton.right + 10,
            y: playlistPlayButton.top+playlistPlayButton.height/2-15,
            width: 40,
            height: 30
        )
        self.tableView.contentInset = UIEdgeInsets(
            top: headerViewHeight,
            left: 0,
            bottom: tableView.contentSize.height-statusBarBottom+200,
            right: 0
        )
        tableView.contentOffset.y = -headerViewHeight
        
        self.reloadPlaylistData(playlist: playlist)
    }
    internal func reloadPlaylistData(playlist: Playlist?) {
        if playlist != nil {
            self.playlist = playlist!
        }
        if self.playlist.title == "library" {
            self.titleLabel.text = LibraryManager.LIBRARY_DISPLAY
            self.coverImageView.image = UIImage(systemName: "music.note.house")
        }
        else {
            self.titleLabel.text = self.playlist.title
            if let image = self.playlist.getImage() {
                self.coverImageView.image = image.cropToSquare(sideLength: Double(coverArtSize))
            }
            else {
                self.coverImageView.image = UIImage(systemName: "list.bullet")
            }
        }
        self.coverImageView.tintColor = .gray
        self.coverImageView.contentMode = .scaleAspectFit
        self.reloadTableView()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomHeader = headerViewHeight+statusBarBottom
        headerView.alpha = 1 - (scrollView.contentOffset.y+bottomHeader)/bottomHeader
        let offset = -(scrollView.contentOffset.y + bottomHeader)
        headerView.transform = CGAffineTransform(translationX: 0, y: min(0, offset))
        if offset > 0 {
            self.headerView.frame = CGRect(
                x: 0,
                y: statusBarBottom,
                width: view.width,
                height: headerViewHeight+offset
            )
            titleLabel.alpha = 1 - offset/60
            playlistPlayButton.transform = CGAffineTransform(translationX: 0, y: offset)
            optionsButton.transform = CGAffineTransform(translationX: 0, y: offset)
            
            self.coverImageView.frame = CGRect(
                x: max(view.width-coverArtSize-10-offset, 10),
                y: 10,
                width: min(coverArtSize+offset, view.width-20),
                height: min(coverArtSize+offset, view.width-20)
            )
        }
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
        reloadTableView()
    }
}

extension PlaylistContentsViewController: SongCellDelegate {
    func optionsButtonTapped(tag: Int) {
        let song = playlist.songList[tag]
        songPlaylistOptionsViewController.setSong(song: song, playlist: playlist, index: tag)
        present(songPlaylistOptionsViewController, animated: true, completion: nil)
    }
}

extension PlaylistContentsViewController: SongPlaylistOptionsViewControllerDelegate {
    private func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
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
