//
//  TabBarViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/16/21.
//

import UIKit

class TabBarViewController: UITabBarController, MiniPlayerViewDelegate, QueueManagerDelegate {
    func changePlayPauseIcon(isPlaying: Bool) {
        miniPlayerView.changePlayPauseIcon(isPlaying: isPlaying)
    }
    
    
    var miniPlayerView = MiniPlayerView(frame: .zero)
    
    func showNowPlayingView() {
        let vc = NowPlayingViewController()
        print("Showing Now Playing View Controller")
        present(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let home = HomeViewController()
        let search = SearchViewController()
        let library = LibraryViewController()
        
        home.title = "Playlists"
        search.title = "Search"
        library.title = "Library"
        
        home.navigationItem.largeTitleDisplayMode = .always
        search.navigationItem.largeTitleDisplayMode = .always
        library.navigationItem.largeTitleDisplayMode = .always

        let navHome = UINavigationController(rootViewController: home)
        let navSearch = UINavigationController(rootViewController: search)
        let navLibrary = UINavigationController(rootViewController: library)
        
        navHome.navigationBar.prefersLargeTitles = true
        navSearch.navigationBar.prefersLargeTitles = true
        navLibrary.navigationBar.prefersLargeTitles = true
        
        navHome.tabBarItem = UITabBarItem(title: "Playlists", image: UIImage(systemName: "house"), tag: 1)
        navSearch.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        navLibrary.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "list.bullet"), tag: 1)
        

        setViewControllers([navHome, navSearch, navLibrary], animated: false)
        addMiniPlayerView()
        miniPlayerView.delegate = self
        QueueManager.shared.delegate = self
    }
    private func addMiniPlayerView() {
        self.view.addSubview(miniPlayerView)
        miniPlayerView.translatesAutoresizingMaskIntoConstraints = false
        miniPlayerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        miniPlayerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        miniPlayerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        miniPlayerView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.10).isActive = true
        updateDisplayedSong()
    }
    func updateDisplayedSong() {
        let displayedSong: Dictionary<String, Any>
        if QueueManager.shared.queue.count > 0 {
            QueueManager.shared.unsuspend()
            displayedSong = QueueManager.shared.queue.object(at: 0) as! Dictionary<String, Any>
        } else {
            QueueManager.shared.suspend()
            displayedSong = Dictionary<String, Any>()
        }

        let songID = displayedSong["id"] as? String ?? ""
        miniPlayerView.songID = songID
        miniPlayerView.titleLabel.text = displayedSong["title"] as? String ?? ""
        miniPlayerView.artistLabel.text = ((displayedSong["artists"] as? NSArray ?? NSArray())!.componentsJoined(by: ", "))
        
        let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(songID).jpg"))
        if let imgData = imageData {
            miniPlayerView.thumbnailImageView.image = UIImage(data: imgData)
        } else {
            miniPlayerView.thumbnailImageView.image = UIImage(named: "placeholder")
        }

        //let oldPlaybackRate = audioPlayer.getPlayerRate()

        //miniPlayerView.playbackRateButton.titleLabel?.text = "x\(oldPlaybackRate == 1.0 ? 1 : oldPlaybackRate)"
        miniPlayerView.progressBar.value = 0.0
        //miniPlayerView.currentTimeLabel.text = "00:00"
        //miniPlayerView.timeLeftLabel.text = (songDict["duration"] as? String) ?? "00:00"
    }
}
