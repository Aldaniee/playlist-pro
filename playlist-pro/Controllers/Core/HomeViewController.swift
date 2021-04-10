//
//  HomeViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 12/12/20.
//

import Foundation
import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    
    private let playlistContentsViewController = PlaylistContentsViewController()
    
    private let createPlaylistViewController = CreatePlaylistViewController()

    private let songPlaylistOptionsViewController = SongPlaylistOptionsViewController()
    
    private var selectedFilter = 0
    
    private let headerView : UIView = {
        let navBarView = UIView()
        navBarView.backgroundColor = .white
        return navBarView
    }()
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Home"
        lbl.font = .systemFont(ofSize: 34, weight: .bold)
        return lbl
    }()
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Find in music"
        return sb
    }()
    private let addButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "plus.button"), for: .normal)
        return btn
    }()
    private let segmentedView : UIView = {
        let segmentedView = UIView()
        return segmentedView
    }()
    private let allMusicBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("All Music", for: .normal)
        btn.setTitleColor(.gray, for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.isSelected = true
        return btn
    }()
    private let playlistsBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Playlists", for: .normal)
        btn.setTitleColor(.gray, for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.isSelected = false
        return btn
    }()
    private let songsBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Songs", for: .normal)
        btn.setTitleColor(.gray, for: .normal)
        btn.setTitleColor(.black, for: .selected)
        btn.isSelected = false
        return btn
    }()
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .white
        tableView.sectionFooterHeight = 0
        tableView.register(PlaylistCell.self, forCellReuseIdentifier: PlaylistCell.identifier)
        return tableView
    }()
    
    // Called every time view appears
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleNotAuthenticated()
        PlaylistsManager.shared.fetchPlaylistsFromStorage()
        // Hide the real NavBar before making our custom one
        self.navigationController?.navigationBar.isHidden = true
        self.reloadTableView()
    }
    let addButtonSize: CGFloat = 80
    let spacing: CGFloat = 40
    var statusBarBottom: CGFloat = 47
    let headerViewHeight: CGFloat = 214
    let tableViewHeaderHeight: CGFloat = 60
    let searchBarHeight: CGFloat = 35
    // Called only when view instatiated
	override func viewDidLoad() {
		super.viewDidLoad()
        view.backgroundColor = .systemBackground
        songPlaylistOptionsViewController.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        createPlaylistViewController.delegate = self
        view.addSubview(tableView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(searchBar)
        headerView.addSubview(addButton)
        view.addSubview(headerView)

        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
        // Status bar height = 47.0
        statusBarBottom = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 47
        // Nav bar height = 47.0
        //let navHeight = navigationController?.navigationBar.frame.height ?? 0.0
        // Hide the real NavBar before making our custom one
        self.navigationController?.navigationBar.isHidden = true
        headerView.frame = CGRect(
            x: 0,
            y: statusBarBottom,
            width: view.width,
            height: headerViewHeight
        )
        titleLabel.frame = CGRect(
            x: 10,
            y: 10,
            width: 150,
            height: 37
        )
        addButton.frame = CGRect(
            x: view.width-addButtonSize-10,
            y: 10,
            width: addButtonSize,
            height: addButtonSize
        )
        segmentedView.frame = CGRect(
            x: 0,
            y: titleLabel.bottom+20,
            width: headerView.width*(2/3),
            height: tableViewHeaderHeight
        )
        allMusicBtn.frame = CGRect(
            x: 10,
            y: 0,
            width: segmentedView.width/3,
            height: segmentedView.height
        )
        playlistsBtn.frame = CGRect(
            x: allMusicBtn.right,
            y: 0,
            width: segmentedView.width/3,
            height: segmentedView.height
        )
        songsBtn.frame = CGRect(
            x: playlistsBtn.right,
            y: 0,
            width: segmentedView.width/3,
            height: segmentedView.height
        )
        searchBar.frame = CGRect(
            x: 5,
            y: segmentedView.bottom,
            width: view.width-10,
            height: searchBarHeight
        )
        
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.white.cgColor
        addSegmentedView()

        tableView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.width,
            height: view.height
        )
        tableView.automaticallyAdjustsScrollIndicatorInsets = false

        self.setTableViewInsets()
    }

    private func setTableViewInsets() {
        self.tableView.contentInset = UIEdgeInsets(
            top: headerViewHeight-statusBarBottom,
            left: 0,
            bottom: tableView.contentSize.height + tableViewHeaderHeight-statusBarBottom,
            right: 0
        )
        tableView.contentOffset.y = -headerViewHeight+statusBarBottom
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        headerView.alpha = 1 - (scrollView.contentOffset.y+headerViewHeight)/headerViewHeight
        let offset = -(scrollView.contentOffset.y + headerViewHeight)
        print(scrollView.contentOffset.y)

        headerView.transform = CGAffineTransform(translationX: 0, y: min(0, offset))
    }
    private func addSegmentedView() {
        headerView.addSubview(segmentedView)
        allMusicBtn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        playlistsBtn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        songsBtn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)

        segmentedView.addSubview(allMusicBtn)
        segmentedView.addSubview(playlistsBtn)
        segmentedView.addSubview(songsBtn)
        
        allMusicBtn.addTarget(self, action: #selector(allMusicAction), for: .touchUpInside)
        playlistsBtn.addTarget(self, action: #selector(playlistsAction), for: .touchUpInside)
        songsBtn.addTarget(self, action: #selector(songsAction), for: .touchUpInside)

    }
    @objc private func allMusicAction(_ sender: AnyObject) {
        print("All Music Selected")
        if !allMusicBtn.isSelected {
            allMusicBtn.isSelected = true
            playlistsBtn.isSelected = false
            songsBtn.isSelected = false
            selectedFilter = 0
            tableView.register(PlaylistCell.self, forCellReuseIdentifier: PlaylistCell.identifier)
            tableView.reloadData()
            self.setTableViewInsets()
        }
    }
    @objc private func playlistsAction(_ sender: AnyObject) {
        print("Playlists Selected")
        if !playlistsBtn.isSelected {
            playlistsBtn.isSelected = true
            allMusicBtn.isSelected = false
            songsBtn.isSelected = false
            selectedFilter = 1
            tableView.register(PlaylistCell.self, forCellReuseIdentifier: PlaylistCell.identifier)
            tableView.reloadData()
            self.setTableViewInsets()
        }
    }
    
    @objc private func songsAction(_ sender: AnyObject) {
        print("Songs Selected")
        if !songsBtn.isSelected {
            songsBtn.isSelected = true
            allMusicBtn.isSelected = false
            playlistsBtn.isSelected = false
            selectedFilter = 2
            tableView.register(SongCell.self, forCellReuseIdentifier: SongCell.identifier)
            tableView.reloadData()
            self.setTableViewInsets()
        }
    }

    @objc func addButtonAction() {
        present(createPlaylistViewController, animated: true, completion: {
            self.reloadTableView()
        })
    }
    func handleNotAuthenticated() {
        // Check auth status and if the user is not logged in, put the auth splash screen in front with this as the root view controller
        if Auth.auth().currentUser == nil {
            // Show log in
            print("No user logged in, presenting authentication splash screen")
            let loginVC = AuthSplashScreenViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: false)
        }
    }
    func openPlaylist(title: String) {
        var returnIndex : Int? = nil
        let playlistArray = PlaylistsManager.shared.playlists
        for index in 0..<playlistArray.count {
            if playlistArray[index].title == title {
                returnIndex = index
            }
        }
        if returnIndex != nil {
            tableView.selectRow(at: IndexPath(row: returnIndex!, section: 0), animated: true, scrollPosition: .top)
        }
    }
}
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let songsSelected = selectedFilter == 2
        let title = songsSelected ? "Songs" : "Playlists"
        return section == 0 ? "" : title
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat(0) : tableViewHeaderHeight
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: section == 0 ? 0 : tableViewHeaderHeight))
        let songsSelected = selectedFilter == 2
        let title = songsSelected ? "Songs" : "Playlists"
        let headerTitle = section == 0 ? "" : title
        let label: UILabel = {
            let lbl = UILabel()
            lbl.textColor = .black
            lbl.font = .systemFont(ofSize: 18, weight: .bold)
            lbl.textAlignment = .left
            lbl.text = headerTitle
            return lbl
        }()
        headerView.addSubview(label)
        label.frame = CGRect(x: 10, y: tableViewHeaderHeight/3, width: headerView.width, height: 18)
        return headerView
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return selectedFilter == 0 ? 1 : 0
        }
        else {
            return selectedFilter == 2 ? LibraryManager.shared.songLibrary.songList.count : PlaylistsManager.shared.playlists.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedFilter != 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PlaylistCell.identifier, for: indexPath) as! PlaylistCell
            
            if indexPath.section == 0 {
                cell.playlist = LibraryManager.shared.songLibrary
                cell.optionsButton.isHidden = true
            }
            else {
                cell.playlist = PlaylistsManager.shared.playlists[indexPath.row]
            }
            cell.refreshCell()
            cell.delegate = self
            cell.optionsButton.tag = indexPath.row
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SongCell.identifier, for: indexPath) as! SongCell
            if indexPath.section == 1 {
                cell.song = LibraryManager.shared.songLibrary.songList[indexPath.row]
                cell.optionsButton.isHidden = false
            }
            cell.refreshCell()
            cell.delegate = self
            cell.optionsButton.tag = indexPath.row
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return selectedFilter == 2 ? SongCell.rowHeight : PlaylistCell.rowHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedFilter != 2 {

            let cell = tableView.cellForRow(at: indexPath) as! PlaylistCell

            print("Selected cell number \(indexPath.row) -> \(cell.playlist?.title ?? "no playlist found")")
            
            let playlist = indexPath.section == 0 ? LibraryManager.shared.songLibrary : PlaylistsManager.shared.playlists[indexPath.row]

            playlistContentsViewController.modalPresentationStyle = .fullScreen
            playlistContentsViewController.reloadPlaylistData(playlist: playlist)


            navigationController?.pushViewController(playlistContentsViewController, animated: true)
        }
        else {
            if indexPath.section != 0 {

                let cell = tableView.cellForRow(at: indexPath) as! SongCell

                print("Selected cell number \(indexPath.row) -> \(cell.song?.title ?? "no song found")")
                QueueManager.shared.setupQueue(with: LibraryManager.shared.songLibrary, startingAt: indexPath.row)
                tableView.reloadData()
            }
        }
    }
    func reloadPlaylistDetailsVCTableView() {
        playlistContentsViewController.reloadTableView()
    }
    
}

extension HomeViewController: PlaylistCellDelegate, SongCellDelegate {
    func optionsButtonTapped(tag: Int) {
        songPlaylistOptionsViewController.setPlaylist(playlist: PlaylistsManager.shared.playlists[tag], index: tag)
        present(songPlaylistOptionsViewController, animated: true, completion: nil)
    }
}

extension HomeViewController: CreatePlaylistDelegate, SongPlaylistOptionsViewControllerDelegate {
    func openAddToPlaylistViewController(song: Song) {}

    func removeFromPlaylist(index: Int) {}
    
    func reloadTableView() {
        tableView.reloadData()
    }
}
