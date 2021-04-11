//
//  TabBarViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/16/21.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    // Testing
    private let testingMode = false
    private let downloadButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .black
        btn.setTitle("Download", for: .normal)
        return btn
    }()
    private let spotifyLoggedInView: UILabel = {
        let view = UILabel()
        view.backgroundColor = .spotifyGreen
        view.text = ""
        return view
    }()
    
    // Definitions
    private var miniPlayerView = MiniPlayerView(frame: .zero)
    private var nowPlayingVC = NowPlayingViewController()
    private var queueVC = QueueViewController()
    private var displayedSong: Song?

    private var isProgressBarSliding = false

    // MARK: - View controller lifecycle methods
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        PlaylistsManager.shared.fetchPlaylistsFromDatabase()
        LibraryManager.shared.fetchLibraryFromDatabase()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateDisplayedSong()
        if testingMode {
            spotifyLoggedInView.text = SpotifyAuthManager.shared.isSignedIn ? " Logged In" : " Logged Out"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        QueueManager.shared.audioPlayer.delegate = self
        QueueManager.shared.delegate = self
        
        tabBar.isTranslucent = false
        tabBar.barTintColor = .blackGray
        tabBar.tintColor = .darkPink

        let home = PlaylistsManager.shared.homeVC
        let search = YoutubeSearchManager.shared.searchVC
        let library = LibraryManager.shared.libraryVC
        
        search.title = "Search"
        library.title = "Library"
        
        search.navigationItem.largeTitleDisplayMode = .always
        library.navigationItem.largeTitleDisplayMode = .always

        let navHome = UINavigationController(rootViewController: home)
        let navSearch = UINavigationController(rootViewController: search)
        let navLibrary = UINavigationController(rootViewController: library)
        
        navSearch.navigationBar.prefersLargeTitles = true
        navLibrary.navigationBar.prefersLargeTitles = true
        
        navHome.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        navSearch.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        navLibrary.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "list.bullet"), tag: 1)
        
        setViewControllers([navHome, navSearch, navLibrary], animated: false)
        view.addSubview(miniPlayerView)
        
        // Added for testing of user login swap
        if testingMode {
            view.addSubview(downloadButton)
            view.addSubview(spotifyLoggedInView)
        }
    }
    override func viewDidLayoutSubviews() {
        
        updateDisplayedSong()
        updateRepeatButton()
        updateShuffleButton()
        
        let miniPlayerHeight = miniPlayerView.isHidden ? 0 : CGFloat(60)
        miniPlayerView.frame = CGRect(
            x: 0,
            y: tabBar.top - miniPlayerHeight,
            width: view.width,
            height: miniPlayerHeight
        )
        
        linkMiniPlayerButtonActions()
        linkNowPlayingVCButtonActions()
        linkQueueVCButtonActions()
        
        if testingMode {
            downloadButton.frame = CGRect(x: view.center.x-50, y: 50, width: 100, height: 50)
            spotifyLoggedInView.frame = CGRect(x:50, y: 50, width: 100, height: 50)
            downloadButton.addTarget(self, action: #selector(downloadButtonAction), for: .touchUpInside)
        }
    }
    
    // MARK: - Internal Logic Methods
    private func changePlayPauseIcon(isPlaying: Bool) {
        let font = UIFont.systemFont(ofSize: 999)
        let configuration = UIImage.SymbolConfiguration(font: font)
        if isPlaying {
            miniPlayerView.pausePlayButton.setImage(UIImage(systemName: "pause.fill"), for: UIControl.State.normal)
            nowPlayingVC.pausePlayButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: configuration), for: UIControl.State.normal)
            queueVC.pausePlayButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: configuration), for: UIControl.State.normal)
        } else {
            miniPlayerView.pausePlayButton.setImage(UIImage(systemName: "play.fill"), for: UIControl.State.normal)
            nowPlayingVC.pausePlayButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: UIControl.State.normal)
            queueVC.pausePlayButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: UIControl.State.normal)
        }
    }
    private func updateRepeatButton() {
        if QueueManager.shared.repeatSelection == RepeatType.none {
            nowPlayingVC.repeatButton.tintColor = .white
            nowPlayingVC.repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
            queueVC.repeatButton.tintColor = .white
            queueVC.repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
        }
        else if QueueManager.shared.repeatSelection == RepeatType.playlist {
            nowPlayingVC.repeatButton.tintColor = .darkPink
            nowPlayingVC.repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
            queueVC.repeatButton.tintColor = .darkPink
            queueVC.repeatButton.setImage(UIImage(systemName: "repeat"), for: .normal)
        }
        else {
            nowPlayingVC.repeatButton.tintColor = .darkPink
            nowPlayingVC.repeatButton.setImage(UIImage(systemName: "repeat.1"), for: .normal)
            queueVC.repeatButton.tintColor = .darkPink
            queueVC.repeatButton.setImage(UIImage(systemName: "repeat.1"), for: .normal)
        }
    }
    private func updateShuffleButton() {
        if QueueManager.shared.shuffleStatus {
            nowPlayingVC.shuffleButton.tintColor = .darkPink
            queueVC.shuffleButton.tintColor = .darkPink
        }
        else {
            nowPlayingVC.shuffleButton.tintColor = .white
            queueVC.shuffleButton.tintColor = .white
        }
    }
    
    // MARK: - Button interaction methods
    
    private func linkMiniPlayerButtonActions() {
        miniPlayerView.miniPlayerButton.addTarget(self, action: #selector(miniplayerButtonPressed), for: .touchUpInside)
        miniPlayerView.pausePlayButton.addTarget(self, action: #selector(pausePlayButtonAction), for: .touchUpInside)
    }
    private func linkNowPlayingVCButtonActions() {
        nowPlayingVC.closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        nowPlayingVC.progressBar.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        nowPlayingVC.nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        nowPlayingVC.pausePlayButton.addTarget(self, action: #selector(pausePlayButtonAction), for: .touchUpInside)
        nowPlayingVC.previousButton.addTarget(self, action: #selector(previousButtonAction), for: .touchUpInside)
        nowPlayingVC.shuffleButton.addTarget(self, action: #selector(shuffleButtonAction), for: .touchUpInside)
        nowPlayingVC.repeatButton.addTarget(self, action: #selector(repeatButtonAction), for: .touchUpInside)
        nowPlayingVC.queueButton.addTarget(self, action: #selector(queueButtonAction), for: .touchUpInside)
    }
    private func linkQueueVCButtonActions() {
        queueVC.nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        queueVC.pausePlayButton.addTarget(self, action: #selector(pausePlayButtonAction), for: .touchUpInside)
        queueVC.previousButton.addTarget(self, action: #selector(previousButtonAction), for: .touchUpInside)
        queueVC.shuffleButton.addTarget(self, action: #selector(shuffleButtonAction), for: .touchUpInside)
        queueVC.repeatButton.addTarget(self, action: #selector(repeatButtonAction), for: .touchUpInside)
    }
    
    @objc func downloadButtonAction() {
        LibraryManager.shared.fetchLibraryFromDatabase()
        PlaylistsManager.shared.fetchPlaylistsFromDatabase()
    }
    
    @objc func miniplayerButtonPressed(sender: UIButton!) {
        print("MiniPlayerView tapped, showing NowPlayingViewController")
        
        nowPlayingVC.modalPresentationStyle = .fullScreen
        nowPlayingVC.transitioningDelegate = self
        nowPlayingVC.modalPresentationStyle = .custom

        present(nowPlayingVC, animated: true, completion: nil)
    }
    
    @objc func pausePlayButtonAction(sender: UIButton?) {
        if QueueManager.shared.isPlaying() {
            print("Paused")
            QueueManager.shared.pause()
            changePlayPauseIcon(isPlaying: false)
        } else{
            print("Playing")
            QueueManager.shared.play()
            changePlayPauseIcon(isPlaying: true)
        }
    }

    @objc func closeButtonAction(sender: UIButton?) {
        print("Close button tapped")
        dismiss(animated: true, completion: nil)
    }
    @objc func queueButtonAction(sender: UIButton?) {
        print("Queue button tapped")
        nowPlayingVC.present(queueVC, animated: true, completion: nil)
    }
    
    @objc func nextButtonAction(sender: UIButton!) {
        print("Next Button tapped")
        QueueManager.shared.nextButtonAction()
        updateDisplayedSong()
   }
    
    @objc func previousButtonAction(sender: UIButton!) {
        print("Previous Button tapped")
        QueueManager.shared.prevButtonAction()
        updateDisplayedSong()
    }
    
    @objc func playbackRateButtonAction(sender: UIButton!) {
        print("Playback rate Button tapped")
        if displayedSong?.id == "" {
            return
        }
        if sender.titleLabel?.text == "x1" {
            sender.setTitle("x1.25", for: .normal)
            QueueManager.shared.setPlayerRate(to: 1.25)
        } else if sender.titleLabel?.text == "x1.25" {
            sender.setTitle("x0.75", for: .normal)
            QueueManager.shared.setPlayerRate(to: 0.75)
        } else {
            sender.setTitle("x1", for: .normal)
            QueueManager.shared.setPlayerRate(to: 1)
        }
    }
    
    @objc func shuffleButtonAction(sender: UIButton!) {
        print("Shuffle button tapped")
        QueueManager.shared.shuffle()
        updateShuffleButton()
        queueVC.tableView.reloadData()
    }
    
    @objc func repeatButtonAction(sender: UIButton!) {
        print("Repeat button tapped")
        QueueManager.shared.toggleRepeatType()
        updateRepeatButton()
    }

    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
                case .began:
                // handle drag began
                    isProgressBarSliding = true
                break
                case .ended:
                // handle drag ended
                    QueueManager.shared.setPlayerCurrentTime(withPercentage: slider.value)
                    isProgressBarSliding = false
                    if displayedSong?.id == nil {
                        slider.value = 0.0
                        return
                    }
                case .moved:
                // handle drag moved
                    let songDuration = Float((nowPlayingVC.currentTimeLabel.text?.convertToTimeInterval())! + (nowPlayingVC.timeLeftLabel.text?.convertToTimeInterval())!)
                    let selectedTime = (songDuration * slider.value).rounded(.toNearestOrAwayFromZero)
                    let timeLeft = (songDuration * (1 - slider.value)).rounded(.toNearestOrAwayFromZero)
                    nowPlayingVC.currentTimeLabel.text = TimeInterval(exactly: selectedTime)?.stringFromTimeInterval()
                    nowPlayingVC.timeLeftLabel.text = TimeInterval(exactly: timeLeft)?.stringFromTimeInterval()
                break
                default:
                    break
            }
        }
    }
}

// MARK: - Delegate Extensions
extension TabBarViewController: UIViewControllerTransitioningDelegate {
    internal func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
// MARK: - Custom Delegate Extensions
extension TabBarViewController: YYTAudioPlayerDelegate, QueueManagerDelegate {
    internal func audioPlayerPeriodicUpdate(currentTime: Float, duration: Float) {
        if !isProgressBarSliding {
            if duration == 0 {
                miniPlayerView.progressBar.value = 0.0
                nowPlayingVC.progressBar.value = 0.0
                nowPlayingVC.currentTimeLabel.text = "00:00"
                nowPlayingVC.timeLeftLabel.text = TimeInterval(exactly: duration)?.stringFromTimeInterval()

                return
            }
            miniPlayerView.progressBar.value = currentTime/duration
            nowPlayingVC.progressBar.value = currentTime/duration
            nowPlayingVC.currentTimeLabel.text = TimeInterval(exactly: currentTime)?.stringFromTimeInterval()
            nowPlayingVC.timeLeftLabel.text = TimeInterval(exactly: duration-currentTime)?.stringFromTimeInterval()
        }
    }
    internal func updateDisplayedSong() {
        if QueueManager.shared.nowPlaying != nil {
            QueueManager.shared.unsuspend()
            displayedSong = QueueManager.shared.nowPlaying
            if miniPlayerView.isHidden == true {
                miniPlayerView.isHidden = false
                UIView.animate(withDuration: 0.5) {
                    self.view.bringSubviewToFront(self.tabBar)
                    let miniPlayerHeight = CGFloat(60)
                    self.miniPlayerView.frame = CGRect(
                        x: 0,
                        y: self.tabBar.top - miniPlayerHeight,
                        width: self.view.width,
                        height: miniPlayerHeight
                    )
                }
            }
            let songID = displayedSong!.id
            miniPlayerView.songID = songID
            let title = displayedSong!.title
            let artist = (displayedSong!.artists as NSArray? ?? NSArray())!.componentsJoined(by: ", ")
            miniPlayerView.titleLabel.text = title
            miniPlayerView.artistLabel.text = artist
            nowPlayingVC.songTitleLabel.text = title
            nowPlayingVC.artistLabel.text = artist
            
            let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(songID).jpg"))
            if let imgData = imageData {
                miniPlayerView.albumCover.image = (UIImage(data: imgData) ?? UIImage()).cropToSquare(sideLength: Double(miniPlayerView.height))
                nowPlayingVC.albumCoverImageView.image = (UIImage(data: imgData) ?? UIImage()).cropToSquare(sideLength: Double(miniPlayerView.height))

            } else {
                miniPlayerView.albumCover.image = UIImage(systemName: "questionmark")
                nowPlayingVC.albumCoverImageView.image = UIImage(systemName: "questionmark")
            }
        } else {
            QueueManager.shared.suspend()
            displayedSong = nil
            if miniPlayerView.isHidden == false {
                miniPlayerView.isHidden = true
                self.miniPlayerView.frame = CGRect(
                    x: 0,
                    y: self.tabBar.top,
                    width: self.view.width,
                    height: 0
                )
            }
        }
        
        miniPlayerView.progressBar.value = 0.0
        nowPlayingVC.progressBar.value = 0.0
        nowPlayingVC.timeLeftLabel.text = displayedSong?.duration ?? "0:00"
        queueVC.tableView.reloadData()
    }
    internal func audioPlayerPlayingStatusChanged(isPlaying: Bool) {
        changePlayPauseIcon(isPlaying: isPlaying)
    }
    internal func refreshQueueVC() {
        queueVC.tableView.reloadData()
    }
}
