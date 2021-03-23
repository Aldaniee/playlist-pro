//
//  TabBarViewController.swift
//  playlist-pro
//
//  Created by Aidan Lee on 2/16/21.
//

import UIKit

class TabBarViewController: UITabBarController, YYTAudioPlayerDelegate, QueueManagerDelegate {
    
    
    let tabBarBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .blackGray
        return view
    }()
    
    var miniPlayerView = MiniPlayerView(frame: .zero)
    var nowPlayingVC = NowPlayingViewController()
    var queueVC = QueueViewController()
    var displayedSong: Song = [:]

    var isProgressBarSliding = false

    
    func showNowPlayingView() {
        print("Showing Now Playing View Controller")
        nowPlayingVC.modalPresentationStyle = .fullScreen
        nowPlayingVC.transitioningDelegate = self
        nowPlayingVC.modalPresentationStyle = .custom

        present(nowPlayingVC, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        QueueManager.shared.audioPlayer.delegate = self
        QueueManager.shared.delegate = self

        
        tabBar.isTranslucent = false
        tabBar.barTintColor = .blackGray
        tabBar.tintColor = .darkPink

        let playlist = HomeViewController()
        let search = SearchViewController()
        let library = LibraryViewController()
        
        playlist.title = "Home"
        search.title = "Search"
        library.title = "Library"
        
        playlist.navigationItem.largeTitleDisplayMode = .always
        search.navigationItem.largeTitleDisplayMode = .always
        library.navigationItem.largeTitleDisplayMode = .always

        let navPlaylist = UINavigationController(rootViewController: playlist)
        let navSearch = UINavigationController(rootViewController: search)
        let navLibrary = UINavigationController(rootViewController: library)
        
        navPlaylist.navigationBar.prefersLargeTitles = true
        navSearch.navigationBar.prefersLargeTitles = true
        navLibrary.navigationBar.prefersLargeTitles = true
        
        navPlaylist.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        navSearch.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        navLibrary.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "list.bullet"), tag: 1)
        
        setViewControllers([navPlaylist, navSearch, navLibrary], animated: false)
        view.addSubview(miniPlayerView)
        view.addSubview(tabBarBackground)
    }
    let miniPlayerHeight = CGFloat(60)
    override func viewDidLayoutSubviews() {
        updateDisplayedSong()
        updateRepeatButton()
        updateShuffleButton()
        miniPlayerView.frame = CGRect(
            x: 0,
            y: tabBar.top-miniPlayerHeight,
            width: view.width,
            height: miniPlayerHeight
        )
        tabBarBackground.frame = CGRect(
            x: 0, y: tabBar.bottom, width: view.width, height: tabBar.height
        )
        miniPlayerView.miniPlayerButton.addTarget(self, action: #selector(miniplayerButtonPressed), for: .touchUpInside)
        miniPlayerView.pausePlayButton.addTarget(self, action: #selector(pausePlayButtonAction), for: .touchUpInside)
        
        nowPlayingVC.closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        nowPlayingVC.progressBar.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        nowPlayingVC.nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        nowPlayingVC.pausePlayButton.addTarget(self, action: #selector(pausePlayButtonAction), for: .touchUpInside)
        nowPlayingVC.previousButton.addTarget(self, action: #selector(previousButtonAction), for: .touchUpInside)
        nowPlayingVC.shuffleButton.addTarget(self, action: #selector(shuffleButtonAction), for: .touchUpInside)
        nowPlayingVC.repeatButton.addTarget(self, action: #selector(repeatButtonAction), for: .touchUpInside)
        nowPlayingVC.queueButton.addTarget(self, action: #selector(queueButtonAction), for: .touchUpInside)
        
        queueVC.nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        queueVC.pausePlayButton.addTarget(self, action: #selector(pausePlayButtonAction), for: .touchUpInside)
        queueVC.previousButton.addTarget(self, action: #selector(previousButtonAction), for: .touchUpInside)
        queueVC.shuffleButton.addTarget(self, action: #selector(shuffleButtonAction), for: .touchUpInside)
        queueVC.repeatButton.addTarget(self, action: #selector(repeatButtonAction), for: .touchUpInside)

    }

    @objc func miniplayerButtonPressed(sender: UIButton!) {
        print("MiniPlayerView tapped, showing NowPlayingViewController")
        showNowPlayingView()
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
    
    
    func audioPlayerPeriodicUpdate(currentTime: Float, duration: Float) {
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
    func audioPlayerPlayingStatusChanged(isPlaying: Bool) {
        changePlayPauseIcon(isPlaying: isPlaying)
    }
    func changePlayPauseIcon(isPlaying: Bool) {
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
    

    func updateDisplayedSong() {
        if QueueManager.shared.nowPlaying.isEmpty == false {
            QueueManager.shared.unsuspend()
            displayedSong = QueueManager.shared.nowPlaying
            miniPlayerView.isHidden = false
        } else {
            QueueManager.shared.suspend()
            displayedSong = Song()
            miniPlayerView.isHidden = true
        }

        let songID = displayedSong[SongValues.id] as? String ?? ""
        miniPlayerView.songID = songID
        let title = displayedSong[SongValues.title] as? String ?? ""
        let artist = (displayedSong[SongValues.artists] as? NSArray ?? NSArray())!.componentsJoined(by: ", ")
        miniPlayerView.titleLabel.text = title
        miniPlayerView.artistLabel.text = artist
        nowPlayingVC.songTitleLabel.text = title
        nowPlayingVC.artistLabel.text = artist
        
        let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(songID).jpg"))
        if let imgData = imageData {
            miniPlayerView.albumCover.image = (UIImage(data: imgData) ?? UIImage()).cropToSquare(size: Double(miniPlayerView.height))
            nowPlayingVC.albumCoverImageView.image = (UIImage(data: imgData) ?? UIImage()).cropToSquare(size: Double(miniPlayerView.height))

        } else {
            miniPlayerView.albumCover.image = UIImage(named: "placeholder")
            nowPlayingVC.albumCoverImageView.image = UIImage(named: "placeholder")

            
        }
        miniPlayerView.progressBar.value = 0.0
        nowPlayingVC.progressBar.value = 0.0
        nowPlayingVC.timeLeftLabel.text = displayedSong[SongValues.duration] as? String ?? "0:00"
        queueVC.tableView.reloadData()
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
        if displayedSong["id"] as! String == "" {
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
                    if displayedSong["id"] as! String == "" {
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
    
    func updateRepeatButton() {
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
    func updateShuffleButton() {
        if QueueManager.shared.shuffleStatus {
            nowPlayingVC.shuffleButton.tintColor = .darkPink
            queueVC.shuffleButton.tintColor = .darkPink
        }
        else {
            nowPlayingVC.shuffleButton.tintColor = .white
            queueVC.shuffleButton.tintColor = .white
        }
    }
    func refreshQueueVC() {
        queueVC.tableView.reloadData()
    }
    private func cropToBounds(image: UIImage, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage = UIImage(cgImage: cgimage)
        let contextSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth = CGFloat(height)
        var cgheight = CGFloat(height)

        posX = ((contextSize.width - contextSize.height) / 2)
        posY = 0
        cgwidth = contextSize.height
        cgheight = contextSize.height

        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        return UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
    }
}
extension TabBarViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
