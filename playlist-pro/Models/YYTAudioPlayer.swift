//
//  YYTAudioPlayer.swift
//  YouTag
//
//  Created by Youstanzr on 3/1/20.
//  Copyright © 2020 Youstanzr. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

protocol YYTAudioPlayerDelegate: class {
	func audioPlayerPeriodicUpdate(currentTime: Float, duration: Float)
	func audioPlayerPlayingStatusChanged(isPlaying: Bool)
}

class YYTAudioPlayer: NSObject, AVAudioPlayerDelegate {

	weak var delegate: YYTAudioPlayerDelegate?

	private(set) var audioPlayer: AVAudioPlayer!
	private var songsQueue: NSMutableArray!
	private(set) var songDict: Song!
	private var updater = CADisplayLink()
	private(set) var isSuspended: Bool = false
	var isSongRepeat: Bool = false
	
	override init() {
		super.init()
		setupInterreuptionsNotifications()
		setupRouteChangeNotifications()
	}
	
	@objc func updateDelegate() {
		delegate?.audioPlayerPeriodicUpdate(currentTime: Float(audioPlayer?.currentTime ?? 0) , duration: Float(audioPlayer?.duration ?? 0))
	}
	
	// MARK: Basics
	/*
	 * AVAudioPlayer: An audio player that provides playback of audio data from a file or memory.
	*/
	func setupPlayer(withQueue queue: NSMutableArray) -> Bool {
		songsQueue = queue
		return setupPlayer()
	}
	
	func setupPlayer() -> Bool {
		return setupPlayer(withSong: songsQueue.object(at: 0) as! Song)
	}
	
	func setupPlayer(withSong songDict: Song) -> Bool {
		self.songDict = songDict
        let songID = songDict[SongValues.id] as! String
        let songExt = songDict[SongValues.fileExtension] as? String ?? "m4a"  //support legacy code
		let url = LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(songID).\(songExt)")
		do {
			if audioPlayer != nil {
				updater.invalidate()
			}
			let oldPlaybackRate = getPlayerRate()
			audioPlayer = try AVAudioPlayer(contentsOf: url)
			audioPlayer.delegate = self
			audioPlayer.enableRate = true
			audioPlayer.prepareToPlay()
			setupNowPlaying()
			delegate?.audioPlayerPlayingStatusChanged(isPlaying: false)
			setPlayerRate(to: oldPlaybackRate)
			updater = CADisplayLink(target: self, selector: #selector(updateDelegate))
			return true
		} catch {
			print("Error: \(error.localizedDescription)")
			return false
		}
	}
	
	func setPlayerRate(to rate: Float) {
		audioPlayer.rate = rate
		updateNowPlaying(isPause: isPlaying())
	}

	func getPlayerRate() -> Float {
		return audioPlayer?.rate ?? 1.0
	}

	func setPlayerCurrentTime(withPercentage percenatge: Float) {
		if audioPlayer == nil {
			return
		}
		audioPlayer.currentTime = TimeInterval(percenatge * Float(audioPlayer.duration))
		updateNowPlaying(isPause: isPlaying())
	}
	
	func setSongRepeat(to status: Bool) {
		isSongRepeat = status
	}

	func suspend() {
		pause()
		isSuspended = true
	}

	func unsuspend() {
		isSuspended = false
	}

	func play() {
		if !isSuspended {
			audioPlayer.play()
			updateNowPlaying(isPause: false)
			delegate?.audioPlayerPlayingStatusChanged(isPlaying: true)
			updater = CADisplayLink(target: self, selector: #selector(updateDelegate))
			updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
		}
	}

	func pause() {
		if !isSuspended && isPlaying() {
			audioPlayer.pause()
			updateNowPlaying(isPause: true)
			delegate?.audioPlayerPlayingStatusChanged(isPlaying: false)
			updater.invalidate()
		}
	}

	func isPlaying() -> Bool {
		return audioPlayer?.isPlaying ?? false
	}
			

	func setupNowPlaying() {
		// Define Now Playing Info
		var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = songDict[SongValues.title] as? String

        let songID = songDict[SongValues.id] as? String ?? ""
		let imageData = try? Data(contentsOf: LocalFilesManager.getLocalFileURL(withNameAndExtension: "\(songID).jpg"))
		let image: UIImage
		if let imgData = imageData {
			image = UIImage(data: imgData)!
		} else {
            image = UIImage(systemName: "questionmark")!
		}
		
		nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
			return image
		}

		nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
		nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration
		nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer.rate
		
		// Set the metadata
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
	}

	func updateNowPlaying(isPause: Bool) {
		// Define Now Playing Info
		var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo!
		
		nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
		nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = !isPause ? audioPlayer.rate : 0.0
		
		// Set the metadata
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
	}
	
	// MARK: Handle Finish Playing
	
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		print("Audio player did finish playing: \(flag)")
		if (flag) {
            if (QueueManager.shared.repeatSelection == RepeatType.song) {
                QueueManager.shared.prevButtonAction()
			} else {
                QueueManager.shared.nextButtonAction()
			}
		}
	}
	
	// MARK: Handle Interruptions
	/*
	When you are playing in background mode, if a phone call come then the sound will be muted but when hang off the phone call then the sound should automatically continue playing.
	*/
	func setupInterreuptionsNotifications() {
		NotificationCenter.default.addObserver(self,
											   selector: #selector(handleInterruption),
											   name: AVAudioSession.interruptionNotification,
											   object: nil)
	}

	@objc func handleInterruption(notification: Notification) {
		guard let userInfo = notification.userInfo,
			let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
			let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
				return
		}
		if type == .began {
			print("Interruption began")
			// Interruption began, take appropriate actions
		}
		else if type == .ended {
			if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
				let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)

				if options.contains(.shouldResume) {
					// Interruption Ended - playback should resume
					print("Interruption Ended - playback should resume")
					play()
				} else {
					// Interruption Ended - playback should NOT resume
					print("Interruption Ended - playback should NOT resume")
					pause()
				}
			}
		}
	}
	
	// MARK: Handle Route Changes
	/*
	when you plug a headphone into the phone then the sound will emit on the headphone. But when you unplug the headphone then the sound automatically continue playing on built-in speaker. Maybe this is the behavior that you don’t expect. B/c when you plug the headphone into you want the sound is private to you, and when you unplug it you don’t want it emit out to other people. We will handle it by receiving events when the route change
	*/
	func setupRouteChangeNotifications() {
		NotificationCenter.default.addObserver(self,
											   selector: #selector(handleRouteChange),
											   name: AVAudioSession.routeChangeNotification,
											   object: nil)
	}
	
	@objc func handleRouteChange(notification: Notification) {
		print("handleRouteChange")
		guard let userInfo = notification.userInfo,
			let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
			let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
				return
		}

		switch reason {
			case .newDeviceAvailable:
				let session = AVAudioSession.sharedInstance()
				for output in session.currentRoute.outputs where
					(output.portType == AVAudioSession.Port.headphones || output.portType == AVAudioSession.Port.bluetoothA2DP) {
					print("headphones connected")
					DispatchQueue.main.sync {
						play()
					}
					break
				}
			case .oldDeviceUnavailable:
				if let previousRoute =
					userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
					for output in previousRoute.outputs where
						(output.portType == AVAudioSession.Port.headphones || output.portType == AVAudioSession.Port.bluetoothA2DP) {
						print("headphones disconnected")
						DispatchQueue.main.sync {
							pause()
						}
						break
					}
				}
			default: ()
		}
	}
	
}
