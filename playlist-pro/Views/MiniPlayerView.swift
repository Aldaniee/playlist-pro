//
//  NowPlayingView.swift
//  Playlist Pro
//
//
//  Tab bar playback controller view
//
import UIKit

protocol MiniPlayerViewDelegate: class {
	func showNowPlayingView()
    func updateNowPlayingView()
    func changePlayPauseIcon(isPlaying: Bool)
    func audioPlayerPeriodicUpdate(currentTime: Float, duration: Float)
}


class MiniPlayerView: UIView, QueueManagerDelegate {

	weak var delegate: MiniPlayerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        QueueManager.shared.delegate = self

        addBackgroundButton()
        addProgressBar()
        addThumbnailImage()
        addNextButton()
        addPlayPauseButtton()
        addPreviousButton()
        addTitleLabel()
        addArtistLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
	var songID = ""
    let backgroundButton: UIButton = {
        let btn = UIButton()
        return btn
    }()
    
	let thumbnailImageView: UIImageView = {
		let imgView = UIImageView()
		imgView.layer.masksToBounds = true
		return imgView
	}()
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.boldSystemFont(ofSize: 18)
        lbl.textAlignment = .left
        return lbl
    }()
    let artistLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = Constants.UI.darkGray
        lbl.font = UIFont.systemFont(ofSize: 18)
        lbl.textAlignment = .left
        return lbl
    }()
	let previousButton: UIButton = {
		let btn = UIButton()
		btn.setImage(UIImage(named: "previous"), for: UIControl.State.normal)
		return btn
	}()
	let pausePlayButton: UIButton = {
		let btn = UIButton()
		btn.setImage(UIImage(named: "play"), for: UIControl.State.normal)
		return btn
	}()
	let nextButton: UIButton = {
		let btn = UIButton()
		btn.setImage(UIImage(named: "next"), for: UIControl.State.normal)
		return btn
	}()
	let progressBar: UISlider = {
		let pBar = UISlider()
        pBar.tintColor = Constants.UI.darkPink
		return pBar
	}()
	var isProgressBarSliding = false

    private func addBackgroundButton() {
        backgroundButton.addTarget(self, action: #selector(backgroundButtonPressed), for: .touchUpInside)
        self.addSubview(backgroundButton)
        backgroundButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundButton.backgroundColor = .systemGray
        backgroundButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        backgroundButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        backgroundButton.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backgroundButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    private func addProgressBar() {
        progressBar.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        backgroundButton.addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.leadingAnchor.constraint(equalTo: backgroundButton.leadingAnchor, constant: 6.0).isActive = true
        progressBar.widthAnchor.constraint(equalTo: backgroundButton.widthAnchor, multiplier: 0.7, constant: -2.5).isActive = true
        progressBar.bottomAnchor.constraint(equalTo: backgroundButton.bottomAnchor).isActive = true
        progressBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
    }
    private func addThumbnailImage() {
        self.addSubview(thumbnailImageView)
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        thumbnailImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 3.5).isActive = true
        thumbnailImageView.bottomAnchor.constraint(equalTo: progressBar.topAnchor, constant: -2.5).isActive = true
        thumbnailImageView.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor).isActive = true
    }
    private func addNextButton() {
        nextButton.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        self.addSubview(nextButton)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.trailingAnchor.constraint(equalTo: backgroundButton.trailingAnchor, constant: -10).isActive = true
        nextButton.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor).isActive = true
        nextButton.heightAnchor.constraint(equalTo: thumbnailImageView.heightAnchor, multiplier: 0.3).isActive = true
        nextButton.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor, multiplier: 0.3).isActive = true
    }
    private func addPlayPauseButtton() {
        pausePlayButton.addTarget(self, action: #selector(pausePlayButtonAction), for: .touchUpInside)
        self.addSubview(pausePlayButton)
        pausePlayButton.translatesAutoresizingMaskIntoConstraints = false
        pausePlayButton.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -10).isActive = true
        pausePlayButton.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor).isActive = true
        pausePlayButton.heightAnchor.constraint(equalTo: thumbnailImageView.heightAnchor, multiplier: 0.5).isActive = true
        pausePlayButton.widthAnchor.constraint(equalTo: thumbnailImageView.heightAnchor, multiplier: 0.5).isActive = true

    }
    private func addPreviousButton() {
        previousButton.addTarget(self, action: #selector(previousButtonAction), for: .touchUpInside)
        self.addSubview(previousButton)
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        previousButton.trailingAnchor.constraint(equalTo: pausePlayButton.leadingAnchor, constant: -10).isActive = true
        previousButton.centerYAnchor.constraint(equalTo: pausePlayButton.centerYAnchor).isActive = true
        previousButton.heightAnchor.constraint(equalTo: nextButton.heightAnchor).isActive = true
        previousButton.widthAnchor.constraint(equalTo: nextButton.heightAnchor).isActive = true

    }
    private func addTitleLabel() {
        self.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: previousButton.leadingAnchor, constant: -10).isActive = true
        titleLabel.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor, constant: 5).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: thumbnailImageView.heightAnchor, multiplier: 0.5, constant: -5).isActive = true
    }
    private func addArtistLabel() {
        self.addSubview(artistLabel)
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        artistLabel.trailingAnchor.constraint(equalTo: pausePlayButton.leadingAnchor, constant: -5).isActive = true
        artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        artistLabel.heightAnchor.constraint(equalTo: titleLabel.heightAnchor).isActive = true
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
    
    @objc func backgroundButtonPressed(sender: UIButton!) {
        print("MiniPlayerView tapped, showing NowPlayingViewController")
        delegate?.showNowPlayingView()
    }
	
    @objc func nextButtonAction(sender: UIButton!) {
        print("Next Button tapped")
        QueueManager.shared.next()
   }
    
    @objc func previousButtonAction(sender: UIButton!) {
        print("Previous Button tapped")
        QueueManager.shared.prev()
    }
	
	@objc func playbackRateButtonAction(sender: UIButton!) {
		print("playback rate Button tapped")
		if songID == "" {
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

	@objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
		if let touchEvent = event.allTouches?.first {
			switch touchEvent.phase {
				case .began:
				// handle drag began
					isProgressBarSliding = true
				break
				case .ended:
				// handle drag ended
					isProgressBarSliding = false
					if songID == "" {
						slider.value = 0.0
						return
					}
                    QueueManager.shared.setPlayerCurrentTime(withPercentage: slider.value)
				case .moved:
				break
				default:
					break
			}
		}
	}
	
	func audioPlayerPeriodicUpdate(currentTime: Float, duration: Float) {
        delegate?.audioPlayerPeriodicUpdate(currentTime: currentTime, duration: duration)
		if !isProgressBarSliding {
			if duration == 0 {
				progressBar.value = 0.0
				return
			}
			self.progressBar.value = currentTime/duration
		}
	}
    func audioPlayerPlayingStatusChanged(isPlaying: Bool) {
        delegate?.changePlayPauseIcon(isPlaying: isPlaying)
        changePlayPauseIcon(isPlaying: isPlaying)
    }
	func changePlayPauseIcon(isPlaying: Bool) {
        delegate?.changePlayPauseIcon(isPlaying: isPlaying)
		if isPlaying {
			self.pausePlayButton.setImage(UIImage(named: "pause"), for: UIControl.State.normal)
		} else {
			self.pausePlayButton.setImage(UIImage(named: "play"), for: UIControl.State.normal)
		}
	}
    func updateDisplayedSong() {
        delegate?.updateNowPlayingView()
        let displayedSong: Dictionary<String, Any>
        if QueueManager.shared.queue.count > 0 {
            QueueManager.shared.unsuspend()
            displayedSong = QueueManager.shared.queue.object(at: 0) as! Dictionary<String, Any>
        } else {
            QueueManager.shared.suspend()
            displayedSong = Dictionary<String, Any>()
        }

        let songID = displayedSong["id"] as? String ?? ""
        self.songID = songID
        titleLabel.text = displayedSong["title"] as? String ?? ""
        artistLabel.text = ((displayedSong["artists"] as? NSArray ?? NSArray())!.componentsJoined(by: ", "))
        
        let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(songID).jpg"))
        if let imgData = imageData {
            thumbnailImageView.image = UIImage(data: imgData)
        } else {
            thumbnailImageView.image = UIImage(named: "placeholder")
        }
        progressBar.value = 0.0
    }
}
